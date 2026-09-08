# N-Queens 안드로이드 앱

`nqueens/index.html` 을 그대로 APK 안에 담아 실행하는 WebView 껍데기다.
웹 앱을 고치면 여기서는 아무것도 손대지 않고 다시 빌드만 하면 된다 —
`syncWebApp` 태스크가 상위 디렉토리의 자산을 빌드할 때마다 복사한다.

- 인터넷 권한이 없다. GitHub Pages 에 접속하지 않는 완전 오프라인 앱이다.
- 외부 라이브러리 의존이 없다 (androidx 포함). AGP 와 안드로이드 프레임워크뿐이다.
- `sw.js` 는 담지 않는다. `file:///android_asset` 에서는 service worker 가 등록되지
  않고, 파일이 이미 앱 안에 있어 캐시할 이유도 없다.

## 빌드

JDK 17 과 Android SDK(platform 34, build-tools 34.0.0)가 필요하다.
`local.properties` 에 `sdk.dir` 을 적어야 한다 (커밋하지 않는다).

```sh
export JAVA_HOME=~/toolchain/jdk-17.0.20.1+1
./gradlew assembleDebug
# 결과: app/build/outputs/apk/debug/app-debug.apk
```

## 설치 (사이드로드)

APK 를 태블릿으로 옮긴 뒤 파일 관리자에서 눌러 설치한다.
안드로이드가 "이 출처의 앱 설치" 권한을 물으면 허용해야 한다.
디버그 서명이라 Play 스토어 배포에는 쓸 수 없다.
