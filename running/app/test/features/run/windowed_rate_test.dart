import 'package:flutter_test/flutter_test.dart';
import 'package:running/features/run/domain/windowed_rate.dart';

void main() {
  test('일정 속도는 그대로 나온다', () {
    final w = WindowedRate(8000);
    for (var s = 0; s <= 30; s++) {
      w.add(s * 1000, s * 3.0);
    }
    expect(w.rate, closeTo(3.0, 1e-9));
  });

  test('시작 직후 2초 미만이면 값을 내지 않는다', () {
    final w = WindowedRate(8000)
      ..add(0, 0)
      ..add(1000, 3);
    expect(w.rate, isNull);
  });

  test('멈추면 창 길이만큼 지나 0 이 된다', () {
    final w = WindowedRate(8000);
    for (var s = 0; s <= 20; s++) {
      w.add(s * 1000, s * 3.0);
    }
    for (var s = 21; s <= 28; s++) {
      w.add(s * 1000, 60);
    }
    expect(w.rate, closeTo(0, 1e-9));
  });

  test('창 경계는 보간한다 — 샘플 간격이 창보다 성겨도 값이 튀지 않는다', () {
    final w = WindowedRate(8000)
      ..add(0, 0)
      ..add(5000, 15)
      ..add(10000, 30)
      ..add(15000, 45);
    expect(w.rate, closeTo(3.0, 1e-9));
  });
}
