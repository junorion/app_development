package com.junorion.sudoku;

import android.app.Activity;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/**
 * sudoku/index.html 을 그대로 담아 띄우는 얇은 WebView 껍데기.
 * 게임 로직은 전부 웹 쪽에 있고, 여기서는 오프라인 실행에 필요한 설정과
 * WebView 에 없는 기능(진동)의 연결만 한다.
 */
public class MainActivity extends Activity {

    private WebView web;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // targetSdk 35 부터 안드로이드는 앱을 강제로 edge-to-edge 로 그린다.
        // 창이 시스템 바 아래까지 펼쳐져야 WebView 가 CSS 의
        // env(safe-area-inset-*) 에 실제 값을 넘겨준다 — 웹 쪽 레이아웃이
        // 그 값으로 아래쪽 내비게이션 바를 피한다.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            getWindow().setDecorFitsSystemWindows(false);
        }

        web = new WebView(this);
        web.setLayoutParams(new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        // 첫 프레임이 흰색으로 번쩍이지 않게 창 배경과 같은 색을 깔아둔다.
        web.setBackgroundColor(0xFF111420);
        // 퍼즐을 오래 들여다보는 동안 화면이 꺼지지 않게 한다.
        web.setKeepScreenOn(true);
        // 보드는 스크롤할 것이 없으므로 가장자리 글로우를 없앤다.
        web.setOverScrollMode(View.OVER_SCROLL_NEVER);
        web.setVerticalScrollBarEnabled(false);
        web.setHorizontalScrollBarEnabled(false);

        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        // 진행 중인 게임·기록·테마를 localStorage 에 저장하므로 반드시 켜야 한다.
        s.setDomStorageEnabled(true);
        // 자산은 android_asset 으로 읽으므로 파일시스템 접근은 열어두지 않는다.
        s.setAllowFileAccess(false);
        s.setAllowContentAccess(false);
        // viewport-fit=cover 를 포함한 meta viewport 를 그대로 따르게 한다.
        s.setUseWideViewPort(true);
        s.setLoadWithOverviewMode(true);
        // 보드를 확대할 일은 없고 두 손가락 확대는 오조작만 만든다.
        s.setSupportZoom(false);
        s.setBuiltInZoomControls(false);
        s.setDisplayZoomControls(false);
        // 기기 글꼴 크기 설정에 레이아웃이 흔들리지 않게 고정한다.
        s.setTextZoom(100);

        // JS 인터페이스를 붙이므로 앱 자산 밖으로는 절대 나가지 않게 막는다.
        web.setWebViewClient(new AssetOnlyClient());
        web.addJavascriptInterface(new Haptics(this), "NQHaptics");

        setContentView(web);
        web.loadUrl("file:///android_asset/index.html");
    }

    /** 앱 자산 밖으로는 나가지 않는다. */
    private static final class AssetOnlyClient extends WebViewClient {

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
            Uri u = request.getUrl();
            return !("file".equals(u.getScheme()) && u.getPath() != null
                     && u.getPath().startsWith("/android_asset/"));
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            // WebView 에는 Vibration API 가 없다. navigator.vibrate 를 네이티브 호출로
            // 갈아끼워, 웹 앱(index.html)은 고치지 않고 진동만 여기서 채워 넣는다.
            view.evaluateJavascript(
                "(function () {"
              + "  if (!window.NQHaptics || !NQHaptics.hasVibrator()) return;"
              + "  var fn = function (p) {"
              + "    try {"
              + "      if (Array.isArray(p)) NQHaptics.pattern(p.join(','));"
              + "      else NQHaptics.oneShot(p | 0);"
              + "    } catch (e) { return false; }"
              + "    return true;"
              + "  };"
              + "  try {"
              + "    Object.defineProperty(navigator, 'vibrate',"
              + "      { value: fn, configurable: true, writable: true });"
              + "  } catch (e) { navigator.vibrate = fn; }"
              + "})();", null);
        }
    }

    @Override
    public void onBackPressed() {
        // 진행 중인 게임을 실수로 날리지 않게, 열려 있는 오버레이가 있으면 그것부터 닫는다.
        web.evaluateJavascript(
            "(function(){ if (typeof overlayOpen !== 'undefined' && overlayOpen) {"
          + "  closeOverlay(); if (S && !S.done) startTimer(); return true; } return false; })();",
            value -> {
                if (!"true".equals(value)) finish();
            });
    }

    @Override
    protected void onPause() {
        super.onPause();
        web.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        web.onResume();
    }

    @Override
    protected void onDestroy() {
        // 액티비티보다 WebView 가 오래 남아 새는 것을 막는다.
        if (web != null) {
            ((ViewGroup) web.getParent()).removeView(web);
            web.destroy();
            web = null;
        }
        super.onDestroy();
    }
}
