import 'package:drift/drift.dart';

import '../features/run/domain/run_session.dart';
import '../features/run/domain/split_tracker.dart';
import 'db.dart';

/// 러닝 기록 저장소 (지침 9장). 화면과 서비스는 DB 를 직접 만지지 않고 이것만 쓴다.
class RunRepository {
  RunRepository(this.db);
  final AppDb db;

  Future<void> createRun({
    required String id,
    required int startedAtMs,
    required int tzOffsetMin,
    String? timerPresetId,
  }) =>
      db.into(db.runs).insert(RunsCompanion.insert(
            id: id,
            startedAt: startedAtMs,
            tzOffsetMin: tzOffsetMin,
            status: RunStatus.recording,
            timerPresetId: Value(timerPresetId),
            snapshotAt: Value(startedAtMs),
          ));

  /// 위치 점과 현재 요약값을 한 트랜잭션으로 (지침 9.2)
  Future<void> saveProgress(
    String runId, {
    required List<TrackPoint> points,
    required List<Split> newSplits,
    required int tMs,
    required double distanceM,
    required double movingSec,
    double? steps,
  }) =>
      db.transaction(() async {
        await db.batch((b) {
          b.insertAll(db.trackPoints, [
            for (final p in points)
              TrackPointsCompanion.insert(
                runId: runId,
                ts: p.sample.tMs,
                lat: p.sample.lat,
                lng: p.sample.lng,
                accuracyM: p.sample.accuracyM,
                speedMps: Value(p.sample.speedMps),
                altitudeM: Value(p.sample.altitudeM),
                segmentIndex: p.segmentIndex,
              ),
          ]);
          b.insertAll(db.splits, [for (final s in newSplits) _split(runId, s)],
              mode: InsertMode.insertOrReplace);
        });
        await (db.update(db.runs)..where((r) => r.id.equals(runId))).write(RunsCompanion(
          snapshotAt: Value(tMs),
          distanceM: Value(distanceM),
          movingTimeSec: Value(movingSec),
          totalSteps: Value(steps),
          avgSpeedMps: Value(movingSec > 0 ? distanceM / movingSec : 0),
          avgCadenceSpm: Value(steps == null || movingSec <= 0 ? null : steps / (movingSec / 60)),
        ));
      });

  /// 정상 종료. 부분 스플릿까지 포함한 전체 스플릿으로 바꿔 쓴다.
  Future<void> finishRun(String runId, {required int endedAtMs, required List<Split> splits}) =>
      db.transaction(() async {
        await (db.delete(db.splits)..where((s) => s.runId.equals(runId))).go();
        await db.batch((b) => b.insertAll(db.splits, [for (final s in splits) _split(runId, s)]));
        await (db.update(db.runs)..where((r) => r.id.equals(runId))).write(RunsCompanion(
          endedAt: Value(endedAtMs),
          status: const Value(RunStatus.finished),
        ));
      });

  /// 앱이 죽은 뒤 남은 기록 (지침 5.7, 9.2)
  Future<List<RunRow>> unfinishedRuns() =>
      (db.select(db.runs)..where((r) => r.status.equalsValue(RunStatus.recording))).get();

  /// "이어서 저장할까요?" 에 예 — 마지막 저장 시점까지로 완료 처리한다.
  /// 완성 스플릿은 저장돼 있으므로 남은 거리·시간으로 부분 스플릿만 더한다.
  Future<void> recover(String runId, {double splitM = 1000}) => db.transaction(() async {
        final run = await (db.select(db.runs)..where((r) => r.id.equals(runId))).getSingle();
        final done = await (db.select(db.splits)
              ..where((s) => s.runId.equals(runId) & s.isPartial.equals(false)))
            .get();
        final restM = run.distanceM - done.length * splitM;
        final restSec = run.movingTimeSec - done.fold<double>(0, (a, s) => a + s.durationSec);
        await (db.delete(db.splits)..where((s) => s.runId.equals(runId) & s.isPartial.equals(true)))
            .go();
        if (restM >= 1) {
          await db.into(db.splits).insert(SplitsCompanion.insert(
                runId: runId,
                index: done.length,
                distanceM: restM,
                durationSec: restSec,
                isPartial: true,
              ));
        }
        await (db.update(db.runs)..where((r) => r.id.equals(runId))).write(RunsCompanion(
          endedAt: Value(run.snapshotAt ?? run.startedAt),
          status: const Value(RunStatus.recovered),
        ));
      });

  /// 러닝 당시 시간대 기준으로 [day] (연·월·일만 본다) 에 시작한 러닝, 시작 시각 순.
  Future<List<RunRow>> runsOnDay(DateTime day) async {
    final dayUtcMs = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch;
    // 시간대는 −12h ~ +14h 이므로 그 폭만큼 넓게 가져와 인덱스를 타고, 날짜는 여기서 가른다
    const pad = 14 * 3600 * 1000;
    final rows = await (db.select(db.runs)
          ..where((r) =>
              r.startedAt.isBetweenValues(dayUtcMs - pad, dayUtcMs + 86400000 + pad) &
              r.status.equalsValue(RunStatus.recording).not())
          ..orderBy([(r) => OrderingTerm.asc(r.startedAt)]))
        .get();
    return [for (final r in rows) if (_sameDay(localDayOf(r), day)) r];
  }

  /// 러닝 당시 시간대의 벽시계 날짜
  static DateTime localDayOf(RunRow r) {
    final t = DateTime.fromMillisecondsSinceEpoch(r.startedAt + r.tzOffsetMin * 60000, isUtc: true);
    return DateTime.utc(t.year, t.month, t.day);
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<RunRow?> run(String id) =>
      (db.select(db.runs)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<List<TrackPointRow>> points(String runId) => (db.select(db.trackPoints)
        ..where((p) => p.runId.equals(runId))
        ..orderBy([(p) => OrderingTerm.asc(p.ts)]))
      .get();

  Future<List<SplitRow>> splitsOf(String runId) => (db.select(db.splits)
        ..where((s) => s.runId.equals(runId))
        ..orderBy([(s) => OrderingTerm.asc(s.index)]))
      .get();

  /// 개별 삭제 — 점과 스플릿도 함께 실제로 지운다 (지침 9.4)
  Future<void> deleteRun(String id) => (db.delete(db.runs)..where((r) => r.id.equals(id))).go();

  /// 설정의 "모든 기록 삭제" (지침 9.4)
  Future<void> deleteAll() => db.transaction(() async {
        await db.delete(db.trackPoints).go();
        await db.delete(db.splits).go();
        await db.delete(db.runs).go();
      });

  SplitsCompanion _split(String runId, Split s) => SplitsCompanion.insert(
        runId: runId,
        index: s.index,
        distanceM: s.distanceM,
        durationSec: s.durationSec,
        avgCadenceSpm: Value(s.avgCadenceSpm),
        isPartial: s.isPartial,
      );
}
