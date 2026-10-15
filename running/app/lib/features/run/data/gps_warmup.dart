import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Ready 화면의 GPS 워밍업 (지침 4.2). 러닝 전이라 정확도를 낮춰 배터리를 아낀다 (11.1).
abstract class GpsWarmup extends ChangeNotifier {
  /// 가장 최근 정확도(m). 아직 없으면 null — "위치를 찾는 중" 안내를 띄운다.
  double? get accuracyM;
  bool get hasGoodFix => (accuracyM ?? double.infinity) <= 25;
  void start();
  void stop();
}

class GeolocatorWarmup extends GpsWarmup {
  StreamSubscription<Position>? _sub;
  double? _acc;

  @override
  double? get accuracyM => _acc;

  @override
  void start() {
    if (_sub != null) return;
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 0),
    ).listen((p) {
      _acc = p.accuracy;
      notifyListeners();
    }, onError: (_) {});
  }

  /// 러닝의 위치 스트림(포그라운드 서비스)과 겹치지 않게 카운트다운 전에 멈춘다
  @override
  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
