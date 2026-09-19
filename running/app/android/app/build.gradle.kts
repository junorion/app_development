plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.junorion.running"
    compileSdk = 37 // 플러그인(permission_handler)이 37 로 컴파일된다. 런타임 동작은 targetSdk 가 정한다
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // 확정 (2026-09-20). Play 에 올린 뒤에는 바꿀 수 없다.
        applicationId = "com.junorion.running"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26 // Android 8.0 (지침 1장)
        targetSdk = 36 // Play 요구 수준 (2026-08-31 부터 API 36)
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 지침 10.4 — dev 는 패키지명이 달라 정식 앱과 나란히 설치된다. 서명이 다른 APK 를 같은
    // 패키지로 덮어쓰면 설치가 거부된다(스도쿠에서 겪었다).
    buildFeatures { resValues = true }
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "톡톡런 진단")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "톡톡런")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
