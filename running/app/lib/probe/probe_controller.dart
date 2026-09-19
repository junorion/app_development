import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../core/format.dart';
import '../data/db.dart';
import '../data/gpx.dart';
import '../data/run_repository.dart';
import '../features/run/data/geolocator_source.dart';
import '../features/run/data/run_recorder.dart';
import '../features/run/data/step_source.dart';
import '../features/run/domain/noise_filter.dart';
import '../features/run/domain/run_session.dart';
import '../platform/platform_channel.dart';
import 'gap_stats.dart';

/// M0 리스크 검증용 컨트롤러 (지침 12.1). 실제 러닝과 같은 경로(포그라운드 서비스 → RunSession
/// → 5초 저장)로 기록하면서, 화면이 꺼진 동안 무엇이 끊기는지 숫자로 남긴다.
class ProbeController extends ChangeNotifier {
  ProbeController(this.repo);

  final RunRepository repo;

  // ── 기기 ──
  Map<String, Object?> device = {};
  Map<String, Object?> power = {};
  final Map<String, PermissionStatus> perms = {};

  // ── 기록 ──
  RunSession? session;
  RunRecorder? _recorder;
  String? runId;
  GeolocatorSource? _loc;
  StepSource? _steps;
  StreamSubscription? _locSub, _stepSub;
  Timer? _ticker;
  String? locError, stepError;

  GapStats locGaps = GapStats();
  GapStats stepGaps = GapStats(longGapMs: 15000);
  double _accSum = 0;
  int _accN = 0;
  double get avgAccuracy => _accN == 0 ? 0 : _accSum / _accN;

  // ── 백그라운드 ──
  late final AppLifecycleListener _life;
  bool inBackground = false;
  int? _bgSinceMs;
  int bgTotalMs = 0;
  int bgLocations = 0;
  int bgSteps = 0;
  int bgEntries = 0;

  // ── 메트로놈 ──
  bool metronomeOn = false;
  double spm = 170;
  Map<String, Object?> metroStats = {};
  Timer? _dartBeat;
  final _beatClock = Stopwatch();
  int _beatN = 0;
  JitterStats dartJitterFg = JitterStats();
  JitterStats dartJitterBg = JitterStats();

  List<RunRow> unfinished = [];

  int get now => DateTime.now().millisecondsSinceEpoch;
  bool get recording =>
      session != null && session!.state != RunState.finished && session!.state != RunState.idle;

  Future<void> init() async {
    _life = AppLifecycleListener(onStateChange: _onLifecycle);
    try {
      device = await PlatformChannel.deviceInfo();
      power = await PlatformChannel.powerState();
    } catch (e) {
      device = {'error': '$e'};
    }
    await refreshPermissions();
    unfinished = await repo.unfinishedRuns();
    notifyListeners();
  }

  Future<void> refreshPermissions() async {
    perms['위치'] = await Permission.locationWhenInUse.status;
    perms['알림'] = await Permission.notification.status;
    perms['신체 활동'] = await Permission.activityRecognition.status;
    try {
      power = await PlatformChannel.powerState();
    } catch (_) {}
    notifyListeners();
  }

  void _onLifecycle(AppLifecycleState s) {
    final bg = s != AppLifecycleState.resumed;
    if (bg == inBackground) return;
    inBackground = bg;
    if (bg) {
      _bgSinceMs = now;
      bgEntries++;
    } else if (_bgSinceMs != null) {
      bgTotalMs += now - _bgSinceMs!;
      _bgSinceMs = null;
      refreshPermissions();
    }
    notifyListeners();
  }

  int get bgMsNow => bgTotalMs + (_bgSinceMs == null ? 0 : now - _bgSinceMs!);

  /// 필요한 순간에 하나씩 요청한다 (지침 8.3). 위치가 없으면 시작하지 않는다.
  Future<String?> _ensurePermissions() async {
    final loc = await Permission.locationWhenInUse.request();
    if (!loc.isGranted) {
      await refreshPermissions();
      return loc.isPermanentlyDenied
          ? '위치 권한이 꺼져 있어요. 설정에서 켜 주세요.'
          : '기록을 위해 위치 권한이 필요해요.';
    }
    await Permission.notification.request(); // 거부해도 기록은 된다
    await Permission.activityRecognition.request(); // 거부하면 케이던스만 --
    await refreshPermissions();
    return null;
  }

  Future<String?> start() async {
    if (recording) return null;
    final err = await _ensurePermissions();
    if (err != null) return err;

    locGaps = GapStats();
    stepGaps = GapStats(longGapMs: 15000);
    _accSum = 0;
    _accN = 0;
    bgTotalMs = bgLocations = bgSteps = bgEntries = 0;
    locError = stepError = null;

    final t0 = now;
    final s = session = RunSession(onState: (_, _) => _recorder?.save(now));
    final id = runId = const Uuid().v4();
    await repo.createRun(
        id: id, startedAtMs: t0, tzOffsetMin: DateTime.now().timeZoneOffset.inMinutes);
    _recorder = RunRecorder(repo, s, id);
    s
      ..startCountdown()
      ..begin(t0);

    _loc = GeolocatorSource(notificationTitle: '러닝 기록 중', notificationText: '진단 기록을 하고 있어요');
    _locSub = _loc!.start().listen((p) {
      locGaps.add(p.tMs);
      _accSum += p.accuracyM;
      _accN++;
      if (inBackground) bgLocations++;
      s.onLocation(p);
    }, onError: (e) {
      locError = '$e';
      notifyListeners();
    });

    if (perms['신체 활동']?.isGranted ?? false) {
      _steps = StepSource();
      _stepSub = _steps!.start().listen((e) {
        stepGaps.add(e.$1);
        if (inBackground) bgSteps++;
        s.onSteps(e.$1, e.$2);
      }, onError: (e) {
        stepError = '$e';
        notifyListeners();
      });
    }

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      final t = now;
      s.tick(t);
      await _recorder?.onTick(t);
      await _pollMetronome();
      notifyListeners();
    });
    notifyListeners();
    return null;
  }

  void togglePause() {
    final s = session;
    if (s == null) return;
    if (s.state == RunState.paused) {
      s.resume(now);
    } else if (s.state == RunState.running || s.state == RunState.autoPaused) {
      s.pause(now);
    }
    notifyListeners();
  }

  Future<void> stop() async {
    final s = session;
    if (s == null || !recording) return;
    _ticker?.cancel();
    await _locSub?.cancel();
    await _loc?.stop();
    await _stepSub?.cancel();
    await _steps?.stop();
    final t = now;
    s.finish(t);
    await _recorder?.finish(t);
    notifyListeners();
  }

  Future<void> recoverAll({required bool keep}) async {
    for (final r in unfinished) {
      keep ? await repo.recover(r.id) : await repo.deleteRun(r.id);
    }
    unfinished = [];
    notifyListeners();
  }

  // ── 메트로놈 ──

  Future<void> toggleMetronome() async {
    if (metronomeOn) {
      await PlatformChannel.metronomeStop();
      _dartBeat?.cancel();
      metronomeOn = false;
    } else {
      await PlatformChannel.metronomeStart(spm: spm);
      metronomeOn = true;
      _startDartBeat();
    }
    await _pollMetronome();
    notifyListeners();
  }

  Future<void> setSpm(double v) async {
    spm = v.clamp(100, 220).roundToDouble();
    if (metronomeOn) {
      await PlatformChannel.metronomeSetSpm(spm);
      _startDartBeat();
    }
    notifyListeners();
  }

  /// 비교용: 지침 6.1 이 금지한 Dart Timer 방식이 얼마나 흔들리는지 잰다 (소리는 내지 않는다)
  void _startDartBeat() {
    _dartBeat?.cancel();
    final intervalUs = (60e6 / spm).round();
    _beatClock
      ..reset()
      ..start();
    _beatN = 0;
    _dartBeat = Timer.periodic(Duration(microseconds: intervalUs), (_) {
      _beatN++;
      final errMs = (_beatClock.elapsedMicroseconds - _beatN * intervalUs) / 1000.0;
      // 누적 오차가 아니라 박자마다의 오차를 보려고 기준을 매번 다시 잡는다
      _beatClock
        ..reset()
        ..start();
      _beatN = 0;
      (inBackground ? dartJitterBg : dartJitterFg).add(errMs);
    });
  }

  Future<void> _pollMetronome() async {
    if (!metronomeOn && metroStats.isEmpty) return;
    try {
      metroStats = await PlatformChannel.metronomeStats();
    } catch (_) {}
  }

  Future<void> pollIdle() async {
    if (recording) return;
    await _pollMetronome();
    notifyListeners();
  }

  // ── 보내기 ──

  String report() {
    final s = session;
    final b = StringBuffer()
      ..writeln('[러닝 진단 결과] ${DateTime.now().toString().substring(0, 16)}')
      ..writeln('기기: ${device['manufacturer']} ${device['model']} · Android ${device['release']} (API ${device['sdk']})')
      ..writeln('센서: GPS ${_yn(device['hasGps'])} · 걸음 수 ${_yn(device['hasStepCounter'])} · 걸음 감지 ${_yn(device['hasStepDetector'])}')
      ..writeln('권한: ${perms.entries.map((e) => '${e.key} ${_perm(e.value)}').join(' · ')}')
      ..writeln('배터리 최적화 제외: ${_yes(power['ignoringBatteryOptimizations'])} · 절전 모드: ${_yes(power['powerSave'])}');
    if (s != null && s.startedAtMs != null) {
      final end = s.endedAtMs ?? now;
      b
        ..writeln('')
        ..writeln('기록: ${s.state.name} · 경과 ${formatDuration((end - s.startedAtMs!) / 1000)} · 이동 ${formatDuration(s.movingSecAt(end))}')
        ..writeln('거리 ${formatKm(s.distanceM)}km · 평균 페이스 ${formatPace(s.avgSpeedMpsAt(end))}/km · 걸음 ${s.steps?.round() ?? '--'} · 평균 케이던스 ${s.avgCadenceSpmAt(end)?.round() ?? '--'}')
        ..writeln('위치: ${locGaps.describe()} · 평균 정확도 ${avgAccuracy.toStringAsFixed(1)}m')
        ..writeln('버린 위치: ${RejectReason.values.map((r) => '${_reason(r)} ${s.filter.rejected[r]}').join(' · ')}')
        ..writeln('걸음 이벤트: ${stepGaps.describe()}')
        ..writeln('백그라운드: $bgEntries번 · 총 ${formatDuration(bgMsNow / 1000)} · 그동안 위치 $bgLocations건 · 걸음 이벤트 $bgSteps건')
        ..writeln('스플릿: ${s.allSplits.map((e) => '${e.isPartial ? '(부분)' : ''}${formatDuration(e.durationSec)}').join(' / ')}');
      if (locError != null) b.writeln('위치 오류: $locError');
      if (stepError != null) b.writeln('걸음 오류: $stepError');
    }
    if (metroStats.isNotEmpty) {
      b
        ..writeln('')
        ..writeln('메트로놈(네이티브): ${metroStats['spm']}spm · ${metroStats['ticks']}박 · ${(metroStats['seconds'] as num? ?? 0).toStringAsFixed(0)}초 · 끊김(underrun) ${metroStats['underruns']}번 · 출력 시계 어긋남 최대 ${(metroStats['maxClockDevMs'] as num? ?? 0).toStringAsFixed(1)}ms')
        ..writeln('Dart Timer 비교(화면 켜짐): ${dartJitterFg.describe()}')
        ..writeln('Dart Timer 비교(백그라운드): ${dartJitterBg.describe()}');
    }
    return b.toString();
  }

  Future<void> shareReport() => SharePlus.instance.share(ShareParams(text: report()));

  Future<void> shareGpx() async {
    final s = session;
    if (s == null || s.track.isEmpty) return;
    final name = 'run-${DateTime.now().toIso8601String().substring(0, 16).replaceAll(':', '')}';
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/$name.gpx');
    await f.writeAsString(toGpx(s.track, name: name));
    await SharePlus.instance.share(ShareParams(files: [XFile(f.path)], text: report()));
  }

  static String _yn(Object? v) => v == true ? '있음' : (v == false ? '없음' : '?');
  static String _yes(Object? v) => v == true ? '예' : (v == false ? '아니오' : '?');
  static String _perm(PermissionStatus s) => switch (s) {
        PermissionStatus.granted => '허용',
        PermissionStatus.limited => '제한',
        PermissionStatus.permanentlyDenied => '영구 거부',
        PermissionStatus.denied => '거부',
        _ => s.name,
      };
  static String _reason(RejectReason r) => switch (r) {
        RejectReason.inaccurate => '정확도',
        RejectReason.nonMonotonic => '시각',
        RejectReason.tooClose => '정지',
        RejectReason.tooFast => '튐',
      };

  @override
  void dispose() {
    _ticker?.cancel();
    _dartBeat?.cancel();
    _life.dispose();
    super.dispose();
  }
}
