import 'auto_pause.dart';
import 'geo.dart';
import 'kalman_smoother.dart';
import 'location_sample.dart';
import 'noise_filter.dart';
import 'split_tracker.dart';
import 'windowed_rate.dart';

/// 지침 5.1 의 상태
enum RunState { idle, countdown, running, paused, autoPaused, finished }

/// 받아들인 위치 한 점과 그 점이 속한 구간(일시정지마다 오른다, 지침 9.1)
class TrackPoint {
  const TrackPoint(this.sample, this.segmentIndex);
  final LocationSample sample;
  final int segmentIndex;
}

/// 러닝 한 번의 측정 상태. 플러그인·시계·UI 에 의존하지 않는 순수 로직이다.
///
/// 시각은 모두 호출하는 쪽이 넘긴다(epoch ms). 그래서 GPX 재생이나 가짜 시계로 그대로
/// 돌려 볼 수 있다. 실제 서비스는 위치가 오면 [onLocation], 걸음이 오면 [onSteps],
/// 1초마다 [tick] 을 부른다.
class RunSession {
  RunSession({
    FilterConfig filter = const FilterConfig(),
    double splitM = 1000,
    this.autoPauseEnabled = true,
    this.onSplit,
    this.onState,
  })  : _filter = NoiseFilter(filter),
        splits = SplitTracker(splitM: splitM);

  final bool autoPauseEnabled;
  final void Function(Split split)? onSplit;
  final void Function(RunState from, RunState to)? onState;

  final NoiseFilter _filter;
  final SplitTracker splits;
  final _speed = WindowedRate(8000); // 현재 속도: 최근 8초 (지침 5.3 의 5~10초)
  final _cadence = WindowedRate(12000); // 현재 케이던스: 최근 12초 (지침 5.4 의 10~15초)
  final _autoPause = AutoPauseDetector();
  final _smoother = KalmanSmoother();
  (double, double)? _lastSmoothed;

  RunState _state = RunState.idle;
  RunState get state => _state;

  final List<TrackPoint> track = [];
  int _segment = 0;

  int? startedAtMs;
  int? endedAtMs;
  double distanceM = 0;

  int _movingMs = 0;
  double _pendingM = 0; // 자동 일시정지 중 받아들인 마지막 점의 거리 (재개되면 넣는다)
  int? _runningSinceMs;

  double? _stepsBase; // 직전에 받은 누적 걸음 (센서 누적값)
  double? steps; // 이동 중에 센 걸음. 센서가 없으면 null.

  NoiseFilter get filter => _filter;

  // ── 상태 전이 ────────────────────────────────────────────

  void startCountdown() {
    _expect({RunState.idle});
    _go(RunState.countdown);
  }

  void cancelCountdown() {
    _expect({RunState.countdown});
    _go(RunState.idle);
  }

  /// 카운트다운이 끝나 기록을 시작한다
  void begin(int tMs) {
    _expect({RunState.countdown, RunState.idle});
    startedAtMs = tMs;
    _runningSinceMs = tMs;
    splits.update(distanceM: 0, movingSec: 0, steps: steps);
    _go(RunState.running);
  }

  void pause(int tMs) {
    _expect({RunState.running, RunState.autoPaused});
    _stopClock(tMs);
    _go(RunState.paused);
  }

  void resume(int tMs) {
    _expect({RunState.paused});
    // 멈춘 사이에 옮긴 거리는 넣지 않는다 — 새 구간으로 끊는다
    _filter.reset();
    _smoother.reset();
    _lastSmoothed = null;
    _speed.clear();
    _cadence.clear();
    _autoPause.reset();
    _segment++;
    _runningSinceMs = tMs;
    _go(RunState.running);
  }

  void finish(int tMs) {
    _expect({RunState.running, RunState.paused, RunState.autoPaused});
    _stopClock(tMs);
    endedAtMs = tMs;
    _go(RunState.finished);
  }

  // ── 입력 ────────────────────────────────────────────────

  void onLocation(LocationSample s) {
    if (_state != RunState.running && _state != RunState.autoPaused) return;
    final r = _filter.add(s);
    if (!r.isAccepted) return;
    // 거리는 평활화한 좌표 사이에서 잰다. 버릴지는 원본 좌표로 판정한다(위에서 끝났다).
    final sm = _smoother.add(s);
    final prev = _lastSmoothed;
    _lastSmoothed = sm;
    final d = prev == null ? 0.0 : haversineM(prev.$1, prev.$2, sm.$1, sm.$2);

    if (_state == RunState.autoPaused) {
      final v = r.dtMs > 0 ? r.distanceM / (r.dtMs / 1000.0) : 0.0;
      if (!_autoPause.update(s.tMs, v)) {
        // 드리프트가 최소 이동을 넘었거나, 다시 뛰기 시작한 첫 점이다. 멈춘 동안 흐른 시간으로
        // 나누면 둘을 가를 수 없으므로 거리를 잡아 두고, 다음 점에서 재개되면 그때 넣는다.
        _pendingM = d;
        track.add(TrackPoint(s, _segment));
        return;
      }
      _runningSinceMs = s.tMs;
      _go(RunState.running);
    }

    distanceM += d + _pendingM;
    _pendingM = 0;
    track.add(TrackPoint(s, _segment));
    _speed.add(s.tMs, distanceM);
    _updateSplits(s.tMs);
  }

  /// [cumulative] 는 센서가 주는 누적 걸음 수 그대로 (Android 는 부팅 후 누적). 차이만 쓴다.
  void onSteps(int tMs, double cumulative) {
    final base = _stepsBase;
    _stepsBase = cumulative;
    if (base == null || cumulative < base) {
      // 첫 값이거나 센서가 리셋됨(재부팅) — 기준만 잡는다
      steps ??= 0;
      return;
    }
    if (_state == RunState.running) {
      steps = (steps ?? 0) + (cumulative - base);
      _cadence.add(tMs, steps!);
    }
  }

  /// 1초마다. 정지 중에는 점이 오지 않으므로 이것이 현재 속도를 0 으로 내리고 자동 일시정지를 건다.
  void tick(int tMs) {
    if (_state != RunState.running) return;
    _speed.add(tMs, distanceM);
    if (steps != null) _cadence.add(tMs, steps!);
    if (autoPauseEnabled && _autoPause.update(tMs, _speed.rate) && _autoPause.isPaused) {
      _stopClock(tMs);
      _pendingM = 0;
      _go(RunState.autoPaused);
    }
  }

  // ── 측정값 ──────────────────────────────────────────────

  double movingSecAt(int tMs) {
    final since = _runningSinceMs;
    return (_movingMs + (since == null ? 0 : tMs - since)) / 1000.0;
  }

  /// m/s. 아직 모르면 null
  double? get currentSpeedMps => _state == RunState.running ? _speed.rate : null;

  /// spm. 센서가 없거나 아직 모르면 null
  double? get currentCadenceSpm {
    final r = _cadence.rate;
    return _state == RunState.running && r != null ? r * 60 : null;
  }

  double avgSpeedMpsAt(int tMs) {
    final sec = movingSecAt(tMs);
    return sec > 0 ? distanceM / sec : 0;
  }

  double? avgCadenceSpmAt(int tMs) {
    final sec = movingSecAt(tMs);
    return steps == null || sec <= 0 ? null : steps! / (sec / 60);
  }

  /// 완료된 스플릿 + (끝났다면) 마지막 부분 스플릿
  List<Split> get allSplits {
    final p = _state == RunState.finished ? splits.partial() : null;
    return [...splits.splits, ?p];
  }

  // ── 내부 ────────────────────────────────────────────────

  void _updateSplits(int tMs) {
    for (final s in splits.update(
        distanceM: distanceM, movingSec: movingSecAt(tMs), steps: steps)) {
      onSplit?.call(s);
    }
  }

  void _stopClock(int tMs) {
    final since = _runningSinceMs;
    if (since != null) _movingMs += tMs - since;
    _runningSinceMs = null;
    _updateSplits(tMs);
  }

  void _expect(Set<RunState> allowed) {
    if (!allowed.contains(_state)) {
      throw StateError('$_state 에서는 할 수 없는 동작');
    }
  }

  void _go(RunState to) {
    final from = _state;
    _state = to;
    onState?.call(from, to);
  }
}
