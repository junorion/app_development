# app_development

브라우저에서 바로 실행되는 퍼즐/게임 앱 모음.
**앱 하나당 디렉토리 하나**를 쓰고, 각 디렉토리 안에서 독립적으로 개발한다.

## 실행

- **온라인 (안드로이드 태블릿·폰 포함)**: https://junorion.github.io/app_development/
  - Chrome 메뉴 → *홈 화면에 추가* 를 하면 아이콘으로 실행된다 (두 앱 모두 PWA manifest 를 포함한다).
- **로컬**: 각 앱 디렉토리의 `index.html` 을 브라우저로 열면 된다 (서버 불필요).

## 앱 목록

| 디렉토리 | 앱 | 실행 방법 |
|---|---|---|
| [`sudoku/`](sudoku/) | 브레인 스도쿠 도쿠도쿠 (난이도 4단계, 설명형 힌트, 메모·되돌리기·기록) | [온라인](https://junorion.github.io/app_development/sudoku/) 또는 `sudoku/index.html` |
| [`nqueens/`](nqueens/) | N-Queens 퍼즐 (N=4~10, 타이머·힌트·다크모드) | [온라인](https://junorion.github.io/app_development/nqueens/) 또는 `nqueens/index.html` |

안드로이드 독립 실행 앱(APK)으로도 감쌀 수 있다 — `<앱>/android/` 참고.

## 구조 규칙

- 새 앱은 저장소 루트에 새 디렉토리를 만들어 그 안에서 개발한다.
- 앱별 요구사항 명세는 해당 디렉토리 안에 둔다 (예: `nqueens/CLAUDE_1.md`).
- 공통 설정(`.gitignore`, `.claude/commands/`)과 앱 목록 페이지(`index.html`)는 루트에서 한 번만 관리한다.
- GitHub Pages 는 `main` 브랜치 루트를 그대로 서빙한다 (`.nojekyll` 로 Jekyll 처리를 끈다).
- 비밀정보(ID/비밀번호, API 키, 토큰, 개인키)는 커밋하지 않는다 — `.gitignore` 참고.
