/// 자동 일시정지 판정 (지침 5.3). 속도가 [stopSpeedMps] 미만으로 [stopHoldMs] 이상 이어지면
/// 멈춘 것으로, [resumeSpeedMps] 이상이 되면 다시 움직이는 것으로 본다.
///
/// 멈춤과 재개의 기준을 다르게 둔다(히스테리시스). 같으면 신호등 앞에서 천천히 걷는 동안
/// 멈춤과 재개가 초 단위로 번갈아 난다.
class AutoPauseDetector {
  AutoPauseDetector({
    this.stopSpeedMps = 0.5,
    this.resumeSpeedMps = 1.0,
    this.stopHoldMs = 4000,
  });

  final double stopSpeedMps;
  final double resumeSpeedMps;
  final int stopHoldMs;

  bool _paused = false;
  int? _slowSinceMs;

  bool get isPaused => _paused;

  void reset() {
    _paused = false;
    _slowSinceMs = null;
  }

  /// 현재 속도를 넣고, 상태가 바뀌었으면 true. 속도를 모르면(null) 판정을 미룬다.
  bool update(int tMs, double? speedMps) {
    if (speedMps == null) return false;
    if (_paused) {
      if (speedMps >= resumeSpeedMps) {
        _paused = false;
        _slowSinceMs = null;
        return true;
      }
      return false;
    }
    if (speedMps < stopSpeedMps) {
      _slowSinceMs ??= tMs;
      if (tMs - _slowSinceMs! >= stopHoldMs) {
        _paused = true;
        return true;
      }
    } else {
      _slowSinceMs = null;
    }
    return false;
  }
}
