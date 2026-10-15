import 'dart:async';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:running/data/db.dart';
import 'package:running/features/run/data/location_source.dart';
import 'package:running/features/run/data/step_source.dart';
import 'package:running/features/run/domain/location_sample.dart';

AppDb memoryDb() =>
    AppDb(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));

/// 테스트가 직접 점을 흘려 넣는 위치 소스
class FakeLocationSource implements LocationSource {
  final _ctl = StreamController<LocationSample>.broadcast();
  bool started = false, stopped = false;

  void emit(LocationSample s) => _ctl.add(s);

  /// 북쪽으로 [m] 미터 지점
  void emitAt(int tMs, double m, {double accuracy = 5}) => emit(LocationSample(
      tMs: tMs, lat: 37.5 + m / 111195.08, lng: 127.0, accuracyM: accuracy));

  @override
  Stream<LocationSample> start() {
    started = true;
    return _ctl.stream;
  }

  @override
  Future<void> stop() async => stopped = true;
}

class FakeStepSource implements StepSource {
  final _ctl = StreamController<(int, double)>.broadcast();
  void emit(int tMs, double cumulative) => _ctl.add((tMs, cumulative));

  @override
  Stream<(int, double)> start() => _ctl.stream;

  @override
  Future<void> stop() async {}
}

/// 센서가 없는 기기처럼 바로 오류를 내는 걸음 소스
class ErrorStepSource implements StepSource {
  @override
  Stream<(int, double)> start() => Stream.error(Exception('StepCount not available'));

  @override
  Future<void> stop() async {}
}
