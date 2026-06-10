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
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use(localProperties::load)
}
fun localPropertyOrEnv(name: String): String =
    localProperties.getProperty(name)
        ?: providers.environmentVariable(name).orNull
        ?: ""

fun googleMapsApiKeyValue(name: String): String =
    localPropertyOrEnv(name)
        .removePrefix("keyString:")
        .trim()

fun googleMapsApiKeyFor(environmentName: String): String =
    googleMapsApiKeyValue("GOOGLE_MAPS_ANDROID_API_KEY_$environmentName")
        .ifBlank { googleMapsApiKeyValue("GOOGLE_MAPS_ANDROID_API_KEY") }

val catchAppRole = providers.gradleProperty("catchAppRole").orElse("consumer").get()
if (catchAppRole !in setOf("consumer", "host")) {
    throw GradleException(
        "Unsupported catchAppRole '$catchAppRole'. Use consumer or host."
    )
}
val isHostApp = catchAppRole == "host"
val baseApplicationId = if (isHostApp) "com.catchdates.host" else "com.catchdates.app"

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

// Guard: google-services.json is an environment working copy swapped by
// ./tool/use_firebase_environment.sh. Building a flavor whose package is not in
// the active file otherwise fails deep inside the google-services plugin with a
// cryptic "No matching client" error. Fail early with an actionable message.
val flavorApplicationIds = mapOf(
    "dev" to "$baseApplicationId.dev",
    "staging" to "$baseApplicationId.staging",
    "prod" to baseApplicationId,
)
val requestedFlavor = flavorApplicationIds.keys.firstOrNull { flavor ->
    gradle.startParameter.taskNames.any { task ->
        task.contains(flavor, ignoreCase = true)
    }
}
if (requestedFlavor != null) {
    val googleServicesFiles = listOf(
        project.file("google-services.json"),
        project.file("src/$requestedFlavor/google-services.json"),
    )
    val expectedApplicationId = flavorApplicationIds.getValue(requestedFlavor)
    for (googleServicesFile in googleServicesFiles) {
        if (!googleServicesFile.exists()) {
            continue
        }
        val packagePattern =
            Regex("\"package_name\"\\s*:\\s*\"" + Regex.escape(expectedApplicationId) + "\"")
        if (!packagePattern.containsMatchIn(googleServicesFile.readText())) {
            throw GradleException(
                "${googleServicesFile.path} does not contain the '$requestedFlavor' " +
                    "flavor package ($expectedApplicationId). The checked-in file is an " +
                    "environment working copy — run " +
                    "./tool/use_firebase_environment.sh $requestedFlavor $catchAppRole before building " +
                    "the $requestedFlavor flavor, or use ./tool/flutter_with_env.sh."
            )
        }
    }
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
        applicationId = baseApplicationId
        minSdk = maxOf(26, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKeyValue(
            "GOOGLE_MAPS_ANDROID_API_KEY"
        )
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", if (isHostApp) "Catch Host Dev" else "Catch Dev")
            manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKeyFor("DEV")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", if (isHostApp) "Catch Host Staging" else "Catch Staging")
            manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKeyFor("STAGING")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", if (isHostApp) "Catch Host" else "Catch")
            manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKeyFor("PROD")
        }
    }

    if (isHostApp) {
        sourceSets {
            getByName("dev") {
                res.setSrcDirs(listOf("src/hostDev/res"))
            }
            getByName("staging") {
                res.setSrcDirs(listOf("src/hostStaging/res"))
            }
            getByName("prod") {
                res.setSrcDirs(listOf("src/hostProd/res"))
            }
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
