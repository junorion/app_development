import 'dart:math' as math;

/// 지구 평균 반경(m). WGS84 타원체 대신 구로 근사한다 — 러닝 거리에서 오차는 0.5% 이내다.
const double earthRadiusM = 6371008.8;

double _rad(double deg) => deg * math.pi / 180.0;

/// 두 좌표 사이의 대원 거리(m). 지침 5.3.
double haversineM(double lat1, double lng1, double lat2, double lng2) {
  final dLat = _rad(lat2 - lat1);
  final dLng = _rad(lng2 - lng1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * earthRadiusM * math.asin(math.min(1.0, math.sqrt(a)));
}

/// m/s → 분/km. 멈춰 있으면(속도가 거의 0) 페이스가 무한대라 null.
double? paceMinPerKm(double speedMps) =>
    speedMps < 0.1 ? null : 1000.0 / (60.0 * speedMps);
