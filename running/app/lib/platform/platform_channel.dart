import 'package:flutter/services.dart';

/// 네이티브 브리지 (`MainActivity.kt`). 플러그인이 주지 않는 것만 여기에 둔다.
class PlatformChannel {
  static const _ch = MethodChannel('running/platform');

  static Future<Map<String, Object?>> deviceInfo() async =>
      Map<String, Object?>.from(await _ch.invokeMethod('deviceInfo') as Map);

  static Future<Map<String, Object?>> powerState() async =>
      Map<String, Object?>.from(await _ch.invokeMethod('powerState') as Map);

  /// Ready 에서 뒤로가기 — 앱을 끝내지 않고 백그라운드로 보낸다 (Android, 지침 4.1)
  static Future<void> moveTaskToBack() => _ch.invokeMethod('moveTaskToBack');

  static Future<void> openBatterySettings() => _ch.invokeMethod('openBatterySettings');

  static Future<void> metronomeStart({required double spm, double volume = 0.8}) =>
      _ch.invokeMethod('metronomeStart', {'spm': spm, 'volume': volume});

  static Future<void> metronomeStop() => _ch.invokeMethod('metronomeStop');

  static Future<void> metronomeSetSpm(double spm) =>
      _ch.invokeMethod('metronomeSetSpm', {'spm': spm});

  static Future<Map<String, Object?>> metronomeStats() async =>
      Map<String, Object?>.from(await _ch.invokeMethod('metronomeStats') as Map);
}
