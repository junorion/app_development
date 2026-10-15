import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/run_repository.dart';
import '../data/location_source.dart';
import '../data/run_recorder.dart';
import '../data/step_source.dart';
import '../domain/run_session.dart';
import '../domain/split_tracker.dart';

/// 러닝 한 번을 소유한다 (지침 5장). 화면은 이것을 구독만 하고 측정값을 계산하지 않는다.
///
/// 위치·걸음 소스는 바꿔 끼울 수 있다 — 실제 GPS 대신 GPX 재생, 테스트에서는 가짜 소스.
class RunService extends ChangeNotifier {
  RunService({
    required this.repo,
    required this.locationSource,
    this.stepSource,
    int Function()? now,
    this.splitM = 1000,
    this.autoPause = true,
    Timer Function(Duration, void Function(Timer))? periodic,
  })  : now = now ?? (() => DateTime.now().millisecondsSinceEpoch),
        _periodic = periodic ?? Timer.periodic;

  /// 1초 tick 을 만드는 함수. 테스트는 가짜를 넣어 tick 을 손으로 넘긴다.
  final Timer Function(Duration, void Function(Timer)) _periodic;

  final RunRepository repo;
  final LocationSource Function() locationSource;
  final StepSource Function()? stepSource;
  final int Function() now;
  final double splitM;
  final bool autoPause;

  RunSession? _session;
  RunRecorder? _recorder;
  String? _runId;
  LocationSource? _loc;
  StepSource? _steps;
  StreamSubscription? _locSub, _stepSub;
  Timer? _ticker;

  /// 가장 최근 위치의 정확도 — GPS 약함 안내에 쓴다
  double? lastAccuracyM;

  final _splitEvents = StreamController<Split>.broadcast();

  /// 스플릿 확정 — 음성 안내·햅틱 (지침 5.5)
  Stream<Split> get splitEvents => _splitEvents.stream;

  RunSession? get session => _session;
  String? get runId => _runId;
  RunState get state => _session?.state ?? RunState.idle;

  /// 기록이 진행 중(일시정지 포함)인가
  bool get isActive =>
      state == RunState.running || state == RunState.paused || state == RunState.autoPaused;

  /// 카운트다운이 끝나면 부른다. 포그라운드 서비스가 여기서 시작된다 — 앱이 화면에 보일 때
  /// 시작해야 백그라운드에서도 위치가 계속 온다 (지침 8.1).
  Future<void> start({String? timerPresetId}) async {
    if (isActive) return;
    final t0 = now();
    final s = _session = RunSession(
      splitM: splitM,
      autoPauseEnabled: autoPause,
      onSplit: _splitEvents.add,
      onState: (_, _) {
        _recorder?.save(now());
        notifyListeners();
      },
    );
    final id = _runId = const Uuid().v4();
    await repo.createRun(
      id: id,
      startedAtMs: t0,
      tzOffsetMin: DateTime.now().timeZoneOffset.inMinutes,
      timerPresetId: timerPresetId,
    );
    _recorder = RunRecorder(repo, s, id);
    s.begin(t0);

    _loc = locationSource();
    _locSub = _loc!.start().listen((p) {
      lastAccuracyM = p.accuracyM;
      s.onLocation(p);
    });
    final stepFactory = stepSource;
    if (stepFactory != null) {
      _steps = stepFactory();
      _stepSub = _steps!.start().listen(
            (e) => s.onSteps(e.$1, e.$2),
            // 센서가 없거나 권한이 없으면 케이던스만 -- 로 두고 나머지는 계속한다 (지침 5.4)
            onError: (_) {},
          );
    }
    _ticker = _periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void _tick() {
    final s = _session;
    if (s == null) return;
    final t = now();
    s.tick(t);
    _recorder?.onTick(t);
    notifyListeners();
  }

  void pause() {
    final s = _session;
    if (s == null || !(s.state == RunState.running || s.state == RunState.autoPaused)) return;
    s.pause(now());
  }

  void resume() {
    final s = _session;
    if (s == null || s.state != RunState.paused) return;
    s.resume(now());
  }

  /// 종료하고 저장까지 마친 뒤 러닝 id 를 돌려준다. Summary 에 들어가는 시점에는 이미 저장돼
  /// 있어야 한다 (지침 4.5).
  Future<String?> finish() async {
    final s = _session;
    if (s == null || !isActive) return null;
    _ticker?.cancel();
    await _locSub?.cancel();
    await _loc?.stop();
    await _stepSub?.cancel();
    await _steps?.stop();
    final t = now();
    s.finish(t);
    await _recorder?.finish(t);
    final id = _runId;
    notifyListeners();
    return id;
  }

  /// Summary 를 보고 나면 다음 러닝을 위해 비운다
  void reset() {
    if (isActive) return;
    _session = null;
    _recorder = null;
    _runId = null;
    lastAccuracyM = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _locSub?.cancel();
    _stepSub?.cancel();
    _splitEvents.close();
    super.dispose();
  }
}
