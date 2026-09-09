#!/usr/bin/env bash
# Play 스토어 그래픽 이미지(1024×500) 두 장을 만든다. graphic.html 이 소스다.
set -euo pipefail
CHROME="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
URL="file:///$(wslpath -w "$DIR/graphic.html" | tr '\\' '/')"

for lang in ko en; do
  out="$DIR/feature-graphic.png"; [ "$lang" = en ] && out="$DIR/feature-graphic-en.png"
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars \
    --virtual-time-budget=4000 --window-size=1024,500 \
    --screenshot="$(wslpath -w "$out")" "${URL}?lang=${lang}" >/dev/null 2>&1
  python3 - "$out" <<'PY'
import struct, sys
p = sys.argv[1]
w, h = struct.unpack('>II', open(p, 'rb').read(33)[16:24])
assert (w, h) == (1024, 500), f"{p}: {w}x{h}"
print(f"  {p.split('/')[-1]:26s} {w}x{h}")
PY
done
