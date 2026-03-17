# 模拟器上崩溃排查

## 1. 先抓崩溃日志（必做）

在电脑上打开命令行，连接雷电模拟器后执行：

```bash
adb logcat -c
adb logcat *:E
```

然后在模拟器里打开应用，等崩溃后把终端里出现的 **红色/错误行**（尤其是带 `FATAL`、`AndroidRuntime`、`Exception`、`Error` 的几段）复制下来，便于排查。

或保存最近 500 行到文件：

```bash
adb logcat -d -t 500 > logcat.txt
```

---

## 2. 常见原因

- **架构/so 不匹配**：已为模拟器加上 `x86`、`x86_64`、`armeabi-v7a`。若依赖的广告 SDK（如 open_ad_sdk）**没有**对应架构的 .so，在模拟器上会报 `UnsatisfiedLinkError` 并闪退，真机正常。
- **雷电版本**：必须用 **64 位雷电** 和 **64 位 Android 镜像**（本包含 x86_64，不含 32 位 x86）。32 位雷电需升级到 64 位。
- **仅做功能测试**：可打 **仅 arm64** 的包在真机或支持 ARM 的模拟器上测；发版再打多架构或 AAB。

---

## 3. 仅打 arm64 包（不包含 x86，包更小、避免 so 缺失导致模拟器崩）

若确认是模拟器上某 so 缺失导致崩溃，可临时只打真机架构再测：

在 `app/build.gradle.kts` 的 `defaultConfig.ndk` 里改为：

```kotlin
ndk {
    abiFilters.addAll(listOf("arm64-v8a"))
}
```

然后执行 `flutter build apk --release`，用生成的 APK 在 **真机** 或 **ARM 模拟器** 上测试。
