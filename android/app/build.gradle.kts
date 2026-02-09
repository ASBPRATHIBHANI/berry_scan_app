plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.berryscan_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.berryscan_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ✅ Keep these FALSE to prevent the "Missing Class" crash
            isMinifyEnabled = false
            isShrinkResources = false
            
            // ✅ Correct way to link ProGuard in Kotlin
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )

            // Keep the signing config (usually debug for testing)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// ✅ UPDATED FIX FOR ANDROID 14 CRASH
configurations.all {
    resolutionStrategy {
        // Force version 1.13.1 which has the "Stylus" fix
        force("androidx.core:core-ktx:1.13.1")
        force("androidx.core:core:1.13.1")
        
        // Keep these as they are safe
        force("androidx.browser:browser:1.8.0")
        force("androidx.activity:activity:1.8.0")
    }
}