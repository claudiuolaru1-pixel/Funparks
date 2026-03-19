pluginManagement {
    // Read flutter.sdk from local.properties WITHOUT java.util.Properties
    val localProperties = file("local.properties")
    val flutterSdkPath = if (localProperties.exists()) {
        localProperties.readLines()
            .firstOrNull { it.startsWith("flutter.sdk=") }
            ?.substringAfter("=")
            ?.trim()
    } else null

    if (flutterSdkPath.isNullOrEmpty()) {
        error("flutter.sdk not set in android/local.properties")
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"

    // Android / Kotlin
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false

    // Firebase (Google services)
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")
