import 'dart:math' as math;

import 'geo.dart';
import 'location_sample.dart';

/// 한 축의 등속 모델 칼만 필터. 상태는 [위치, 속도].
class _Axis {
  double p, v = 0;
  double p00, p01 = 0, p11;

  _Axis(this.p, double r2)
      : p00 = r2,
        p11 = 25; // 처음 속도는 모른다 (±5m/s)

  void step(double dt, double z, double r2, double q) {
    // 예측
    p += v * dt;
    final dt2 = dt * dt, dt3 = dt2 * dt, dt4 = dt3 * dt;
    final n00 = p00 + 2 * dt * p01 + dt2 * p11 + q * dt4 / 4;
    final n01 = p01 + dt * p11 + q * dt3 / 2;
    final n11 = p11 + q * dt2;
    // 갱신
    final s = n00 + r2;
    final k0 = n00 / s, k1 = n01 / s;
    final y = z - p;
    p += k0 * y;
    v += k1 * y;
    p00 = (1 - k0) * n00;
    p01 = (1 - k0) * n01;
    p11 = n11 - k1 * n01;
  }
}

/// 위치 평활화 (지침 5.2). GPS 잡음은 경로를 좌우로 흔들고, 흔들린 만큼 거리가 부풀려진다
/// (합성 GPX 에서 약 4%). 러너는 가속이 작다는 가정으로 흔들림을 걷어 낸다.
///
/// 첫 점을 원점으로 한 평면(m)에서 두 축을 따로 거른다. 러닝 경로 크기에서는 충분히 정확하다.
class KalmanSmoother {
  KalmanSmoother({this.accelSigma = 0.6});

  /// 가정하는 가속도의 표준편차(m/s²). 작을수록 더 매끄럽고, 모퉁이를 더 깎는다.
  final double accelSigma;

  double? _lat0, _lng0, _kx;
  _Axis? _x, _y;
  int? _lastMs;

  void reset() {
    _x = _y = null;
    _lastMs = null;
  }

  /// 걸러진 위치 (lat, lng)
  (double, double) add(LocationSample s) {
    if (_lat0 == null) {
      _lat0 = s.lat;
      _lng0 = s.lng;
      _kx = earthRadiusM * math.cos(s.lat * math.pi / 180) * math.pi / 180;
    }
    const ky = earthRadiusM * math.pi / 180;
    final zx = (s.lng - _lng0!) * _kx!;
    final zy = (s.lat - _lat0!) * ky;
    // 보고된 정확도는 약 68% 반경이다. 축별 표준편차로 옮긴다.
    final sigma = math.max(s.accuracyM, 3.0) / 1.5;
    final r2 = sigma * sigma;
    final last = _lastMs;
    if (_x == null || last == null) {
      _x = _Axis(zx, r2);
      _y = _Axis(zy, r2);
    } else {
      final dt = (s.tMs - last) / 1000.0;
      final q = accelSigma * accelSigma;
      _x!.step(dt, zx, r2, q);
      _y!.step(dt, zy, r2, q);
    }
    _lastMs = s.tMs;
    return (_lat0! + _y!.p / ky, _lng0! + _x!.p / _kx!);
  }
}
