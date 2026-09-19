import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:running/data/db.dart';
import 'package:running/data/run_repository.dart';
import 'package:running/features/run/data/run_recorder.dart';
import 'package:running/features/run/domain/location_sample.dart';
import 'package:running/features/run/domain/run_session.dart';

const mPerDegLat = 111195.08;

void main() {
  late AppDb db;
  late RunRepository repo;

  setUp(() {
    db = AppDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = RunRepository(db);
  });
  tearDown(() => db.close());

  /// 3m/s 로 [sec] 초 달리며 1초마다 recorder.onTick
  Future<(RunSession, RunRecorder)> runFor(int sec, {String id = 'r1', int t0 = 1758340800000}) async {
    final s = RunSession()
      ..startCountdown()
      ..begin(t0);
    await repo.createRun(id: id, startedAtMs: t0, tzOffsetMin: 540);
    final rec = RunRecorder(repo, s, id);
    for (var i = 1; i <= sec; i++) {
      final t = t0 + i * 1000;
      s
        ..onLocation(LocationSample(tMs: t, lat: 37.5 + i * 3 / mPerDegLat, lng: 127, accuracyM: 5))
        ..tick(t);
      await rec.onTick(t);
    }
    return (s, rec);
  }

  test('5초마다 점이 쌓이고, 겹치거나 빠지는 점이 없다', () async {
    final (s, _) = await runFor(23);
    final pts = await repo.points('r1');
    // 마지막 저장은 21초 (1, 6, 11, 16, 21) — 그 뒤 2초 분량은 아직 메모리에만 있다
    expect(pts.length, s.track.length - 2);
    expect(pts.map((p) => p.ts).toSet().length, pts.length);
    final run = (await repo.run('r1'))!;
    expect(run.status, RunStatus.recording);
    expect(run.snapshotAt, 1758340800000 + 21000);
  });

  test('정상 종료 — 요약·스플릿(부분 포함) 저장, 복구 대상이 아니다', () async {
    final (s, rec) = await runFor(400);
    final end = 1758340800000 + 400000;
    s.finish(end);
    await rec.finish(end);
    final run = (await repo.run('r1'))!;
    expect(run.status, RunStatus.finished);
    expect(run.distanceM, closeTo(1197, 3));
    expect(run.movingTimeSec, 400);
    final splits = await repo.splitsOf('r1');
    expect(splits.map((e) => e.isPartial), [false, true]);
    expect((await repo.points('r1')).length, s.track.length);
    expect(await repo.unfinishedRuns(), isEmpty);
  });

  test('앱이 죽으면 recording 으로 남고, 복구하면 마지막 저장까지로 완료된다', () async {
    await runFor(403); // 마지막 저장 401초
    final left = await repo.unfinishedRuns();
    expect(left.map((r) => r.id), ['r1']);

    await repo.recover('r1');
    final run = (await repo.run('r1'))!;
    expect(run.status, RunStatus.recovered);
    expect(run.endedAt, 1758340800000 + 401000);
    expect(run.movingTimeSec, 401);
    final splits = await repo.splitsOf('r1');
    expect(splits, hasLength(2));
    expect(splits.last.isPartial, isTrue);
    expect(splits.last.distanceM, closeTo(run.distanceM - 1000, 1e-6));
    expect(await repo.unfinishedRuns(), isEmpty);
  });

  test('삭제하면 점과 스플릿도 지워진다', () async {
    final (s, rec) = await runFor(400);
    s.finish(1758340800000 + 400000);
    await rec.finish(1758340800000 + 400000);
    await repo.deleteRun('r1');
    expect(await db.select(db.trackPoints).get(), isEmpty);
    expect(await db.select(db.splits).get(), isEmpty);
  });

  test('자정을 넘긴 러닝은 시작한 날짜로 묶인다 — 러닝 당시 시간대 기준', () async {
    // 한국 23:50 (UTC 14:50) 에 시작
    final t0 = DateTime.utc(2026, 9, 19, 14, 50).millisecondsSinceEpoch;
    await repo.createRun(id: 'late', startedAtMs: t0, tzOffsetMin: 540);
    await repo.finishRun('late', endedAtMs: t0 + 30 * 60000, splits: []);
    // 같은 UTC 시각이라도 뉴욕(−4h)에서 시작했다면 19일 오전
    await repo.createRun(id: 'ny', startedAtMs: t0, tzOffsetMin: -240);
    await repo.finishRun('ny', endedAtMs: t0 + 60000, splits: []);
    // 기록 중인 것은 일별 목록에 나오지 않는다
    await repo.createRun(id: 'rec', startedAtMs: t0, tzOffsetMin: 540);

    expect((await repo.runsOnDay(DateTime(2026, 9, 19))).map((r) => r.id).toSet(), {'late', 'ny'});
    expect(await repo.runsOnDay(DateTime(2026, 9, 20)), isEmpty);
  });

  test('모든 기록 삭제', () async {
    await runFor(30);
    await repo.deleteAll();
    expect(await db.select(db.runs).get(), isEmpty);
    expect(await db.select(db.trackPoints).get(), isEmpty);
  });
}
