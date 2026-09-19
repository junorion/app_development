/// 한 스플릿(기본 1km) 구간의 기록 (지침 5.5, 9.1 Split)
class Split {
  const Split({
    required this.index,
    required this.distanceM,
    required this.durationSec,
    required this.steps,
    required this.isPartial,
  });

  /// 0 부터
  final int index;
  final double distanceM;

  /// 일시정지를 뺀 이동 시간
  final double durationSec;

  /// 걸음 센서가 없으면 null
  final double? steps;

  /// 마지막 미완 구간
  final bool isPartial;

  double? get avgCadenceSpm =>
      steps == null || durationSec <= 0 ? null : steps! / (durationSec / 60.0);

  double get speedMps => durationSec <= 0 ? 0 : distanceM / durationSec;

  @override
  String toString() =>
      'Split(#$index ${distanceM.toStringAsFixed(1)}m ${durationSec.toStringAsFixed(1)}s'
      '${isPartial ? ' partial' : ''})';
}

/// 누적 진행값을 받아 스플릿 경계를 넘을 때마다 구간을 확정한다.
///
/// 시각은 벽시계가 아니라 **이동 시간**(일시정지 제외)을 받는다. 그래야 구간 중간에 쉬어도
/// 그 시간이 구간 기록에 들어가지 않는다. 경계를 넘는 두 점 사이는 선형 보간한다 — 샘플은
/// 1초·5m 간격이라 경계에서 최대 한 샘플만큼 어긋나는 것을 없앤다.
class SplitTracker {
  SplitTracker({this.splitM = 1000});

  /// 스플릿 거리. 마일 단위면 1609.344 (지침 5.5)
  final double splitM;

  final List<Split> splits = [];

  double _lastDist = 0;
  double _lastMovingSec = 0;
  double? _lastSteps;

  // 현재 진행 중인 구간의 시작점
  double _startMovingSec = 0;
  double? _startSteps;
  bool _started = false;

  /// 새 진행값. 이번 호출에서 확정된 스플릿들을 돌려준다 (한 번에 둘 이상 넘을 수도 있다).
  List<Split> update(
      {required double distanceM, required double movingSec, double? steps}) {
    if (!_started) {
      _started = true;
      _startSteps = steps;
      _lastSteps = steps;
    }
    final done = <Split>[];
    if (distanceM > _lastDist) {
      var boundary = (splits.length + 1) * splitM;
      while (distanceM >= boundary) {
        final f = (boundary - _lastDist) / (distanceM - _lastDist);
        final tAt = _lastMovingSec + (movingSec - _lastMovingSec) * f;
        final stepsAt = (steps == null || _lastSteps == null)
            ? null
            : _lastSteps! + (steps - _lastSteps!) * f;
        final s = Split(
          index: splits.length,
          distanceM: splitM,
          durationSec: tAt - _startMovingSec,
          steps: (stepsAt == null || _startSteps == null) ? null : stepsAt - _startSteps!,
          isPartial: false,
        );
        splits.add(s);
        done.add(s);
        _startMovingSec = tAt;
        _startSteps = stepsAt;
        boundary += splitM;
      }
    }
    _lastDist = distanceM;
    _lastMovingSec = movingSec;
    _lastSteps = steps;
    // 걸음 센서가 중간에 살아나면 그 시점부터 센다
    _startSteps ??= steps;
    return done;
  }

  /// 종료 시 마지막 미완 구간. 1m 도 안 되면 없음.
  Split? partial() {
    final d = _lastDist - splits.length * splitM;
    if (d < 1) return null;
    return Split(
      index: splits.length,
      distanceM: d,
      durationSec: _lastMovingSec - _startMovingSec,
      steps: (_lastSteps == null || _startSteps == null) ? null : _lastSteps! - _startSteps!,
      isPartial: true,
    );
  }
}
