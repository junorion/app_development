/// 인터벌 타이머 시퀀스 (지침 7.1). 예: 걷기 5분, [달리기 4분 + 걷기 1분] × 5, 걷기 5분.
enum StepKind { run, walk, rest }

class TimerStep {
  const TimerStep({required this.label, required this.durationSec, required this.kind});
  final String label;
  final int durationSec;
  final StepKind kind;
}

class TimerBlock {
  const TimerBlock({required this.steps, this.repeat = 1});
  final List<TimerStep> steps;
  final int repeat;

  int get oneRoundSec => steps.fold(0, (a, s) => a + s.durationSec);
  int get totalSec => oneRoundSec * repeat;
}

class IntervalSequence {
  const IntervalSequence({required this.name, required this.blocks, this.repeat = 1});
  final String name;
  final List<TimerBlock> blocks;

  /// 전체 반복 횟수. 0 이면 무한 (지침 7.1)
  final int repeat;

  bool get isInfinite => repeat == 0;

  /// 한 바퀴 소요 시간(초)
  int get roundSec => blocks.fold(0, (a, b) => a + b.totalSec);

  /// 전체 소요 시간. 무한이면 null.
  int? get totalSec => isInfinite ? null : roundSec * repeat;
}

/// 경과 시간으로 계산한 현재 위치
class TimerPosition {
  const TimerPosition({
    required this.step,
    required this.stepOrdinal,
    required this.remainingInStepSec,
    required this.round,
    required this.blockIndex,
    required this.blockRound,
    required this.finished,
  });

  /// 끝났으면 null
  final TimerStep? step;

  /// 시퀀스 시작 후 몇 번째 스텝인지 (0 부터, 반복을 펼쳐서 센다). 이 값이 바뀌면 스텝 전환이다.
  final int stepOrdinal;
  final double remainingInStepSec;

  /// 전체 반복 중 몇 번째 (0 부터)
  final int round;
  final int blockIndex;

  /// 블록 반복 중 몇 번째 (0 부터)
  final int blockRound;
  final bool finished;
}

/// 시퀀스 시작 후 [elapsedSec] (일시정지 제외) 시점의 위치. 순수 함수 (지침 7.2).
///
/// 화면 갱신 주기와 무관하게 이 결과만으로 스텝 전환을 판단한다. 백그라운드에서 돌아와도,
/// 일시정지를 여러 번 해도 어긋나지 않는다.
TimerPosition positionAt(IntervalSequence seq, double elapsedSec) {
  final roundSec = seq.roundSec;
  final stepsPerRound = seq.blocks.fold<int>(0, (a, b) => a + b.steps.length * b.repeat);
  if (roundSec <= 0 || stepsPerRound == 0) return _finished(0);

  final t = elapsedSec < 0 ? 0.0 : elapsedSec;
  final round = (t / roundSec).floor();
  if (!seq.isInfinite && round >= seq.repeat) {
    return _finished(stepsPerRound * seq.repeat);
  }
  var rest = t - round * roundSec;
  var ordinal = round * stepsPerRound;
  for (var bi = 0; bi < seq.blocks.length; bi++) {
    final b = seq.blocks[bi];
    if (rest >= b.totalSec) {
      rest -= b.totalSec;
      ordinal += b.steps.length * b.repeat;
      continue;
    }
    final one = b.oneRoundSec;
    final br = (rest / one).floor();
    rest -= br * one;
    ordinal += br * b.steps.length;
    for (final s in b.steps) {
      if (rest < s.durationSec) {
        return TimerPosition(
          step: s,
          stepOrdinal: ordinal,
          remainingInStepSec: s.durationSec - rest,
          round: round,
          blockIndex: bi,
          blockRound: br,
          finished: false,
        );
      }
      rest -= s.durationSec;
      ordinal++;
    }
  }
  // 부동소수 경계에서만 온다 — 다음 바퀴의 첫 스텝으로 본다
  return positionAt(seq, (round + 1) * roundSec.toDouble());
}

TimerPosition _finished(int ordinal) => TimerPosition(
      step: null,
      stepOrdinal: ordinal,
      remainingInStepSec: 0,
      round: 0,
      blockIndex: 0,
      blockRound: 0,
      finished: true,
    );
