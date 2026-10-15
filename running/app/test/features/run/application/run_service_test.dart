import 'package:flutter_test/flutter_test.dart';
import 'package:running/data/db.dart';
import 'package:running/data/run_repository.dart';
import 'package:running/features/run/application/run_service.dart';
import 'package:running/features/run/domain/run_session.dart';
import 'package:running/features/run/domain/split_tracker.dart';

import '../../../support/fakes.dart';
import '../../../support/manual_ticker.dart';

void main() {
  late AppDb db;
  late RunRepository repo;
  late FakeLocationSource loc;
  late FakeStepSource steps;
  late ManualTicker ticker;
  late RunService svc;
  var t = 0;

  setUp(() {
    db = memoryDb();
    repo = RunRepository(db);
    loc = FakeLocationSource();
    steps = FakeStepSource();
    ticker = ManualTicker();
    t = 1758340800000;
    svc = RunService(
        repo: repo,
        locationSource: () => loc,
        stepSource: () => steps,
        now: () => t,
        periodic: ticker.create);
  });

  tearDown(() async {
    svc.dispose();
    await db.close();
  });

  /// 1초 흘리고, 위치·걸음을 넣고, tick
  Future<void> second(double posM, double stepsCum) async {
    t += 1000;
    loc.emitAt(t, posM);
    steps.emit(t, stepsCum);
    await Future<void>.delayed(Duration.zero);
    ticker.fire();
  }

  test('시작 → 스플릿 이벤트 → 종료하면 저장까지 끝나 있다', () async {
    final splits = <Split>[];
    svc.splitEvents.listen(splits.add);
    await svc.start();
    expect(svc.state, RunState.running);
    expect(loc.started, isTrue);
    steps.emit(t, 1000);

    for (var i = 1; i <= 400; i++) {
      await second(i * 3.0, 1000 + i * 3.0);
    }
    await Future<void>.delayed(Duration.zero);
    expect(splits, hasLength(1));
    expect(svc.session!.currentCadenceSpm, closeTo(180, 1));

    final id = await svc.finish();
    expect(id, isNotNull);
    expect(loc.stopped, isTrue);
    expect(svc.state, RunState.finished);
    expect(svc.isActive, isFalse);

    final row = (await repo.run(id!))!;
    expect(row.status, RunStatus.finished);
    expect(row.distanceM, closeTo(1197, 5));
    expect((await repo.splitsOf(id)).map((s) => s.isPartial), [false, true]);

    svc.reset();
    expect(svc.session, isNull);
  });

  test('일시정지·재개가 상태에 반영되고 알림이 간다', () async {
    var notified = 0;
    svc.addListener(() => notified++);
    await svc.start();
    svc.pause();
    expect(svc.state, RunState.paused);
    expect(svc.isActive, isTrue);
    svc.resume();
    expect(svc.state, RunState.running);
    expect(notified, greaterThanOrEqualTo(3));
    await svc.finish();
  });

  test('걸음 센서 오류는 무시하고 기록은 계속한다', () async {
    final svc2 = RunService(
        repo: repo,
        locationSource: () => loc,
        stepSource: () => ErrorStepSource(),
        now: () => t,
        periodic: ManualTicker().create);
    await svc2.start();
    await Future<void>.delayed(Duration.zero);
    expect(svc2.state, RunState.running);
    expect(svc2.session!.steps, isNull);
    await svc2.finish();
    svc2.dispose();
  });
}
