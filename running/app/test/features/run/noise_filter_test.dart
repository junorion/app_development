import 'package:flutter_test/flutter_test.dart';
import 'package:running/features/run/domain/location_sample.dart';
import 'package:running/features/run/domain/noise_filter.dart';

/// 위도 방향으로 [m] 미터 떨어진 점
LocationSample at(int sec, double m, {double acc = 5}) => LocationSample(
    tMs: sec * 1000, lat: 37.5 + m / 111195.0, lng: 127.0, accuracyM: acc);

void main() {
  test('첫 유효 샘플은 거리를 누적하지 않는다', () {
    final f = NoiseFilter();
    final r = f.add(at(0, 0));
    expect(r.isAccepted, isTrue);
    expect(r.distanceM, 0);
  });

  test('정확도가 나쁜 점은 첫 점이어도 버린다', () {
    final f = NoiseFilter();
    expect(f.add(at(0, 0, acc: 40)).reason, RejectReason.inaccurate);
    expect(f.anchor, isNull);
  });

  test('정지 드리프트(2.5m 미만)는 무시하고 기준을 유지한다', () {
    final f = NoiseFilter()..add(at(0, 0));
    expect(f.add(at(1, 1.5)).reason, RejectReason.tooClose);
    // 드리프트가 쌓여도 기준점은 처음 점이므로 3m 가 되면 받아들인다
    final r = f.add(at(2, 3));
    expect(r.isAccepted, isTrue);
    expect(r.distanceM, closeTo(3, 0.01));
  });

  test('순간 튐(12m/s 초과)은 버리고 다음 정상 점은 받는다', () {
    final f = NoiseFilter()..add(at(0, 0));
    expect(f.add(at(1, 80)).reason, RejectReason.tooFast);
    final r = f.add(at(2, 6));
    expect(r.isAccepted, isTrue);
    expect(r.distanceM, closeTo(6, 0.01));
    expect(f.rejected[RejectReason.tooFast], 1);
  });

  test('시각이 거꾸로 가면 버린다', () {
    final f = NoiseFilter()..add(at(5, 0));
    expect(f.add(at(5, 10)).reason, RejectReason.nonMonotonic);
  });

  test('reset 후 첫 점은 다시 거리 0', () {
    final f = NoiseFilter()..add(at(0, 0));
    f.reset();
    expect(f.add(at(60, 200)).distanceM, 0);
  });
}

