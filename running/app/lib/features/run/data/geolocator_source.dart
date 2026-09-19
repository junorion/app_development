import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/location_sample.dart';
import 'location_source.dart';

/// 실제 GPS. 러닝 중에만 최고 정확도로 받는다 (지침 5.2).
///
/// Android 는 위치 스트림과 함께 포그라운드 서비스(type: location)를 띄운다 — 앱이 화면에
/// 보일 때(Start 를 누를 때) 시작해야 백그라운드에서도 계속 받는다 (지침 8.1).
/// 백그라운드 위치 권한은 요청하지 않는다.
class GeolocatorSource implements LocationSource {
  GeolocatorSource({required this.notificationTitle, required this.notificationText});

  final String notificationTitle;
  final String notificationText;
  StreamSubscription<Position>? _sub;
  StreamController<LocationSample>? _ctl;

  LocationSettings _settings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: notificationTitle,
          notificationText: notificationText,
          notificationChannelName: '러닝 기록',
          setOngoing: true,
          // 화면이 꺼져도 CPU 를 깨워 둔다 — 걸음·메트로놈·저장이 멈추지 않게
          enableWakeLock: true,
        ),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.fitness,
        distanceFilter: 5,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }
    return const LocationSettings(accuracy: LocationAccuracy.best);
  }

  @override
  Stream<LocationSample> start() {
    final ctl = _ctl = StreamController<LocationSample>();
    _sub = Geolocator.getPositionStream(locationSettings: _settings()).listen(
      (p) => ctl.add(LocationSample(
        // 수신 시각을 쓴다 — 걸음·tick 과 같은 시계여야 한다. GPS 시각은 기기마다 어긋난다.
        tMs: DateTime.now().millisecondsSinceEpoch,
        lat: p.latitude,
        lng: p.longitude,
        accuracyM: p.accuracy,
        speedMps: p.speed >= 0 ? p.speed : null,
        altitudeM: p.altitude,
      )),
      onError: ctl.addError,
    );
    return ctl.stream;
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await _ctl?.close();
  }
}
