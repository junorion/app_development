# 작업 규칙

junorion 의 앱 개발 템플릿([app_development](https://github.com/junorion/app_development))에서
만든 저장소다. 앱 하나 = 저장소 하나. 로컬 위치는 `/home/noble/app_development/<앱-id>/`.

## 언어

- 대화, 질문, 보고, 커밋 메시지는 모두 한국어로 한다. 응답 문체는 `.claude/output-styles/natural-korean.md`.
- 경로, 명령어, 식별자, 라이브러리 이름, 로그 인용은 원문 그대로 둔다.
- 커밋 메시지: 첫 줄에 사용자에게 보이는 결과를 한국어로 쓰고, 이유가 diff 로 드러나지 않으면
  빈 줄 뒤에 짧게 적는다. `feat:` 같은 접두사는 쓰지 않는다.

## 구조

| 경로 | 내용 |
|---|---|
| `index.html` | 앱 전체. 단일 HTML(인라인 CSS/JS/SVG), 외부 요청 없음, `file://` 로도 돈다 |
| `manifest.webmanifest`, `sw.js` | PWA. 앱 파일을 바꾸면 `sw.js` 의 `CACHE` 버전을 올린다 |
| `icon.html` → `icon-512.png`, `icon-192.png` | 아이콘 원본과 산출물 (`app-icon` skill) |
| `android/` | WebView APK. 웹 파일은 빌드 때 복사해 쓰고 사본을 커밋하지 않는다 |
| `test/` | Node 스텁 테스트 (`node test/run.js`). 프레임워크 없음 |
| `BACKLOG.md` | 작은 할 일 목록 |
| `PRODUCT.md` | 앱이 무엇이고 누구를 위한 것인지 (`define-product` 가 만든다) |
| `docs/specs/<slug>/spec.md` | 기능 덩어리 하나의 확정된 스펙과 인수 기준 (`shape-idea` 가 만든다) |
| `docs/decisions/` | 다음 작업도 따라야 할 확정된 결정 (`project-knowledge`) |
| `docs/follow-ups/` | 발견했지만 이번에 고치지 않은 문제, 한 파일에 하나 (`project-knowledge`) |
| `GLOSSARY.md` | 이 앱에서 정한 용어 (`project-knowledge`) |

`PRODUCT.md` 와 `docs/` 는 처음부터 만들어 두지 않는다. 해당 skill 이 필요할 때 만든다.

Flutter 처럼 웹이 아닌 앱이면 `index.html`·`sw.js`·`android/`·`test/` 를 지우고
`flutter create` 로 만든 프로젝트를 `app/` 에 둔다. 이 문서와 skill 은 그대로 쓴다.

## 아키텍처 원칙

코드가 단일 파일을 넘어서면 모든 구조 판단은 아래 다섯 가지를 기준으로 한다.
세부 규칙이 없을 때도 이 원칙을 만족하는 쪽을 고른다.

1. 코드는 기술 종류가 아니라 비즈니스 의미 단위로 묶는다.
2. 의존성은 한 방향(위에서 아래)으로만 흐른다.
3. 같은 급의 모듈은 서로를 모른다. 조합은 상위에서 한다.
4. 모듈은 공개 API 로만 노출한다. 내부는 언제든 바꿀 수 있다.
5. 공유 코드는 예상만으로 만들지 않는다. 실제 중복이 확인되면 그때 아래로 추출한다.
   이 템플릿에 무엇을 올릴지도 같은 기준이다.

## 일하는 흐름: 크기에 따라 고른다

| 요청 | 흐름 |
|---|---|
| 버그, 문구·색 수정, 작은 기능 하나 | `BACKLOG.md` 에 등록하고 위에서부터 하나씩. 구체적인 항목은 묻지 말고 진행 |
| 새 앱, 앱 방향 변경 | `define-product` → `PRODUCT.md` |
| 여러 화면·상태에 걸친 기능 덩어리, 결정할 것이 많은 기능 | `shape-idea` → `docs/specs/<slug>/spec.md` → (결과가 여럿이면 `split-into-tasks`) → `implement` |
| 화면 모양을 정해야 할 때 | `build-prototype` 으로 더미 데이터 시안을 만들어 고르게 한다 |
| 큰 결과를 넘기기 전 사용자가 직접 확인하고 싶을 때 | `human-review` |

- 범위가 열려 있거나 되돌리기 어려운 것(서버·계정·광고·결제, 스토어 신고에 영향, 패키지명)은
  어느 흐름이든 확인을 받는다.
- 한 항목 = 검증 → 커밋 → push → 상태 갱신(백로그 표 또는 스펙의 task 상태).
- 이미 출시된 동작과 스펙이 어긋나면 `babysit-specs`, 문서끼리 어긋나면 `maintain-project-context`.

## 검증과 리뷰 예산

혼자 만드는 앱이다. 동작하는 결과가 코드 완결성보다 우선이고, 품질은 실제로 돌려 본 결과로 증명한다.
skill 본문이 더 강한 리뷰를 요구해도 이 예산이 우선한다.

- 화면 변경은 `web-verify` 로 라이트·다크 스크린샷을 눈으로 확인하고, 로직 변경은 `node test/run.js`.
  실기기에서만 볼 수 있는 것(터치 감, 진동, 설치 메뉴, 위치·카메라 권한)은 그렇다고 밝히고
  사용자에게 확인을 부탁한다.
- 자동 코드 리뷰는 `implement` 한 번에 최대 1회, `code-review low` 로만 돌린다.
  리뷰어를 부를 수 없으면 그 사실만 적고 완료로 본다.
- 지적 중 인수 기준을 깨거나 주 경로가 실제로 깨지는 것만 고친다. 나머지는
  `docs/follow-ups/` 에 남기고 재리뷰는 하지 않는다.
- 스펙이 요구하지 않은 보안 하드닝, 엣지 케이스, 성능 방어는 범위 밖이다.

## 기록과 백업

- **백업**: 의미 있는 단위마다 커밋하고 `git push` (SSH, `git@github.com:junorion/<앱-id>.git`).
  혼자 쓰는 저장소라 PR 없이 main 에 바로 올린다.
- **비밀정보 금지**: ID/비밀번호·API 키·토큰·서명 키는 커밋하지 않는다. 새 종류의 설정
  파일을 추가하면 `.gitignore` 에 걸리는지 먼저 확인한다. 서명 키는 `~/keystores/` (저장소 밖).
- **사용자에게 조작을 부탁할 때**: 단계마다 어느 기기(PC 브라우저 / 태블릿 / 폰)에서 하는
  일인지, 붙여넣을 정확한 주소와 버튼 이름을 적는다. `curl` 등으로 내가 먼저 확인할 수
  있는 것은 묻기 전에 확인한다.

## 디자인 원칙

- 앱마다 이름·성격에 맞는 방향을 먼저 정한다. 이전 앱의 스타일을 기본값으로 삼지 않는다.
- 이모지·유니코드 글리프 금지. 아이콘은 인라인 SVG.
- 색은 `:root` 토큰으로만. 라이트/다크 둘 다 확인하고, 커밋 전 정의되지 않은 토큰과
  잘못된 색 값(`#5a6party` 같은 오타는 브라우저가 조용히 무시한다)을 훑는다.
- 상태가 바뀔 때 `innerHTML` 을 통째로 다시 쓰지 말고 DOM 을 유지한 채 클래스만 바꾼다.
  그래야 CSS 전이가 산다.
- loading, empty, error, disabled 상태를 정상 화면과 함께 설계한다.
- 터치 대상 44px 이상, `prefers-reduced-motion` 존중, 짧은 진동 피드백(`haptic()`).
- APK 는 edge-to-edge 로 그려지므로 `env(safe-area-inset-*)` 로 시스템 바를 피한다.

## WebView(APK) 와 Chrome 의 차이

- `navigator.vibrate` 없음 → `MainActivity` 가 네이티브 진동으로 갈아끼운다 (웹 코드는 그대로).
- service worker 등록 안 됨 (`file:///android_asset`) → `sw.js` 는 APK 에 넣지 않는다.
- 뒤로 가기 → 웹의 `window.onAndroidBack()` 이 `true` 를 돌려주면 앱을 닫지 않는다.
  오버레이를 쓰면 여기서 닫는다.
- WebView 에 없는 기능은 `index.html` 을 고치지 말고 안드로이드 쪽(JS 인터페이스 +
  `evaluateJavascript`)에서 메꾼다. 그래야 웹 버전이 영향을 받지 않는다.

## skill

| 묶음 | skill |
|---|---|
| 앱 공통 | `new-app` `web-verify` `android-build` `app-icon` `play-release` |
| 개발 흐름 | `define-product` `shape-idea` `split-into-tasks` `implement` `babysit-specs` `human-review` |
| 지식·도구 | `project-knowledge` `maintain-project-context` `tdd` `build-prototype` `explain-visually` `commit` |

개발 흐름·지식·도구 skill 은 [toy-crane/skills](https://github.com/toy-crane/skills) (MIT) 에서
가져왔다. `commit` 은 한국어 커밋 메시지로 고쳤다. 원본의 Next.js·shadcn·Supabase 전용 skill,
skills CLI 관리용 skill, PR·worktree 흐름 skill 은 넣지 않았다.
