---
name: switch-ad-subject-base-object
description: >-
  Switches base_object to a new ad mediation subject (icon, package id, app
  label string search-replace, Taku AppAdConfig IDs, revenue share, Android
  release signing jks check, release APK).
  Use when the user says 切换新的广告主体、切换广告主体、换广告主体、换包换主体.
disable-model-invocation: false
---

# 切换新的广告主体（base_object）

触发语：**切换新的广告主体**（或语义相同的「换广告主体」「换包换主体」等）。

在项目根目录 `base_object` 下按顺序执行；**凡涉及取值须先向用户确认后再改代码或执行不可逆命令**。

## 一次性确认清单（推荐先做）

触发本流程后，**优先把下面清单一次性发给用户**，请用户按序号逐项回复（可复制模板填空）。**收集齐全后再从第一步开始执行**，避免执行过程中反复打断追问。

助手可先读取仓库：当前 `AndroidManifest.xml` 的 `android:label`、`build.gradle.kts` 的 `storeFile` 文件名、`AppAdConfig` 与 `displayRevenueShare` 的**现状**，把「当前值」填进清单再让用户确认或修改，减少用户记忆负担。

```markdown
【切换广告主体 — 请一次性确认】

1. 应用图标：是否已按 pubspec 要求换好图标源文件并可执行 launcher_icons？（是 / 否）

2. 新 Android 包名：（例如 com.xxx.yyy）

3. 应用显示名：
   - 当前仓库里 android:label 为：（助手读取后填写）
   - 代码/资源中是否要把上述字符串全局替换为新名称？新名称是：（若不需要替换写「不替换」）

4. Taku `AppAdConfig`（`lib/core/config/app_ad_config.dart`），请给出终值：
   - appidStr：
   - appidkeyStr：
   - splashID：
   - bannerPlacementID：
   - interstitialPlacementID：
   - nativePlacementID：
   - rewarderPlacementID：
   - 各 *SceneID 是否与本条 placement 同值一并改？（是 / 否 / 我自己另有说明：___）

5. 预估收益系数 `AdInfo.displayRevenueShare`（0～1，含端点）：

6. Release 签名：
   - 当前 Gradle 中 storeFile 文件名为：（助手读取后填写）
   - 是否已在 `android/app/` 下放好对应 jks、且就是本次主体要用的签名？（是 / 否）
   - 若需改用别的 jks 文件名，新文件名为：（不写表示与 Gradle 一致）
   - keyAlias / 密钥密码是否已在本地 Gradle 里自行改好？（是 / 否）（不要在对话里发密码）

7. APK 输出目录打开路径是否仍用 `E:\WWWgitee\base_object\build\app\outputs\flutter-apk`？（是 / 否，否则给出路径：___）
```

若用户已主动贴出部分答案，助手把清单里对应项标为已提供，**只追问空缺项**。

## 第一步：更换 Flutter 应用图标

1. **先确认**：用户是否已按 `pubspec.yaml` 里 `flutter_launcher_icons` 的配置**替换好图标源文件**（如 `assets/app_icon.png` 等，以项目实际配置为准）。
2. 若未换好：提示用户先换图标文件，**不要**执行生成命令。
3. 若已换好：在项目根目录执行：

```bash
fvm flutter pub run flutter_launcher_icons
```

## 第二步：修改 Android 包名

1. **向用户询问**目标包名（例如 `com.xxx.yyy`）。
2. 在项目根目录执行（将 `[包名]` 换成用户提供的包名）：

```bash
fvm dart run change_app_package_name:main [包名]
```

## 第三步：应用显示名（与 AndroidManifest 一致的全局文案）

1. 读取 `android/app/src/main/AndroidManifest.xml` 中 `application` 的 **`android:label` 当前值**（用户曾约定参考约第 29 行，以文件为准）。
2. 用该字符串在仓库内搜索**所有相同关键字**（建议 `rg` / 编辑器全局搜索；排除 `build/`、`.dart_tool/`、第三方缓存等无关目录）。
3. **替换目标字符串须向用户确认**后再批量替换（可能涉及 Dart、Android 资源、`Info.plist` 的 `CFBundleDisplayName` 等；以实际命中为准）。

## 第四步：Taku 广告配置

修改 `lib/core/config/app_ad_config.dart` 中与后台一致的常量（**数值须与用户确认后再写入**）：

- `appidStr`
- `appidkeyStr`
- `splashID`
- `bannerPlacementID`
- `interstitialPlacementID`
- `nativePlacementID`
- `rewarderPlacementID`

说明：文件中若还有对应的 `*SceneID`，通常应与 placement 保持一致；若用户只要求改上述字段，改完后提醒用户核对 **sceneID** 是否也需同步（见 `.cursor/rules/app-ad-config.mdc`）。

## 第五步：预估收益分成系数

1. 打开 `lib/models/localModels/AdInfo.dart` 中的 **`displayRevenueShare`**（界面「预估收益」与首页汇总使用的系数）。
2. **向用户确认**数值，范围 **0～1**（含 0、1）；确认后再修改。

## 第六步：Release 签名文件（jks）

**必须在执行 Release 打包命令之前完成。**

1. 读取 `android/app/build.gradle.kts` 中的 **`signingConfigs`**（用户曾约定参考约第 59–72 行，以文件为准），查看各配置里的 `storeFile = file("…")`，提取 **jks 文件名**（如 `xxx.jks`）。
2. **向用户确认**：是否已为当前广告主体 **更换好** 对应的 `.jks` 文件，并已放到 **`android/app/`** 目录下（与 `file("xxx.jks")` 的相对路径一致）。未就绪则 **不要** 执行下一步打包。
3. **向用户获取 / 核对 jks 文件名**：与用户确认本次使用的 jks 文件名是否与 `build.gradle.kts` 里配置一致；若需改用新文件，由用户确认新文件名后 **同步修改** `storeFile = file("…")`，并提醒用户自行在本地更新 `keyAlias`、`storePassword`、`keyPassword`（**不要在对话中收集或复述密钥与密码**）。

## 第七步：Release 打包

在项目根目录执行：

```bash
fvm flutter build apk --release -v
```

## 第八步：打开 APK 输出目录

打包成功后，在 Windows 上打开目录（路径按用户机器约定）：

```bash
explorer "E:\WWWgitee\base_object\build\app\outputs\flutter-apk"
```

若项目路径不同，将 `E:\WWWgitee\base_object` 换成实际仓库根目录。

## 执行原则

- **一次性收集**：优先使用上文「一次性确认清单」收齐再动手；缺项再单独追问。
- **确认优先**：包名、替换用应用名、`AppAdConfig` 各字段、`displayRevenueShare`、**Release jks 是否就位及文件名与 Gradle 一致** 均需确认后再打包。
- **顺序**：尽量按步骤 1→8；改包名后再全局搜旧应用名，避免漏改。
- **回归**：完成后提醒用户真机验证开屏 / 横幅 / 激励及已接入形态。
