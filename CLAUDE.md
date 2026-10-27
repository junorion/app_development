# 작업 규칙

junorion 의 앱 개발 템플릿([app_development](https://github.com/junorion/app_development))에서
만든 저장소다. 앱 하나 = 저장소 하나. 로컬 위치는 `/home/noble/app_development/<앱-id>/`.

## 구조

| 경로 | 내용 |
|---|---|
| `index.html` | 앱 전체. 단일 HTML(인라인 CSS/JS/SVG), 외부 요청 없음 — `file://` 로도 돈다 |
| `manifest.webmanifest`, `sw.js` | PWA. 앱 파일을 바꾸면 `sw.js` 의 `CACHE` 버전을 올린다 |
| `icon.html` → `icon-512.png`, `icon-192.png` | 아이콘 원본과 산출물 (`app-icon` skill) |
| `android/` | WebView APK. 웹 파일은 빌드 때 복사해 쓰고 사본을 커밋하지 않는다 |
| `test/` | Node 스텁 테스트 (`node test/run.js`). 프레임워크 없음 |
| `BACKLOG.md` | 할 일 목록 |
| `.claude/skills/` | 공통 skill — `new-app` `web-verify` `android-build` `app-icon` `play-release` |

Flutter 처럼 웹이 아닌 앱이면 `index.html`·`sw.js`·`android/`·`test/` 를 지우고
`flutter create` 로 만든 프로젝트를 `app/` 에 둔다. 이 문서와 skill 은 그대로 쓴다.

## 일하는 방식

- **백로그**: 요구가 오면 `BACKLOG.md` 에 등록하고 위에서부터 하나씩. 구체적인 항목은 묻지
  말고 진행하고, 범위가 열려 있거나 되돌리기 어려운 것(서버·계정·광고·결제, 스토어 신고에
  영향)만 확인을 받는다. 한 항목 = 검증 → 커밋 → 상태 갱신.
- **검증 후 커밋**: 화면 변경은 `web-verify` 로 라이트·다크 스크린샷을 눈으로 확인,
  로직 변경은 `node test/run.js`. 실기기에서만 볼 수 있는 것(터치 감, 진동, 설치 메뉴)은
  그렇다고 밝히고 사용자에게 확인을 부탁한다.
- **백업**: 의미 있는 단위마다 커밋하고 `git push` (SSH, `git@github.com:junorion/<앱-id>.git`).
- **비밀정보 금지**: ID/비밀번호·API 키·토큰·서명 키는 커밋하지 않는다. 새 종류의 설정
  파일을 추가하면 `.gitignore` 에 걸리는지 먼저 확인한다. 서명 키는 `~/keystores/` (저장소 밖).
- **사용자에게 조작을 부탁할 때**: 단계마다 어느 기기(PC 브라우저 / 태블릿 / 폰)에서 하는
  일인지, 붙여넣을 정확한 주소와 버튼 이름을 적는다. `curl` 등으로 내가 먼저 확인할 수
  있는 것은 묻기 전에 확인한다.

## 디자인 원칙

- 앱마다 이름·성격에 맞는 방향을 먼저 정한다. 이전 앱의 스타일을 기본값으로 삼지 않는다.
- 이모지·유니코드 글리프 금지 — 아이콘은 인라인 SVG.
- 색은 `:root` 토큰으로만. 라이트/다크 둘 다 확인하고, 커밋 전 정의되지 않은 토큰과
  잘못된 색 값(`#5a6party` 같은 오타는 브라우저가 조용히 무시한다)을 훑는다.
- 상태가 바뀔 때 `innerHTML` 을 통째로 다시 쓰지 말고 DOM 을 유지한 채 클래스만 바꾼다 —
  그래야 CSS 전이가 산다.
- 터치 대상 44px 이상, `prefers-reduced-motion` 존중, 짧은 진동 피드백(`haptic()`).
- APK 는 edge-to-edge 로 그려지므로 `env(safe-area-inset-*)` 로 시스템 바를 피한다.

## WebView(APK) 와 Chrome 의 차이

- `navigator.vibrate` 없음 → `MainActivity` 가 네이티브 진동으로 갈아끼운다 (웹 코드는 그대로).
- service worker 등록 안 됨 (`file:///android_asset`) → `sw.js` 는 APK 에 넣지 않는다.
- 뒤로 가기 → 웹의 `window.onAndroidBack()` 이 `true` 를 돌려주면 앱을 닫지 않는다.
  오버레이를 쓰면 여기서 닫는다.
- WebView 에 없는 기능은 `index.html` 을 고치지 말고 안드로이드 쪽(JS 인터페이스 +
  `evaluateJavascript`)에서 메꾼다. 그래야 웹 버전이 영향을 받지 않는다.
