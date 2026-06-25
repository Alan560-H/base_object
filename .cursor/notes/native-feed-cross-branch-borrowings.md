# 信息流跨分支借鉴清单

> **来源分支**：`5.12banner_`（`lib/features/ads/infrastructure/native_tool.dart` 等）  
> **目标分支**：`is_banner`（`lib/services/ads/native_tool.dart` + `home_page`）  
> **记录时间**：2026-06-25  
> **用途**：切回 `is_banner` 时，保留其换条/频次内核，选择性迁入新分支的工程与 UX 做法。

---

## 一、建议借鉴（值得迁）

### 1. UI 组件拆分

| 文件 | 做法 |
|------|------|
| `home_native_feed_slot.dart` | 信息流槽位独立 Widget：`paused` 占位 / `loading` / `PlatformNativeWidget` + `ValueKey(generation)` |
| `home_ad_controls.dart` | 横幅 + 收益记录 + 信息流三按钮同区；`Listenable.merge` 监听多个 `ValueNotifier` |

**迁到 is_banner**：可把 `home_page` 里内联槽位拆成同名组件，按钮区可对照 `HomeAdControls` 整理（不必改 Riverpod 全栈，Widget 拆分即可）。

### 2. 按钮倒计时 UX（改语义，保留形态）

`5.12banner_` 用 `nativeFeedAutoReloadCountdown` 在停止按钮上显示 `停止信息流（16）`。

- **不要**照搬 16 秒常量（与 Taku 后台 30s 冲突）。
- **可借鉴**：换条/轮询等待期间在按钮或槽位旁显示「下一条准备中 Ns」，数据源改为 `_refreshPoll` 或「距上次曝光」的**展示态**，而非写死定时换条。

相关代码：`home_ad_controls.dart` 第 46–53 行；`native_tool.dart` 的 `ValueNotifier<int?> nativeFeedAutoReloadCountdown`。

### 3. 失败重试 token（防串请求）

```dart
int _nativeFailReloadToken = 0;
// start/pause 时 ++；fail 重试前存 token，delay 后比对，不一致则放弃
```

`is_banner` 有 `_maxFailRetries` 和 `_swapInProgress`，但没有 token。pause/start 后旧 `nativeAdFailToLoadAD` 的 2s 重试仍可能触发——可补 `_nativeFailReloadToken`。

### 4. 预加载互斥 `_preloadInFlight`

`preloadNativeFeedOnce()` 用 `_preloadInFlight` 避免并发 preload。  
`is_banner` 有 `_refreshPreloadInFlight`，语义接近；可对照是否覆盖「用户点开始前的 idle preload」场景。

### 5. load 管道统一 `_invokeNativeLoadPipeline`

单次封装：`loadNativeAd` → `entryNativeScenario`（placement + scene 一致）。  
`is_banner` 若在多处重复 load+entry，可收成同一私有方法，减少漏 `entryNativeScenario`。

### 6. 文案集中 `UiStrings`

`startNativeFeed` / `stopNativeFeed` / `nativeTapToLoad` / `nativeLoading` / `nativeFailed` / `nativeReady` / `nativeAndroidOnly` / `adTypeNative`。  
`is_banner` 若仍有硬编码中文，可迁到 `ui_strings` 或 i18n（与项目规范一致）。

### 7. 类型命名 `AdInfo.typeNativeFeed`

比 `typeNative` 更不易与「原生平台」混淆。切分支时统一一种即可（改统计、展示记录、filter 一处不漏）。

### 8. 收益弹窗 `home_revenue_dialog.dart`

首页「收益记录」弹窗已接 `typeNativeFeed` 展示。`is_banner` 若在 `ad_record_page` 已有列表，可对照弹窗/摘要卡片文案是否一致。

### 9. `PlatformNativeWidget` 参数

`5.12banner_`：`isAdaptiveHeight: true` + `sceneID: AppAdConfig.nativeSceneId`。  
确认 `is_banner` 的 `PlatformNativeWidget` 是否同样传 `sceneID` 与自适应高度。

### 10. 日志前缀与 extra 截断

`_logNativeFeed` + `_nativeFeedExtraPreview`（480 字符截断）便于 logcat 排障。可并入 `is_banner` 的 `AdLogCollector` 或保留 `[NativeFeed]` 前缀。

### 11. Riverpod 分层（中长期，非必须一次做完）

```
features/ads/infrastructure/native_tool.dart
features/ads/providers/ad_service_providers.dart  → nativeToolProvider
features/home/providers/home_provider.dart        → start/pause 委托
```

`is_banner` 当前 `ChangeNotifier` + `globalContainer` 已够用；若后续全项目迁 Riverpod，以 `5.12banner_` 为模板，**换条状态机仍用 is_banner 版本**。

---

## 二、不要借鉴（已知问题）

| 做法 | 原因 |
|------|------|
| `_nativeFeedPostShowReloadDelay = 16s` 曝光后强制 remove+restart | 与腾讯源 30s 展示间隔冲突 → 4005、无效请求 |
| 进首页 3s `_scheduleNativeFeedAutoStartAfterEnter` | 与「受控开始/停止」产品意图冲突；审核/省电不利 |
| `MainShell` 切 Tab 不 pause | 后台继续 load/换条；应采用 is_banner「离开首页 pause」 |
| `await loadNativeAd` / `await removeNativeAd` 无超时 | Android 无回调会卡死整条链路；**保留 is_banner 300ms 超时** |
| `nativeAdFailToLoadAD` 固定 2s 重试 | 4005 时会刷屏；**保留 is_banner 频次策略** |
| 换条只看 `getNativeValidAds` 有数据 | 曾导致连刷；**保留 is_banner `topAdInfo.req_id` 判断** |

---

## 三、is_banner 必须保留的核心（勿被覆盖）

1. **换条条件**：当前条已曝光 + `checkNativeAdLoadStatus` 的 `topAdInfo.req_id` ≠ 当前展示 id + `isReady && !isLoading`
2. **换条动作**：`removeNativeAd`（超时）→ `slotGeneration++` → 保持 ready 态（不闪长 loading）
3. **曝光后**：3s 轮询 `_evaluateAutoRefresh`，由 SDK/后台间隔决定何时 `refreshPreload`
4. **4005**：`refreshPreload` 失败不重试刷屏，等下一轮轮询
5. **Tab**：`app_shell` 仅 `currentIndex==0 && index!=0` 时 `pauseNativePlayback`
6. **`_recordedReqIds` / `_impressionRecordedGeneration`**：防重复记曝光

---

## 四、切分支后建议操作顺序

1. `git checkout is_banner`（确认在 `6086176` 或更新 commit）
2. 只迁 **Widget 拆分** + **UiStrings** + **`_nativeFailReloadToken`**（小步）
3. 若要做按钮倒计时：接轮询/等待态，**不接 16s 定时换条**
4. `fvm flutter analyze` + 真机：满间隔留首页 ≥40s，看 `refreshPreload` / `已换条`
5. 全量 Riverpod 重构单独 PR，不与换条逻辑混提交

---

## 五、关键文件对照

| 能力 | `5.12banner_` | `is_banner` |
|------|---------------|-------------|
| Native 逻辑 | `lib/features/ads/infrastructure/native_tool.dart` | `lib/services/ads/native_tool.dart` |
| 槽位 UI | `lib/features/home/presentation/home_native_feed_slot.dart` | `lib/features/home/presentation/home_page.dart`（内联 `_HomeNativeSlot`） |
| 按钮 | `home_ad_controls.dart` | `home_page` / notifier |
| 配置 | `lib/core/app_ad_config.dart`（`b6a0d63ff30465`） | `lib/shared/config/app_ad_config.dart`（`b6a2bdabf9155f`） |
| Tab pause | 无 | `lib/app/app_shell.dart` |

---

## 六、给助手的提示语（切回 is_banner 后可直接粘贴）

```
请对照 .cursor/notes/native-feed-cross-branch-borrowings.md：
在 is_banner 上保留 topAdInfo 换条与 300ms 超时，只借鉴 5.12banner_ 的 UI 拆分、UiStrings、failReloadToken、按钮等待倒计时（不要 16s 定时换条和 3s 自动开播）。
```
