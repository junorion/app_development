# app_development

**앱마다 별도 저장소로 옮겼다 (2026-10-27).** 이 저장소는 옛 주소를 살려두기 위한 허브로만 남는다.
분리 전 히스토리는 이 저장소에 그대로 있고, 각 앱 저장소에도 `git subtree split` 으로 보존했다.

## 앱 저장소

| 저장소 | 앱 | 실행 |
|---|---|---|
| [junorion/sudoku](https://github.com/junorion/sudoku) | 브레인 스도쿠 도쿠도쿠 | [온라인](https://junorion.github.io/sudoku/) |
| [junorion/nqueens](https://github.com/junorion/nqueens) | N-Queens 퍼즐 | [온라인](https://junorion.github.io/nqueens/) |
| junorion/score (비공개) | 악보 추출 앱 (개발 중) | — |
| junorion/running (비공개) | 톡톡런 — 러닝 기록 앱 (개발 중) | — |

## 이 저장소에 남은 것

- `index.html` — 앱 목록 랜딩 페이지 (https://junorion.github.io/app_development/)
- `sudoku/index.html`, `nqueens/index.html` — 옛 주소로 들어오면 새 주소로 넘긴다
- `sudoku/sw.js`, `nqueens/sw.js` — 옛 주소에 설치된 PWA 서비스워커를 스스로 해제한다
- `sudoku/privacy.html` — Play 스토어에 등록된 개인정보처리방침 URL이라 **지우면 안 된다**
  (`sudoku` 저장소의 `privacy.html` 을 고치면 여기에도 똑같이 반영한다)
- `.claude/commands/` — 작업 공간 공통 Claude Code 명령
