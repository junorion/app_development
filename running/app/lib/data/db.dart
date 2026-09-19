import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'db.g.dart';

/// 지침 9.1. 시각은 UTC epoch ms, 내부 단위는 SI.
@DataClassName('RunRow')
class Runs extends Table {
  TextColumn get id => text()(); // UUID
  IntColumn get startedAt => integer()();
  /// 러닝 당시 시간대. 일별 기록은 이 시간대 기준 날짜로 묶는다 (지침 9.1, 11.3 자정·시간대)
  IntColumn get tzOffsetMin => integer()();
  IntColumn get endedAt => integer().nullable()();
  RealColumn get movingTimeSec => real().withDefault(const Constant(0))();
  RealColumn get distanceM => real().withDefault(const Constant(0))();
  RealColumn get avgSpeedMps => real().withDefault(const Constant(0))();
  RealColumn get avgCadenceSpm => real().nullable()();
  RealColumn get totalSteps => real().nullable()();
  TextColumn get status => textEnum<RunStatus>()();
  TextColumn get timerPresetId => text().nullable()();
  /// 마지막 스냅샷 시각 — 복구할 때 종료 시각으로 쓴다
  IntColumn get snapshotAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum RunStatus { recording, finished, recovered }

@DataClassName('TrackPointRow')
@TableIndex(name: 'track_run_ts', columns: {#runId, #ts})
class TrackPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get runId => text().references(Runs, #id, onDelete: KeyAction.cascade)();
  IntColumn get ts => integer()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get accuracyM => real()();
  RealColumn get speedMps => real().nullable()();
  RealColumn get altitudeM => real().nullable()();
  IntColumn get segmentIndex => integer()();
}

@DataClassName('SplitRow')
class Splits extends Table {
  TextColumn get runId => text().references(Runs, #id, onDelete: KeyAction.cascade)();
  IntColumn get index => integer()();
  RealColumn get distanceM => real()();
  RealColumn get durationSec => real()();
  RealColumn get avgCadenceSpm => real().nullable()();
  BoolColumn get isPartial => boolean()();

  @override
  Set<Column> get primaryKey => {runId, index};
}

@DataClassName('TimerPresetRow')
class TimerPresets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get repeatCount => integer().withDefault(const Constant(1))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TimerBlockRow')
class TimerBlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get presetId => text().references(TimerPresets, #id, onDelete: KeyAction.cascade)();
  IntColumn get order => integer()();
  IntColumn get repeatCount => integer().withDefault(const Constant(1))();
}

@DataClassName('TimerStepRow')
class TimerSteps extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get blockId => integer().references(TimerBlocks, #id, onDelete: KeyAction.cascade)();
  IntColumn get order => integer()();
  TextColumn get label => text()();
  IntColumn get durationSec => integer()();
  TextColumn get type => text()(); // run / walk / rest
  TextColumn get soundId => text().nullable()();
  BoolColumn get vibrate => boolean().withDefault(const Constant(true))();
  TextColumn get voiceText => text().nullable()();
}

@DriftDatabase(tables: [Runs, TrackPoints, Splits, TimerPresets, TimerBlocks, TimerSteps])
class AppDb extends _$AppDb {
  AppDb([QueryExecutor? e]) : super(e ?? driftDatabase(name: 'running'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // 일별 조회용 (지침 9.2)
          await customStatement('CREATE INDEX IF NOT EXISTS runs_started_at ON runs (started_at)');
        },
        beforeOpen: (_) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
