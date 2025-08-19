plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.xinrui.vita"
    compileSdk = flutter.compileSdkVersion
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
        applicationId = "com.xinrui.vita"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // 添加默认的渠道信息
        manifestPlaceholders["channel"] = "default"
        // 新增：限制 APK 只包含 arm64-v8a 架构
        ndk {
            abiFilters.add("arm64-v8a")
        }
    }
    flavorDimensions("channel") // 配置渠道维度，这里使用括号的形式

    productFlavors {
        create("maingf") {
            dimension = "channel"
            manifestPlaceholders["channel"] = ""
        }
        create("huawei") {
            dimension = "channel"
            manifestPlaceholders["channel"] = "huawei"
        }
        create("xiaomi") {
            dimension = "channel"
            manifestPlaceholders["channel"] = "xiaomi"
        }
        create("baidu") {
            dimension = "channel"
            manifestPlaceholders["channel"] = "baidu"
        }
        create("vivo") {
            dimension = "channel"
            manifestPlaceholders["channel"] = "vivo"
        }
        create("oppo") {
            dimension = "channel"
            manifestPlaceholders["channel"] = "oppo"
        }
        create("gaoxu") {
            dimension = "channel"
            manifestPlaceholders["channel"] = "gaoxu"
        }
        create("minm") {
            dimension = "channel"
            manifestPlaceholders["channel"] = "minm"
        }
        create("tuoni") {
            dimension = "channel"
            manifestPlaceholders["channel"] = "tuoni"
        }
        create("rongyao") {
            dimension = "channel"
            manifestPlaceholders["channel"] = "rongyao"
        }
        create("pdd") {
            dimension = "channel"
            manifestPlaceholders["channel"] = "pdd"
        }

    }
    // 添加签名配置
    signingConfigs {
        create("release") {  // 定义名为 "release" 的签名配置
            storeFile = file("android.keystore")  // 替换为你的签名文件名
            storePassword = "aa123456"  // 密钥库密码
            keyAlias = "1"            // 密钥别名
            keyPassword = "aa123456"      // 密钥密码
        }
        create("customDebug") {  // 定义名为 "release" 的签名配置
            storeFile = file("android.keystore")  // 替换为你的签名文件名
            storePassword = "aa123456"  // 密钥库密码
            keyAlias = "1"            // 密钥别名
            keyPassword = "aa123456"      // 密钥密码
        }
    }
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
            // 可选：启用代码混淆和资源压缩
            isMinifyEnabled = true
            isShrinkResources = true
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

flutter {
    source = "../.."
}