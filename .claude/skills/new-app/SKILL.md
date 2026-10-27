---
name: new-app
description: 새 앱을 시작한다 — app_development 템플릿으로 GitHub 저장소(junorion/<앱-id>)를 만들고, 작업 공간에 클론해 init.sh 로 이름·패키지를 바꾸고, 첫 커밋·push·Pages 까지 켠다. "새 앱 만들자", "○○ 앱 시작" 같은 요청에 쓴다.
---

# 새 앱 시작

작업 공간: `/home/noble/app_development/` (git 아님). 앱마다 그 아래 디렉토리 = 저장소 하나.
템플릿: `junorion/app_development` (로컬 `/home/noble/app_development/hub/`).

## 1. 정할 것

- **한국어 이름 / 영어 짧은 이름** — 사용자가 말하지 않았으면 2~3개 제안하고 고르게 한다
  (스토어에 노출되는 이름이라 사용자 몫).
- **앱-id** — 영문 소문자+숫자, 짧게. 저장소 이름·`com.junorion.<앱-id>`·저장 키 접두사가 된다.
  패키지명은 Play 에 올린 뒤 못 바꾸므로 제안하고 확인받는다.
- **종류** — 웹(PWA + WebView APK, 기본) 인지, 네이티브 기능이 많아 Flutter 인지.
- **공개 범위** — 웹앱은 무료 Pages 를 쓰려면 public. Flutter/비공개 실험은 private.

이미 있는 이름인지 먼저 본다: `gh repo view junorion/<앱-id>` 가 실패해야 한다.

## 2. 만들기

```sh
cd /home/noble/app_development
gh repo create junorion/<앱-id> --public --template junorion/app_development --clone
cd <앱-id>
git config user.name junorion && git config user.email junorion@gmail.com
./init.sh <앱-id> "<한국어 이름>" "<영어 짧은 이름>"
node test/run.js
git add -A && git commit -m "<한국어 이름> — 템플릿에서 시작"
git push
```
- 템플릿 복제가 비동기라 `--clone` 이 빈 저장소를 받거나 실패하면 몇 초 뒤
  `git pull origin main` (또는 `gh repo clone`) 으로 다시 받는다.
- 커밋 메시지 끝에는 시스템이 알려주는 Co-Authored-By 줄을 붙인다.

**Flutter 앱이면**: init 후 `index.html manifest.webmanifest sw.js icon.html icon-*.png android test .nojekyll`
를 지우고, `export PATH=~/toolchain/flutter/bin:$PATH` 후 `flutter create --org com.junorion --project-name <앱-id> app`.
CLAUDE.md 의 구조 표를 Flutter 에 맞게 고친다. `.gitignore` 는 그대로 두고 `app/.gitignore` 가 더해진다.

## 3. Pages (웹앱)

```sh
gh api -X POST repos/junorion/<앱-id>/pages -f 'source[branch]=main' -f 'source[path]=/'
```
1~2분 뒤 `curl -s -o /dev/null -w '%{http_code}' https://junorion.github.io/<앱-id>/` 가 200 인지
확인한다 (백그라운드 반복 확인 — 포그라운드 sleep 금지). 태블릿에서 404 가 나면 Chrome 이
빌드 전 404 를 캐시한 것이니 시크릿 탭으로 열게 한다.

## 4. 기록

- 앱 방향이 아직 흐리면 `define-product` 로 `PRODUCT.md` 부터 만든다. 작은 앱이면
  `BACKLOG.md` 에 요구를 등록하고 첫 항목부터 진행한다 (크기별 흐름은 `CLAUDE.md`).
- 메모리에 `<앱-id>-status.md` (type: project) 를 만들고 MEMORY.md 에 한 줄 추가한다 —
  이름, 저장소, 주소, 종류, 지금 단계.
- 사용자에게: 저장소 주소, 웹 주소, 로컬 경로, 다음 할 일을 짧게 알린다.

## 템플릿 자체를 고칠 때

앱을 만들다 공통으로 쓸 만한 것(스크립트, skill, 규칙)이 생기면 `hub/` 에서 고쳐 커밋·push 한다.
이미 만든 앱에는 자동으로 퍼지지 않는다 — 필요한 앱에 따로 옮긴다.
