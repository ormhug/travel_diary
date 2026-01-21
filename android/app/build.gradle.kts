plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ha"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        // Включаем поддержку Java 8 (Desugaring)
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.ha"
        // Для уведомлений нужен минимум 21
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ВАЖНО: Используем синтаксис add() - это решает ошибку Unresolved reference
    add("coreLibraryDesugaring", "com.android.tools:desugar_jdk_libs:2.0.4")
}
