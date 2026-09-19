import 'package:flutter_test/flutter_test.dart';
import 'package:running/features/timer/domain/interval_sequence.dart';

const walk5 = TimerStep(label: '걷기', durationSec: 300, kind: StepKind.walk);
const run4 = TimerStep(label: '달리기', durationSec: 240, kind: StepKind.run);
const walk1 = TimerStep(label: '걷기', durationSec: 60, kind: StepKind.walk);

/// 지침 7장의 예: 걷기 5분, [달리기 4분 + 걷기 1분] × 5회, 걷기 5분
const example = IntervalSequence(name: '예시', blocks: [
  TimerBlock(steps: [walk5]),
  TimerBlock(steps: [run4, walk1], repeat: 5),
  TimerBlock(steps: [walk5]),
]);

void main() {
  test('전체 소요 시간 35분', () {
    expect(example.totalSec, 35 * 60);
  });

  test('시작은 워밍업 걷기, 남은 5분', () {
    final p = positionAt(example, 0);
    expect(p.step, walk5);
    expect(p.remainingInStepSec, 300);
    expect(p.stepOrdinal, 0);
  });

  test('5분 정각에 첫 달리기로 넘어간다', () {
    expect(positionAt(example, 299.9).stepOrdinal, 0);
    final p = positionAt(example, 300);
    expect(p.step, run4);
    expect(p.stepOrdinal, 1);
  });

  test('블록 셋째 반복의 걷기 — 5 + 5×2 + 4 분 + 30초', () {
    final p = positionAt(example, (5 + 10 + 4) * 60 + 30);
    expect(p.step, walk1);
    expect(p.blockIndex, 1);
    expect(p.blockRound, 2);
    expect(p.remainingInStepSec, 30);
    expect(p.stepOrdinal, 1 + 2 * 2 + 1);
  });

  test('쿨다운 후 종료', () {
    expect(positionAt(example, 34 * 60).step, walk5);
    final p = positionAt(example, 35 * 60);
    expect(p.finished, isTrue);
    expect(p.step, isNull);
    expect(p.stepOrdinal, 12);
  });

  test('전체 반복 0 은 무한 — 둘째 바퀴도 이어진다', () {
    const seq = IntervalSequence(name: '무한', repeat: 0, blocks: [
      TimerBlock(steps: [run4, walk1]),
    ]);
    expect(seq.totalSec, isNull);
    final p = positionAt(seq, 300 * 7 + 250);
    expect(p.round, 7);
    expect(p.step, walk1);
    expect(p.stepOrdinal, 15);
  });

  test('전체 반복 2 — 두 바퀴 뒤 종료', () {
    const seq = IntervalSequence(name: '두 번', repeat: 2, blocks: [
      TimerBlock(steps: [run4, walk1]),
    ]);
    expect(positionAt(seq, 599).finished, isFalse);
    expect(positionAt(seq, 600).finished, isTrue);
  });

  test('빈 시퀀스는 바로 종료', () {
    expect(positionAt(const IntervalSequence(name: '빈', blocks: []), 0).finished, isTrue);
  });
}
