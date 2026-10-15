import 'dart:async';

/// 손으로 넘기는 주기 타이머. `RunService(periodic: ticker.create)` 로 넣는다.
class ManualTicker {
  void Function(Timer)? _cb;
  final _timer = _NoopTimer();

  Timer create(Duration d, void Function(Timer) cb) {
    _cb = cb;
    _timer.active = true;
    return _timer;
  }

  void fire() {
    if (_timer.active) _cb?.call(_timer);
  }
}

class _NoopTimer implements Timer {
  bool active = false;
  @override
  void cancel() => active = false;
  @override
  bool get isActive => active;
  @override
  int get tick => 0;
}
