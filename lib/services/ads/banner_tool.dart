import 'dart:async';
import 'dart:math' as math;

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/app/providers.dart';
import 'package:base_object/data/notifiers/ad_stats_notifier.dart';
import 'package:base_object/services/ads/banner_ad_upload_handler.dart';
import 'package:base_object/shared/config/app_ad_config.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:base_object/services/ads/ad_log_collector.dart';
import 'package:base_object/services/ads/ad_log_formatter.dart';
import 'package:base_object/shared/config/screen_layout.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiffy/jiffy.dart';

double _defaultLogicalWidth() => defaultLogicalWidth();

/// 首页横幅占位条展示用状态
enum HomeBannerSlotState { idle, loading, ready, failed }

class BannerTool extends ChangeNotifier {
  BannerTool({required AdStatsNotifier adStatsNotifier})
    : _adStatsNotifier = adStatsNotifier;

  final AdStatsNotifier _adStatsNotifier;

  static BannerTool get to => globalContainer.read(bannerToolProvider);

  /// 与 [loadBannerWith] 一致的 320:50 横幅高度。
  static double standardBannerHeight(double logicalWidth) =>
      logicalWidth * 50 / 320;

  /// 底栏上抬最小高度兜底（screenutil .h），防止过小导致 Tab 与横幅重叠。
  static const double minBannerBottomLiftH = 50;

  /// 在 320:50 估算基础上的微调（screenutil .h）。
  static const double bannerBottomLiftExtraH = 50;

  /// 横幅播放时底栏上抬：横幅估算高度 + Tab 与横幅间距 + 微调。
  double bannerBottomLiftHeight(BuildContext context) {
    final double proportional =
        standardBannerHeight(MediaQuery.sizeOf(context).width);
    return math.max(
      minBannerBottomLiftH.h,
      proportional -
          bannerBottomLiftExtraH.h ,
    );
  }

  /// 横幅播放中时，页面底部需预留高度（含安全区），避免列表被 SDK 横幅遮挡。
  double contentBottomInset(BuildContext context) {
    final double safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    if (_bannerPlaybackPaused) return safeBottom;
    return bannerBottomLiftHeight(context) + safeBottom;
  }

  HomeBannerSlotState _bannerSlotState = HomeBannerSlotState.idle;
  HomeBannerSlotState get bannerSlotState => _bannerSlotState;

  /// 未点「开始横幅」前为 true：不自动 load/show；用户开始后为 false，直至停止或加载失败
  bool _bannerPlaybackPaused = true;
  bool get bannerPlaybackPaused => _bannerPlaybackPaused;

  Timer? _bannerPollingTimer;
  Timer? _bannerPollingCountdownTimer;
  Timer? _bannerFillPollTimer;
  int _bannerPollingToken = 0;
  int _bannerPollingCountdownToken = 0;
  int _bannerFillPollToken = 0;
  DateTime? _lastBannerShowAt;

  /// 倒计时结束已 remove，正在 3 秒轮询等缓存（此阶段勿置 paused）。
  bool _bannerPollingAwaitingCache = false;

  /// 无缓存轮询阶段是否已发起过 load（避免每 3 秒重复打 load）。
  bool _bannerLoadRequestedWhileAwaiting = false;

  /// fillPoll 触发的 load，用于区分 SDK 预加载回调。
  bool _bannerFillPollOwnsLoad = false;

  static const Duration _bannerFillPollInterval = Duration(seconds: 3);

  bool get _bannerPollingEnabled =>
      globalContainer.read(homeAdPollingProvider).bannerPollingEnabled;

  int get _bannerPollingIntervalSeconds =>
      globalContainer.read(homeAdPollingProvider).bannerIntervalSeconds;

  void _setBannerSlotState(HomeBannerSlotState value) {
    _bannerSlotState = value;
    notifyListeners();
  }

  void _setBannerPlaybackPaused(bool value) {
    _bannerPlaybackPaused = value;
    notifyListeners();
  }

  /// 停止横幅：移除原生横幅容器
  Future<void> pauseBannerPlayback() async {
    _bannerPollingAwaitingCache = false;
    _bannerLoadRequestedWhileAwaiting = false;
    _bannerFillPollOwnsLoad = false;
    _cancelBannerPollingTimers();
    _stopBannerFillPoll();
    _bannerPollingToken++;
    _setBannerPlaybackPaused(true);
    await removeBannerAd();
    _setBannerSlotState(HomeBannerSlotState.idle);
  }

  /// 开始横幅：load → DidFinishLoading → show
  Future<void> startBannerPlayback() async {
    _bannerPollingAwaitingCache = false;
    _bannerLoadRequestedWhileAwaiting = false;
    _bannerFillPollOwnsLoad = false;
    _cancelBannerPollingTimers();
    _stopBannerFillPoll();
    _bannerPollingToken++;
    _lastBannerShowAt = null;
    _setBannerPlaybackPaused(false);
    await loadBannerWith({}, logicalWidth: _defaultLogicalWidth());
  }

  /// [logicalWidth] 屏宽逻辑像素，用于 320:50 比例
  Future<void> loadBannerWith(
    Map<dynamic, dynamic> extraMap, {
    double? logicalWidth,
  }) async {
    final double w = logicalWidth ?? _defaultLogicalWidth();
    final double h = standardBannerHeight(w);
    final Map<dynamic, dynamic> merged = Map<dynamic, dynamic>.from(extraMap);
    merged[ATCommon.getAdSizeKey()] = ATBannerManager.createLoadBannerAdSize(
      w,
      h,
    );

    Utils.logError("横幅广告透传参数:$merged");
    _setBannerSlotState(HomeBannerSlotState.loading);
    try {
      await ATBannerManager.loadBannerAd(
        placementID: AppAdConfig.bannerPlacementID,
        extraMap: merged,
      );
    } catch (e, st) {
      _bannerFillPollOwnsLoad = false;
      _setBannerSlotState(HomeBannerSlotState.failed);
      if (!_bannerPlaybackPaused && !_bannerPollingAwaitingCache) {
        _setBannerPlaybackPaused(true);
      }
      Utils.logError("横幅 loadBannerAd 异常: $e $st");
    }
  }

  Future<void> _loadBannerFromFillPoll() async {
    _bannerFillPollOwnsLoad = true;
    await loadBannerWith({}, logicalWidth: _defaultLogicalWidth());
  }

  showBannerInRectangle() async {
    await ATBannerManager.showBannerInRectangle(
      placementID: AppAdConfig.bannerPlacementID,
      extraMap: {
        ATCommon.getAdSizeKey(): ATBannerManager.createLoadBannerAdSize(
          400,
          500,
          x: 0,
          y: 200,
        ),
      },
    );
  }

  Future<void> showAdInPosition() async {
    await ATBannerManager.showAdInPosition(
      placementID: AppAdConfig.bannerPlacementID,
      position: ATCommon.getAdATBannerAdShowingPositionBottom(),
    );
  }

  removeBannerAd() async {
    await ATBannerManager.removeBannerAd(
      placementID: AppAdConfig.bannerPlacementID,
    );
  }

  hideBannerAd() async {
    await ATBannerManager.hideBannerAd(
      placementID: AppAdConfig.bannerPlacementID,
    );
  }

  afreshShowBannerAd() async {
    await ATBannerManager.afreshShowBannerAd(
      placementID: AppAdConfig.bannerPlacementID,
    );
  }

  Future<bool> bannerAdReady() async {
    try {
      return await ATBannerManager.bannerAdReady(
        placementID: AppAdConfig.bannerPlacementID,
      );
    } catch (e, st) {
      Utils.logError('横幅 bannerAdReady 异常: $e $st');
      return false;
    }
  }

  Future<bool> hasBannerValidAds() async {
    try {
      final String value = await ATBannerManager.getBannerValidAds(
        placementID: AppAdConfig.bannerPlacementID,
      );
      Utils.logError(
        '[BannerPoll] getBannerValidAds len=${value.length} '
        '${value.isEmpty ? "（空）" : "preview=${value.length > 120 ? "${value.substring(0, 120)}…" : value}"}',
      );
      return value.isNotEmpty;
    } catch (e, st) {
      Utils.logError('横幅 getBannerValidAds 异常: $e $st');
      return false;
    }
  }

  Future<bool> _bannerHasCache() async {
    final bool ready = await bannerAdReady();
    if (ready) {
      Utils.logError('[BannerPoll] bannerAdReady=true');
      return true;
    }
    return hasBannerValidAds();
  }

  void _stopBannerFillPoll() {
    _bannerFillPollTimer?.cancel();
    _bannerFillPollTimer = null;
    _bannerFillPollToken++;
    _bannerLoadRequestedWhileAwaiting = false;
    _bannerFillPollOwnsLoad = false;
  }

  void _startBannerFillPoll() {
    _stopBannerFillPoll();
    final int fillToken = ++_bannerFillPollToken;
    Utils.logError(
      '[BannerPoll] 启动每 ${_bannerFillPollInterval.inSeconds} 秒轮询查缓存 fillToken=$fillToken',
    );
    unawaited(_bannerFillPollTick(fillToken: fillToken));
    _bannerFillPollTimer = Timer.periodic(
      _bannerFillPollInterval,
      (_) => unawaited(_bannerFillPollTick(fillToken: fillToken)),
    );
  }

  Future<void> _bannerFillPollTick({required int fillToken}) async {
    if (!_bannerPollingEnabled) return;
    if (fillToken != _bannerFillPollToken) return;
    if (_bannerPlaybackPaused && !_bannerPollingAwaitingCache) return;

    Utils.logError('[BannerPoll] 3秒轮询：检查横幅缓存… fillToken=$fillToken');
    final bool hasCache = await _bannerHasCache();
    if (fillToken != _bannerFillPollToken || !_bannerPollingEnabled) {
      return;
    }
    if (_bannerPlaybackPaused && !_bannerPollingAwaitingCache) {
      return;
    }

    if (hasCache) {
      _stopBannerFillPoll();
      Utils.logError('[BannerPoll] 3秒轮询：有缓存 → loadBannerWith 下一条');
      await _loadBannerFromFillPoll();
      return;
    }

    if (!_bannerLoadRequestedWhileAwaiting) {
      _bannerLoadRequestedWhileAwaiting = true;
      Utils.logError('[BannerPoll] 3秒轮询：无缓存 → loadBannerWith 请求下一条');
      await _loadBannerFromFillPoll();
      return;
    }

    if (_bannerSlotState == HomeBannerSlotState.failed) {
      _bannerLoadRequestedWhileAwaiting = false;
      Utils.logError('[BannerPoll] 3秒轮询：上次 load 失败，重试 loadBannerWith');
      await _loadBannerFromFillPoll();
      return;
    }

    Utils.logError(
      '[BannerPoll] 3秒轮询：仍无缓存，load 进行中，'
      '${_bannerFillPollInterval.inSeconds}s 后再查 fillToken=$fillToken',
    );
  }

  void onPollingConfigChanged() {
    if (!_bannerPollingEnabled) {
      _bannerPollingAwaitingCache = false;
      _bannerLoadRequestedWhileAwaiting = false;
      _bannerFillPollOwnsLoad = false;
      _cancelBannerPollingTimers();
      _stopBannerFillPoll();
      _bannerPollingToken++;
      return;
    }
    _reapplyBannerPollingSchedule();
  }

  void _reapplyBannerPollingSchedule() {
    if (!_bannerPollingEnabled || _bannerPlaybackPaused) return;
    if (_lastBannerShowAt != null) {
      _rescheduleBannerPollingFromLastShow();
    } else {
      Utils.logError(
        '[BannerPoll] 尚无 DidShow，按完整间隔 $_bannerPollingIntervalSeconds s 启动',
      );
      _scheduleBannerPollingSwitch();
    }
  }

  void _cancelBannerPollingTimers() {
    _bannerPollingTimer?.cancel();
    _bannerPollingTimer = null;
    _bannerPollingCountdownToken++;
    _bannerPollingCountdownTimer?.cancel();
    _bannerPollingCountdownTimer = null;
  }

  void _startBannerPollingCountdown({
    required int totalSeconds,
    required int token,
  }) {
    _bannerPollingCountdownToken++;
    final int countdownToken = _bannerPollingCountdownToken;
    _bannerPollingCountdownTimer?.cancel();
    int remaining = totalSeconds;
    Utils.logError(
      '[BannerPoll] 倒计时开始 设定=${totalSeconds}s token=$token',
    );
    _bannerPollingCountdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) {
        if (countdownToken != _bannerPollingCountdownToken ||
            token != _bannerPollingToken) {
          t.cancel();
          return;
        }
        remaining--;
        if (remaining <= 0) {
          Utils.logError('[BannerPoll] 倒计时归零 token=$token');
          t.cancel();
          return;
        }
        Utils.logError(
          '[BannerPoll] 倒计时 剩余 ${remaining}s / ${totalSeconds}s token=$token',
        );
      },
    );
  }

  void _armBannerPollingSwitch({
    required Duration delay,
    required int token,
  }) {
    final int seconds = delay.inSeconds;
    Utils.logError(
      '[BannerPoll] 已排期 ${seconds}s 后关闭并检查缓存 token=$token',
    );
    _startBannerPollingCountdown(totalSeconds: seconds, token: token);
    _bannerPollingTimer = Timer(delay, () {
      _bannerPollingCountdownTimer?.cancel();
      unawaited(_onBannerPollingTick(token));
    });
  }

  void _scheduleBannerPollingSwitch() {
    if (!_bannerPollingEnabled || _bannerPlaybackPaused) return;
    _cancelBannerPollingTimers();
    final int token = ++_bannerPollingToken;
    final int seconds = _bannerPollingIntervalSeconds;
    _armBannerPollingSwitch(
      delay: Duration(seconds: seconds),
      token: token,
    );
  }

  void _rescheduleBannerPollingFromLastShow() {
    _cancelBannerPollingTimers();
    final DateTime? lastShow = _lastBannerShowAt;
    if (lastShow == null) return;
    final int seconds = _bannerPollingIntervalSeconds;
    final Duration elapsed = DateTime.now().difference(lastShow);
    final Duration total = Duration(seconds: seconds);
    final int token = ++_bannerPollingToken;
    if (elapsed >= total) {
      Utils.logError('[BannerPoll] 已超时，立即关闭并检查缓存 token=$token');
      unawaited(_onBannerPollingTick(token));
      return;
    }
    final Duration remaining = total - elapsed;
    Utils.logError(
      '[BannerPoll] 按剩余 ${remaining.inSeconds}s 重排（设定=${seconds}s）token=$token',
    );
    _armBannerPollingSwitch(delay: remaining, token: token);
  }

  Future<void> _onBannerPollingTick(int token) async {
    if (token != _bannerPollingToken) return;
    if (!_bannerPollingEnabled) return;

    _bannerPollingAwaitingCache = true;
    _bannerLoadRequestedWhileAwaiting = false;
    _bannerFillPollOwnsLoad = false;

    if (_bannerPlaybackPaused) {
      Utils.logError(
        '[BannerPoll] 倒计时结束但 paused=true，恢复为 false 以继续 3 秒轮询',
      );
      _setBannerPlaybackPaused(false);
    }

    Utils.logError(
      '[BannerPoll] 倒计时结束，移除当前横幅 设定=${_bannerPollingIntervalSeconds}s token=$token',
    );

    // removeBannerAd 的 Future 在部分机型上可能长期不 complete，不能阻塞 3 秒轮询。
    unawaited(
      removeBannerAd()
          .then((_) {
            Utils.logError('[BannerPoll] removeBannerAd 完成 token=$token');
          })
          .catchError((Object e, StackTrace st) {
            Utils.logError('[BannerPoll] removeBannerAd 异常: $e $st');
          }),
    );

    if (token != _bannerPollingToken || !_bannerPollingEnabled) {
      _bannerPollingAwaitingCache = false;
      Utils.logError(
        '[BannerPoll] 轮询 tick 已失效 token=$token current=$_bannerPollingToken '
        'enabled=$_bannerPollingEnabled',
      );
      return;
    }

    Utils.logError(
      '[BannerPoll] 开始每 ${_bannerFillPollInterval.inSeconds} 秒轮询查缓存并请求 load',
    );
    _setBannerSlotState(HomeBannerSlotState.loading);
    _startBannerFillPoll();
  }

  void _onBannerDidShowForPolling() {
    if (_bannerPollingAwaitingCache && _bannerFillPollTimer != null) {
      Utils.logError(
        '[BannerPoll] DidShow（fill 轮询进行中 SDK 误展示），忽略重排倒计时',
      );
      return;
    }
    _bannerPollingAwaitingCache = false;
    _bannerLoadRequestedWhileAwaiting = false;
    _bannerFillPollOwnsLoad = false;
    _lastBannerShowAt = DateTime.now();
    if (_bannerPollingEnabled && !_bannerPlaybackPaused) {
      Utils.logError(
        '[BannerPoll] DidShow 成功，按设定 ${_bannerPollingIntervalSeconds}s 启动倒计时',
      );
      _scheduleBannerPollingSwitch();
    }
  }

  StreamSubscription<ATBannerResponse>? _bannerSubscription;

  /// 横幅广告监听（换条由 SDK bannerAdAutoRefreshSucceed 负责）
  void bannerListen() {
    if (_bannerSubscription != null) {
      return;
    }
    _bannerSubscription = ATListenerManager.bannerEventHandler.listen((value) {
      switch (value.bannerStatus) {
        case BannerStatus.bannerAdFailToLoadAD:
          if (_bannerPollingEnabled && _bannerPollingAwaitingCache) {
            Utils.logError(
              '[BannerPoll] failToLoad（remove/轮询阶段常见），保持轮询不暂停 '
              'msg=${value.requestMessage}',
            );
            _bannerFillPollOwnsLoad = false;
            _bannerLoadRequestedWhileAwaiting = false;
            _setBannerSlotState(HomeBannerSlotState.failed);
            break;
          }
          _setBannerSlotState(HomeBannerSlotState.failed);
          if (!_bannerPlaybackPaused) {
            _setBannerPlaybackPaused(true);
          }
          AdLogCollector.addLog(
            AdLogFormatter.bannerFail(
              placementId: value.placementID.toString(),
              requestMessage: value.requestMessage,
              extraMap: value.extraMap,
            ),
          );
          break;
        case BannerStatus.bannerAdDidFinishLoading:
          if (_bannerPollingEnabled &&
              _bannerPollingAwaitingCache &&
              !_bannerFillPollOwnsLoad) {
            Utils.logError(
              '[BannerPoll] DidFinishLoading（SDK 预加载），等待 fill 轮询阶段忽略 auto show',
            );
            break;
          }
          _bannerFillPollOwnsLoad = false;
          _stopBannerFillPoll();
          Utils.logError(
            "横幅广告 bannerAdDidFinishLoading ---- placementID: ${value.placementID}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerEvent(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
              desc: '加载完成',
            ),
          );
          _setBannerSlotState(HomeBannerSlotState.ready);
          if (!_bannerPlaybackPaused) {
            // 非场景展示，仅用 placementID（与 AppAdConfig 一致）
            showAdInPosition();
          }
          break;
        case BannerStatus.bannerAdAutoRefreshSucceed:
          Utils.logError(
            "横幅广告 bannerAdAutoRefreshSucceed ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerEvent(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
              desc: '自动刷新成功',
            ),
          );
          if (_bannerPollingEnabled) {
            Utils.logError(
              '[BannerPoll] 轮询 ON，SDK AutoRefresh（忽略记收益，不重排倒计时）',
            );
            break;
          }
          _adStatsNotifier.addAdInfos(
            AdInfo.fromTakuExtra(
              extraMap: value.extraMap,
              placementID: value.placementID.toString(),
              createdTime: Jiffy.now().format(pattern: 'yyyy-MM-dd HH:mm:ss'),
              adType: AdInfo.typeBanner,
            ),
          );
          handleBannerAdUpload(value);
          break;
        case BannerStatus.bannerAdDidClick:
          Utils.logError(
            "横幅广告 bannerAdDidClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerEvent(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
              desc: '点击',
            ),
          );
          break;
        case BannerStatus.bannerAdDidDeepLink:
          Utils.logError(
            "横幅广告 bannerAdDidDeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap} ---- isDeeplinkSuccess:${value.isDeeplinkSuccess}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerEvent(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
              desc: 'DeepLink（成功:${value.isDeeplinkSuccess}）',
            ),
          );
          break;
        case BannerStatus.bannerAdDidShowSucceed:
          Utils.logError(
            "横幅广告 bannerAdDidShowSucceed ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerSuccess(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
            ),
          );
          _adStatsNotifier.addAdInfos(
            AdInfo.fromTakuExtra(
              extraMap: value.extraMap,
              placementID: value.placementID.toString(),
              createdTime: Jiffy.now().format(pattern: 'yyyy-MM-dd HH:mm:ss'),
              adType: AdInfo.typeBanner,
            ),
          );
          _onBannerDidShowForPolling();
          break;
        case BannerStatus.bannerAdTapCloseButton:
          Utils.logError(
            "横幅广告 bannerAdTapCloseButton ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerEvent(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
              desc: '点击关闭',
            ),
          );
          break;
        case BannerStatus.bannerAdAutoRefreshFail:
          Utils.logError(
            "横幅广告 bannerAdAutoRefreshFail ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerFail(
              placementId: value.placementID.toString(),
              requestMessage: value.requestMessage,
              extraMap: value.extraMap,
            ),
          );
          break;
        case BannerStatus.bannerAdDidMultipleLoaded:
          Utils.logError(
            "横幅广告 bannerAdDidMultipleLoaded ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerEvent(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
              desc: '多条广告加载完成',
            ),
          );
          break;
        case BannerStatus.bannerAdDidAdSourceBiddingAttempt:
        case BannerStatus.bannerAdDidAdSourceBiddingFilled:
        case BannerStatus.bannerAdDidAdSourceBiddingFail:
        case BannerStatus.bannerAdDidAdSourceAttempt:
        case BannerStatus.bannerAdDidAdSourceLoadFilled:
        case BannerStatus.bannerAdDidAdSourceLoadFail:
          Utils.logError(
            "横幅广告 ${value.bannerStatus} ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          AdLogCollector.addLog(
            AdLogFormatter.bannerEvent(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
              desc: value.bannerStatus.toString(),
            ),
          );
          break;
        case BannerStatus.bannerAdUnknown:
          Utils.logError("横幅广告 bannerAdUnknown");
          AdLogCollector.addLog(
            AdLogFormatter.bannerEvent(
              placementId: value.placementID.toString(),
              extraMap: value.extraMap,
              desc: '未知状态',
            ),
          );
          break;
      }
    });
  }
}
