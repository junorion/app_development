import 'package:flutter_test/flutter_test.dart';
import 'package:running/features/run/domain/auto_pause.dart';

void main() {
  test('0.5m/s 미만이 4초 이어져야 멈춘다', () {
    final d = AutoPauseDetector();
    expect(d.update(0, 0.2), isFalse);
    expect(d.update(3000, 0.2), isFalse);
    expect(d.update(4000, 0.2), isTrue);
    expect(d.isPaused, isTrue);
  });

  test('중간에 한 번이라도 빨라지면 다시 센다', () {
    final d = AutoPauseDetector()
      ..update(0, 0.2)
      ..update(3000, 0.2)
      ..update(3500, 2.0);
    expect(d.update(6000, 0.2), isFalse);
    expect(d.isPaused, isFalse);
  });

  test('재개는 1.0m/s 이상 — 0.7m/s 로 서성이면 멈춘 채로 둔다', () {
    final d = AutoPauseDetector()
      ..update(0, 0)
      ..update(4000, 0);
    expect(d.update(5000, 0.7), isFalse);
    expect(d.isPaused, isTrue);
    expect(d.update(6000, 1.2), isTrue);
    expect(d.isPaused, isFalse);
  });

  test('속도를 모르면 판정하지 않는다', () {
    final d = AutoPauseDetector();
    expect(d.update(0, null), isFalse);
    expect(d.update(10000, null), isFalse);
    expect(d.isPaused, isFalse);
  });
}
