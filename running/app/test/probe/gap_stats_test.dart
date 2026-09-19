import 'package:flutter_test/flutter_test.dart';
import 'package:running/probe/gap_stats.dart';

void main() {
  test('최대 간격과 긴 끊김을 센다', () {
    final g = GapStats();
    for (final t in [0, 1000, 2000, 9000, 10000, 30000]) {
      g.add(t);
    }
    expect(g.count, 6);
    expect(g.maxGapMs, 20000);
    expect(g.maxGapAtMs, 30000);
    expect(g.longGaps, 2);
    expect(g.longGapTotalMs, 27000);
  });

  test('지터 — 절대값 평균·최대·10ms 초과', () {
    final j = JitterStats()
      ..add(2)
      ..add(-4)
      ..add(15);
    expect(j.meanAbsMs, 7);
    expect(j.maxAbsMs, 15);
    expect(j.over10ms, 1);
  });
}
