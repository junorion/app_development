import '../features/run/domain/geo.dart';

/// 초 → "m:ss" 또는 "h:mm:ss"
String formatDuration(num sec) {
  final s = sec.floor();
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, r = s % 60;
  final ss = r.toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$ss' : '$m:$ss';
}

/// m/s → 5'42"  (모르거나 멈춰 있으면 --)
String formatPace(double? mps) {
  if (mps == null) return '--';
  final p = paceMinPerKm(mps);
  if (p == null || p > 60) return '--';
  var m = p.floor();
  var s = ((p - m) * 60).round();
  if (s == 60) {
    m++;
    s = 0;
  }
  return "$m'${s.toString().padLeft(2, '0')}\"";
}

/// m → "1.23" (km, 소수 둘째 자리 버림 — 1.999 가 2.00 으로 먼저 보이면 안 된다)
String formatKm(double m) => ((m / 10).floor() / 100).toStringAsFixed(2);
