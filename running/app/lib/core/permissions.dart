import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum LocationAccess { granted, denied, permanentlyDenied, serviceOff }

/// 권한은 한꺼번에 묻지 않고 필요한 순간에 하나씩 요청한다 (지침 8.3).
/// 화면은 이 클래스만 쓴다 — 테스트에서 가짜로 바꿔 끼운다.
class PermissionGate {
  Future<LocationAccess> location() async {
    if (!await Geolocator.isLocationServiceEnabled()) return LocationAccess.serviceOff;
    return _map(await Permission.locationWhenInUse.status);
  }

  /// Ready 진입 시 (8.3 ①)
  Future<LocationAccess> requestLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return LocationAccess.serviceOff;
    return _map(await Permission.locationWhenInUse.request());
  }

  /// 첫 Start 시 알림(Android 13+)과 신체 활동/모션 (8.3 ②③). 거부해도 러닝은 진행한다.
  Future<void> requestRunExtras() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.notification.request();
      await Permission.activityRecognition.request();
    } else {
      await Permission.sensors.request();
    }
  }

  Future<bool> activityGranted() async => defaultTargetPlatform == TargetPlatform.android
      ? await Permission.activityRecognition.isGranted
      : await Permission.sensors.isGranted;

  Future<void> openSettings() => openAppSettings();
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  static LocationAccess _map(PermissionStatus s) => switch (s) {
        PermissionStatus.granted || PermissionStatus.limited => LocationAccess.granted,
        PermissionStatus.permanentlyDenied || PermissionStatus.restricted =>
          LocationAccess.permanentlyDenied,
        _ => LocationAccess.denied,
      };
}
