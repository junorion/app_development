#!/usr/bin/env bash
# Play 스토어 스크린샷을 다시 찍는다. WSL2 에서 Windows 의 Chrome 을 헤드리스로 부른다.
#
#   bash sudoku/store/capture.sh
#
# 결과: store/screenshot-1..7.png (한국어), screenshot-en-1..7.png (영어)
# 규격: 1080×1920 (9:16). Play 는 각 변 320~3840px, 종횡비 2:1 이내를 요구한다.
set -euo pipefail

CHROME="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
URL_BASE="file:///$(wslpath -w "$DIR/shots.html" | tr '\\' '/')"

# 순서 = 스토어에 보이는 순서. 첫 두 장이 검색 결과에 뜬다.
SCENES=(
  "home:light"      # 1. 홈 — 레벨·점수·코인, 이어하기/데일리
  "hint:light"      # 2. 설명형 힌트 — 이 앱의 차별점
  "game:light"      # 3. 게임 진행
  "daily:light"     # 4. 데일리 달력
  "game:dark"       # 5. 어두운 화면
  "result:dark"     # 6. 완료 — 점수와 코인
  "stats:dark"      # 7. 기록
)

shoot() {  # shoot <장면> <테마> <언어> <출력파일>
  local scene="$1" theme="$2" lang="$3" out="$4"
  local prof; prof="$(mktemp -d)"
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars \
    --allow-file-access-from-files --force-device-scale-factor=2.6667 \
    --user-data-dir="$(wslpath -w "$prof")" \
    --virtual-time-budget=20000 --window-size=405,720 \
    --screenshot="$(wslpath -w "$out")" \
    "${URL_BASE}?scene=${scene}&theme=${theme}&lang=${lang}" >/dev/null 2>&1
  rm -rf "$prof"
  python3 - "$out" <<'PY'
import struct, sys
p = sys.argv[1]
w, h = struct.unpack('>II', open(p, 'rb').read(33)[16:24])
assert (w, h) == (1080, 1920), f"{p}: {w}x{h}"
print(f"  {p.split('/')[-1]:24s} {w}x{h}")
PY
}

for lang in ko en; do
  suffix=""; [ "$lang" = en ] && suffix="en-"
  echo "── ${lang}"
  n=0
  for entry in "${SCENES[@]}"; do
    n=$((n + 1))
    shoot "${entry%%:*}" "${entry##*:}" "$lang" "$DIR/screenshot-${suffix}${n}.png"
  done
done
