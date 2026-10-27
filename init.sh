#!/usr/bin/env bash
# 템플릿에서 막 만든 저장소를 새 앱으로 바꾼다. 한 번 실행하면 이 파일은 지워진다.
#
#   ./init.sh <앱-id> "<한국어 이름>" "<영어 짧은 이름>"
#   ./init.sh tetris "블록 쌓기" "Blocks"
#
# 앱-id 는 영문 소문자로 시작하고 소문자·숫자만 쓴다. 저장소 이름, 안드로이드 패키지
# (com.junorion.<앱-id>), localStorage 키 접두사, service worker 캐시 이름에 쓰인다.
# 안드로이드 패키지는 Play 에 한 번 올리면 바꿀 수 없으니 신중히 정한다.
set -euo pipefail
cd "$(dirname "$0")"

if [ $# -ne 3 ]; then sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 1; fi
id=$1; ko=$2; en=$3
[[ $id =~ ^[a-z][a-z0-9]*$ ]] || { echo "앱-id 는 영문 소문자로 시작하는 소문자·숫자여야 합니다: $id"; exit 1; }
[ "$id" != myapp ] || { echo "myapp 은 템플릿 자리표시자입니다"; exit 1; }

# 바꿀 파일을 명시한다 — .claude/skills 나 CLAUDE.md 의 설명문까지 바뀌면 안 된다.
files=(
  index.html manifest.webmanifest sw.js test/app.test.js
  android/settings.gradle android/app/build.gradle
  android/app/src/main/java/com/junorion/myapp/MainActivity.java
  android/app/src/main/java/com/junorion/myapp/Haptics.java
  android/app/src/main/res/values/strings.xml
  android/app/src/main/res/values-ko/strings.xml
)
esc() { printf '%s' "$1" | sed 's/[\/&]/\\&/g'; }
gradle_name=$(printf '%s' "$en" | tr -cd '[:alnum:]')
for f in "${files[@]}"; do
  sed -i -e "s/myapp/$id/g" -e "s/\"MyApp\"/\"$(esc "$gradle_name")\"/g" \
         -e "s/My App/$(esc "$en")/g" -e "s/새 앱/$(esc "$ko")/g" "$f"
done
git mv android/app/src/main/java/com/junorion/myapp "android/app/src/main/java/com/junorion/$id"

cat > README.md <<EOF
# $ko

- 웹: https://junorion.github.io/$id/ (GitHub Pages, main 루트)
- 안드로이드: \`android/\` — 웹 소스를 WebView 로 감싼 APK (\`android-build\` skill)
- 테스트: \`node test/run.js\`
- 할 일: [BACKLOG.md](BACKLOG.md)

[app_development](https://github.com/junorion/app_development) 템플릿에서 시작했다.
작업 규칙은 [CLAUDE.md](CLAUDE.md).
EOF

git rm -q --cached init.sh 2>/dev/null || true
rm -f init.sh
echo "$ko ($id) 로 초기화했습니다. 다음: 앱 내용·아이콘(icon.html)·BACKLOG.md 를 채우고 커밋하세요."
