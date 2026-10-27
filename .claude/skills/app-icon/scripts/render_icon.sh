#!/usr/bin/env bash
# 아이콘 HTML 을 헤드리스 Chrome(Windows) 으로 512px 스크린샷 → icon-512.png, icon-192.png
#   bash render_icon.sh <icon.html> <출력 디렉토리>
set -euo pipefail
src=$(realpath "$1"); out=$(realpath "$2")
here=$(cd "$(dirname "$0")" && pwd)
chrome="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
tmp=$(mktemp -d)
# Windows 배율 때문에 --window-size 가 CSS 픽셀과 어긋나므로 배율을 1 로 고정한다.
"$chrome" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
  --default-background-color=00000000 --window-size=512,512 \
  --screenshot="$(wslpath -w "$tmp/shot.png")" "file:///$(wslpath -w "$src" | tr '\\' '/')" 2>/dev/null
python3 "$here/png_resize.py" "$tmp/shot.png" "$out/icon-512.png" 512
python3 "$here/png_resize.py" "$tmp/shot.png" "$out/icon-192.png" 192
rm -rf "$tmp"
