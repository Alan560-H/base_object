plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.base_object"
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
        applicationId = "com.example.base_object"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        minSdk = 24
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // 添加默认的渠道信息
        manifestPlaceholders["channel"] = "default"
        ndk {
            abiFilters.add("arm64-v8a")
        }
    }
    flavorDimensions("channel") // 配置渠道维度，这里使用括号的形式
    productFlavors {
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
        create("vovi") {
            dimension = "channel"
            manifestPlaceholders["channel"] = "vovi"
        }
    }
    // 添加签名配置
    signingConfigs {
        create("release") {  // 定义名为 "release" 的签名配置
            storeFile = file("hzs-base.jks")  // 替换为你的签名文件名
            storePassword = "hzs520.1314"  // 密钥库密码
            keyAlias = "hzs-base"            // 密钥别名
            keyPassword = "hzs520.1314"      // 密钥密码
        }
        create("customDebug") {  // 定义名为 "release" 的签名配置
            storeFile = file("hzs-base.jks")  // 替换为你的签名文件名
            storePassword = "hzs520.1314"  // 密钥库密码
            keyAlias = "hzs-base"            // 密钥别名
            keyPassword = "hzs520.1314"
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
