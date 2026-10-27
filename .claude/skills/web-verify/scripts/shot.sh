#!/usr/bin/env bash
# 페이지를 원하는 CSS 픽셀 크기로 헤드리스 Chrome(Windows) 스크린샷한다.
#   bash shot.sh <page.html | http://...> <out.png> [폭=390] [높이=844] [light|dark]
# 정적 빌드(Next export 등)처럼 루트 경로로 자산을 부르는 페이지는 로컬 서버 URL 을 준다.
# 헤드리스 Chrome 은 뷰포트를 ~500px 아래로 줄이지 못하므로, 큰 창 안에 원하는 폭의
# iframe 을 띄워 찍고 그 영역만 잘라낸다. 테마는 prefers-color-scheme 으로 준다 — 매번 새
# 프로필이라 localStorage 가 비어 있어, 저장된 테마가 없는 첫 실행 상태로 찍힌다.
set -euo pipefail
out=$(realpath -m "$2"); W=${3:-390}; H=${4:-844}; theme=${5:-light}
here=$(cd "$(dirname "$0")" && pwd)
chrome="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
tmp=$(mktemp -d)
case "$1" in
  http://*|https://*) url=$1 ;;
  *) url="file:///$(wslpath -w "$(realpath "$1")" | tr '\\' '/')" ;;
esac
cat > "$tmp/frame.html" <<HTML
<!DOCTYPE html><html><body style="margin:0;background:#000">
<iframe src="$url" style="border:0;display:block;width:${W}px;height:${H}px"></iframe>
</body></html>
HTML
winW=$(( W < 600 ? 600 : W ))
dark=(); [ "$theme" = dark ] && dark=(--force-dark-mode)
"$chrome" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
  --allow-file-access-from-files --virtual-time-budget=${SHOT_WAIT_MS:-1500} --window-size=$winW,$H "${dark[@]}" \
  --screenshot="$(wslpath -w "$tmp/shot.png")" "file:///$(wslpath -w "$tmp/frame.html" | tr '\\' '/')" 2>/dev/null
python3 "$here/pngcrop.py" "$tmp/shot.png" "$out" "$W" "$H"
rm -rf "$tmp"
