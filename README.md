# app_development — 앱 개발 템플릿

junorion 의 앱을 시작할 때 쓰는 GitHub 템플릿 저장소다. 웹(PWA) 단일 HTML + WebView
안드로이드 래퍼 + Node 스텁 테스트 + 공통 Claude Code skill 이 들어 있다.

## 새 앱 만들기

Claude Code 에서 `/new-app` 을 쓰거나, 직접:

```sh
cd /home/noble/app_development
gh repo create junorion/<앱-id> --public --template junorion/app_development --clone
cd <앱-id> && ./init.sh <앱-id> "<한국어 이름>" "<영어 짧은 이름>"
```

## 들어 있는 것

| 경로 | 내용 |
|---|---|
| `index.html` | 시작 화면 — 색 토큰(라이트/다크), safe-area, 저장 헬퍼, 진동, service worker 등록 |
| `manifest.webmanifest`, `sw.js` | PWA (오프라인 실행, 홈 화면 추가) |
| `icon.html`, `icon-*.png` | 아이콘 원본과 산출물 |
| `android/` | WebView APK — 진동 브리지, 뒤로 가기 훅, 릴리스 서명 자리, targetSdk 36 |
| `test/` | `node test/run.js` — `index.html` 스크립트를 스텁 DOM 위에서 돌린다 |
| `CLAUDE.md` | 작업 규칙 (백로그, 검증, 비밀정보, 디자인 원칙, WebView 차이) |
| `BACKLOG.md` | 할 일 목록 틀 |
| `.claude/skills/` | `new-app` `web-verify` `android-build` `app-icon` `play-release` |
| `.claude/commands/` | `/project` `/save` |
| `init.sh` | 템플릿 → 새 앱 (이름·패키지·키 접두사 치환, 실행 후 스스로 지워짐) |

## 템플릿 고치기

앱을 만들다 공통으로 쓸 만한 것이 생기면 이 저장소에 올린다. 이미 만든 앱에는 자동으로
퍼지지 않으므로 필요한 앱에 따로 옮긴다.
