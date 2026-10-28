---
name: android-build
description: 웹앱을 감싼 WebView APK/AAB 를 빌드·점검하고 실기기에 보낼 준비를 한다 — JDK·SDK 경로, 디버그/릴리스 서명, versionCode, aapt 정적 점검. 에뮬레이터는 쓸 수 없다. APK 를 만들거나 안드로이드 쪽을 고칠 때 쓴다.
---

# 안드로이드 빌드 (WebView 래퍼)

## 환경 (sudo 없이 홈에 설치됨)

```sh
export JAVA_HOME=~/toolchain/jdk-17.0.20.1+1      # PATH 에 java 가 없어 매번 필요
cd android
[ -f local.properties ] || echo "sdk.dir=$HOME/Android/sdk" > local.properties   # .gitignore 됨
```
SDK: `~/Android/sdk` (build-tools 의 `aapt` 로 점검). Gradle 은 wrapper(`./gradlew`)를 쓴다.
**에뮬레이터는 못 쓴다** (`/dev/kvm` 권한 없음) → 정적 점검 + 실기기.

## 빌드

| 목적 | 명령 | 산출물 |
|---|---|---|
| 빠른 확인 | `./gradlew -q assembleDebug` | `app/build/outputs/apk/debug/app-debug.apk` |
| 실기기 설치 | `./gradlew -q assembleRelease` | `app/build/outputs/apk/release/app-release.apk` |
| Play 업로드 | `./gradlew -q bundleRelease` | `app/build/outputs/bundle/release/app-release.aab` |

빌드할 때마다 `syncWebApp` 태스크가 저장소 루트의 `index.html`·manifest·아이콘을 복사한다.
웹 파일을 더 추가했으면(폰트, 이미지) `app/build.gradle` 의 `include` 목록에 넣는다.
`sw.js` 는 넣지 않는다 (WebView 의 `file://` 에서는 등록되지 않는다).

## 서명

- 디버그 서명과 릴리스 서명은 **덮어쓰기 설치가 안 된다** ("앱이 설치되지 않습니다").
  한 번 릴리스로 설치한 기기에는 계속 릴리스 APK 를 보낸다. 디버그로 바꾸려면 앱을 지워야
  하고 그러면 저장된 기록도 지워진다 — 사용자에게 미리 말한다.
- 릴리스 키는 저장소 밖 `~/keystores/<앱-id>-upload.jks`, 비밀번호는
  `~/keystores/<앱-id>-upload.password.txt` (권한 600). 없으면 만든다:
  ```sh
  mkdir -p ~/keystores && chmod 700 ~/keystores
  PW=$(openssl rand -base64 24 | tr -d '/+=' | cut -c1-24)
  printf '%s\n' "$PW" > ~/keystores/<앱-id>-upload.password.txt && chmod 600 ~/keystores/<앱-id>-upload.password.txt
  $JAVA_HOME/bin/keytool -genkeypair -keystore ~/keystores/<앱-id>-upload.jks -alias <앱-id>-upload \
    -keyalg RSA -keysize 4096 -validity 10000 -storepass "$PW" -keypass "$PW" -dname "CN=junorion"
  ```
- `android/keystore.properties` (`.gitignore` 됨 — 커밋 전 `git status` 로 다시 확인):
  ```
  storeFile=/home/noble/keystores/<앱-id>-upload.jks
  storePassword=...
  keyAlias=<앱-id>-upload
  keyPassword=...
  ```
- **업로드 키를 잃으면 그 앱은 업데이트할 수 없다.** 만들었으면 사용자에게 백업을 권한다.

## 버전

Play 에 올리거나 기기에 업데이트로 설치할 때마다 `app/build.gradle` 의 `versionCode` 를
1 올린다 (내려가면 설치 거부). `versionName` 은 사람이 읽는 표기.

## 정적 점검 (빌드 후 매번)

```sh
AAPT=$(ls -d ~/Android/sdk/build-tools/*/ | tail -1)aapt
$AAPT dump badging <apk> | grep -E "^package|application-label|sdkVersion|targetSdk"
unzip -l <apk> | grep -E "assets/|mipmap"
```
패키지명·버전·targetSdk, 자산(index.html 이 최신인지 크기로), 아이콘이 들어갔는지 본다.
Play 의 targetSdk 요구는 매년 오른다 — 출시 전 현재 요구를 확인한다 (`play-release`).

## 실기기로 보내기

APK 를 Windows 다운로드 폴더로 복사하고 사용자에게 전달·설치를 부탁한다:
```sh
cp app/build/outputs/apk/release/app-release.apk "/mnt/c/Users/junor/Downloads/<앱-id>-<versionName>.apk"
```
안내에는 기기(태블릿/폰), 전달 방법, "출처를 알 수 없는 앱 설치 허용" 위치를 적는다.
테스트 태블릿은 **진동 모터가 없다** — 진동은 V35 폰에서 보거나 확인 불가로 표시한다.

## 프레임워크 정적 빌드(Next.js 등)를 감쌀 때

단일 HTML 이 아니라 빌드 결과 디렉토리(`out/` 등)를 담는 경우. 실제 예: `junorion/starmap` 의 `android/`.

- 루트 경로(`/_next/…`, `/data/…`)로 파일을 부르므로 `file:///android_asset` 로는 안 열린다.
  `androidx.webkit` 의 `WebViewAssetLoader` 로 `https://appassets.androidplatform.net/` 에서 내주고
  `gradle.properties` 에 `android.useAndroidX=true`. https 라서 위치·카메라 API 도 쓸 수 있다.
  `/` → `index.html`, 확장자 없는 경로 → `.html` 로 바꿔 주는 PathHandler 를 직접 둔다.
- **aapt 는 밑줄로 시작하는 디렉토리를 자산에서 뺀다**(기본 무시 패턴 `<dir>_*`). `_next/` 가 통째로 빠져
  빈 화면이 된다. `androidResources { ignoreAssetsPattern "!.svn:!.git:!.ds_store:!*.scc:.*:!CVS:!thumbs.db:!picasa.ini:!*~" }`
  로 바꾸고, 빌드 후 `out/` 파일 수와 APK 의 `assets/` 파일 수가 같은지 비교한다.
- 복사 태스크는 `Copy` 가 아니라 `Sync` 로 둔다. `Copy` 는 지워진 파일을 정리하지 않아, 해시가 바뀐 옛 청크가
  APK 에 계속 남는다(starmap 에서 5개가 남았다).
- 웹 빌드를 먼저 해야 한다. `syncWebApp` 이 `out/index.html` 이 없으면 멈추게 해 둔다.
- 위치: `WebChromeClient.onGeolocationPermissionsShowPrompt` 에서 런타임 권한을 요청하고, 결과를
  `callback.invoke(origin, granted, false)` 로 돌려준다. 매니페스트에 COARSE/FINE 둘 다.
- ESLint 같은 웹 도구가 `android/**/build/**` 의 복사본까지 검사하지 않게 무시 목록에 넣는다.

## WebView 에서 꼭 지킬 것 (빠뜨리면 조용히 망가짐)

- `configChanges="orientation|screenSize|..."` — 없으면 회전 때 WebView 가 새로 만들어져 상태가 날아간다.
- `addJavascriptInterface` 클래스는 **최상위 public** (리플렉션 호출).
- JS 인터페이스를 붙였으면 `shouldOverrideUrlLoading` 으로 `android_asset` 밖 이동을 막는다.
- `setDomStorageEnabled(true)` — localStorage 저장.
- targetSdk 35+ 는 edge-to-edge 강제 → 웹 쪽에서 `env(safe-area-inset-*)` 로 시스템 바를 피한다.
