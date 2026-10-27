---
name: play-release
description: Google Play 출시 준비 — 요건(테스터 12명×14일, targetSdk), 스토어 자료(아이콘·그래픽·스크린샷·문안), 개인정보처리방침 페이지, AAB, 사용자가 Play Console 에서 할 단계 안내. 앱을 Play 에 올리거나 업데이트할 때 쓴다.
---

# Play 스토어 출시

완성된 예시: 스도쿠 저장소의 `store/` (`/home/noble/app_development/sudoku/store/`) —
`PUBLISHING.md`(콘솔 단계별 절차), `LISTING.md`(문안·설문 답), `TESTERS.md`(테스터 모집·안내문),
`capture.sh`·`shots.html`(스크린샷), `graphic.html`·`capture-graphic.sh`(그래픽 이미지).
새 앱은 이 파일들을 `store/` 로 복사해 앱에 맞게 고치는 데서 시작한다.

## 먼저 확인할 것 (일정을 좌우함)

1. **개인 개발자 계정은 테스터 12명이 14일 연속** 비공개 테스트에 참여해야 프로덕션을
   신청할 수 있다. 동시에 12명, 한 명이 빠지면 다시 14일 → 15~20명을 모은다.
   **"내부 테스트" 트랙은 세지 않는다** — 반드시 "비공개 테스트". 조직 계정은 면제(D-U-N-S 필요).
2. **targetSdk 요구가 매년 오른다** (2026-08-31 부터 API 36). 출시 전 웹에서 현재 요구를 다시
   확인하고 `compileSdk`/`targetSdk` 를 맞춘다. AGP 도 그에 맞게 올려야 할 수 있다.

## 준비물 체크리스트

| 항목 | 규격 / 방법 |
|---|---|
| AAB | `./gradlew bundleRelease` (`android-build`), 업로드 키 서명, versionCode 증가 |
| 앱 아이콘 | 512×512 **32비트 PNG(알파 포함)** — `icon-512.png` (`app-icon`) |
| 그래픽 이미지 | 1024×500 PNG — HTML 로 그려 `web-verify/scripts/shot.sh graphic.html out.png 1024 500` |
| 휴대전화 스크린샷 | 2~8장, 9:16 권장(예: 1080×1920). 앱 상태를 심은 사본을 찍는다 |
| 문안 | 앱 이름(30자), 짧은 설명(80자), 자세한 설명(4000자) — 한국어·영어 |
| 개인정보처리방침 | `privacy.html` 을 저장소 루트에 두고 Pages 로 서빙: `https://junorion.github.io/<앱-id>/privacy.html` |
| 콘텐츠 등급·데이터 보안·타겟층 | 설문 답을 `store/LISTING.md` 에 미리 적어 둔다 |

## 개인정보처리방침

수집하는 것이 없어도 URL 은 필수다. 스도쿠 `privacy.html` 을 출발점으로 쓰고 **실제와 맞게**
고친다 — 광고(AdMob)·분석·계정·서버를 붙이면 수집 항목과 제3자 제공을 반드시 적고,
Play Console 의 데이터 보안 답도 함께 바꾼다. 문의처는 앱 저장소
(`https://github.com/junorion/<앱-id>`). 배포 후 `curl` 로 200 을 확인한다.

## 사용자 몫 (계정·신원이 걸린 일)

Play Console 작업은 대신 할 수 없다. `store/PUBLISHING.md` 를 앱에 맞게 고쳐 주고,
단계마다 **PC 브라우저**에서 어느 메뉴를 누르는지, 붙여넣을 값과 올릴 파일 경로를 적는다.
앱 이름·광고 여부·유료 여부·계정 유형처럼 되돌리기 어려운 결정은 사용자에게 확인받는다.

## 출시 후 업데이트

versionCode 올림 → `bundleRelease` → 콘솔에서 같은 트랙에 새 버전 → 출시 노트(ko/en).
권한이나 수집 항목이 바뀌면 데이터 보안·개인정보처리방침을 같이 고친다.
