package com.junorion.running

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorManager
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val metronome = Metronome()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "running/platform")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "deviceInfo" -> result.success(deviceInfo())
                    "powerState" -> result.success(powerState())
                    // 제외를 요청하는 시스템 대화상자는 쓰지 않고 설정 목록 화면으로 보낸다 (지침 8.4)
                    "openBatterySettings" -> {
                        startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                        result.success(null)
                    }
                    "metronomeStart" -> {
                        (call.argument<Double>("spm"))?.let { metronome.setSpm(it) }
                        (call.argument<Double>("volume"))?.let { metronome.setVolume(it) }
                        metronome.start(); result.success(null)
                    }
                    "metronomeStop" -> { metronome.stop(); result.success(null) }
                    "metronomeSetSpm" -> { metronome.setSpm(call.argument<Double>("spm")!!); result.success(null) }
                    "metronomeStats" -> result.success(metronome.stats())
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        metronome.stop()
        super.onDestroy()
    }

    private fun deviceInfo(): Map<String, Any> {
        val sm = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        return mapOf(
            "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL,
            "release" to Build.VERSION.RELEASE,
            "sdk" to Build.VERSION.SDK_INT,
            "hasGps" to packageManager.hasSystemFeature(PackageManager.FEATURE_LOCATION_GPS),
            "hasStepCounter" to (sm.getDefaultSensor(Sensor.TYPE_STEP_COUNTER) != null),
            "hasStepDetector" to (sm.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR) != null),
        )
    }

    private fun powerState(): Map<String, Any> {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        return mapOf(
            "ignoringBatteryOptimizations" to pm.isIgnoringBatteryOptimizations(packageName),
            "powerSave" to pm.isPowerSaveMode,
        )
    }
}
