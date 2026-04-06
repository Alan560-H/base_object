---
name: ad-revenue-and-local-stats
description: >-
  Local ad records via Store and AdInfo, home list UI, AdLogCollector and
  AdLogFormatter. Use when changing 预估收益, 展示记录, banner/rewarded counts,
  or ad log cards.
---

# 本地广告收益与统计（base_object）

## 数据层

- **`lib/models/localModels/AdInfo.dart`**：单条记录字段；**`fromTakuExtra`** 从 Taku `extraMap` 解析（如 `publisher_revenue_cny`）。
- **`lib/store/store.dart`**：**`addAdInfos` / `getAdInfos`**，横幅与激励的条数、金额汇总 getter（含今日维度）。

## 展示层

- 首页广告记录列表：**`lib/pages/home/home_controller.dart`** 中 **`buildChatList`**（类型、收益展示口径、生成时间格式等）。

## 日志卡片

- **`lib/utils/ad_log_formatter.dart`**：统一多行卡片文案（类型、code、广告位、desc）。
- **`lib/utils/ad_log_collector.dart`**：内存列表、条数上限、弹窗绑定。

## 常见误区

- **列表条数 / 「横幅（总计）x 次」** 来自写入 **`Store` 的 `AdInfo`**（例如横幅多在 **`bannerAdDidShowSucceed`**），与控制台里某一回调（如 **`bannerAdAutoRefreshSucceed`**）出现次数**不必相等**。
- 改 **乘系数、小数位、仅 UI 展示** 时，明确是否影响持久化含义；改 **`fromTakuExtra`** 时同步检查历史本地 JSON 兼容。

## 检查清单

- [ ] 新增统计口径时注明对应 SDK 回调，避免双计数
- [ ] `AdLogFormatter` 与 `AdLogCollector` 文案一致、可读
- [ ] 清空/初始化列表时与 `LocalStorage`（`AppKeys.adInfosKey`）行为一致
