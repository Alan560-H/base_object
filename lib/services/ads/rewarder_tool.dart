import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/app/providers.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:base_object/data/notifiers/ad_stats_notifier.dart';
import 'package:base_object/data/notifiers/user_notifier.dart';
import 'package:base_object/services/ads/ad_log_collector.dart';
import 'package:base_object/services/ads/ad_log_formatter.dart';
import 'package:base_object/shared/config/app_ad_config.dart';
import 'package:base_object/shared/widgets/cu_toast.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jiffy/jiffy.dart';

/// 激励视频：load / ready / show / 监听；收益仅在 [RewardedStatus.rewardedVideoDidRewardSuccess] 写入。
class RewarderTool {
  RewarderTool({
    required AdStatsNotifier adStatsNotifier,
    required UserNotifier userNotifier,
  }) : _adStatsNotifier = adStatsNotifier,
       _userNotifier = userNotifier;

  static const Duration _loadTimeout = Duration(seconds: 20);

  final AdStatsNotifier _adStatsNotifier;
  final UserNotifier _userNotifier;

  /// 一次观看流程进行中，防止连点
  bool _isBusy = false;

  /// 用户已点击观看，等待 [RewardedStatus.rewardedVideoDidFinishLoading] 后自动 show
  bool _pendingShow = false;

  /// 已调用 show，防止与 ready 直 show / 加载完成回调重复展示
  bool _isPresenting = false;

  Timer? _loadTimeoutTimer;
  StreamSubscription<ATRewardResponse>? _rewardedSubscription;

  static RewarderTool get to => globalContainer.read(rewarderToolProvider);

  /// 首页唯一入口：ready 则 show，否则 load 并在加载完成后自动 show
  Future<void> watchRewardedVideo() async {
    if (_isBusy) {
      return;
    }
    _isBusy = true;
    _pendingShow = false;
    EasyLoading.show(status: '正在获取广告…');

    try {
      if (await rewardedVideoReady()) {
        await _presentRewardedVideo();
        return;
      }

      final Map<dynamic, dynamic> status = await checkRewardedVideoLoadStatus();
      if (_isMapFlag(status['isReady'])) {
        await _presentRewardedVideo();
        return;
      }

      _pendingShow = true;
      if (_isMapFlag(status['isLoading'])) {
        _startLoadTimeout();
        return;
      }

      _startLoadTimeout();
      final ({String userID, String extra}) params = _loadParams();
      await loadRewardedVideo(userID: params.userID, extra: params.extra);
    } catch (e, st) {
      Utils.logError('watchRewardedVideo 异常: $e', error: e, stackTrace: st);
      _resetWatchState();
      CuToast.error(msg: '激励视频异常，请稍后再试');
    }
  }

  /// 激励视频加载（Taku 文档 1.1：userID 必传，extra 选传）
  Future<void> loadRewardedVideo({
    required String userID,
    required String extra,
  }) async {
    Utils.logError('激励 load userId:$userID, extra=$extra');
    await ATRewardedManager.loadRewardedVideo(
      placementID: AppAdConfig.rewarderPlacementID,
      extraMap: {
        ATRewardedManager.kATAdLoadingExtraUserDataKeywordKey(): extra,
        ATRewardedManager.kATAdLoadingExtraUserIDKey(): userID,
      },
    );
  }

  Future<bool> rewardedVideoReady() async {
    return ATRewardedManager.rewardedVideoReady(
      placementID: AppAdConfig.rewarderPlacementID,
    );
  }

  Future<Map<dynamic, dynamic>> checkRewardedVideoLoadStatus() async {
    return ATRewardedManager.checkRewardedVideoLoadStatus(
      placementID: AppAdConfig.rewarderPlacementID,
    );
  }

  Future<void> _logValidAds() async {
    await ATRewardedManager.getRewardedVideoValidAds(
      placementID: AppAdConfig.rewarderPlacementID,
    ).then((value) {
      Utils.logError('激励广告：激励视频有效广告数量：$value');
    });
  }

  /// 激励视频监听（须在 initTopon 后注册一次，见 splash_page）
  void rewardedAdListen() {
    if (_rewardedSubscription != null) {
      return;
    }
    _rewardedSubscription = ATListenerManager.rewardedVideoEventHandler.listen(
      _onRewardedEvent,
    );
  }

  void _onRewardedEvent(ATRewardResponse value) {
    if (value.placementID.toString() != AppAdConfig.rewarderPlacementID) {
      return;
    }

    switch (value.rewardStatus) {
      case RewardedStatus.rewardedVideoDidFailToLoad:
        Utils.logError(
          '激励广告 加载失败 ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}',
        );
        AdLogCollector.addLog(
          AdLogFormatter.rewardedFail(
            placementId: value.placementID.toString(),
            requestMessage: value.requestMessage,
            extraMap: value.extraMap,
          ),
        );
        if (_isBusy || _pendingShow) {
          _resetWatchState();
          CuToast.error(msg: '广告加载失败');
        }
        unawaited(_logValidAds());
        break;
      case RewardedStatus.rewardedVideoDidFinishLoading:
        Utils.logError(
          '激励广告 加载成功 ---- placementID: ${value.placementID}',
        );
        if (_pendingShow) {
          _safePresentFromListener();
        }
        break;
      case RewardedStatus.rewardedVideoDidStartPlaying:
        Utils.logError(
          '激励广告 开始播放 ---- placementID: ${value.placementID} ---- extra:${value.extraMap}',
        );
        EasyLoading.dismiss();
        break;
      case RewardedStatus.rewardedVideoDidEndPlaying:
        Utils.logError(
          '激励广告 结束播放 ---- placementID: ${value.placementID} ---- extra:${value.extraMap}',
        );
        break;
      case RewardedStatus.rewardedVideoDidFailToPlay:
        Utils.logError(
          '激励广告 播放失败 ---- placementID: ${value.placementID} ---- extra:${value.extraMap}',
        );
        AdLogCollector.addLog(
          AdLogFormatter.rewardedFail(
            placementId: value.placementID.toString(),
            requestMessage: value.requestMessage,
            extraMap: value.extraMap,
          ),
        );
        _resetWatchState();
        CuToast.error(msg: '广告播放失败');
        break;
      case RewardedStatus.rewardedVideoDidRewardSuccess:
      case RewardedStatus.rewardedVideoDidAgainRewardSuccess:
        _onRewardGranted(value);
        break;
      case RewardedStatus.rewardedVideoDidClick:
        Utils.logError(
          '激励广告 点击 ---- placementID: ${value.placementID} ---- extra:${value.extraMap}',
        );
        break;
      case RewardedStatus.rewardedVideoDidDeepLink:
        Utils.logError(
          '激励广告 DeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap} ---- isDeeplinkSuccess:${value.isDeeplinkSuccess}',
        );
        break;
      case RewardedStatus.rewardedVideoDidClose:
        Utils.logError(
          '激励广告 关闭 ---- placementID: ${value.placementID} ---- extra:${value.extraMap}',
        );
        _resetWatchState();
        break;
      case RewardedStatus.rewardedVideoDidAgainStartPlaying:
        Utils.logError(
          '激励广告 Again 开始播放 ---- placementID: ${value.placementID} ---- extra:${value.extraMap}',
        );
        break;
      case RewardedStatus.rewardedVideoDidAgainEndPlaying:
        Utils.logError(
          '激励广告 Again 结束播放 ---- placementID: ${value.placementID} ---- extra:${value.extraMap}',
        );
        break;
      case RewardedStatus.rewardedVideoDidAgainFailToPlay:
        Utils.logError(
          '激励广告 Again 播放失败 ---- placementID: ${value.placementID} ---- extra:${value.extraMap}',
        );
        break;
      case RewardedStatus.rewardedVideoDidAgainClick:
        Utils.logError(
          '激励广告 Again 点击 ---- placementID: ${value.placementID} ---- extra:${value.extraMap}',
        );
        break;
      case RewardedStatus.rewardedVideoUnknown:
        Utils.logError('激励广告 rewardedVideoUnknown');
        break;
    }
  }

  void _onRewardGranted(ATRewardResponse value) {
    Utils.logError(
      '激励广告 激励成功 ---- placementID: ${value.placementID} ---- extra:${value.extraMap}',
    );
    AdLogCollector.addLog(
      AdLogFormatter.rewardedSuccess(
        placementId: value.placementID.toString(),
        extraMap: value.extraMap,
      ),
    );
    final AdInfo adInfo = AdInfo.fromTakuExtra(
      extraMap: value.extraMap,
      placementID: value.placementID.toString(),
      createdTime: Jiffy.now().format(pattern: 'yyyy-MM-dd HH:mm:ss'),
      adType: AdInfo.typeRewarded,
    );
    _safeAddAdInfo(adInfo);
    CuToast.success(msg: '观看完成，已记录收益');
  }

  void _safePresentFromListener() {
    unawaited(
      _presentRewardedVideo().catchError((Object e, StackTrace st) {
        Utils.logError('_presentRewardedVideo 失败: $e', error: e, stackTrace: st);
        _resetWatchState();
        CuToast.error(msg: '广告播放失败');
      }),
    );
  }

  void _safeAddAdInfo(AdInfo adInfo) {
    unawaited(
      _adStatsNotifier.addAdInfos(adInfo).catchError((Object e, StackTrace st) {
        Utils.logError('addAdInfos 失败: $e', error: e, stackTrace: st);
      }),
    );
  }

  Future<void> _presentRewardedVideo() async {
    if (_isPresenting) {
      return;
    }
    _isPresenting = true;
    _pendingShow = false;
    _cancelLoadTimeout();
    await ATRewardedManager.showRewardedVideo(
      placementID: AppAdConfig.rewarderPlacementID,
    );
  }

  ({String userID, String extra}) _loadParams() {
    final int userId = _userNotifier.userModel.id;
    return (
      userID: '$userId',
      extra: 'userid_${userId}_type_1_amount_0_time_0',
    );
  }

  bool _isMapFlag(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }

  void _startLoadTimeout() {
    _cancelLoadTimeout();
    _loadTimeoutTimer = Timer(_loadTimeout, () {
      if (!_isBusy && !_pendingShow) {
        return;
      }
      Utils.logError('激励广告加载超时');
      _resetWatchState();
      CuToast.error(msg: '广告加载超时，请稍后再试');
    });
  }

  void _cancelLoadTimeout() {
    _loadTimeoutTimer?.cancel();
    _loadTimeoutTimer = null;
  }

  void _resetWatchState({bool dismissLoading = true}) {
    _isBusy = false;
    _pendingShow = false;
    _isPresenting = false;
    _cancelLoadTimeout();
    if (dismissLoading) {
      EasyLoading.dismiss();
    }
  }
}
