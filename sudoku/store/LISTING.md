# Play 스토어 등록 자료 — 브레인 스도쿠 도쿠도쿠

Play Console 에 그대로 붙여 넣을 수 있게 정리했다. 이 디렉토리의 이미지와 함께 쓴다.
**빌드 산출물(AAB)은 커밋하지 않는다** — `sudoku/android/` 에서 다시 만들면 된다.

## 기본 정보

| 항목 | 값 |
|---|---|
| 앱 이름 (30자 이내) | `브레인 스도쿠 도쿠도쿠` |
| 패키지명 | `com.junorion.sudoku` |
| 기본 언어 | 한국어 (ko-KR) · 영어(en-US) 등록정보 추가 |
| 앱 또는 게임 | **게임** |
| 카테고리 | 퍼즐 |
| 유료/무료 | 무료 (인앱 결제 없음, 광고 없음) |
| 개인정보처리방침 URL | `https://junorion.github.io/app_development/sudoku/privacy.html` |
| 연락처 이메일 | *(직접 입력 — 개인 계정은 스토어에 공개 표시된다)* |

## 짧은 설명 (80자 이내)

```
해가 하나뿐인 퍼즐만. 왜 그 숫자인지 설명해 주는 힌트. 매일 새 데일리. 광고 없이.
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

■ 답이 아니라 이유를 알려 주는 힌트
막혔을 때 힌트를 누르면 숫자만 채워 주지 않습니다. "이 3×3 박스에서 5가 들어갈 수 있는
칸은 여기 하나뿐"처럼 근거를 설명하고, 그 근거가 되는 칸을 보드에서 함께 짚어 줍니다.
숫자는 직접 확인하고 적용을 눌러야 들어갑니다. 잘못 놓은 숫자가 있으면 그것부터 알려 줍니다.
힌트 하나에 코인 하나가 들고, 한 판을 끝낼 때마다 코인이 하나씩 쌓입니다.

■ 매일 새 퍼즐, 데일리
날짜마다 정해진 문제가 하나씩 있습니다. 서버가 없어도 같은 날이면 어느 기기에서나 같은
문제가 나옵니다. 달력에서 지난 날짜도 풀 수 있고, 끝낸 날은 표시로 남습니다. 데일리는
점수를 1.5배로 받습니다.

■ 점수와 레벨
난이도와 걸린 시간, 쓴 힌트 수로 점수가 매겨지고, 점수가 쌓이면 레벨이 오릅니다. 오늘
얼마나 했는지 홈 화면에서 한눈에 보입니다.

■ 필요한 것은 다 있습니다
· 연필 메모 — 후보 숫자를 작게 적어 둘 수 있습니다
· 자동 메모 — 시작할 때 모든 빈칸에 후보를 채워 둘 수 있습니다 (켜고 끌 수 있습니다)
· 숫자를 확정하면 같은 줄·박스의 해당 메모가 저절로 지워집니다
· 되돌리기 / 다시하기 — 횟수 제한 없음
· 규칙을 어긴 숫자를 바로 표시합니다
· 고른 칸의 줄·박스와 같은 숫자를 함께 강조합니다
· 숫자를 먼저 고르고 칸을 찍는 입력 방식도 고를 수 있습니다
· 숫자판에 각 숫자가 몇 개 남았는지 보여 줍니다
· 시간 측정과 일시정지
· 설정에서 입력 방식 · 자동 메모 · 진동 · 오류 표시 · 시간 표시를 끄고 켤 수 있습니다

■ 이어서 하기와 기록
앱을 껐다 켜도 놓아둔 숫자와 메모, 시간이 그대로 남습니다. 난이도별 완료 횟수와 최고
기록, 평균 시간, 연속 완료 횟수를 모아 둡니다.

■ 광고 없음 · 인터넷 없음
광고를 넣지 않았습니다. 인터넷 권한 자체가 없어서 어떤 서버와도 통신하지 않습니다.
비행기 안에서도, 지하철에서도 그대로 됩니다. 수집하는 개인정보도 없습니다.

■ 눈이 편한 화면
숫자가 크고 군더더기가 없습니다. 밝은 화면과 어두운 화면을 고를 수 있고, 휴대폰과
태블릿, 세로와 가로 모두에 맞춰 크기가 조절됩니다. 한국어와 영어를 지원합니다.
```

## 영어 등록정보 (en-US)

Play Console 의 **기본 스토어 등록정보 → 언어 추가 → English (United States)** 에 넣는다.
앱 UI 도 기기 언어가 한국어가 아니면 영어로 뜬다.

### App name (30자 이내)

```
Brain Sudoku Dokudoku
```

### Short description (80자 이내)

```
Single-solution puzzles, with hints that explain why. No ads, no internet.
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

■ Hints that explain, not just answer
When you are stuck, a hint does not simply fill a cell. It tells you why — "in this 3×3 box,
5 can only go in the marked cell" — and highlights the cells that make it true. You place the
number yourself by tapping Apply. If you have put a wrong number down, it says so first.
A hint costs one coin, and you earn a coin every time you finish a puzzle.

■ A new puzzle every day
Every date has its own puzzle. There is no server, yet the same day gives the same puzzle on
every device. You can go back and solve earlier days from the calendar, and finished days stay
marked. Daily puzzles are worth 1.5× the points.

■ Points and levels
Points come from the difficulty, your time and how many hints you used, and they add up to
levels. The home screen shows where you stand at a glance.

■ Everything you expect
· Pencil marks for candidate numbers
· Auto pencil marks — start a puzzle with every candidate filled in (optional)
· Placing a number clears that candidate from its row, column and box automatically
· Undo and redo, with no limit
· Numbers that break a rule are flagged as you type
· The selected cell's row, column, box and matching numbers are highlighted
· Pick a number first and tap cells, if you prefer that way round
· The keypad shows how many of each number are left
· Timer with pause
· Settings for input style, auto notes, vibration, mistake marking and the timer

■ Resume and records
Close the app and come back — your numbers, pencil marks and time are still there.
Solve counts, best and average times per difficulty, and your win streak are kept.

■ No ads, no internet
There is no advertising. The app does not even request the internet permission, so it
cannot talk to any server. It works on a plane, underground, anywhere. Nothing about you
is collected.

■ Easy on the eyes
Big, uncluttered numbers. Light and dark themes, and a layout that fits phones and tablets
in both portrait and landscape. Korean and English.
```

## 그래픽 자료

| 항목 | 파일 | 규격 |
|---|---|---|
| 앱 아이콘 | `icon-512.png` | 512×512, 32비트 PNG(알파 포함) |
| 그래픽 이미지 (한국어) | `feature-graphic.png` | 1024×500, 24비트 PNG |
| 그래픽 이미지 (영어) | `feature-graphic-en.png` | 1024×500 |
| 스크린샷 1 | `screenshot-1.png` | 1080×1920 — 홈 (레벨·점수·코인) |
| 스크린샷 2 | `screenshot-2.png` | 1080×1920 — 설명형 힌트 |
| 스크린샷 3 | `screenshot-3.png` | 1080×1920 — 게임 진행 (밝은 화면) |
| 스크린샷 4 | `screenshot-4.png` | 1080×1920 — 데일리 달력 |
| 스크린샷 5 | `screenshot-5.png` | 1080×1920 — 게임 진행 (어두운 화면) |
| 스크린샷 6 | `screenshot-6.png` | 1080×1920 — 완료 (점수와 코인) |
| 스크린샷 7 | `screenshot-7.png` | 1080×1920 — 기록 |

영어(en-US) 등록정보에는 `screenshot-en-1.png` ~ `screenshot-en-7.png` 와
`feature-graphic-en.png` 를 쓴다. 아이콘은 글자가 없으므로 그대로 재사용한다.

**규격 주의**: Play 는 스크린샷의 각 변이 320~3840px, **종횡비가 2:1 이내**여야 한다.
예전에 쓰던 864×1920 은 2.22:1 이라 규격을 벗어나 있었다. 지금은 1080×1920(9:16)이다.

**다시 찍는 법**: 화면을 고쳤으면 아래를 돌린다. 앱 화면을 직접 캡처하므로 손으로 맞춘
가짜 이미지가 아니다.

```bash
bash sudoku/store/capture.sh          # 스크린샷 14장 (한국어 7 + 영어 7)
bash sudoku/store/capture-graphic.sh  # 그래픽 이미지 2장
```

`capture.sh` 는 `shots.html` 을, `capture-graphic.sh` 는 `graphic.html` 을 소스로 쓴다.
장면을 바꾸거나 늘리려면 그 두 파일을 고친다.

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
