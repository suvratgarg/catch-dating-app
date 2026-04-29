import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val releaseBuildRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
val requiredKeystoreProperties = listOf(
    "storeFile",
    "storePassword",
    "keyAlias",
    "keyPassword",
)

if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use(keystoreProperties::load)

    val invalidKeystoreProperties = requiredKeystoreProperties.filter { key ->
        val value = keystoreProperties.getProperty(key)?.trim()
        value.isNullOrEmpty() || value == "change-me"
    }

    if (invalidKeystoreProperties.isNotEmpty()) {
        throw GradleException(
            "Invalid Android release signing config in ${keystorePropertiesFile.path}. " +
                "Replace placeholder values for: ${invalidKeystoreProperties.joinToString()}."
        )
    }
} else if (releaseBuildRequested) {
    throw GradleException(
        "Missing Android release signing config: ${keystorePropertiesFile.path}. " +
            "Copy android/key.properties.example to android/key.properties, point it at a real " +
            "upload keystore, and keep both files out of git."
    )
}

val releaseStoreFile = if (keystorePropertiesFile.exists()) {
    file(keystoreProperties.getProperty("storeFile"))
} else {
    null
}

if (releaseBuildRequested && releaseStoreFile != null && !releaseStoreFile.exists()) {
    throw GradleException(
        "Android release keystore does not exist: ${releaseStoreFile.path}. " +
            "Create the upload keystore or update storeFile in ${keystorePropertiesFile.path}."
    )
}

android {
    namespace = "com.catchdates.app"
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
        applicationId = "com.catchdates.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Catch Dev")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "Catch Staging")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Catch")
        }
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = releaseStoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
                    .also { signingConfig = it }
            }
        }
    }
}

flutter {
    source = "../.."
}
