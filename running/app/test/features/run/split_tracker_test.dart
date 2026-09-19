import 'package:flutter_test/flutter_test.dart';
import 'package:running/features/run/domain/split_tracker.dart';

void main() {
  test('경계를 넘는 두 점 사이를 선형 보간한다', () {
    final t = SplitTracker()
      ..update(distanceM: 0, movingSec: 0, steps: 0)
      ..update(distanceM: 990, movingSec: 297, steps: 890);
    final done = t.update(distanceM: 1010, movingSec: 303, steps: 910);
    expect(done, hasLength(1));
    expect(done.single.durationSec, closeTo(300, 1e-9));
    expect(done.single.steps, closeTo(900, 1e-9));
    expect(done.single.avgCadenceSpm, closeTo(180, 1e-9));
  });

  test('둘째 구간은 첫 경계의 보간 시각부터 잰다', () {
    final t = SplitTracker()
      ..update(distanceM: 0, movingSec: 0, steps: 0)
      ..update(distanceM: 1010, movingSec: 303, steps: 910);
    final done = t.update(distanceM: 2020, movingSec: 603, steps: 1810);
    expect(done.single.index, 1);
    // 두 번째 경계 시각: 303 + 300×(990/1010) = 597.059..., 첫 경계 시각: 300
    expect(done.single.durationSec, closeTo(303 + 300 * 990 / 1010 - 300, 1e-9));
  });

  test('한 번에 두 경계를 넘으면 둘 다 확정한다 (터널 뒤 GPS 복귀 등)', () {
    final t = SplitTracker()..update(distanceM: 0, movingSec: 0);
    final done = t.update(distanceM: 2500, movingSec: 750);
    expect(done.map((s) => s.durationSec), [closeTo(300, 1e-9), closeTo(300, 1e-9)]);
    expect(done.first.steps, isNull);
  });

  test('마지막 미완 구간은 부분 스플릿', () {
    final t = SplitTracker()
      ..update(distanceM: 0, movingSec: 0)
      ..update(distanceM: 1500, movingSec: 450);
    final p = t.partial()!;
    expect(p.isPartial, isTrue);
    expect(p.distanceM, closeTo(500, 1e-9));
    expect(p.durationSec, closeTo(150, 1e-9));
  });

  test('딱 경계에서 끝나면 부분 스플릿이 없다', () {
    final t = SplitTracker()
      ..update(distanceM: 0, movingSec: 0)
      ..update(distanceM: 1000, movingSec: 300);
    expect(t.splits, hasLength(1));
    expect(t.partial(), isNull);
  });

  test('마일 단위', () {
    final t = SplitTracker(splitM: 1609.344)..update(distanceM: 0, movingSec: 0);
    expect(t.update(distanceM: 1609.344, movingSec: 480).single.durationSec, 480);
  });
}
