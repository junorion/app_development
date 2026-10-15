import 'dart:async';

import 'package:pedometer/pedometer.dart';

/// 걸음 수 소스. Android 는 부팅 후 누적값이 오므로 차이는 [RunSession.onSteps] 가 낸다 (지침 5.4).
abstract interface class StepSource {
  /// (수신 시각 ms, 누적 걸음 수)
  Stream<(int, double)> start();
  Future<void> stop();
}

class PedometerStepSource implements StepSource {
  StreamSubscription<StepCount>? _sub;

  @override
  Stream<(int, double)> start() {
    final ctl = StreamController<(int, double)>();
    _sub = Pedometer.stepCountStream.listen(
      (e) => ctl.add((DateTime.now().millisecondsSinceEpoch, e.steps.toDouble())),
      onError: ctl.addError,
      onDone: ctl.close,
    );
    return ctl.stream;
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}
