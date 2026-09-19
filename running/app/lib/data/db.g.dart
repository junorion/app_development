// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $RunsTable extends Runs with TableInfo<$RunsTable, RunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tzOffsetMinMeta = const VerificationMeta(
    'tzOffsetMin',
  );
  @override
  late final GeneratedColumn<int> tzOffsetMin = GeneratedColumn<int>(
    'tz_offset_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _movingTimeSecMeta = const VerificationMeta(
    'movingTimeSec',
  );
  @override
  late final GeneratedColumn<double> movingTimeSec = GeneratedColumn<double>(
    'moving_time_sec',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgSpeedMpsMeta = const VerificationMeta(
    'avgSpeedMps',
  );
  @override
  late final GeneratedColumn<double> avgSpeedMps = GeneratedColumn<double>(
    'avg_speed_mps',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgCadenceSpmMeta = const VerificationMeta(
    'avgCadenceSpm',
  );
  @override
  late final GeneratedColumn<double> avgCadenceSpm = GeneratedColumn<double>(
    'avg_cadence_spm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalStepsMeta = const VerificationMeta(
    'totalSteps',
  );
  @override
  late final GeneratedColumn<double> totalSteps = GeneratedColumn<double>(
    'total_steps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RunStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RunStatus>($RunsTable.$converterstatus);
  static const VerificationMeta _timerPresetIdMeta = const VerificationMeta(
    'timerPresetId',
  );
  @override
  late final GeneratedColumn<String> timerPresetId = GeneratedColumn<String>(
    'timer_preset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snapshotAtMeta = const VerificationMeta(
    'snapshotAt',
  );
  @override
  late final GeneratedColumn<int> snapshotAt = GeneratedColumn<int>(
    'snapshot_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    tzOffsetMin,
    endedAt,
    movingTimeSec,
    distanceM,
    avgSpeedMps,
    avgCadenceSpm,
    totalSteps,
    status,
    timerPresetId,
    snapshotAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('tz_offset_min')) {
      context.handle(
        _tzOffsetMinMeta,
        tzOffsetMin.isAcceptableOrUnknown(
          data['tz_offset_min']!,
          _tzOffsetMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tzOffsetMinMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('moving_time_sec')) {
      context.handle(
        _movingTimeSecMeta,
        movingTimeSec.isAcceptableOrUnknown(
          data['moving_time_sec']!,
          _movingTimeSecMeta,
        ),
      );
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    }
    if (data.containsKey('avg_speed_mps')) {
      context.handle(
        _avgSpeedMpsMeta,
        avgSpeedMps.isAcceptableOrUnknown(
          data['avg_speed_mps']!,
          _avgSpeedMpsMeta,
        ),
      );
    }
    if (data.containsKey('avg_cadence_spm')) {
      context.handle(
        _avgCadenceSpmMeta,
        avgCadenceSpm.isAcceptableOrUnknown(
          data['avg_cadence_spm']!,
          _avgCadenceSpmMeta,
        ),
      );
    }
    if (data.containsKey('total_steps')) {
      context.handle(
        _totalStepsMeta,
        totalSteps.isAcceptableOrUnknown(data['total_steps']!, _totalStepsMeta),
      );
    }
    if (data.containsKey('timer_preset_id')) {
      context.handle(
        _timerPresetIdMeta,
        timerPresetId.isAcceptableOrUnknown(
          data['timer_preset_id']!,
          _timerPresetIdMeta,
        ),
      );
    }
    if (data.containsKey('snapshot_at')) {
      context.handle(
        _snapshotAtMeta,
        snapshotAt.isAcceptableOrUnknown(data['snapshot_at']!, _snapshotAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      tzOffsetMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tz_offset_min'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      movingTimeSec: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}moving_time_sec'],
      )!,
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_m'],
      )!,
      avgSpeedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_speed_mps'],
      )!,
      avgCadenceSpm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_cadence_spm'],
      ),
      totalSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_steps'],
      ),
      status: $RunsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      timerPresetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timer_preset_id'],
      ),
      snapshotAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snapshot_at'],
      ),
    );
  }

  @override
  $RunsTable createAlias(String alias) {
    return $RunsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RunStatus, String, String> $converterstatus =
      const EnumNameConverter<RunStatus>(RunStatus.values);
}

class RunRow extends DataClass implements Insertable<RunRow> {
  final String id;
  final int startedAt;

  /// 러닝 당시 시간대. 일별 기록은 이 시간대 기준 날짜로 묶는다 (지침 9.1, 11.3 자정·시간대)
  final int tzOffsetMin;
  final int? endedAt;
  final double movingTimeSec;
  final double distanceM;
  final double avgSpeedMps;
  final double? avgCadenceSpm;
  final double? totalSteps;
  final RunStatus status;
  final String? timerPresetId;

  /// 마지막 스냅샷 시각 — 복구할 때 종료 시각으로 쓴다
  final int? snapshotAt;
  const RunRow({
    required this.id,
    required this.startedAt,
    required this.tzOffsetMin,
    this.endedAt,
    required this.movingTimeSec,
    required this.distanceM,
    required this.avgSpeedMps,
    this.avgCadenceSpm,
    this.totalSteps,
    required this.status,
    this.timerPresetId,
    this.snapshotAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<int>(startedAt);
    map['tz_offset_min'] = Variable<int>(tzOffsetMin);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    map['moving_time_sec'] = Variable<double>(movingTimeSec);
    map['distance_m'] = Variable<double>(distanceM);
    map['avg_speed_mps'] = Variable<double>(avgSpeedMps);
    if (!nullToAbsent || avgCadenceSpm != null) {
      map['avg_cadence_spm'] = Variable<double>(avgCadenceSpm);
    }
    if (!nullToAbsent || totalSteps != null) {
      map['total_steps'] = Variable<double>(totalSteps);
    }
    {
      map['status'] = Variable<String>(
        $RunsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || timerPresetId != null) {
      map['timer_preset_id'] = Variable<String>(timerPresetId);
    }
    if (!nullToAbsent || snapshotAt != null) {
      map['snapshot_at'] = Variable<int>(snapshotAt);
    }
    return map;
  }

  RunsCompanion toCompanion(bool nullToAbsent) {
    return RunsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      tzOffsetMin: Value(tzOffsetMin),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      movingTimeSec: Value(movingTimeSec),
      distanceM: Value(distanceM),
      avgSpeedMps: Value(avgSpeedMps),
      avgCadenceSpm: avgCadenceSpm == null && nullToAbsent
          ? const Value.absent()
          : Value(avgCadenceSpm),
      totalSteps: totalSteps == null && nullToAbsent
          ? const Value.absent()
          : Value(totalSteps),
      status: Value(status),
      timerPresetId: timerPresetId == null && nullToAbsent
          ? const Value.absent()
          : Value(timerPresetId),
      snapshotAt: snapshotAt == null && nullToAbsent
          ? const Value.absent()
          : Value(snapshotAt),
    );
  }

  factory RunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunRow(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      tzOffsetMin: serializer.fromJson<int>(json['tzOffsetMin']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      movingTimeSec: serializer.fromJson<double>(json['movingTimeSec']),
      distanceM: serializer.fromJson<double>(json['distanceM']),
      avgSpeedMps: serializer.fromJson<double>(json['avgSpeedMps']),
      avgCadenceSpm: serializer.fromJson<double?>(json['avgCadenceSpm']),
      totalSteps: serializer.fromJson<double?>(json['totalSteps']),
      status: $RunsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      timerPresetId: serializer.fromJson<String?>(json['timerPresetId']),
      snapshotAt: serializer.fromJson<int?>(json['snapshotAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<int>(startedAt),
      'tzOffsetMin': serializer.toJson<int>(tzOffsetMin),
      'endedAt': serializer.toJson<int?>(endedAt),
      'movingTimeSec': serializer.toJson<double>(movingTimeSec),
      'distanceM': serializer.toJson<double>(distanceM),
      'avgSpeedMps': serializer.toJson<double>(avgSpeedMps),
      'avgCadenceSpm': serializer.toJson<double?>(avgCadenceSpm),
      'totalSteps': serializer.toJson<double?>(totalSteps),
      'status': serializer.toJson<String>(
        $RunsTable.$converterstatus.toJson(status),
      ),
      'timerPresetId': serializer.toJson<String?>(timerPresetId),
      'snapshotAt': serializer.toJson<int?>(snapshotAt),
    };
  }

  RunRow copyWith({
    String? id,
    int? startedAt,
    int? tzOffsetMin,
    Value<int?> endedAt = const Value.absent(),
    double? movingTimeSec,
    double? distanceM,
    double? avgSpeedMps,
    Value<double?> avgCadenceSpm = const Value.absent(),
    Value<double?> totalSteps = const Value.absent(),
    RunStatus? status,
    Value<String?> timerPresetId = const Value.absent(),
    Value<int?> snapshotAt = const Value.absent(),
  }) => RunRow(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    tzOffsetMin: tzOffsetMin ?? this.tzOffsetMin,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    movingTimeSec: movingTimeSec ?? this.movingTimeSec,
    distanceM: distanceM ?? this.distanceM,
    avgSpeedMps: avgSpeedMps ?? this.avgSpeedMps,
    avgCadenceSpm: avgCadenceSpm.present
        ? avgCadenceSpm.value
        : this.avgCadenceSpm,
    totalSteps: totalSteps.present ? totalSteps.value : this.totalSteps,
    status: status ?? this.status,
    timerPresetId: timerPresetId.present
        ? timerPresetId.value
        : this.timerPresetId,
    snapshotAt: snapshotAt.present ? snapshotAt.value : this.snapshotAt,
  );
  RunRow copyWithCompanion(RunsCompanion data) {
    return RunRow(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      tzOffsetMin: data.tzOffsetMin.present
          ? data.tzOffsetMin.value
          : this.tzOffsetMin,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      movingTimeSec: data.movingTimeSec.present
          ? data.movingTimeSec.value
          : this.movingTimeSec,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      avgSpeedMps: data.avgSpeedMps.present
          ? data.avgSpeedMps.value
          : this.avgSpeedMps,
      avgCadenceSpm: data.avgCadenceSpm.present
          ? data.avgCadenceSpm.value
          : this.avgCadenceSpm,
      totalSteps: data.totalSteps.present
          ? data.totalSteps.value
          : this.totalSteps,
      status: data.status.present ? data.status.value : this.status,
      timerPresetId: data.timerPresetId.present
          ? data.timerPresetId.value
          : this.timerPresetId,
      snapshotAt: data.snapshotAt.present
          ? data.snapshotAt.value
          : this.snapshotAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunRow(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('tzOffsetMin: $tzOffsetMin, ')
          ..write('endedAt: $endedAt, ')
          ..write('movingTimeSec: $movingTimeSec, ')
          ..write('distanceM: $distanceM, ')
          ..write('avgSpeedMps: $avgSpeedMps, ')
          ..write('avgCadenceSpm: $avgCadenceSpm, ')
          ..write('totalSteps: $totalSteps, ')
          ..write('status: $status, ')
          ..write('timerPresetId: $timerPresetId, ')
          ..write('snapshotAt: $snapshotAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    tzOffsetMin,
    endedAt,
    movingTimeSec,
    distanceM,
    avgSpeedMps,
    avgCadenceSpm,
    totalSteps,
    status,
    timerPresetId,
    snapshotAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunRow &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.tzOffsetMin == this.tzOffsetMin &&
          other.endedAt == this.endedAt &&
          other.movingTimeSec == this.movingTimeSec &&
          other.distanceM == this.distanceM &&
          other.avgSpeedMps == this.avgSpeedMps &&
          other.avgCadenceSpm == this.avgCadenceSpm &&
          other.totalSteps == this.totalSteps &&
          other.status == this.status &&
          other.timerPresetId == this.timerPresetId &&
          other.snapshotAt == this.snapshotAt);
}

class RunsCompanion extends UpdateCompanion<RunRow> {
  final Value<String> id;
  final Value<int> startedAt;
  final Value<int> tzOffsetMin;
  final Value<int?> endedAt;
  final Value<double> movingTimeSec;
  final Value<double> distanceM;
  final Value<double> avgSpeedMps;
  final Value<double?> avgCadenceSpm;
  final Value<double?> totalSteps;
  final Value<RunStatus> status;
  final Value<String?> timerPresetId;
  final Value<int?> snapshotAt;
  final Value<int> rowid;
  const RunsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.tzOffsetMin = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.movingTimeSec = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.avgSpeedMps = const Value.absent(),
    this.avgCadenceSpm = const Value.absent(),
    this.totalSteps = const Value.absent(),
    this.status = const Value.absent(),
    this.timerPresetId = const Value.absent(),
    this.snapshotAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunsCompanion.insert({
    required String id,
    required int startedAt,
    required int tzOffsetMin,
    this.endedAt = const Value.absent(),
    this.movingTimeSec = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.avgSpeedMps = const Value.absent(),
    this.avgCadenceSpm = const Value.absent(),
    this.totalSteps = const Value.absent(),
    required RunStatus status,
    this.timerPresetId = const Value.absent(),
    this.snapshotAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       tzOffsetMin = Value(tzOffsetMin),
       status = Value(status);
  static Insertable<RunRow> custom({
    Expression<String>? id,
    Expression<int>? startedAt,
    Expression<int>? tzOffsetMin,
    Expression<int>? endedAt,
    Expression<double>? movingTimeSec,
    Expression<double>? distanceM,
    Expression<double>? avgSpeedMps,
    Expression<double>? avgCadenceSpm,
    Expression<double>? totalSteps,
    Expression<String>? status,
    Expression<String>? timerPresetId,
    Expression<int>? snapshotAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (tzOffsetMin != null) 'tz_offset_min': tzOffsetMin,
      if (endedAt != null) 'ended_at': endedAt,
      if (movingTimeSec != null) 'moving_time_sec': movingTimeSec,
      if (distanceM != null) 'distance_m': distanceM,
      if (avgSpeedMps != null) 'avg_speed_mps': avgSpeedMps,
      if (avgCadenceSpm != null) 'avg_cadence_spm': avgCadenceSpm,
      if (totalSteps != null) 'total_steps': totalSteps,
      if (status != null) 'status': status,
      if (timerPresetId != null) 'timer_preset_id': timerPresetId,
      if (snapshotAt != null) 'snapshot_at': snapshotAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunsCompanion copyWith({
    Value<String>? id,
    Value<int>? startedAt,
    Value<int>? tzOffsetMin,
    Value<int?>? endedAt,
    Value<double>? movingTimeSec,
    Value<double>? distanceM,
    Value<double>? avgSpeedMps,
    Value<double?>? avgCadenceSpm,
    Value<double?>? totalSteps,
    Value<RunStatus>? status,
    Value<String?>? timerPresetId,
    Value<int?>? snapshotAt,
    Value<int>? rowid,
  }) {
    return RunsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      tzOffsetMin: tzOffsetMin ?? this.tzOffsetMin,
      endedAt: endedAt ?? this.endedAt,
      movingTimeSec: movingTimeSec ?? this.movingTimeSec,
      distanceM: distanceM ?? this.distanceM,
      avgSpeedMps: avgSpeedMps ?? this.avgSpeedMps,
      avgCadenceSpm: avgCadenceSpm ?? this.avgCadenceSpm,
      totalSteps: totalSteps ?? this.totalSteps,
      status: status ?? this.status,
      timerPresetId: timerPresetId ?? this.timerPresetId,
      snapshotAt: snapshotAt ?? this.snapshotAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (tzOffsetMin.present) {
      map['tz_offset_min'] = Variable<int>(tzOffsetMin.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (movingTimeSec.present) {
      map['moving_time_sec'] = Variable<double>(movingTimeSec.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (avgSpeedMps.present) {
      map['avg_speed_mps'] = Variable<double>(avgSpeedMps.value);
    }
    if (avgCadenceSpm.present) {
      map['avg_cadence_spm'] = Variable<double>(avgCadenceSpm.value);
    }
    if (totalSteps.present) {
      map['total_steps'] = Variable<double>(totalSteps.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $RunsTable.$converterstatus.toSql(status.value),
      );
    }
    if (timerPresetId.present) {
      map['timer_preset_id'] = Variable<String>(timerPresetId.value);
    }
    if (snapshotAt.present) {
      map['snapshot_at'] = Variable<int>(snapshotAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('tzOffsetMin: $tzOffsetMin, ')
          ..write('endedAt: $endedAt, ')
          ..write('movingTimeSec: $movingTimeSec, ')
          ..write('distanceM: $distanceM, ')
          ..write('avgSpeedMps: $avgSpeedMps, ')
          ..write('avgCadenceSpm: $avgCadenceSpm, ')
          ..write('totalSteps: $totalSteps, ')
          ..write('status: $status, ')
          ..write('timerPresetId: $timerPresetId, ')
          ..write('snapshotAt: $snapshotAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackPointsTable extends TrackPoints
    with TableInfo<$TrackPointsTable, TrackPointRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES runs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speedMpsMeta = const VerificationMeta(
    'speedMps',
  );
  @override
  late final GeneratedColumn<double> speedMps = GeneratedColumn<double>(
    'speed_mps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altitudeMMeta = const VerificationMeta(
    'altitudeM',
  );
  @override
  late final GeneratedColumn<double> altitudeM = GeneratedColumn<double>(
    'altitude_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _segmentIndexMeta = const VerificationMeta(
    'segmentIndex',
  );
  @override
  late final GeneratedColumn<int> segmentIndex = GeneratedColumn<int>(
    'segment_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    runId,
    ts,
    lat,
    lng,
    accuracyM,
    speedMps,
    altitudeM,
    segmentIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackPointRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMMeta);
    }
    if (data.containsKey('speed_mps')) {
      context.handle(
        _speedMpsMeta,
        speedMps.isAcceptableOrUnknown(data['speed_mps']!, _speedMpsMeta),
      );
    }
    if (data.containsKey('altitude_m')) {
      context.handle(
        _altitudeMMeta,
        altitudeM.isAcceptableOrUnknown(data['altitude_m']!, _altitudeMMeta),
      );
    }
    if (data.containsKey('segment_index')) {
      context.handle(
        _segmentIndexMeta,
        segmentIndex.isAcceptableOrUnknown(
          data['segment_index']!,
          _segmentIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_segmentIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackPointRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackPointRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      )!,
      ts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_m'],
      )!,
      speedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_mps'],
      ),
      altitudeM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude_m'],
      ),
      segmentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segment_index'],
      )!,
    );
  }

  @override
  $TrackPointsTable createAlias(String alias) {
    return $TrackPointsTable(attachedDatabase, alias);
  }
}

class TrackPointRow extends DataClass implements Insertable<TrackPointRow> {
  final int id;
  final String runId;
  final int ts;
  final double lat;
  final double lng;
  final double accuracyM;
  final double? speedMps;
  final double? altitudeM;
  final int segmentIndex;
  const TrackPointRow({
    required this.id,
    required this.runId,
    required this.ts,
    required this.lat,
    required this.lng,
    required this.accuracyM,
    this.speedMps,
    this.altitudeM,
    required this.segmentIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['run_id'] = Variable<String>(runId);
    map['ts'] = Variable<int>(ts);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['accuracy_m'] = Variable<double>(accuracyM);
    if (!nullToAbsent || speedMps != null) {
      map['speed_mps'] = Variable<double>(speedMps);
    }
    if (!nullToAbsent || altitudeM != null) {
      map['altitude_m'] = Variable<double>(altitudeM);
    }
    map['segment_index'] = Variable<int>(segmentIndex);
    return map;
  }

  TrackPointsCompanion toCompanion(bool nullToAbsent) {
    return TrackPointsCompanion(
      id: Value(id),
      runId: Value(runId),
      ts: Value(ts),
      lat: Value(lat),
      lng: Value(lng),
      accuracyM: Value(accuracyM),
      speedMps: speedMps == null && nullToAbsent
          ? const Value.absent()
          : Value(speedMps),
      altitudeM: altitudeM == null && nullToAbsent
          ? const Value.absent()
          : Value(altitudeM),
      segmentIndex: Value(segmentIndex),
    );
  }

  factory TrackPointRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackPointRow(
      id: serializer.fromJson<int>(json['id']),
      runId: serializer.fromJson<String>(json['runId']),
      ts: serializer.fromJson<int>(json['ts']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      accuracyM: serializer.fromJson<double>(json['accuracyM']),
      speedMps: serializer.fromJson<double?>(json['speedMps']),
      altitudeM: serializer.fromJson<double?>(json['altitudeM']),
      segmentIndex: serializer.fromJson<int>(json['segmentIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'runId': serializer.toJson<String>(runId),
      'ts': serializer.toJson<int>(ts),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'accuracyM': serializer.toJson<double>(accuracyM),
      'speedMps': serializer.toJson<double?>(speedMps),
      'altitudeM': serializer.toJson<double?>(altitudeM),
      'segmentIndex': serializer.toJson<int>(segmentIndex),
    };
  }

  TrackPointRow copyWith({
    int? id,
    String? runId,
    int? ts,
    double? lat,
    double? lng,
    double? accuracyM,
    Value<double?> speedMps = const Value.absent(),
    Value<double?> altitudeM = const Value.absent(),
    int? segmentIndex,
  }) => TrackPointRow(
    id: id ?? this.id,
    runId: runId ?? this.runId,
    ts: ts ?? this.ts,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    accuracyM: accuracyM ?? this.accuracyM,
    speedMps: speedMps.present ? speedMps.value : this.speedMps,
    altitudeM: altitudeM.present ? altitudeM.value : this.altitudeM,
    segmentIndex: segmentIndex ?? this.segmentIndex,
  );
  TrackPointRow copyWithCompanion(TrackPointsCompanion data) {
    return TrackPointRow(
      id: data.id.present ? data.id.value : this.id,
      runId: data.runId.present ? data.runId.value : this.runId,
      ts: data.ts.present ? data.ts.value : this.ts,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      speedMps: data.speedMps.present ? data.speedMps.value : this.speedMps,
      altitudeM: data.altitudeM.present ? data.altitudeM.value : this.altitudeM,
      segmentIndex: data.segmentIndex.present
          ? data.segmentIndex.value
          : this.segmentIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackPointRow(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('ts: $ts, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('speedMps: $speedMps, ')
          ..write('altitudeM: $altitudeM, ')
          ..write('segmentIndex: $segmentIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    runId,
    ts,
    lat,
    lng,
    accuracyM,
    speedMps,
    altitudeM,
    segmentIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackPointRow &&
          other.id == this.id &&
          other.runId == this.runId &&
          other.ts == this.ts &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.accuracyM == this.accuracyM &&
          other.speedMps == this.speedMps &&
          other.altitudeM == this.altitudeM &&
          other.segmentIndex == this.segmentIndex);
}

class TrackPointsCompanion extends UpdateCompanion<TrackPointRow> {
  final Value<int> id;
  final Value<String> runId;
  final Value<int> ts;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double> accuracyM;
  final Value<double?> speedMps;
  final Value<double?> altitudeM;
  final Value<int> segmentIndex;
  const TrackPointsCompanion({
    this.id = const Value.absent(),
    this.runId = const Value.absent(),
    this.ts = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.speedMps = const Value.absent(),
    this.altitudeM = const Value.absent(),
    this.segmentIndex = const Value.absent(),
  });
  TrackPointsCompanion.insert({
    this.id = const Value.absent(),
    required String runId,
    required int ts,
    required double lat,
    required double lng,
    required double accuracyM,
    this.speedMps = const Value.absent(),
    this.altitudeM = const Value.absent(),
    required int segmentIndex,
  }) : runId = Value(runId),
       ts = Value(ts),
       lat = Value(lat),
       lng = Value(lng),
       accuracyM = Value(accuracyM),
       segmentIndex = Value(segmentIndex);
  static Insertable<TrackPointRow> custom({
    Expression<int>? id,
    Expression<String>? runId,
    Expression<int>? ts,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? accuracyM,
    Expression<double>? speedMps,
    Expression<double>? altitudeM,
    Expression<int>? segmentIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runId != null) 'run_id': runId,
      if (ts != null) 'ts': ts,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (speedMps != null) 'speed_mps': speedMps,
      if (altitudeM != null) 'altitude_m': altitudeM,
      if (segmentIndex != null) 'segment_index': segmentIndex,
    });
  }

  TrackPointsCompanion copyWith({
    Value<int>? id,
    Value<String>? runId,
    Value<int>? ts,
    Value<double>? lat,
    Value<double>? lng,
    Value<double>? accuracyM,
    Value<double?>? speedMps,
    Value<double?>? altitudeM,
    Value<int>? segmentIndex,
  }) {
    return TrackPointsCompanion(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      ts: ts ?? this.ts,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracyM: accuracyM ?? this.accuracyM,
      speedMps: speedMps ?? this.speedMps,
      altitudeM: altitudeM ?? this.altitudeM,
      segmentIndex: segmentIndex ?? this.segmentIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (speedMps.present) {
      map['speed_mps'] = Variable<double>(speedMps.value);
    }
    if (altitudeM.present) {
      map['altitude_m'] = Variable<double>(altitudeM.value);
    }
    if (segmentIndex.present) {
      map['segment_index'] = Variable<int>(segmentIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackPointsCompanion(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('ts: $ts, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('speedMps: $speedMps, ')
          ..write('altitudeM: $altitudeM, ')
          ..write('segmentIndex: $segmentIndex')
          ..write(')'))
        .toString();
  }
}

class $SplitsTable extends Splits with TableInfo<$SplitsTable, SplitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SplitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES runs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _indexMeta = const VerificationMeta('index');
  @override
  late final GeneratedColumn<int> index = GeneratedColumn<int>(
    'index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<double> durationSec = GeneratedColumn<double>(
    'duration_sec',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgCadenceSpmMeta = const VerificationMeta(
    'avgCadenceSpm',
  );
  @override
  late final GeneratedColumn<double> avgCadenceSpm = GeneratedColumn<double>(
    'avg_cadence_spm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPartialMeta = const VerificationMeta(
    'isPartial',
  );
  @override
  late final GeneratedColumn<bool> isPartial = GeneratedColumn<bool>(
    'is_partial',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_partial" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    runId,
    index,
    distanceM,
    durationSec,
    avgCadenceSpm,
    isPartial,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'splits';
  @override
  VerificationContext validateIntegrity(
    Insertable<SplitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('index')) {
      context.handle(
        _indexMeta,
        index.isAcceptableOrUnknown(data['index']!, _indexMeta),
      );
    } else if (isInserting) {
      context.missing(_indexMeta);
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    } else if (isInserting) {
      context.missing(_distanceMMeta);
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecMeta);
    }
    if (data.containsKey('avg_cadence_spm')) {
      context.handle(
        _avgCadenceSpmMeta,
        avgCadenceSpm.isAcceptableOrUnknown(
          data['avg_cadence_spm']!,
          _avgCadenceSpmMeta,
        ),
      );
    }
    if (data.containsKey('is_partial')) {
      context.handle(
        _isPartialMeta,
        isPartial.isAcceptableOrUnknown(data['is_partial']!, _isPartialMeta),
      );
    } else if (isInserting) {
      context.missing(_isPartialMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {runId, index};
  @override
  SplitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SplitRow(
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      )!,
      index: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}index'],
      )!,
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_m'],
      )!,
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}duration_sec'],
      )!,
      avgCadenceSpm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_cadence_spm'],
      ),
      isPartial: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_partial'],
      )!,
    );
  }

  @override
  $SplitsTable createAlias(String alias) {
    return $SplitsTable(attachedDatabase, alias);
  }
}

class SplitRow extends DataClass implements Insertable<SplitRow> {
  final String runId;
  final int index;
  final double distanceM;
  final double durationSec;
  final double? avgCadenceSpm;
  final bool isPartial;
  const SplitRow({
    required this.runId,
    required this.index,
    required this.distanceM,
    required this.durationSec,
    this.avgCadenceSpm,
    required this.isPartial,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['run_id'] = Variable<String>(runId);
    map['index'] = Variable<int>(index);
    map['distance_m'] = Variable<double>(distanceM);
    map['duration_sec'] = Variable<double>(durationSec);
    if (!nullToAbsent || avgCadenceSpm != null) {
      map['avg_cadence_spm'] = Variable<double>(avgCadenceSpm);
    }
    map['is_partial'] = Variable<bool>(isPartial);
    return map;
  }

  SplitsCompanion toCompanion(bool nullToAbsent) {
    return SplitsCompanion(
      runId: Value(runId),
      index: Value(index),
      distanceM: Value(distanceM),
      durationSec: Value(durationSec),
      avgCadenceSpm: avgCadenceSpm == null && nullToAbsent
          ? const Value.absent()
          : Value(avgCadenceSpm),
      isPartial: Value(isPartial),
    );
  }

  factory SplitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SplitRow(
      runId: serializer.fromJson<String>(json['runId']),
      index: serializer.fromJson<int>(json['index']),
      distanceM: serializer.fromJson<double>(json['distanceM']),
      durationSec: serializer.fromJson<double>(json['durationSec']),
      avgCadenceSpm: serializer.fromJson<double?>(json['avgCadenceSpm']),
      isPartial: serializer.fromJson<bool>(json['isPartial']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'runId': serializer.toJson<String>(runId),
      'index': serializer.toJson<int>(index),
      'distanceM': serializer.toJson<double>(distanceM),
      'durationSec': serializer.toJson<double>(durationSec),
      'avgCadenceSpm': serializer.toJson<double?>(avgCadenceSpm),
      'isPartial': serializer.toJson<bool>(isPartial),
    };
  }

  SplitRow copyWith({
    String? runId,
    int? index,
    double? distanceM,
    double? durationSec,
    Value<double?> avgCadenceSpm = const Value.absent(),
    bool? isPartial,
  }) => SplitRow(
    runId: runId ?? this.runId,
    index: index ?? this.index,
    distanceM: distanceM ?? this.distanceM,
    durationSec: durationSec ?? this.durationSec,
    avgCadenceSpm: avgCadenceSpm.present
        ? avgCadenceSpm.value
        : this.avgCadenceSpm,
    isPartial: isPartial ?? this.isPartial,
  );
  SplitRow copyWithCompanion(SplitsCompanion data) {
    return SplitRow(
      runId: data.runId.present ? data.runId.value : this.runId,
      index: data.index.present ? data.index.value : this.index,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
      avgCadenceSpm: data.avgCadenceSpm.present
          ? data.avgCadenceSpm.value
          : this.avgCadenceSpm,
      isPartial: data.isPartial.present ? data.isPartial.value : this.isPartial,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SplitRow(')
          ..write('runId: $runId, ')
          ..write('index: $index, ')
          ..write('distanceM: $distanceM, ')
          ..write('durationSec: $durationSec, ')
          ..write('avgCadenceSpm: $avgCadenceSpm, ')
          ..write('isPartial: $isPartial')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    runId,
    index,
    distanceM,
    durationSec,
    avgCadenceSpm,
    isPartial,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SplitRow &&
          other.runId == this.runId &&
          other.index == this.index &&
          other.distanceM == this.distanceM &&
          other.durationSec == this.durationSec &&
          other.avgCadenceSpm == this.avgCadenceSpm &&
          other.isPartial == this.isPartial);
}

class SplitsCompanion extends UpdateCompanion<SplitRow> {
  final Value<String> runId;
  final Value<int> index;
  final Value<double> distanceM;
  final Value<double> durationSec;
  final Value<double?> avgCadenceSpm;
  final Value<bool> isPartial;
  final Value<int> rowid;
  const SplitsCompanion({
    this.runId = const Value.absent(),
    this.index = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.avgCadenceSpm = const Value.absent(),
    this.isPartial = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SplitsCompanion.insert({
    required String runId,
    required int index,
    required double distanceM,
    required double durationSec,
    this.avgCadenceSpm = const Value.absent(),
    required bool isPartial,
    this.rowid = const Value.absent(),
  }) : runId = Value(runId),
       index = Value(index),
       distanceM = Value(distanceM),
       durationSec = Value(durationSec),
       isPartial = Value(isPartial);
  static Insertable<SplitRow> custom({
    Expression<String>? runId,
    Expression<int>? index,
    Expression<double>? distanceM,
    Expression<double>? durationSec,
    Expression<double>? avgCadenceSpm,
    Expression<bool>? isPartial,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (runId != null) 'run_id': runId,
      if (index != null) 'index': index,
      if (distanceM != null) 'distance_m': distanceM,
      if (durationSec != null) 'duration_sec': durationSec,
      if (avgCadenceSpm != null) 'avg_cadence_spm': avgCadenceSpm,
      if (isPartial != null) 'is_partial': isPartial,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SplitsCompanion copyWith({
    Value<String>? runId,
    Value<int>? index,
    Value<double>? distanceM,
    Value<double>? durationSec,
    Value<double?>? avgCadenceSpm,
    Value<bool>? isPartial,
    Value<int>? rowid,
  }) {
    return SplitsCompanion(
      runId: runId ?? this.runId,
      index: index ?? this.index,
      distanceM: distanceM ?? this.distanceM,
      durationSec: durationSec ?? this.durationSec,
      avgCadenceSpm: avgCadenceSpm ?? this.avgCadenceSpm,
      isPartial: isPartial ?? this.isPartial,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (index.present) {
      map['index'] = Variable<int>(index.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<double>(durationSec.value);
    }
    if (avgCadenceSpm.present) {
      map['avg_cadence_spm'] = Variable<double>(avgCadenceSpm.value);
    }
    if (isPartial.present) {
      map['is_partial'] = Variable<bool>(isPartial.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SplitsCompanion(')
          ..write('runId: $runId, ')
          ..write('index: $index, ')
          ..write('distanceM: $distanceM, ')
          ..write('durationSec: $durationSec, ')
          ..write('avgCadenceSpm: $avgCadenceSpm, ')
          ..write('isPartial: $isPartial, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimerPresetsTable extends TimerPresets
    with TableInfo<$TimerPresetsTable, TimerPresetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimerPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatCountMeta = const VerificationMeta(
    'repeatCount',
  );
  @override
  late final GeneratedColumn<int> repeatCount = GeneratedColumn<int>(
    'repeat_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, repeatCount, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timer_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerPresetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('repeat_count')) {
      context.handle(
        _repeatCountMeta,
        repeatCount.isAcceptableOrUnknown(
          data['repeat_count']!,
          _repeatCountMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimerPresetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerPresetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      repeatCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TimerPresetsTable createAlias(String alias) {
    return $TimerPresetsTable(attachedDatabase, alias);
  }
}

class TimerPresetRow extends DataClass implements Insertable<TimerPresetRow> {
  final String id;
  final String name;
  final int repeatCount;
  final int updatedAt;
  const TimerPresetRow({
    required this.id,
    required this.name,
    required this.repeatCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['repeat_count'] = Variable<int>(repeatCount);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TimerPresetsCompanion toCompanion(bool nullToAbsent) {
    return TimerPresetsCompanion(
      id: Value(id),
      name: Value(name),
      repeatCount: Value(repeatCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory TimerPresetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerPresetRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      repeatCount: serializer.fromJson<int>(json['repeatCount']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'repeatCount': serializer.toJson<int>(repeatCount),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TimerPresetRow copyWith({
    String? id,
    String? name,
    int? repeatCount,
    int? updatedAt,
  }) => TimerPresetRow(
    id: id ?? this.id,
    name: name ?? this.name,
    repeatCount: repeatCount ?? this.repeatCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TimerPresetRow copyWithCompanion(TimerPresetsCompanion data) {
    return TimerPresetRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      repeatCount: data.repeatCount.present
          ? data.repeatCount.value
          : this.repeatCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerPresetRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('repeatCount: $repeatCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, repeatCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerPresetRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.repeatCount == this.repeatCount &&
          other.updatedAt == this.updatedAt);
}

class TimerPresetsCompanion extends UpdateCompanion<TimerPresetRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> repeatCount;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TimerPresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.repeatCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimerPresetsCompanion.insert({
    required String id,
    required String name,
    this.repeatCount = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<TimerPresetRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? repeatCount,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (repeatCount != null) 'repeat_count': repeatCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimerPresetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? repeatCount,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TimerPresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      repeatCount: repeatCount ?? this.repeatCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (repeatCount.present) {
      map['repeat_count'] = Variable<int>(repeatCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimerPresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('repeatCount: $repeatCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimerBlocksTable extends TimerBlocks
    with TableInfo<$TimerBlocksTable, TimerBlockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimerBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<String> presetId = GeneratedColumn<String>(
    'preset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES timer_presets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatCountMeta = const VerificationMeta(
    'repeatCount',
  );
  @override
  late final GeneratedColumn<int> repeatCount = GeneratedColumn<int>(
    'repeat_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [id, presetId, order, repeatCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timer_blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerBlockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_presetIdMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('repeat_count')) {
      context.handle(
        _repeatCountMeta,
        repeatCount.isAcceptableOrUnknown(
          data['repeat_count']!,
          _repeatCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimerBlockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerBlockRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_id'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      repeatCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_count'],
      )!,
    );
  }

  @override
  $TimerBlocksTable createAlias(String alias) {
    return $TimerBlocksTable(attachedDatabase, alias);
  }
}

class TimerBlockRow extends DataClass implements Insertable<TimerBlockRow> {
  final int id;
  final String presetId;
  final int order;
  final int repeatCount;
  const TimerBlockRow({
    required this.id,
    required this.presetId,
    required this.order,
    required this.repeatCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['preset_id'] = Variable<String>(presetId);
    map['order'] = Variable<int>(order);
    map['repeat_count'] = Variable<int>(repeatCount);
    return map;
  }

  TimerBlocksCompanion toCompanion(bool nullToAbsent) {
    return TimerBlocksCompanion(
      id: Value(id),
      presetId: Value(presetId),
      order: Value(order),
      repeatCount: Value(repeatCount),
    );
  }

  factory TimerBlockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerBlockRow(
      id: serializer.fromJson<int>(json['id']),
      presetId: serializer.fromJson<String>(json['presetId']),
      order: serializer.fromJson<int>(json['order']),
      repeatCount: serializer.fromJson<int>(json['repeatCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'presetId': serializer.toJson<String>(presetId),
      'order': serializer.toJson<int>(order),
      'repeatCount': serializer.toJson<int>(repeatCount),
    };
  }

  TimerBlockRow copyWith({
    int? id,
    String? presetId,
    int? order,
    int? repeatCount,
  }) => TimerBlockRow(
    id: id ?? this.id,
    presetId: presetId ?? this.presetId,
    order: order ?? this.order,
    repeatCount: repeatCount ?? this.repeatCount,
  );
  TimerBlockRow copyWithCompanion(TimerBlocksCompanion data) {
    return TimerBlockRow(
      id: data.id.present ? data.id.value : this.id,
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      order: data.order.present ? data.order.value : this.order,
      repeatCount: data.repeatCount.present
          ? data.repeatCount.value
          : this.repeatCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerBlockRow(')
          ..write('id: $id, ')
          ..write('presetId: $presetId, ')
          ..write('order: $order, ')
          ..write('repeatCount: $repeatCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, presetId, order, repeatCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerBlockRow &&
          other.id == this.id &&
          other.presetId == this.presetId &&
          other.order == this.order &&
          other.repeatCount == this.repeatCount);
}

class TimerBlocksCompanion extends UpdateCompanion<TimerBlockRow> {
  final Value<int> id;
  final Value<String> presetId;
  final Value<int> order;
  final Value<int> repeatCount;
  const TimerBlocksCompanion({
    this.id = const Value.absent(),
    this.presetId = const Value.absent(),
    this.order = const Value.absent(),
    this.repeatCount = const Value.absent(),
  });
  TimerBlocksCompanion.insert({
    this.id = const Value.absent(),
    required String presetId,
    required int order,
    this.repeatCount = const Value.absent(),
  }) : presetId = Value(presetId),
       order = Value(order);
  static Insertable<TimerBlockRow> custom({
    Expression<int>? id,
    Expression<String>? presetId,
    Expression<int>? order,
    Expression<int>? repeatCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (presetId != null) 'preset_id': presetId,
      if (order != null) 'order': order,
      if (repeatCount != null) 'repeat_count': repeatCount,
    });
  }

  TimerBlocksCompanion copyWith({
    Value<int>? id,
    Value<String>? presetId,
    Value<int>? order,
    Value<int>? repeatCount,
  }) {
    return TimerBlocksCompanion(
      id: id ?? this.id,
      presetId: presetId ?? this.presetId,
      order: order ?? this.order,
      repeatCount: repeatCount ?? this.repeatCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (presetId.present) {
      map['preset_id'] = Variable<String>(presetId.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (repeatCount.present) {
      map['repeat_count'] = Variable<int>(repeatCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimerBlocksCompanion(')
          ..write('id: $id, ')
          ..write('presetId: $presetId, ')
          ..write('order: $order, ')
          ..write('repeatCount: $repeatCount')
          ..write(')'))
        .toString();
  }
}

class $TimerStepsTable extends TimerSteps
    with TableInfo<$TimerStepsTable, TimerStepRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimerStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _blockIdMeta = const VerificationMeta(
    'blockId',
  );
  @override
  late final GeneratedColumn<int> blockId = GeneratedColumn<int>(
    'block_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES timer_blocks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soundIdMeta = const VerificationMeta(
    'soundId',
  );
  @override
  late final GeneratedColumn<String> soundId = GeneratedColumn<String>(
    'sound_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vibrateMeta = const VerificationMeta(
    'vibrate',
  );
  @override
  late final GeneratedColumn<bool> vibrate = GeneratedColumn<bool>(
    'vibrate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibrate" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _voiceTextMeta = const VerificationMeta(
    'voiceText',
  );
  @override
  late final GeneratedColumn<String> voiceText = GeneratedColumn<String>(
    'voice_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    blockId,
    order,
    label,
    durationSec,
    type,
    soundId,
    vibrate,
    voiceText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timer_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerStepRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('block_id')) {
      context.handle(
        _blockIdMeta,
        blockId.isAcceptableOrUnknown(data['block_id']!, _blockIdMeta),
      );
    } else if (isInserting) {
      context.missing(_blockIdMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('sound_id')) {
      context.handle(
        _soundIdMeta,
        soundId.isAcceptableOrUnknown(data['sound_id']!, _soundIdMeta),
      );
    }
    if (data.containsKey('vibrate')) {
      context.handle(
        _vibrateMeta,
        vibrate.isAcceptableOrUnknown(data['vibrate']!, _vibrateMeta),
      );
    }
    if (data.containsKey('voice_text')) {
      context.handle(
        _voiceTextMeta,
        voiceText.isAcceptableOrUnknown(data['voice_text']!, _voiceTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimerStepRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerStepRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      blockId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}block_id'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      soundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound_id'],
      ),
      vibrate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibrate'],
      )!,
      voiceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_text'],
      ),
    );
  }

  @override
  $TimerStepsTable createAlias(String alias) {
    return $TimerStepsTable(attachedDatabase, alias);
  }
}

class TimerStepRow extends DataClass implements Insertable<TimerStepRow> {
  final int id;
  final int blockId;
  final int order;
  final String label;
  final int durationSec;
  final String type;
  final String? soundId;
  final bool vibrate;
  final String? voiceText;
  const TimerStepRow({
    required this.id,
    required this.blockId,
    required this.order,
    required this.label,
    required this.durationSec,
    required this.type,
    this.soundId,
    required this.vibrate,
    this.voiceText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['block_id'] = Variable<int>(blockId);
    map['order'] = Variable<int>(order);
    map['label'] = Variable<String>(label);
    map['duration_sec'] = Variable<int>(durationSec);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || soundId != null) {
      map['sound_id'] = Variable<String>(soundId);
    }
    map['vibrate'] = Variable<bool>(vibrate);
    if (!nullToAbsent || voiceText != null) {
      map['voice_text'] = Variable<String>(voiceText);
    }
    return map;
  }

  TimerStepsCompanion toCompanion(bool nullToAbsent) {
    return TimerStepsCompanion(
      id: Value(id),
      blockId: Value(blockId),
      order: Value(order),
      label: Value(label),
      durationSec: Value(durationSec),
      type: Value(type),
      soundId: soundId == null && nullToAbsent
          ? const Value.absent()
          : Value(soundId),
      vibrate: Value(vibrate),
      voiceText: voiceText == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceText),
    );
  }

  factory TimerStepRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerStepRow(
      id: serializer.fromJson<int>(json['id']),
      blockId: serializer.fromJson<int>(json['blockId']),
      order: serializer.fromJson<int>(json['order']),
      label: serializer.fromJson<String>(json['label']),
      durationSec: serializer.fromJson<int>(json['durationSec']),
      type: serializer.fromJson<String>(json['type']),
      soundId: serializer.fromJson<String?>(json['soundId']),
      vibrate: serializer.fromJson<bool>(json['vibrate']),
      voiceText: serializer.fromJson<String?>(json['voiceText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'blockId': serializer.toJson<int>(blockId),
      'order': serializer.toJson<int>(order),
      'label': serializer.toJson<String>(label),
      'durationSec': serializer.toJson<int>(durationSec),
      'type': serializer.toJson<String>(type),
      'soundId': serializer.toJson<String?>(soundId),
      'vibrate': serializer.toJson<bool>(vibrate),
      'voiceText': serializer.toJson<String?>(voiceText),
    };
  }

  TimerStepRow copyWith({
    int? id,
    int? blockId,
    int? order,
    String? label,
    int? durationSec,
    String? type,
    Value<String?> soundId = const Value.absent(),
    bool? vibrate,
    Value<String?> voiceText = const Value.absent(),
  }) => TimerStepRow(
    id: id ?? this.id,
    blockId: blockId ?? this.blockId,
    order: order ?? this.order,
    label: label ?? this.label,
    durationSec: durationSec ?? this.durationSec,
    type: type ?? this.type,
    soundId: soundId.present ? soundId.value : this.soundId,
    vibrate: vibrate ?? this.vibrate,
    voiceText: voiceText.present ? voiceText.value : this.voiceText,
  );
  TimerStepRow copyWithCompanion(TimerStepsCompanion data) {
    return TimerStepRow(
      id: data.id.present ? data.id.value : this.id,
      blockId: data.blockId.present ? data.blockId.value : this.blockId,
      order: data.order.present ? data.order.value : this.order,
      label: data.label.present ? data.label.value : this.label,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
      type: data.type.present ? data.type.value : this.type,
      soundId: data.soundId.present ? data.soundId.value : this.soundId,
      vibrate: data.vibrate.present ? data.vibrate.value : this.vibrate,
      voiceText: data.voiceText.present ? data.voiceText.value : this.voiceText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerStepRow(')
          ..write('id: $id, ')
          ..write('blockId: $blockId, ')
          ..write('order: $order, ')
          ..write('label: $label, ')
          ..write('durationSec: $durationSec, ')
          ..write('type: $type, ')
          ..write('soundId: $soundId, ')
          ..write('vibrate: $vibrate, ')
          ..write('voiceText: $voiceText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    blockId,
    order,
    label,
    durationSec,
    type,
    soundId,
    vibrate,
    voiceText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerStepRow &&
          other.id == this.id &&
          other.blockId == this.blockId &&
          other.order == this.order &&
          other.label == this.label &&
          other.durationSec == this.durationSec &&
          other.type == this.type &&
          other.soundId == this.soundId &&
          other.vibrate == this.vibrate &&
          other.voiceText == this.voiceText);
}

class TimerStepsCompanion extends UpdateCompanion<TimerStepRow> {
  final Value<int> id;
  final Value<int> blockId;
  final Value<int> order;
  final Value<String> label;
  final Value<int> durationSec;
  final Value<String> type;
  final Value<String?> soundId;
  final Value<bool> vibrate;
  final Value<String?> voiceText;
  const TimerStepsCompanion({
    this.id = const Value.absent(),
    this.blockId = const Value.absent(),
    this.order = const Value.absent(),
    this.label = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.type = const Value.absent(),
    this.soundId = const Value.absent(),
    this.vibrate = const Value.absent(),
    this.voiceText = const Value.absent(),
  });
  TimerStepsCompanion.insert({
    this.id = const Value.absent(),
    required int blockId,
    required int order,
    required String label,
    required int durationSec,
    required String type,
    this.soundId = const Value.absent(),
    this.vibrate = const Value.absent(),
    this.voiceText = const Value.absent(),
  }) : blockId = Value(blockId),
       order = Value(order),
       label = Value(label),
       durationSec = Value(durationSec),
       type = Value(type);
  static Insertable<TimerStepRow> custom({
    Expression<int>? id,
    Expression<int>? blockId,
    Expression<int>? order,
    Expression<String>? label,
    Expression<int>? durationSec,
    Expression<String>? type,
    Expression<String>? soundId,
    Expression<bool>? vibrate,
    Expression<String>? voiceText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (blockId != null) 'block_id': blockId,
      if (order != null) 'order': order,
      if (label != null) 'label': label,
      if (durationSec != null) 'duration_sec': durationSec,
      if (type != null) 'type': type,
      if (soundId != null) 'sound_id': soundId,
      if (vibrate != null) 'vibrate': vibrate,
      if (voiceText != null) 'voice_text': voiceText,
    });
  }

  TimerStepsCompanion copyWith({
    Value<int>? id,
    Value<int>? blockId,
    Value<int>? order,
    Value<String>? label,
    Value<int>? durationSec,
    Value<String>? type,
    Value<String?>? soundId,
    Value<bool>? vibrate,
    Value<String?>? voiceText,
  }) {
    return TimerStepsCompanion(
      id: id ?? this.id,
      blockId: blockId ?? this.blockId,
      order: order ?? this.order,
      label: label ?? this.label,
      durationSec: durationSec ?? this.durationSec,
      type: type ?? this.type,
      soundId: soundId ?? this.soundId,
      vibrate: vibrate ?? this.vibrate,
      voiceText: voiceText ?? this.voiceText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (blockId.present) {
      map['block_id'] = Variable<int>(blockId.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (soundId.present) {
      map['sound_id'] = Variable<String>(soundId.value);
    }
    if (vibrate.present) {
      map['vibrate'] = Variable<bool>(vibrate.value);
    }
    if (voiceText.present) {
      map['voice_text'] = Variable<String>(voiceText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimerStepsCompanion(')
          ..write('id: $id, ')
          ..write('blockId: $blockId, ')
          ..write('order: $order, ')
          ..write('label: $label, ')
          ..write('durationSec: $durationSec, ')
          ..write('type: $type, ')
          ..write('soundId: $soundId, ')
          ..write('vibrate: $vibrate, ')
          ..write('voiceText: $voiceText')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $RunsTable runs = $RunsTable(this);
  late final $TrackPointsTable trackPoints = $TrackPointsTable(this);
  late final $SplitsTable splits = $SplitsTable(this);
  late final $TimerPresetsTable timerPresets = $TimerPresetsTable(this);
  late final $TimerBlocksTable timerBlocks = $TimerBlocksTable(this);
  late final $TimerStepsTable timerSteps = $TimerStepsTable(this);
  late final Index trackRunTs = Index(
    'track_run_ts',
    'CREATE INDEX track_run_ts ON track_points (run_id, ts)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    runs,
    trackPoints,
    splits,
    timerPresets,
    timerBlocks,
    timerSteps,
    trackRunTs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'runs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_points', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'runs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('splits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'timer_presets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('timer_blocks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'timer_blocks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('timer_steps', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$RunsTableCreateCompanionBuilder = RunsCompanion Function({
  required String id,
  required int startedAt,
  required int tzOffsetMin,
  Value<int?> endedAt,
  Value<double> movingTimeSec,
  Value<double> distanceM,
  Value<double> avgSpeedMps,
  Value<double?> avgCadenceSpm,
  Value<double?> totalSteps,
  required RunStatus status,
  Value<String?> timerPresetId,
  Value<int?> snapshotAt,
  Value<int> rowid,
});
typedef $$RunsTableUpdateCompanionBuilder = RunsCompanion Function({
  Value<String> id,
  Value<int> startedAt,
  Value<int> tzOffsetMin,
  Value<int?> endedAt,
  Value<double> movingTimeSec,
  Value<double> distanceM,
  Value<double> avgSpeedMps,
  Value<double?> avgCadenceSpm,
  Value<double?> totalSteps,
  Value<RunStatus> status,
  Value<String?> timerPresetId,
  Value<int?> snapshotAt,
  Value<int> rowid,
});

final class $$RunsTableReferences
    extends BaseReferences<_$AppDb, $RunsTable, RunRow> {
  $$RunsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TrackPointsTable, List<TrackPointRow>>
  _trackPointsRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.trackPoints,
    aliasName: 'runs__id__track_points__run_id',
  );

  $$TrackPointsTableProcessedTableManager get trackPointsRefs {
    final manager = $$TrackPointsTableTableManager(
      $_db,
      $_db.trackPoints,
    ).filter((f) => f.runId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackPointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SplitsTable, List<SplitRow>> _splitsRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.splits,
    aliasName: 'runs__id__splits__run_id',
  );

  $$SplitsTableProcessedTableManager get splitsRefs {
    final manager = $$SplitsTableTableManager(
      $_db,
      $_db.splits,
    ).filter((f) => f.runId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_splitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RunsTableFilterComposer extends Composer<_$AppDb, $RunsTable> {
  $$RunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tzOffsetMin => $composableBuilder(
    column: $table.tzOffsetMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get movingTimeSec => $composableBuilder(
    column: $table.movingTimeSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgCadenceSpm => $composableBuilder(
    column: $table.avgCadenceSpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalSteps => $composableBuilder(
    column: $table.totalSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RunStatus, RunStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get timerPresetId => $composableBuilder(
    column: $table.timerPresetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snapshotAt => $composableBuilder(
    column: $table.snapshotAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trackPointsRefs(
    Expression<bool> Function($$TrackPointsTableFilterComposer f) f,
  ) {
    final $$TrackPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackPoints,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackPointsTableFilterComposer(
            $db: $db,
            $table: $db.trackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> splitsRefs(
    Expression<bool> Function($$SplitsTableFilterComposer f) f,
  ) {
    final $$SplitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splits,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitsTableFilterComposer(
            $db: $db,
            $table: $db.splits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RunsTableOrderingComposer extends Composer<_$AppDb, $RunsTable> {
  $$RunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tzOffsetMin => $composableBuilder(
    column: $table.tzOffsetMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get movingTimeSec => $composableBuilder(
    column: $table.movingTimeSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgCadenceSpm => $composableBuilder(
    column: $table.avgCadenceSpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalSteps => $composableBuilder(
    column: $table.totalSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timerPresetId => $composableBuilder(
    column: $table.timerPresetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snapshotAt => $composableBuilder(
    column: $table.snapshotAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunsTableAnnotationComposer extends Composer<_$AppDb, $RunsTable> {
  $$RunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get tzOffsetMin => $composableBuilder(
    column: $table.tzOffsetMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get movingTimeSec => $composableBuilder(
    column: $table.movingTimeSec,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgCadenceSpm => $composableBuilder(
    column: $table.avgCadenceSpm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalSteps => $composableBuilder(
    column: $table.totalSteps,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RunStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get timerPresetId => $composableBuilder(
    column: $table.timerPresetId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snapshotAt => $composableBuilder(
    column: $table.snapshotAt,
    builder: (column) => column,
  );

  Expression<T> trackPointsRefs<T extends Object>(
    Expression<T> Function($$TrackPointsTableAnnotationComposer a) f,
  ) {
    final $$TrackPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackPoints,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> splitsRefs<T extends Object>(
    Expression<T> Function($$SplitsTableAnnotationComposer a) f,
  ) {
    final $$SplitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splits,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitsTableAnnotationComposer(
            $db: $db,
            $table: $db.splits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RunsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $RunsTable,
          RunRow,
          $$RunsTableFilterComposer,
          $$RunsTableOrderingComposer,
          $$RunsTableAnnotationComposer,
          $$RunsTableCreateCompanionBuilder,
          $$RunsTableUpdateCompanionBuilder,
          (RunRow, $$RunsTableReferences),
          RunRow,
          PrefetchHooks Function({bool trackPointsRefs, bool splitsRefs})
        > {
  $$RunsTableTableManager(_$AppDb db, $RunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> tzOffsetMin = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<double> movingTimeSec = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<double> avgSpeedMps = const Value.absent(),
                Value<double?> avgCadenceSpm = const Value.absent(),
                Value<double?> totalSteps = const Value.absent(),
                Value<RunStatus> status = const Value.absent(),
                Value<String?> timerPresetId = const Value.absent(),
                Value<int?> snapshotAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion(
                id: id,
                startedAt: startedAt,
                tzOffsetMin: tzOffsetMin,
                endedAt: endedAt,
                movingTimeSec: movingTimeSec,
                distanceM: distanceM,
                avgSpeedMps: avgSpeedMps,
                avgCadenceSpm: avgCadenceSpm,
                totalSteps: totalSteps,
                status: status,
                timerPresetId: timerPresetId,
                snapshotAt: snapshotAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int startedAt,
                required int tzOffsetMin,
                Value<int?> endedAt = const Value.absent(),
                Value<double> movingTimeSec = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<double> avgSpeedMps = const Value.absent(),
                Value<double?> avgCadenceSpm = const Value.absent(),
                Value<double?> totalSteps = const Value.absent(),
                required RunStatus status,
                Value<String?> timerPresetId = const Value.absent(),
                Value<int?> snapshotAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion.insert(
                id: id,
                startedAt: startedAt,
                tzOffsetMin: tzOffsetMin,
                endedAt: endedAt,
                movingTimeSec: movingTimeSec,
                distanceM: distanceM,
                avgSpeedMps: avgSpeedMps,
                avgCadenceSpm: avgCadenceSpm,
                totalSteps: totalSteps,
                status: status,
                timerPresetId: timerPresetId,
                snapshotAt: snapshotAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RunsTable, RunRow>(table),
                  $$RunsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({trackPointsRefs = false, splitsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trackPointsRefs) db.trackPoints,
                    if (splitsRefs) db.splits,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trackPointsRefs)
                        await $_getPrefetchedData<
                          RunRow,
                          $RunsTable,
                          TrackPointRow
                        >(
                          currentTable: table,
                          referencedTable: $$RunsTableReferences
                              ._trackPointsRefsTable(db),
                          managerFromTypedResult: (p0) => $$RunsTableReferences(
                            db,
                            table,
                            p0,
                          ).trackPointsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.runId == item.id),
                          typedResults: items,
                        ),
                      if (splitsRefs)
                        await $_getPrefetchedData<RunRow, $RunsTable, SplitRow>(
                          currentTable: table,
                          referencedTable: $$RunsTableReferences
                              ._splitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RunsTableReferences(db, table, p0).splitsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.runId == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $RunsTable,
      RunRow,
      $$RunsTableFilterComposer,
      $$RunsTableOrderingComposer,
      $$RunsTableAnnotationComposer,
      $$RunsTableCreateCompanionBuilder,
      $$RunsTableUpdateCompanionBuilder,
      (RunRow, $$RunsTableReferences),
      RunRow,
      PrefetchHooks Function({bool trackPointsRefs, bool splitsRefs})
    >;
typedef $$TrackPointsTableCreateCompanionBuilder =
    TrackPointsCompanion Function({
      Value<int> id,
      required String runId,
      required int ts,
      required double lat,
      required double lng,
      required double accuracyM,
      Value<double?> speedMps,
      Value<double?> altitudeM,
      required int segmentIndex,
    });
typedef $$TrackPointsTableUpdateCompanionBuilder =
    TrackPointsCompanion Function({
      Value<int> id,
      Value<String> runId,
      Value<int> ts,
      Value<double> lat,
      Value<double> lng,
      Value<double> accuracyM,
      Value<double?> speedMps,
      Value<double?> altitudeM,
      Value<int> segmentIndex,
    });

final class $$TrackPointsTableReferences
    extends BaseReferences<_$AppDb, $TrackPointsTable, TrackPointRow> {
  $$TrackPointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RunsTable _runIdTable(_$AppDb db) =>
      db.runs.createAlias('track_points__run_id__runs__id');

  $$RunsTableProcessedTableManager get runId {
    final $_column = $_itemColumn<String>('run_id')!;

    final manager = $$RunsTableTableManager(
      $_db,
      $_db.runs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_runIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackPointsTableFilterComposer
    extends Composer<_$AppDb, $TrackPointsTable> {
  $$TrackPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitudeM => $composableBuilder(
    column: $table.altitudeM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$RunsTableFilterComposer get runId {
    final $$RunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableFilterComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableOrderingComposer
    extends Composer<_$AppDb, $TrackPointsTable> {
  $$TrackPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitudeM => $composableBuilder(
    column: $table.altitudeM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$RunsTableOrderingComposer get runId {
    final $$RunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableOrderingComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableAnnotationComposer
    extends Composer<_$AppDb, $TrackPointsTable> {
  $$TrackPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<double> get speedMps =>
      $composableBuilder(column: $table.speedMps, builder: (column) => column);

  GeneratedColumn<double> get altitudeM =>
      $composableBuilder(column: $table.altitudeM, builder: (column) => column);

  GeneratedColumn<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => column,
  );

  $$RunsTableAnnotationComposer get runId {
    final $$RunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableAnnotationComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $TrackPointsTable,
          TrackPointRow,
          $$TrackPointsTableFilterComposer,
          $$TrackPointsTableOrderingComposer,
          $$TrackPointsTableAnnotationComposer,
          $$TrackPointsTableCreateCompanionBuilder,
          $$TrackPointsTableUpdateCompanionBuilder,
          (TrackPointRow, $$TrackPointsTableReferences),
          TrackPointRow,
          PrefetchHooks Function({bool runId})
        > {
  $$TrackPointsTableTableManager(_$AppDb db, $TrackPointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> runId = const Value.absent(),
                Value<int> ts = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<double> accuracyM = const Value.absent(),
                Value<double?> speedMps = const Value.absent(),
                Value<double?> altitudeM = const Value.absent(),
                Value<int> segmentIndex = const Value.absent(),
              }) => TrackPointsCompanion(
                id: id,
                runId: runId,
                ts: ts,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                speedMps: speedMps,
                altitudeM: altitudeM,
                segmentIndex: segmentIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String runId,
                required int ts,
                required double lat,
                required double lng,
                required double accuracyM,
                Value<double?> speedMps = const Value.absent(),
                Value<double?> altitudeM = const Value.absent(),
                required int segmentIndex,
              }) => TrackPointsCompanion.insert(
                id: id,
                runId: runId,
                ts: ts,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                speedMps: speedMps,
                altitudeM: altitudeM,
                segmentIndex: segmentIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrackPointsTable, TrackPointRow>(table),
                  $$TrackPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({runId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (runId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.runId,
                        referencedTable: $$TrackPointsTableReferences
                            ._runIdTable(db),
                        referencedColumn: $$TrackPointsTableReferences
                            ._runIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $TrackPointsTable,
      TrackPointRow,
      $$TrackPointsTableFilterComposer,
      $$TrackPointsTableOrderingComposer,
      $$TrackPointsTableAnnotationComposer,
      $$TrackPointsTableCreateCompanionBuilder,
      $$TrackPointsTableUpdateCompanionBuilder,
      (TrackPointRow, $$TrackPointsTableReferences),
      TrackPointRow,
      PrefetchHooks Function({bool runId})
    >;
typedef $$SplitsTableCreateCompanionBuilder = SplitsCompanion Function({
  required String runId,
  required int index,
  required double distanceM,
  required double durationSec,
  Value<double?> avgCadenceSpm,
  required bool isPartial,
  Value<int> rowid,
});
typedef $$SplitsTableUpdateCompanionBuilder = SplitsCompanion Function({
  Value<String> runId,
  Value<int> index,
  Value<double> distanceM,
  Value<double> durationSec,
  Value<double?> avgCadenceSpm,
  Value<bool> isPartial,
  Value<int> rowid,
});

final class $$SplitsTableReferences
    extends BaseReferences<_$AppDb, $SplitsTable, SplitRow> {
  $$SplitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RunsTable _runIdTable(_$AppDb db) =>
      db.runs.createAlias('splits__run_id__runs__id');

  $$RunsTableProcessedTableManager get runId {
    final $_column = $_itemColumn<String>('run_id')!;

    final manager = $$RunsTableTableManager(
      $_db,
      $_db.runs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_runIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SplitsTableFilterComposer extends Composer<_$AppDb, $SplitsTable> {
  $$SplitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get index => $composableBuilder(
    column: $table.index,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgCadenceSpm => $composableBuilder(
    column: $table.avgCadenceSpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPartial => $composableBuilder(
    column: $table.isPartial,
    builder: (column) => ColumnFilters(column),
  );

  $$RunsTableFilterComposer get runId {
    final $$RunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableFilterComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitsTableOrderingComposer extends Composer<_$AppDb, $SplitsTable> {
  $$SplitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get index => $composableBuilder(
    column: $table.index,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgCadenceSpm => $composableBuilder(
    column: $table.avgCadenceSpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPartial => $composableBuilder(
    column: $table.isPartial,
    builder: (column) => ColumnOrderings(column),
  );

  $$RunsTableOrderingComposer get runId {
    final $$RunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableOrderingComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitsTableAnnotationComposer extends Composer<_$AppDb, $SplitsTable> {
  $$SplitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get index =>
      $composableBuilder(column: $table.index, builder: (column) => column);

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<double> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgCadenceSpm => $composableBuilder(
    column: $table.avgCadenceSpm,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPartial =>
      $composableBuilder(column: $table.isPartial, builder: (column) => column);

  $$RunsTableAnnotationComposer get runId {
    final $$RunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableAnnotationComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $SplitsTable,
          SplitRow,
          $$SplitsTableFilterComposer,
          $$SplitsTableOrderingComposer,
          $$SplitsTableAnnotationComposer,
          $$SplitsTableCreateCompanionBuilder,
          $$SplitsTableUpdateCompanionBuilder,
          (SplitRow, $$SplitsTableReferences),
          SplitRow,
          PrefetchHooks Function({bool runId})
        > {
  $$SplitsTableTableManager(_$AppDb db, $SplitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SplitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SplitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SplitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> runId = const Value.absent(),
                Value<int> index = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<double> durationSec = const Value.absent(),
                Value<double?> avgCadenceSpm = const Value.absent(),
                Value<bool> isPartial = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SplitsCompanion(
                runId: runId,
                index: index,
                distanceM: distanceM,
                durationSec: durationSec,
                avgCadenceSpm: avgCadenceSpm,
                isPartial: isPartial,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String runId,
                required int index,
                required double distanceM,
                required double durationSec,
                Value<double?> avgCadenceSpm = const Value.absent(),
                required bool isPartial,
                Value<int> rowid = const Value.absent(),
              }) => SplitsCompanion.insert(
                runId: runId,
                index: index,
                distanceM: distanceM,
                durationSec: durationSec,
                avgCadenceSpm: avgCadenceSpm,
                isPartial: isPartial,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SplitsTable, SplitRow>(table),
                  $$SplitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({runId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (runId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.runId,
                        referencedTable: $$SplitsTableReferences._runIdTable(
                          db,
                        ),
                        referencedColumn: $$SplitsTableReferences
                            ._runIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SplitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $SplitsTable,
      SplitRow,
      $$SplitsTableFilterComposer,
      $$SplitsTableOrderingComposer,
      $$SplitsTableAnnotationComposer,
      $$SplitsTableCreateCompanionBuilder,
      $$SplitsTableUpdateCompanionBuilder,
      (SplitRow, $$SplitsTableReferences),
      SplitRow,
      PrefetchHooks Function({bool runId})
    >;
typedef $$TimerPresetsTableCreateCompanionBuilder =
    TimerPresetsCompanion Function({
      required String id,
      required String name,
      Value<int> repeatCount,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$TimerPresetsTableUpdateCompanionBuilder =
    TimerPresetsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> repeatCount,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$TimerPresetsTableReferences
    extends BaseReferences<_$AppDb, $TimerPresetsTable, TimerPresetRow> {
  $$TimerPresetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TimerBlocksTable, List<TimerBlockRow>>
  _timerBlocksRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.timerBlocks,
    aliasName: 'timer_presets__id__timer_blocks__preset_id',
  );

  $$TimerBlocksTableProcessedTableManager get timerBlocksRefs {
    final manager = $$TimerBlocksTableTableManager(
      $_db,
      $_db.timerBlocks,
    ).filter((f) => f.presetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_timerBlocksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TimerPresetsTableFilterComposer
    extends Composer<_$AppDb, $TimerPresetsTable> {
  $$TimerPresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> timerBlocksRefs(
    Expression<bool> Function($$TimerBlocksTableFilterComposer f) f,
  ) {
    final $$TimerBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timerBlocks,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerBlocksTableFilterComposer(
            $db: $db,
            $table: $db.timerBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimerPresetsTableOrderingComposer
    extends Composer<_$AppDb, $TimerPresetsTable> {
  $$TimerPresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimerPresetsTableAnnotationComposer
    extends Composer<_$AppDb, $TimerPresetsTable> {
  $$TimerPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> timerBlocksRefs<T extends Object>(
    Expression<T> Function($$TimerBlocksTableAnnotationComposer a) f,
  ) {
    final $$TimerBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timerBlocks,
      getReferencedColumn: (t) => t.presetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.timerBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimerPresetsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $TimerPresetsTable,
          TimerPresetRow,
          $$TimerPresetsTableFilterComposer,
          $$TimerPresetsTableOrderingComposer,
          $$TimerPresetsTableAnnotationComposer,
          $$TimerPresetsTableCreateCompanionBuilder,
          $$TimerPresetsTableUpdateCompanionBuilder,
          (TimerPresetRow, $$TimerPresetsTableReferences),
          TimerPresetRow,
          PrefetchHooks Function({bool timerBlocksRefs})
        > {
  $$TimerPresetsTableTableManager(_$AppDb db, $TimerPresetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimerPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimerPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimerPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> repeatCount = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimerPresetsCompanion(
                id: id,
                name: name,
                repeatCount: repeatCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> repeatCount = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TimerPresetsCompanion.insert(
                id: id,
                name: name,
                repeatCount: repeatCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimerPresetsTable, TimerPresetRow>(table),
                  $$TimerPresetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({timerBlocksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (timerBlocksRefs) db.timerBlocks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (timerBlocksRefs)
                    await $_getPrefetchedData<
                      TimerPresetRow,
                      $TimerPresetsTable,
                      TimerBlockRow
                    >(
                      currentTable: table,
                      referencedTable: $$TimerPresetsTableReferences
                          ._timerBlocksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TimerPresetsTableReferences(
                            db,
                            table,
                            p0,
                          ).timerBlocksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.presetId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TimerPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $TimerPresetsTable,
      TimerPresetRow,
      $$TimerPresetsTableFilterComposer,
      $$TimerPresetsTableOrderingComposer,
      $$TimerPresetsTableAnnotationComposer,
      $$TimerPresetsTableCreateCompanionBuilder,
      $$TimerPresetsTableUpdateCompanionBuilder,
      (TimerPresetRow, $$TimerPresetsTableReferences),
      TimerPresetRow,
      PrefetchHooks Function({bool timerBlocksRefs})
    >;
typedef $$TimerBlocksTableCreateCompanionBuilder =
    TimerBlocksCompanion Function({
      Value<int> id,
      required String presetId,
      required int order,
      Value<int> repeatCount,
    });
typedef $$TimerBlocksTableUpdateCompanionBuilder =
    TimerBlocksCompanion Function({
      Value<int> id,
      Value<String> presetId,
      Value<int> order,
      Value<int> repeatCount,
    });

final class $$TimerBlocksTableReferences
    extends BaseReferences<_$AppDb, $TimerBlocksTable, TimerBlockRow> {
  $$TimerBlocksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TimerPresetsTable _presetIdTable(_$AppDb db) =>
      db.timerPresets.createAlias('timer_blocks__preset_id__timer_presets__id');

  $$TimerPresetsTableProcessedTableManager get presetId {
    final $_column = $_itemColumn<String>('preset_id')!;

    final manager = $$TimerPresetsTableTableManager(
      $_db,
      $_db.timerPresets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_presetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TimerStepsTable, List<TimerStepRow>>
  _timerStepsRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.timerSteps,
    aliasName: 'timer_blocks__id__timer_steps__block_id',
  );

  $$TimerStepsTableProcessedTableManager get timerStepsRefs {
    final manager = $$TimerStepsTableTableManager(
      $_db,
      $_db.timerSteps,
    ).filter((f) => f.blockId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_timerStepsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TimerBlocksTableFilterComposer
    extends Composer<_$AppDb, $TimerBlocksTable> {
  $$TimerBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => ColumnFilters(column),
  );

  $$TimerPresetsTableFilterComposer get presetId {
    final $$TimerPresetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.timerPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerPresetsTableFilterComposer(
            $db: $db,
            $table: $db.timerPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> timerStepsRefs(
    Expression<bool> Function($$TimerStepsTableFilterComposer f) f,
  ) {
    final $$TimerStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timerSteps,
      getReferencedColumn: (t) => t.blockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerStepsTableFilterComposer(
            $db: $db,
            $table: $db.timerSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimerBlocksTableOrderingComposer
    extends Composer<_$AppDb, $TimerBlocksTable> {
  $$TimerBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$TimerPresetsTableOrderingComposer get presetId {
    final $$TimerPresetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.timerPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerPresetsTableOrderingComposer(
            $db: $db,
            $table: $db.timerPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimerBlocksTableAnnotationComposer
    extends Composer<_$AppDb, $TimerBlocksTable> {
  $$TimerBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => column,
  );

  $$TimerPresetsTableAnnotationComposer get presetId {
    final $$TimerPresetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presetId,
      referencedTable: $db.timerPresets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerPresetsTableAnnotationComposer(
            $db: $db,
            $table: $db.timerPresets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> timerStepsRefs<T extends Object>(
    Expression<T> Function($$TimerStepsTableAnnotationComposer a) f,
  ) {
    final $$TimerStepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timerSteps,
      getReferencedColumn: (t) => t.blockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerStepsTableAnnotationComposer(
            $db: $db,
            $table: $db.timerSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimerBlocksTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $TimerBlocksTable,
          TimerBlockRow,
          $$TimerBlocksTableFilterComposer,
          $$TimerBlocksTableOrderingComposer,
          $$TimerBlocksTableAnnotationComposer,
          $$TimerBlocksTableCreateCompanionBuilder,
          $$TimerBlocksTableUpdateCompanionBuilder,
          (TimerBlockRow, $$TimerBlocksTableReferences),
          TimerBlockRow,
          PrefetchHooks Function({bool presetId, bool timerStepsRefs})
        > {
  $$TimerBlocksTableTableManager(_$AppDb db, $TimerBlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimerBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimerBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimerBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> presetId = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<int> repeatCount = const Value.absent(),
              }) => TimerBlocksCompanion(
                id: id,
                presetId: presetId,
                order: order,
                repeatCount: repeatCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String presetId,
                required int order,
                Value<int> repeatCount = const Value.absent(),
              }) => TimerBlocksCompanion.insert(
                id: id,
                presetId: presetId,
                order: order,
                repeatCount: repeatCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimerBlocksTable, TimerBlockRow>(table),
                  $$TimerBlocksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({presetId = false, timerStepsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (timerStepsRefs) db.timerSteps],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (presetId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.presetId,
                        referencedTable: $$TimerBlocksTableReferences
                            ._presetIdTable(db),
                        referencedColumn: $$TimerBlocksTableReferences
                            ._presetIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (timerStepsRefs)
                    await $_getPrefetchedData<
                      TimerBlockRow,
                      $TimerBlocksTable,
                      TimerStepRow
                    >(
                      currentTable: table,
                      referencedTable: $$TimerBlocksTableReferences
                          ._timerStepsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TimerBlocksTableReferences(
                            db,
                            table,
                            p0,
                          ).timerStepsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.blockId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TimerBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $TimerBlocksTable,
      TimerBlockRow,
      $$TimerBlocksTableFilterComposer,
      $$TimerBlocksTableOrderingComposer,
      $$TimerBlocksTableAnnotationComposer,
      $$TimerBlocksTableCreateCompanionBuilder,
      $$TimerBlocksTableUpdateCompanionBuilder,
      (TimerBlockRow, $$TimerBlocksTableReferences),
      TimerBlockRow,
      PrefetchHooks Function({bool presetId, bool timerStepsRefs})
    >;
typedef $$TimerStepsTableCreateCompanionBuilder = TimerStepsCompanion Function({
  Value<int> id,
  required int blockId,
  required int order,
  required String label,
  required int durationSec,
  required String type,
  Value<String?> soundId,
  Value<bool> vibrate,
  Value<String?> voiceText,
});
typedef $$TimerStepsTableUpdateCompanionBuilder = TimerStepsCompanion Function({
  Value<int> id,
  Value<int> blockId,
  Value<int> order,
  Value<String> label,
  Value<int> durationSec,
  Value<String> type,
  Value<String?> soundId,
  Value<bool> vibrate,
  Value<String?> voiceText,
});

final class $$TimerStepsTableReferences
    extends BaseReferences<_$AppDb, $TimerStepsTable, TimerStepRow> {
  $$TimerStepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TimerBlocksTable _blockIdTable(_$AppDb db) =>
      db.timerBlocks.createAlias('timer_steps__block_id__timer_blocks__id');

  $$TimerBlocksTableProcessedTableManager get blockId {
    final $_column = $_itemColumn<int>('block_id')!;

    final manager = $$TimerBlocksTableTableManager(
      $_db,
      $_db.timerBlocks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_blockIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TimerStepsTableFilterComposer
    extends Composer<_$AppDb, $TimerStepsTable> {
  $$TimerStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soundId => $composableBuilder(
    column: $table.soundId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vibrate => $composableBuilder(
    column: $table.vibrate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voiceText => $composableBuilder(
    column: $table.voiceText,
    builder: (column) => ColumnFilters(column),
  );

  $$TimerBlocksTableFilterComposer get blockId {
    final $$TimerBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.blockId,
      referencedTable: $db.timerBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerBlocksTableFilterComposer(
            $db: $db,
            $table: $db.timerBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimerStepsTableOrderingComposer
    extends Composer<_$AppDb, $TimerStepsTable> {
  $$TimerStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soundId => $composableBuilder(
    column: $table.soundId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibrate => $composableBuilder(
    column: $table.vibrate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voiceText => $composableBuilder(
    column: $table.voiceText,
    builder: (column) => ColumnOrderings(column),
  );

  $$TimerBlocksTableOrderingComposer get blockId {
    final $$TimerBlocksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.blockId,
      referencedTable: $db.timerBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerBlocksTableOrderingComposer(
            $db: $db,
            $table: $db.timerBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimerStepsTableAnnotationComposer
    extends Composer<_$AppDb, $TimerStepsTable> {
  $$TimerStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get soundId =>
      $composableBuilder(column: $table.soundId, builder: (column) => column);

  GeneratedColumn<bool> get vibrate =>
      $composableBuilder(column: $table.vibrate, builder: (column) => column);

  GeneratedColumn<String> get voiceText =>
      $composableBuilder(column: $table.voiceText, builder: (column) => column);

  $$TimerBlocksTableAnnotationComposer get blockId {
    final $$TimerBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.blockId,
      referencedTable: $db.timerBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.timerBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimerStepsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $TimerStepsTable,
          TimerStepRow,
          $$TimerStepsTableFilterComposer,
          $$TimerStepsTableOrderingComposer,
          $$TimerStepsTableAnnotationComposer,
          $$TimerStepsTableCreateCompanionBuilder,
          $$TimerStepsTableUpdateCompanionBuilder,
          (TimerStepRow, $$TimerStepsTableReferences),
          TimerStepRow,
          PrefetchHooks Function({bool blockId})
        > {
  $$TimerStepsTableTableManager(_$AppDb db, $TimerStepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimerStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimerStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimerStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> blockId = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> durationSec = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> soundId = const Value.absent(),
                Value<bool> vibrate = const Value.absent(),
                Value<String?> voiceText = const Value.absent(),
              }) => TimerStepsCompanion(
                id: id,
                blockId: blockId,
                order: order,
                label: label,
                durationSec: durationSec,
                type: type,
                soundId: soundId,
                vibrate: vibrate,
                voiceText: voiceText,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int blockId,
                required int order,
                required String label,
                required int durationSec,
                required String type,
                Value<String?> soundId = const Value.absent(),
                Value<bool> vibrate = const Value.absent(),
                Value<String?> voiceText = const Value.absent(),
              }) => TimerStepsCompanion.insert(
                id: id,
                blockId: blockId,
                order: order,
                label: label,
                durationSec: durationSec,
                type: type,
                soundId: soundId,
                vibrate: vibrate,
                voiceText: voiceText,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimerStepsTable, TimerStepRow>(table),
                  $$TimerStepsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({blockId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (blockId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.blockId,
                        referencedTable: $$TimerStepsTableReferences
                            ._blockIdTable(db),
                        referencedColumn: $$TimerStepsTableReferences
                            ._blockIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TimerStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $TimerStepsTable,
      TimerStepRow,
      $$TimerStepsTableFilterComposer,
      $$TimerStepsTableOrderingComposer,
      $$TimerStepsTableAnnotationComposer,
      $$TimerStepsTableCreateCompanionBuilder,
      $$TimerStepsTableUpdateCompanionBuilder,
      (TimerStepRow, $$TimerStepsTableReferences),
      TimerStepRow,
      PrefetchHooks Function({bool blockId})
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$RunsTableTableManager get runs => $$RunsTableTableManager(_db, _db.runs);
  $$TrackPointsTableTableManager get trackPoints =>
      $$TrackPointsTableTableManager(_db, _db.trackPoints);
  $$SplitsTableTableManager get splits =>
      $$SplitsTableTableManager(_db, _db.splits);
  $$TimerPresetsTableTableManager get timerPresets =>
      $$TimerPresetsTableTableManager(_db, _db.timerPresets);
  $$TimerBlocksTableTableManager get timerBlocks =>
      $$TimerBlocksTableTableManager(_db, _db.timerBlocks);
  $$TimerStepsTableTableManager get timerSteps =>
      $$TimerStepsTableTableManager(_db, _db.timerSteps);
}
