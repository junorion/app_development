import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/permissions.dart';
import '../data/db.dart';
import '../data/run_repository.dart';
import '../features/run/application/run_service.dart';
import '../features/run/data/geolocator_source.dart';
import '../features/run/data/gps_warmup.dart';
import '../features/run/data/step_source.dart';
import '../platform/platform_channel.dart';

final dbProvider = Provider<AppDb>((ref) {
  final db = AppDb();
  ref.onDispose(db.close);
  return db;
});

final repoProvider = Provider((ref) => RunRepository(ref.watch(dbProvider)));

final runServiceProvider = Provider<RunService>((ref) {
  final s = RunService(
    repo: ref.watch(repoProvider),
    locationSource: () => GeolocatorSource(
      notificationTitle: '톡톡런',
      notificationText: '러닝을 기록하고 있어요',
    ),
    stepSource: PedometerStepSource.new,
  );
  ref.onDispose(s.dispose);
  return s;
});

final permissionGateProvider = Provider((ref) => PermissionGate());

final gpsWarmupProvider = Provider<GpsWarmup>((ref) {
  final w = GeolocatorWarmup();
  ref.onDispose(w.dispose);
  return w;
});

/// 플랫폼 동작 — 테스트에서 가짜로 바꾼다
class AppPlatform {
  bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  Future<void> moveTaskToBack() => PlatformChannel.moveTaskToBack();
}

final appPlatformProvider = Provider((ref) => AppPlatform());

/// 앱을 켤 때 한 번만 복구 안내를 띄운다 (지침 5.7)
final recoveryCheckedProvider = StateProvider<bool>((ref) => false);
