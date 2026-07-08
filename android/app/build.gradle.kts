plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.naozhongle"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.naozhongle"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["OPENINSTALL_APPKEY"] = "kl25pf"
        manifestPlaceholders["channel"] = "default"
        // 真机: arm64-v8a + armeabi-v7a（老 32 位机）；不含 x86_64（模拟器）
        ndk {
            abiFilters.addAll(listOf("arm64-v8a", "armeabi-v7a"))
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }

//    signingConfigs {
//        create("release") {  // 定义名为 "release" 的签名配置
//            storeFile = file("ruyimh_key.jks")  // 替换为你的签名文件名
//            storePassword = "usxw4fQ4"  // 密钥库密码
//            keyAlias = "ym251627"            // 密钥别名
//            keyPassword = "usxw4fQ4"      // 密钥密码
//        }
//        create("customDebug") {  // 定义名为 "release" 的签名配置
//            storeFile = file("ruyimh_key.jks")  // 替换为你的签名文件名
//            storePassword = "usxw4fQ4"  // 密钥库密码
//            keyAlias = "ym251627"            // 密钥别名
//            keyPassword = "usxw4fQ4"      // 密钥密码
//        }
//    }
    signingConfigs {
        create("release") {  // 定义名为 "release" 的签名配置
            storeFile = file("naozhongle.jks")  // 替换为你的签名文件名
            storePassword = "hzs520.1314"  // 密钥库密码
            keyAlias = "naozhongle"            // 密钥别名
            keyPassword = "hzs520.1314"      // 密钥密
        }
        create("customDebug") {  // 定义名为 "release" 的签名配置
            storeFile = file("naozhongle.jks")  // 替换为你的签名文件名
            storePassword = "hzs520.1314"  // 密钥库密码
            keyAlias = "naozhongle"            // 密钥别名
            keyPassword = "hzs520.1314"      // 密钥密码
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
            // 可选：启用代码混淆和资源压缩
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        /// 自定义debugger签名
        debug {
            signingConfig = signingConfigs.getByName("customDebug")
        }
    }
}
// 在这里添加子项目的依赖配置
dependencies {
    // Taku 6.5.73（Gradle/Maven，替代 android/app/libs 本地 AAR）
    api("com.anythink.sdk:core-taku:6.5.73.3")

    // 中国内地 SDK 必要 Support（Jetifier 与 AndroidX 共存）
    api("com.android.support:appcompat-v7:28.0.0")
    api("com.android.support:localbroadcastmanager:28.0.0")

    // SDM / ADX（替代 kuying 本地 AAR）
    api("com.anythink.sdk:adapter-taku-sdm:6.5.68.1.0")
    api("com.smartdigimkttech.sdk:sdm-sdk-cn:6.5.68")

    // 优量汇 GDT 4.690
    api("com.anythink.sdk:adapter-taku-gdt:4.690.1560.1.2")
    api("com.qq.e.union:union:4.690.1560")
}
flutter {
    source = "../.."
}