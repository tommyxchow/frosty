import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val envProperties = Properties()
val envPropertiesFile = rootProject.file("../.env")
if (envPropertiesFile.exists()) {
    envPropertiesFile.inputStream().use { envInput ->
        envInput
            .bufferedReader()
            .lineSequence()
            .map(String::trim)
            .filter { line -> line.isNotEmpty() && !line.startsWith("#") }
            .forEach { line ->
                val separatorIndex = line.indexOf("=")
                if (separatorIndex > 0) {
                    val key = line.substring(0, separatorIndex).trim()
                    val value = line.substring(separatorIndex + 1)
                        .trim()
                        .trim('"')
                        .trim('\'')
                    envProperties.setProperty(key, value)
                }
            }
    }
}

fun resolveConfigValue(name: String): String {
    return providers.gradleProperty(name).orNull
        ?: System.getenv(name)
        ?: envProperties.getProperty(name)
        ?: ""
}

fun String.asAndroidStringResource(): String {
    return "\"${replace("\\", "\\\\").replace("\"", "\\\"")}\""
}

android {
    namespace = "com.namecallfilter.glacier"
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
        applicationId = "com.namecallfilter.glacier"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        resValue(
            "string",
            "cast_receiver_app_id",
            resolveConfigValue("CAST_RECEIVER_APP_ID").asAndroidStringResource(),
        )
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("debug") {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
        release {
            // Use the real upload key when key.properties is present (release
            // workflows create it from secrets). Allow debug signing only when a CI
            // compile-only check explicitly opts in via ALLOW_DEBUG_SIGNED_RELEASE;
            // otherwise fail loudly so a real release can never be silently
            // debug-signed if the keystore step is ever missing.
            signingConfig = when {
                keystorePropertiesFile.exists() -> signingConfigs.getByName("release")
                System.getenv("ALLOW_DEBUG_SIGNED_RELEASE") != null -> signingConfigs.getByName("debug")
                else -> error("key.properties missing - set ALLOW_DEBUG_SIGNED_RELEASE=1 for compile-only builds")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.webkit:webkit:1.15.0")
    implementation("com.google.android.gms:play-services-cast-framework:22.3.1")
    testImplementation("junit:junit:4.13.2")
}
