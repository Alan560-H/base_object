---
name: taku-flutter-base-object
description: >-
  Integrates and debugs Taku (anythink_sdk) in the base_object Flutter app:
  init, splash, banner, rewarded video, listeners, AppAdConfig placement IDs.
  Use when editing lib/manager/*_tool.dart, Init_tool, splash flow, or when the
  user mentions Taku, TopOn, anythink_sdk, 开屏, 横幅, 激励, 广告位.
---

# Taku Flutter（base_object）

## 官方文档

- <https://help.takuad.com/docs/flutter>（导入、初始化、各广告形态、监听回调）

## 代码地图

| 职责 | 路径 |
|------|------|
| SDK 初始化、部分全局设置 | `lib/manager/Init_tool.dart` |
| 闪屏串联 init 与跳转 | `lib/pages/splash_page/splash_controller.dart` |
| 开屏广告 | `lib/manager/splash_tool.dart` |
| 横幅 | `lib/manager/banner_tool.dart` |
| 激励视频 | `lib/manager/rewarder_tool.dart` |
| 广告位 / appId 配置 | `lib/core/config/app_ad_config.dart` |

## 工作流建议

1. 修改加载或展示逻辑前，确认 **`initTopon` 已成功**（闪屏 `initAd` 超时策略见 `splash_controller`）。
2. 新增或调整 **`ATListenerManager` 监听**时，避免重复 `listen`；参考 `BannerTool.bannerListen` 的单例写法。
3. 区分 **SDK 原生日志**（`InitTool.setSdkDebugLog`）与 **业务日志**（`AdLogCollector`）。
4. 升级 **`pubspec.yaml` 中 anythink_sdk 版本**后，对照官方文档核对 API 与回调枚举。

## 检查清单

- [ ] placement / scene 与后台一致（`AppAdConfig`）
- [ ] 初始化完成后再 load / show
- [ ] 监听不重复注册
- [ ] 横幅「展示成功」与「自动刷新成功」语义分离，避免重复计曝光
