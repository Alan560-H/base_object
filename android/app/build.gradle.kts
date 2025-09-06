plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.cjbao"
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
        applicationId = "com.cjbao"
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
        manifestPlaceholders.put("APPLOG_SCHEME", "rangersapplog.dc6f26f3112ee022".lowercase())
    }
    flavorDimensions("channel") // 配置渠道维度，这里使用括号的形式

    productFlavors {
        create("maingf") {
            dimension = "channel"
            manifestPlaceholders["channel"] = "maingf"
        }

        create("huawei") {
            dimension = "channel"
            manifestPlaceholders["channel"] = "huawei"
        }
        create("cjbao") {
            dimension = "channel"
            manifestPlaceholders["channel"] = "cjbao"
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
            storeFile = file("cjbao.jks")  // 替换为你的签名文件名
            storePassword = "aa123456"  // 密钥库密码
            keyAlias = "cjbao"            // 密钥别名
            keyPassword = "aa123456"      // 密钥密码
        }
        create("customDebug") {  // 定义名为 "release" 的签名配置
            storeFile = file("cjbao.jks")  // 替换为你的签名文件名
            storePassword = "aa123456"  // 密钥库密码
            keyAlias = "cjbao"            // 密钥别名
            keyPassword = "aa123456"      // 密钥密码
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
//    api("com.anythink.sdk:core-taku:6.5.10")
//    api("com.anythink.sdk:core-china-taku:6.5.10")
//    api("com.anythink.sdk:nativead-taku:6.5.10")
//    api("com.anythink.sdk:banner-taku:6.5.10")
//    api("com.anythink.sdk:interstitial-taku:6.5.10")
//    api("com.anythink.sdk:rewardedvideo-taku:6.5.10")
//    api("com.anythink.sdk:splash-taku:6.5.10")
//    api("com.android.support:appcompat-v7:28.0.0")
//    //Baidu
//    api("com.anythink.sdk:adapter-taku-baidu:6.5.10.1")
//    api("mobi.baidu.sdk:mobads:9.400")
//    //Kuaishou
//    api("com.anythink.sdk:adapter-taku-kuaishou:6.5.10")
//    api("com.anythink.sdk:sdk-ads-kuaishou:4.6.30.1")
//    api("com.android.support:design:28.0.0")
//    //Sigmob
//    api("com.anythink.sdk:adapter-taku-sigmob:6.5.10")
//    api("com.anythink.sdk:sdk-ads-sigmob:4.24.0")
//    //Csj
//    api("com.anythink.sdk:adapter-taku-csj:6.5.10")
//    api("com.pangle.cn:ads-sdk-pro:6.9.2.3")
//    //GDT
//    api("com.anythink.sdk:adapter-taku-gdt:6.5.10")
//    api("com.qq.e.union:union:4.642.1512")
    // 本地 aar/jar 依赖
    api(fileTree(mapOf(
        "dir" to "libs", // 指向 app 模块内的 libs 目录（相对路径）
        "include" to listOf("*.aar", "*.jar"), // 包含 libs 下所有 .aar 和 .jar 文件
        // 若需要排除清单文件冲突，可取消下面这行的注释
    )))
}
flutter {
    source = "../.."
}