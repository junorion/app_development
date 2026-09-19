import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:running/features/map/domain/route_segments.dart';
import 'package:running/features/map/domain/speed_color.dart';

const mPerDegLat = 111195.08;

/// 북쪽으로 [speed] m/s 로 [sec] 초 달린 경로 (1초 간격)
List<RoutePoint> northRun(double speed, int sec,
    {double fromM = 0, int fromSec = 0, int segment = 0}) => [
      for (var s = 0; s <= sec; s++)
        RoutePoint(37.5 + (fromM + speed * s) / mPerDegLat, 127.0,
            (fromSec + s) * 1000, segment),
    ];

void main() {
  test('조각은 약 30m 이고 끝점을 공유한다', () {
    final segs = buildSpeedSegments(northRun(3, 100)); // 300m
    expect(segs.length, 10);
    for (var i = 1; i < segs.length; i++) {
      expect(identical(segs[i].points.first, segs[i - 1].points.last), isTrue);
    }
    for (final s in segs) {
      expect(s.speedMps, closeTo(3, 0.01));
    }
  });

  test('속도가 바뀐 구간이 조각 속도에 드러난다', () {
    final pts = [...northRun(2, 60), ...northRun(4, 60, fromM: 120, fromSec: 60).skip(1)];
    final segs = buildSpeedSegments(pts);
    expect(segs.first.speedMps, closeTo(2, 0.01));
    expect(segs.last.speedMps, closeTo(4, 0.01));
  });

  test('일시정지로 끊긴 구간은 잇지 않는다', () {
    final pts = [...northRun(3, 20), ...northRun(3, 20, fromM: 500, fromSec: 100, segment: 1)];
    final segs = buildSpeedSegments(pts);
    for (final s in segs) {
      expect(s.points.map((p) => p.segment).toSet(), hasLength(1));
      expect(s.speedMps, closeTo(3, 0.01)); // 끊긴 사이(500m 점프)를 속도에 넣지 않는다
    }
  });

  test('짧은 꼬리는 앞 조각에 붙는다', () {
    final segs = buildSpeedSegments(northRun(3, 13)); // 39m → 30m + 9m
    expect(segs, hasLength(1));
    expect(segs.single.points, hasLength(14));
  });

  test('이상치는 5~95% 로 잘려 끝 색에 붙는다', () {
    final speeds = [for (var i = 0; i < 100; i++) 2.0 + i * 0.02, 50.0];
    final t = normalizeSpeeds(speeds);
    expect(t.last, 1.0);
    expect(t.first, 0.0);
    expect(t[50], closeTo(0.5, 0.05));
  });

  test('모두 같은 속도면 가운데 색', () {
    expect(normalizeSpeeds([3, 3, 3]), [0.5, 0.5, 0.5]);
  });

  test('직선 위 점은 단순화로 양 끝만 남고, 꺾인 점은 남는다', () {
    final line = northRun(3, 100);
    expect(simplify(line, 1), hasLength(2));
    final bent = [...line, RoutePoint(line.last.lat, 127.001, 101000)];
    final s = simplify(bent, 1);
    expect(s, hasLength(3));
    expect(identical(s[1], line.last), isTrue);
  });

  test('색 보간 — 양 끝과 가운데', () {
    const scale = [Color(0xFF6FB1E8), Color(0xFF5CC8B0), Color(0xFFF2D16B),
        Color(0xFFF2A25E), Color(0xFFE8695F)];
    expect(speedColor(scale, 0), scale.first);
    expect(speedColor(scale, 1), scale.last);
    expect(speedColor(scale, 0.5), scale[2]);
    expect(speedColor(scale, 2), scale.last);
  });
}
