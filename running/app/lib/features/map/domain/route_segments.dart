import 'dart:math' as math;

import '../../run/domain/geo.dart';

/// 저장된 경로의 한 점. [segment] 는 일시정지마다 오른다 (지침 9.1 TrackPoint.segmentIndex).
class RoutePoint {
  const RoutePoint(this.lat, this.lng, this.tMs, [this.segment = 0]);
  final double lat;
  final double lng;
  final int tMs;
  final int segment;
}

/// 색 하나로 칠할 경로 조각
class SpeedSegment {
  const SpeedSegment(this.points, this.speedMps);
  final List<RoutePoint> points;
  final double speedMps;
}

/// 경로를 약 [targetM] 미터 단위로 나누고 조각마다 평균 속도를 낸다 (지침 5.6 1~2단계).
///
/// 이웃한 조각은 끝점을 공유한다 — 공유하지 않으면 색이 바뀌는 곳마다 틈이 보인다.
/// 일시정지로 끊긴 곳은 잇지 않는다.
List<SpeedSegment> buildSpeedSegments(List<RoutePoint> pts, {double targetM = 30}) {
  final out = <SpeedSegment>[];
  var cur = <RoutePoint>[];
  var dist = 0.0;

  void flush() {
    if (cur.length >= 2) {
      final dt = (cur.last.tMs - cur.first.tMs) / 1000.0;
      out.add(SpeedSegment(List.unmodifiable(cur), dt > 0 ? dist / dt : 0));
    }
  }

  for (final p in pts) {
    if (cur.isNotEmpty && p.segment != cur.last.segment) {
      flush();
      cur = [];
      dist = 0;
    }
    if (cur.isNotEmpty) {
      dist += haversineM(cur.last.lat, cur.last.lng, p.lat, p.lng);
    }
    cur.add(p);
    if (dist >= targetM) {
      flush();
      cur = [p];
      dist = 0;
    }
  }
  // 남은 꼬리가 너무 짧으면 속도가 튀므로 앞 조각에 붙인다
  if (cur.length >= 2 && dist < targetM / 3 && out.isNotEmpty &&
      out.last.points.last.segment == cur.first.segment) {
    final prev = out.removeLast();
    final merged = [...prev.points, ...cur.skip(1)];
    final d = _pathLen(merged);
    final dt = (merged.last.tMs - merged.first.tMs) / 1000.0;
    out.add(SpeedSegment(List.unmodifiable(merged), dt > 0 ? d / dt : 0));
  } else {
    flush();
  }
  return out;
}

double _pathLen(List<RoutePoint> p) {
  var d = 0.0;
  for (var i = 1; i < p.length; i++) {
    d += haversineM(p[i - 1].lat, p[i - 1].lng, p[i].lat, p[i].lng);
  }
  return d;
}

/// 속도를 이 러닝의 하위 5% ~ 상위 95% 범위로 잘라 0~1 로 편다 (지침 5.6 3단계).
/// 모든 조각이 같은 속도면 전부 가운데(0.5).
List<double> normalizeSpeeds(List<double> speeds, {double lowQ = 0.05, double highQ = 0.95}) {
  if (speeds.isEmpty) return const [];
  final sorted = [...speeds]..sort();
  final lo = _quantile(sorted, lowQ);
  final hi = _quantile(sorted, highQ);
  if (hi - lo < 1e-6) return List.filled(speeds.length, 0.5);
  return [for (final s in speeds) ((s - lo) / (hi - lo)).clamp(0.0, 1.0)];
}

double _quantile(List<double> sorted, double q) {
  final pos = (sorted.length - 1) * q;
  final i = pos.floor();
  final j = math.min(i + 1, sorted.length - 1);
  return sorted[i] + (sorted[j] - sorted[i]) * (pos - i);
}

/// Douglas–Peucker 단순화. 화면 표시에만 쓴다 — 원본 좌표는 그대로 저장한다 (지침 5.6).
/// 거리는 첫 점 기준 등장방형 투영(m)으로 잰다. 러닝 경로 크기에서는 충분히 정확하다.
List<RoutePoint> simplify(List<RoutePoint> pts, double toleranceM) {
  if (pts.length < 3) return pts;
  final lat0 = pts.first.lat * math.pi / 180;
  final kx = earthRadiusM * math.cos(lat0) * math.pi / 180;
  const ky = earthRadiusM * math.pi / 180;
  final xs = [for (final p in pts) p.lng * kx];
  final ys = [for (final p in pts) p.lat * ky];

  final keep = List<bool>.filled(pts.length, false);
  keep[0] = keep[pts.length - 1] = true;
  final stack = <(int, int)>[(0, pts.length - 1)];
  while (stack.isNotEmpty) {
    final (a, b) = stack.removeLast();
    var maxD = -1.0;
    var idx = -1;
    for (var i = a + 1; i < b; i++) {
      final d = _segDist(xs[i], ys[i], xs[a], ys[a], xs[b], ys[b]);
      if (d > maxD) {
        maxD = d;
        idx = i;
      }
    }
    if (idx >= 0 && maxD > toleranceM) {
      keep[idx] = true;
      stack
        ..add((a, idx))
        ..add((idx, b));
    }
  }
  return [for (var i = 0; i < pts.length; i++) if (keep[i]) pts[i]];
}

double _segDist(double px, double py, double ax, double ay, double bx, double by) {
  final dx = bx - ax, dy = by - ay;
  final len2 = dx * dx + dy * dy;
  var t = len2 == 0 ? 0.0 : ((px - ax) * dx + (py - ay) * dy) / len2;
  t = t.clamp(0.0, 1.0);
  final cx = ax + t * dx - px, cy = ay + t * dy - py;
  return math.sqrt(cx * cx + cy * cy);
}
