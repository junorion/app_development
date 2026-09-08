package com.junorion.nqueens;

import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/**
 * nqueens/index.html 을 그대로 담아 띄우는 얇은 WebView 껍데기.
 * 앱 로직은 전부 웹 쪽에 있고, 여기서는 오프라인 실행에 필요한 설정과
 * WebView 에 없는 기능(진동)의 연결만 한다.
 */
public class MainActivity extends Activity {

    private WebView web;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        web = new WebView(this);
        web.setLayoutParams(new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        // 첫 프레임이 흰색으로 번쩍이지 않게 창 배경과 같은 색을 깔아둔다.
        web.setBackgroundColor(0xFF1F1A16);
        // 퍼즐을 오래 들여다보는 동안 화면이 꺼지지 않게 한다.
        web.setKeepScreenOn(true);
        // 보드는 스크롤할 것이 없으므로 가장자리 글로우를 없앤다.
        web.setOverScrollMode(View.OVER_SCROLL_NEVER);
        web.setVerticalScrollBarEnabled(false);
        web.setHorizontalScrollBarEnabled(false);

        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        // 테마 선택을 localStorage 에 저장하므로 DOM storage 가 필요하다.
        s.setDomStorageEnabled(true);
        // 자산은 android_asset 으로 읽으므로 파일시스템 접근은 열어두지 않는다.
        s.setAllowFileAccess(false);
        s.setAllowContentAccess(false);
        // <meta name="viewport" width=device-width, viewport-fit=cover> 를 그대로 따르게 한다.
        s.setUseWideViewPort(true);
        s.setLoadWithOverviewMode(true);
        // 퍼즐 보드는 확대할 일이 없고, 두 손가락 확대는 오조작만 만든다.
        s.setSupportZoom(false);
        s.setBuiltInZoomControls(false);
        s.setDisplayZoomControls(false);
        // 기기의 글꼴 크기 설정에 따라 레이아웃이 어긋나지 않게 고정한다.
        s.setTextZoom(100);

        // JS 인터페이스를 붙이므로, 앱 자산이 아닌 곳으로는 절대 이동하지 않게 막는다.
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
            // navigator.vibrate 를 네이티브 호출로 갈아끼운다. 웹 앱(index.html)은
            // 고치지 않고 그대로 두면서, WebView 에 없는 진동만 여기서 채워 넣는다.
            // buzz() 가 호출 시점마다 navigator.vibrate 를 확인하므로 교체 시점은 늦어도 된다.
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
