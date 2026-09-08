package com.junorion.sudoku;

import android.content.Context;
import android.os.Build;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.os.VibratorManager;
import android.webkit.JavascriptInterface;

/**
 * 웹 쪽 navigator.vibrate 가 실제로 도달하는 곳.
 *
 * WebView 에는 Vibration API 가 구현되어 있지 않다 — Chrome 에서는 동작하는
 * navigator.vibrate 가 WebView 에서는 아무 일도 하지 않는다. 그래서 네이티브
 * Vibrator 로 직접 연결한다.
 *
 * addJavascriptInterface 는 리플렉션으로 메서드를 호출하므로, 클래스가 public 이
 * 아니면 기기에 따라 접근이 막힐 수 있다. 그래서 내부 클래스로 두지 않는다.
 */
public final class Haptics {

    private final Vibrator vibrator;

    public Haptics(Context context) {
        this.vibrator = resolve(context);
    }

    private static Vibrator resolve(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            VibratorManager vm =
                    (VibratorManager) context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE);
            return vm == null ? null : vm.getDefaultVibrator();
        }
        return (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
    }

    @JavascriptInterface
    public boolean hasVibrator() {
        return vibrator != null && vibrator.hasVibrator();
    }

    @JavascriptInterface
    public void oneShot(int ms) {
        if (!hasVibrator() || ms <= 0) return;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && ms <= 40) {
            // 웹 앱이 쓰는 6~12ms 는 진동 모터가 낼 수 있는 길이가 아니다. 짧은 탭은
            // 길이를 늘리는 대신 플랫폼이 주는 클릭 햅틱으로 바꾼다.
            vibrator.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK));
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createOneShot(
                    Math.max(ms, 20), VibrationEffect.DEFAULT_AMPLITUDE));
        } else {
            vibrator.vibrate(Math.max(ms, 20));
        }
    }

    @JavascriptInterface
    public void pattern(String csv) {
        if (!hasVibrator() || csv == null || csv.isEmpty()) return;

        String[] parts = csv.split(",");
        // 웹은 [진동, 멈춤, 진동...] 이고 안드로이드는 [대기, 진동, 대기...] 라서
        // 맨 앞에 0 을 넣어 한 칸 밀어준다.
        long[] timings = new long[parts.length + 1];
        timings[0] = 0;
        for (int i = 0; i < parts.length; i++) {
            long v;
            try {
                v = Long.parseLong(parts[i].trim());
            } catch (NumberFormatException e) {
                return;
            }
            // 웹 배열의 짝수 번째(0,2,4...)가 진동 구간이다. 짧으면 느껴지지 않으므로 올린다.
            timings[i + 1] = (i % 2 == 0) ? Math.max(v, 25) : Math.max(v, 0);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(timings, -1));
        } else {
            vibrator.vibrate(timings, -1);
        }
    }
}
