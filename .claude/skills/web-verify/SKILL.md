---
name: web-verify
description: 웹앱(index.html) 화면·로직을 WSL2 에서 검증한다 — 헤드리스 Chrome 으로 폰/태블릿 너비 라이트·다크 스크린샷, 레이아웃 측정, CSS 토큰 점검, Node 스텁 테스트. 화면에 보이는 변경이나 로직 변경을 커밋하기 전에 쓴다.
---

# 웹앱 검증 (WSL2)

WSL 에는 브라우저가 없어서 Windows 의 Chrome 을 헤드리스로 부른다
(`/mnt/c/Program Files/Google/Chrome/Application/chrome.exe`). 스크립트는 이 skill 의 `scripts/`.

## 1. 스크린샷 — 눈으로 확인

```sh
S=.claude/skills/web-verify/scripts
bash $S/shot.sh index.html <스크래치>/shot-phone.png 390 844 light
bash $S/shot.sh index.html <스크래치>/shot-phone-dark.png 390 844 dark
bash $S/shot.sh index.html <스크래치>/shot-tablet.png 800 1280 light
```
출력은 스크래치 디렉토리에 두고 Read 로 본다. 라이트·다크, 폰·태블릿, 성공/오류 같은
특수 상태를 각각 확인한다. 특수 상태는 상태를 미리 넣은 사본(예: localStorage 키를 심는
`<script>` 를 앞에 붙인 복사본)을 찍는다.

- 헤드리스 Chrome 은 뷰포트를 ~500px 아래로 못 줄인다 → `shot.sh` 가 iframe 에 넣어 찍고 잘라낸다.
- **iframe 안에서 데이터를 비동기로 불러오는 페이지(fetch 후 canvas 그리기 등)는 빈 화면으로 찍힌다.**
  가상 시간이 iframe 의 로딩을 기다려 주지 않는다. 이럴 때는 iframe 없이 폭 500px 로 직접 찍는다
  (500 < 640 이라 휴대폰 배치 판정에는 충분하다):
  `chrome.exe --headless=new --force-device-scale-factor=1 --virtual-time-budget=10000 --window-size=500,1000 --screenshot=... <URL>`
- 정적 빌드(Next.js export 등)는 `/_next/…` 같은 루트 경로를 쓰므로 `file://` 로 안 열린다. 서버로 띄우고
  URL 을 준다. **Windows 의 Chrome 은 WSL 의 127.0.0.1 에 닿지 않는다** → WSL IP 에 묶는다:
  `python3 -m http.server 8123 --bind $(ip -4 addr show eth0 | grep -o 'inet [0-9.]*' | cut -d' ' -f2)`.
  이 주소는 보안 출처가 아니라 위치·카메라 API 는 막힌다(앱은 대체값으로 그려진다).
  서버를 끌 때 `pkill -f "^python3 -m http.server 8123"` 처럼 **명령 시작을 고정**한다 — 그냥 패턴을 쓰면
  pkill 을 실행한 셸 자신이 걸려 죽는다.
- `--window-size` 는 Windows 배율 때문에 CSS 픽셀과 어긋난다 → `--force-device-scale-factor=1` 로 고정.
- **작은 스크린샷에서 글자 색을 눈으로 판단하지 말 것.** 서브픽셀 안티에일리어싱 때문에
  흰 글자가 빨갛게 보이기도 한다. 의심되면 PNG 픽셀 값을 직접 읽는다
  (`app-icon/scripts/png_resize.py` 의 `read_png`).

## 2. 레이아웃 측정 — 숫자로 확인

가로 넘침, 요소 크기처럼 눈으로 애매한 것은 페이지 사본 끝에 측정 스크립트를 심고 DOM 을 덤프한다.
```html
<script>addEventListener("load",()=>{const p=document.createElement("pre");p.id="m";
p.textContent=JSON.stringify({sw:document.documentElement.scrollWidth,cw:document.documentElement.clientWidth,
board:document.querySelector("main").getBoundingClientRect()});document.body.append(p)})</script>
```
```sh
"/mnt/c/Program Files/Google/Chrome/Application/chrome.exe" --headless=new --disable-gpu \
  --virtual-time-budget=1500 --dump-dom "file:///$(wslpath -w copy.html | tr '\\' '/')" | grep -o '<pre id="m">.*</pre>'
```
폰 너비 측정은 `shot.sh` 처럼 iframe 에 넣고 `postMessage` 로 받는다. `sw == cw` 면 가로 넘침 없음.

## 3. CSS 토큰 점검 — 커밋 전 매번

```sh
python3 .claude/skills/web-verify/scripts/check-tokens.py index.html
```
정의되지 않은 토큰, 형식이 틀린 색 값(`#5a6party`), 한 테마에만 있는 토큰을 찾는다.
브라우저는 이런 값을 조용히 무시해서 눈으로는 놓치기 쉽다.

## 4. 로직 테스트

```sh
node test/run.js
```
`test/load-app.js` 가 `index.html` 의 `<script>` 를 스텁 DOM 위에서 평가한다.
`loadApp({ ids, storage })` → `{ run, byId, storage, vibrations }`. `run("expr")` 로 앱 안의
변수·함수에 접근한다. 스텁이 실제 DOM 의 부수효과(`textContent = ""` 가 자식을 비우는 등)를
흉내내지 않으면 가짜 실패가 나므로, 필요한 동작은 `test/dom-stub.js` 에 더한다.
테스트는 반드시 저장소의 `test/` 에 둔다 — 스크래치에 두면 깨진 채 방치된다.

## 5. service worker 를 볼 때

`--virtual-time-budget` 을 쓰면 SW 등록이 AbortError 로 중단된다. SW 는 로컬 서버로 확인한다:
`python3 -m http.server 8123 --bind 127.0.0.1` (https 또는 localhost 에서만 등록됨).
끝나면 서버 프로세스를 반드시 정리한다. 배포 후에는 `curl -s -o /dev/null -w '%{http_code}'` 로 확인.

## 6. 사용자에게 보여줄 때

리눅스 경로와 Windows 경로를 함께 준다: `explorer.exe "$(wslpath -w <경로>)"` 로 바로 열 수도 있다.
실기기에서만 확인되는 것(터치 감, 진동, 홈 화면 추가)은 그렇다고 밝히고 확인을 부탁한다.
