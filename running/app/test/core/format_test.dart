import 'package:flutter_test/flutter_test.dart';
import 'package:running/core/format.dart';

void main() {
  test('시간', () {
    expect(formatDuration(0), '0:00');
    expect(formatDuration(342.9), '5:42');
    expect(formatDuration(3725), '1:02:05');
  });

  test('페이스', () {
    expect(formatPace(1000 / 342), "5'42\"");
    expect(formatPace(1000 / 359.8), "6'00\""); // 59.8초는 반올림해 분이 올라간다
    expect(formatPace(0), '--');
    expect(formatPace(null), '--');
  });

  test('거리는 반올림하지 않고 버린다', () {
    expect(formatKm(1999), '1.99');
    expect(formatKm(0), '0.00');
    expect(formatKm(12345), '12.34');
  });
}
