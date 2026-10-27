---
name: app-icon
description: 앱 아이콘(icon-512.png, icon-192.png)을 icon.html 에서 만든다 — 헤드리스 Chrome 렌더링 + 순수 파이썬 PNG 리샘플, Play 가 요구하는 32비트 RGBA. 아이콘을 새로 그리거나 바꿀 때 쓴다.
---

# 앱 아이콘 만들기

WSL 에 이미지 라이브러리(PIL, ImageMagick)가 없다. 그래서 아이콘을 **HTML/SVG 로 그리고**
Chrome 으로 찍은 뒤, `zlib`/`struct` 만 쓰는 파이썬으로 RGBA 변환·축소한다.

```sh
bash .claude/skills/app-icon/scripts/render_icon.sh icon.html .
# → ./icon-512.png (512, RGBA), ./icon-192.png (192, RGBA)
```
그 다음 Read 로 `icon-192.png` 를 열어 눈으로 확인한다.

## 그리는 규칙

- `icon.html` 은 512×512 고정, `body` 에 배경을 **가장자리까지** 채운다. manifest 의
  `purpose: "any maskable"` 과 안드로이드 adaptive icon 이 둥글게·사각으로 잘라내므로,
  그림은 **가운데 80%(약 410px) 안**에 둔다.
- 앱 안의 그림(로고, 말, 보드)과 같은 그림을 쓴다 — 홈 화면 아이콘과 앱 첫 화면이 같아야 한다.
- 이모지·시스템 글꼴 글자를 쓰지 않는다 (기기마다 달라 보인다). 글자가 꼭 필요하면 SVG path 로.
- 바꾼 뒤 `sw.js` 의 `CACHE` 버전을 올린다 — 안 그러면 설치된 PWA 가 옛 아이콘을 쥐고 있다.

## 산출물이 쓰이는 곳

| 파일 | 쓰는 곳 |
|---|---|
| `icon-512.png` | manifest, Play 스토어 앱 아이콘(512×512 **32비트 PNG** 필수 — 24비트는 거부될 수 있다), 안드로이드 런처(빌드 때 `mipmap-xxxhdpi` 로 복사) |
| `icon-192.png` | manifest, favicon, apple-touch-icon |

## 스크립트

- `render_icon.sh <icon.html> <출력 디렉토리>` — Chrome 스크린샷(배율 1 고정) → 두 크기
- `png_resize.py <입력> <출력> <px>` — 8비트 RGB/RGBA PNG 를 RGBA 로, 면적 평균 축소.
  `read_png`/`write_png` 는 다른 스크립트에서 import 해 픽셀을 직접 읽을 때도 쓴다.
  스토어 그래픽 이미지(1024×500)처럼 정사각형이 아닌 것은 `web-verify` 의 `shot.sh` 로 찍는다.
