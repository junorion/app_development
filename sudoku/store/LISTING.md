# Play 스토어 등록 자료 — 스도쿠

Play Console 에 그대로 붙여 넣을 수 있게 정리했다. 이 디렉토리의 이미지와 함께 쓴다.
**빌드 산출물(AAB)은 커밋하지 않는다** — `sudoku/android/` 에서 다시 만들면 된다.

## 기본 정보

| 항목 | 값 |
|---|---|
| 앱 이름 (30자 이내) | `스도쿠` |
| 패키지명 | `com.junorion.sudoku` |
| 기본 언어 | 한국어 (ko-KR) · 영어(en-US) 등록정보 추가 |
| 앱 또는 게임 | **게임** |
| 카테고리 | 퍼즐 |
| 유료/무료 | 무료 (인앱 결제 없음, 광고 없음) |
| 개인정보처리방침 URL | `https://junorion.github.io/app_development/sudoku/privacy.html` |
| 연락처 이메일 | *(직접 입력 — 개인 계정은 스토어에 공개 표시된다)* |

## 짧은 설명 (80자 이내)

```
해가 하나뿐인 퍼즐만 골라 냅니다. 광고 없이, 인터넷 없이. 난이도 네 단계.
```

## 자세한 설명 (4000자 이내)

```
매번 새로 만드는 스도쿠입니다. 미리 넣어 둔 문제 목록을 돌려쓰지 않고, 게임을 시작할
때마다 새 퍼즐을 만들어 냅니다.

■ 해가 하나뿐인 문제만
만든 퍼즐이 정말로 답이 하나인지 검사해서, 통과한 것만 내보냅니다. 논리적으로 풀리지
않아 찍어야 하는 문제는 나오지 않습니다.

■ 난이도 네 단계
쉬움 · 보통 · 어려움 · 전문가. 빈칸 개수뿐 아니라 푸는 데 필요한 풀이 기법까지 확인해서
난이도를 정합니다. "어려움"이라 적혀 있는데 실제로는 쉬운 문제가 섞이지 않습니다.

■ 필요한 것은 다 있습니다
· 연필 메모 — 후보 숫자를 작게 적어 둘 수 있습니다
· 숫자를 확정하면 같은 줄·박스의 해당 메모가 저절로 지워집니다
· 되돌리기 / 다시하기 — 횟수 제한 없음
· 힌트 — 막혔을 때 한 칸을 열어 줍니다
· 규칙을 어긴 숫자를 바로 표시합니다
· 고른 칸의 줄·박스와 같은 숫자를 함께 강조합니다
· 숫자판에 각 숫자가 몇 개 남았는지 보여 줍니다
· 시간 측정과 일시정지

■ 이어서 하기와 기록
앱을 껐다 켜도 놓아둔 숫자와 메모, 시간이 그대로 남습니다. 난이도별 완료 횟수와 최고
기록, 평균 시간, 연속 완료 횟수를 모아 둡니다.

■ 광고 없음 · 인터넷 없음
광고를 넣지 않았습니다. 인터넷 권한 자체가 없어서 어떤 서버와도 통신하지 않습니다.
비행기 안에서도, 지하철에서도 그대로 됩니다. 수집하는 개인정보도 없습니다.

■ 눈이 편한 화면
종이에 인쇄한 퍼즐처럼 보이게 만들었습니다. 밝은 화면과 어두운 화면을 고를 수 있고,
휴대폰과 태블릿, 세로와 가로 모두에 맞춰 크기가 조절됩니다.
```

## 영어 등록정보 (en-US)

Play Console 의 **기본 스토어 등록정보 → 언어 추가 → English (United States)** 에 넣는다.
앱 UI 도 기기 언어가 한국어가 아니면 영어로 뜬다.

### App name (30자 이내)

```
Sudoku
```

### Short description (80자 이내)

```
Only puzzles with a single solution. No ads, no internet. Four difficulties.
```

### Full description (4000자 이내)

```
A sudoku that builds a fresh puzzle every time. No recycled list of stored problems —
a new puzzle is generated when you start a game.

■ Every puzzle has exactly one solution
Each generated puzzle is checked to confirm it has one and only one answer. You will never
be forced to guess.

■ Four difficulties
Easy, Normal, Hard, Expert. Difficulty is set by how many blanks there are and confirmed
against the solving techniques a puzzle actually needs, so a puzzle marked "Hard" is never
secretly an easy one.

■ Everything you expect
· Pencil marks for candidate numbers
· Placing a number clears that candidate from its row, column and box automatically
· Undo and redo, with no limit
· Hints when you are stuck
· Numbers that break a rule are flagged as you type
· The selected cell's row, column, box and matching numbers are highlighted
· The keypad shows how many of each number are left
· Timer with pause

■ Resume and records
Close the app and come back — your numbers, pencil marks and time are still there.
Solve counts, best and average times per difficulty, and your win streak are kept.

■ No ads, no internet
There is no advertising. The app does not even request the internet permission, so it
cannot talk to any server. It works on a plane, underground, anywhere. Nothing about you
is collected.

■ Easy on the eyes
Drawn to look like a puzzle printed on paper. Light and dark themes, and a layout that
fits phones and tablets in both portrait and landscape.
```

## 그래픽 자료

| 항목 | 파일 | 규격 |
|---|---|---|
| 앱 아이콘 | `icon-512.png` | 512×512, 32비트 PNG(알파 포함) |
| 그래픽 이미지 | `feature-graphic.png` | 1024×500, 24비트 PNG |
| 스크린샷 1 | `screenshot-1.png` | 864×1920 — 게임 진행(어두운 화면) |
| 스크린샷 2 | `screenshot-2.png` | 864×1920 — 게임 진행(밝은 화면) |
| 스크린샷 3 | `screenshot-3.png` | 864×1920 — 난이도 선택 |
| 스크린샷 4 | `screenshot-4.png` | 864×1920 — 완료 화면 |
| 스크린샷 5 | `screenshot-5.png` | 864×1920 — 기록 |

영어(en-US) 등록정보에는 `screenshot-en-1.png` ~ `screenshot-en-5.png` 를 쓴다 (같은 화면의
영어판). 아이콘과 그래픽 이미지는 언어와 무관하므로 그대로 재사용한다.

휴대전화 스크린샷은 최소 2장이 필요하다. 태블릿 스크린샷은 필수가 아니지만, 넣으면
태블릿 사용자에게 노출이 좋아진다.

## 콘텐츠 등급 설문 (IARC)

모든 항목에 **아니요**로 답하면 된다. 근거를 함께 적어 둔다.

| 질문 범주 | 답 | 근거 |
|---|---|---|
| 폭력 | 아니요 | 숫자 퍼즐뿐이다 |
| 성적 콘텐츠 | 아니요 | 없음 |
| 욕설 | 아니요 | 없음 |
| 통제 물질(술·담배·마약) | 아니요 | 없음 |
| 도박 / 도박 모사 | 아니요 | 없음. 확률 요소나 베팅이 없다 |
| 공포 | 아니요 | 없음 |
| 사용자 간 상호작용 | 아니요 | 네트워크 기능이 없다 |
| 위치 공유 | 아니요 | 위치를 쓰지 않는다 |
| 개인정보 공유 | 아니요 | 수집하지 않는다 |
| 디지털 구매 | 아니요 | 인앱 결제가 없다 |

→ 결과: 전체 이용가 수준

## 데이터 보안 양식

| 질문 | 답 |
|---|---|
| 앱이 사용자 데이터를 수집하거나 공유합니까? | **아니요** |
| 전송 중 데이터 암호화 | 해당 없음 (전송하지 않음) |
| 사용자가 데이터 삭제를 요청할 수 있습니까? | 해당 없음 (수집하지 않음) |

> 기기 안에만 저장하고 밖으로 내보내지 않는 데이터는 Play 기준으로 "수집"이 아니다.
> 진행 상황·기록·테마는 전부 기기 안(localStorage)에만 있다.

## 그 밖의 선언

| 항목 | 답 |
|---|---|
| 광고 포함 | 아니요 |
| 타깃 연령 | 13세 이상 (아동 대상 앱으로 신고하지 않는다 — 가족 정책 요건을 피한다) |
| 정부 앱 | 아니요 |
| 금융 기능 | 아니요 |
| 뉴스 앱 | 아니요 |
| 앱 접근 권한 | 모든 기능이 제한 없이 사용 가능 (로그인 불필요) |
| 데이터 세이프티 - 계정 삭제 | 계정 개념 없음 |

## 서명

Play App Signing 을 쓴다(신규 앱은 사실상 필수). 우리가 만든 키는 **업로드 키**가 되고,
스토어에 배포되는 서명은 Google 이 관리하는 키로 이뤄진다.

- 업로드 키: `~/keystores/sudoku-upload.jks` (별칭 `sudoku-upload`, RSA 4096, 2054년까지)
- 비밀번호: `~/keystores/sudoku-upload.password.txt`
- SHA-256: `88:20:6D:12:C0:50:2C:C7:C6:F1:4A:9E:4E:AF:F3:C0:DF:A6:C6:D8:CB:55:75:8B:D0:C3:2C:05:32:49:E5:13`

**이 두 파일은 반드시 따로 백업한다.** 잃어버리면 같은 앱의 업데이트를 올릴 수 없다
(Play 지원팀을 통해 업로드 키 재설정은 가능하지만 시간이 걸린다).

## 업데이트할 때

`sudoku/android/app/build.gradle` 의 `versionCode` 를 반드시 올린다. 같은 versionCode 는
두 번 업로드할 수 없다. `versionName` 은 사용자에게 보이는 표기다.

```sh
export JAVA_HOME=~/toolchain/jdk-17.0.20.1+1
cd sudoku/android && ./gradlew bundleRelease
# 결과: app/build/outputs/bundle/release/app-release.aab
```
