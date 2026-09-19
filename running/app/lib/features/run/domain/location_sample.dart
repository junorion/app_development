/// 위치 소스(실제 GPS 또는 GPX 재생)가 내보내는 한 점. 내부 단위는 SI (지침 9장).
class LocationSample {
  const LocationSample({
    required this.tMs,
    required this.lat,
    required this.lng,
    required this.accuracyM,
    this.speedMps,
    this.altitudeM,
  });

  /// 수신 시각 (epoch ms, UTC)
  final int tMs;
  final double lat;
  final double lng;

  /// 수평 정확도 반경(m)
  final double accuracyM;

  /// 기기가 보고한 속도. 필터는 쓰지 않고 좌표 간 거리로 다시 계산한다.
  final double? speedMps;
  final double? altitudeM;

  @override
  String toString() => 'LocationSample($tMs, $lat, $lng, ±$accuracyM)';
}
