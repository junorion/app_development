import 'package:flutter_test/flutter_test.dart';
import 'package:running/features/run/domain/geo.dart';

void main() {
  test('위도 1도는 약 111.2km', () {
    expect(haversineM(37, 127, 38, 127), closeTo(111195, 5));
  });

  test('경도 1도는 위도 60도에서 적도의 절반', () {
    expect(haversineM(60, 10, 60, 11), closeTo(haversineM(0, 10, 0, 11) / 2, 100));
  });

  test('같은 점은 0', () {
    expect(haversineM(37.5, 127.0, 37.5, 127.0), 0);
  });

  test('페이스 환산 — 3.333m/s 는 5분/km, 멈춤은 null', () {
    expect(paceMinPerKm(1000 / 300), closeTo(5.0, 1e-9));
    expect(paceMinPerKm(0), isNull);
  });
}
