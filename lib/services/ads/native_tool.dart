import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/app/providers.dart';
import 'package:base_object/data/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:base_object/data/models/localModels/UpADModel.dart';
import 'package:base_object/data/notifiers/ad_stats_notifier.dart';
import 'package:base_object/data/notifiers/user_notifier.dart';
import 'package:base_object/shared/config/app_ad_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiffy/jiffy.dart';

/// 首页信息流槽位状态
enum HomeNativeSlotState { idle, loading, ready, failed }

String _nativeFeedExtraPreview(dynamic extra) {
  if (extra == null) return 'null';
  final String s = extra.toString();
  const int maxLen = 480;
  return s.length > maxLen ? '${s.substring(0, maxLen)}…(len=${s.length})' : s;
}

void _logNativeFeed(String message) {
  Utils.logError('[NativeFeed] $message');
}

/// Taku 原生信息流：展示时序与老项目一致；黄忠胜1/2/3 仅调试日志。
class NativeTool extends ChangeNotifier {
  NativeTool({
    required AdStatsNotifier adStatsNotifier,
    required UserNotifier userNotifier,
  }) : _adStatsNotifier = adStatsNotifier,
       _userNotifier = userNotifier;

  /// 单次展示成功后，延迟自动先停再开（与 nativeAdDidShowNativeAd 联动）
  static const Duration _nativeFeedPostShowReloadDelay = Duration(seconds: 16);

  /// 黄忠胜3：有效广告列表轮询间隔（仅日志，不参与挂载/换条）。
  static const Duration _nativeValidAdsPollInterval = Duration(seconds: 5);

  final AdStatsNotifier _adStatsNotifier;
  final UserNotifier _userNotifier;

  static NativeTool get to => globalContainer.read(nativeToolProvider);

  bool _nativeFeedPlaybackPaused = true;
  bool get nativeFeedPlaybackPaused => _nativeFeedPlaybackPaused;

  HomeNativeSlotState _nativeSlotState = HomeNativeSlotState.idle;
  HomeNativeSlotState get nativeSlotState => _nativeSlotState;

  bool _isViewCreated = false;
  bool get isViewCreated => _isViewCreated;

  int _nativeFeedPlatformGeneration = 0;
  int get nativeFeedPlatformGeneration => _nativeFeedPlatformGeneration;

  int? _nativeFeedAutoReloadCountdown;
  int? get nativeFeedAutoReloadCountdown => _nativeFeedAutoReloadCountdown;

  /// 仅驱动「停止信息流（N）」按钮文案，避免每秒 notify 重建 PlatformView。
  final ChangeNotifier _reloadCountdownListenable = ChangeNotifier();
  Listenable get reloadCountdownListenable => _reloadCountdownListenable;

  int _nativeFailReloadToken = 0;
  bool _preloadInFlight = false;
  Timer? _nativeFeedPostShowReloadTimer;
  Timer? _nativeValidAdsPollTimer;
  StreamSubscription<ATNativeResponse>? _nativeAdSubscription;

  double get adHeight => 250.h;

  void _notify() => notifyListeners();

  void _setPaused(bool value) {
    if (_nativeFeedPlaybackPaused == value) return;
    _nativeFeedPlaybackPaused = value;
    _notify();
  }

  void _setSlotState(HomeNativeSlotState value) {
    if (_nativeSlotState == value) return;
    _nativeSlotState = value;
    _notify();
  }

  void _setViewCreated(bool value, {String reason = ''}) {
    if (_isViewCreated == value) return;
    final String from = _isViewCreated ? 'true' : 'false';
    _isViewCreated = value;
    _notify();
    _logNativeFeed(
      'isViewCreated $from→${value ? 'true' : 'false'}'
      '${reason.isEmpty ? '' : ' reason=$reason'} '
      'paused=$_nativeFeedPlaybackPaused slot=$_nativeSlotState',
    );
  }

  void _setReloadCountdown(int? value) {
    if (_nativeFeedAutoReloadCountdown == value) return;
    _nativeFeedAutoReloadCountdown = value;
    _reloadCountdownListenable.notifyListeners();
  }

  void _cancelNativeFeedPostShowReloadTimer() {
    _nativeFeedPostShowReloadTimer?.cancel();
    _nativeFeedPostShowReloadTimer = null;
    _setReloadCountdown(null);
  }

  void _onNativeFeedPostShowReloadPeriodicTick(Timer t) {
    final int? cur = _nativeFeedAutoReloadCountdown;
    if (cur == null) {
      t.cancel();
      _nativeFeedPostShowReloadTimer = null;
      return;
    }
    if (cur <= 1) {
      _nativeFeedPostShowReloadTimer?.cancel();
      _nativeFeedPostShowReloadTimer = null;
      _setReloadCountdown(null);
      if (!_nativeFeedPlaybackPaused) {
        unawaited(_nativeFeedPostShowReloadTick());
      }
      return;
    }
    _setReloadCountdown(cur - 1);
  }

  void _scheduleNativeFeedPostShowReload() {
    _cancelNativeFeedPostShowReloadTimer();
    final int total = _nativeFeedPostShowReloadDelay.inSeconds;
    _setReloadCountdown(total);
    _logNativeFeed(
      '已启动 ${total}s 自动刷新倒计时（每秒更新），到时 remove→startNativeFeedPlayback 全自动',
    );
    _nativeFeedPostShowReloadTimer = Timer.periodic(
      const Duration(seconds: 1),
      _onNativeFeedPostShowReloadPeriodicTick,
    );
  }

  Future<void> _nativeFeedPostShowReloadTick() async {
    if (_nativeFeedPlaybackPaused) {
      _logNativeFeed('postShowReload：已跳过（playbackPaused=true）');
      return;
    }
    _logNativeFeed(
      'postShowReload：${_nativeFeedPostShowReloadDelay.inSeconds}s 到，'
      'remove → 短延迟 → startNativeFeedPlayback（与手动「开始」相同：始终 load+展示）',
    );
    _preloadInFlight = false;
    _nativeFeedPlatformGeneration++;
    _setViewCreated(false, reason: 'postShowReload');
    _setSlotState(HomeNativeSlotState.loading);
    try {
      await removeNativeAd();
      _logNativeFeed('postShowReload removeNativeAd 完成');
    } catch (e, st) {
      _logNativeFeed('postShowReload removeNativeAd 异常: $e $st');
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await startNativeFeedPlayback();
  }

  void _stopNativeValidAdsPoll() {
    _nativeValidAdsPollTimer?.cancel();
    _nativeValidAdsPollTimer = null;
  }

  void _startNativeValidAdsPoll() {
    _stopNativeValidAdsPoll();
    unawaited(_pollHuangZhongsheng3());
    _nativeValidAdsPollTimer = Timer.periodic(
      _nativeValidAdsPollInterval,
      (_) => unawaited(_pollHuangZhongsheng3()),
    );
    _logNativeFeed(
      '已启动每 ${_nativeValidAdsPollInterval.inSeconds} 秒轮询（黄忠胜3）',
    );
  }

  bool _parseNativeIsLoading(dynamic value) {
    if (value is! Map) return true;
    final dynamic isLoading = value['isLoading'];
    if (isLoading is bool) return isLoading;
    if (isLoading is num) return isLoading != 0;
    return false;
  }

  /// 黄忠胜1 + 黄忠胜2（仅日志，不改变 load/挂载时序）。
  Future<void> _pollHuangZhongsheng1And2() async {
    try {
      final bool ready = await ATNativeManager.nativeAdReady(
        placementID: AppAdConfig.nativePlacementID,
      );
      _logNativeFeed('黄忠胜1：信息流广告是否就绪（有缓存）：$ready');
    } catch (e, st) {
      _logNativeFeed('黄忠胜1：查询失败：$e $st');
    }
    try {
      final dynamic value = await ATNativeManager.checkNativeAdLoadStatus(
        placementID: AppAdConfig.nativePlacementID,
      );
      final bool isLoading = _parseNativeIsLoading(value);
      _logNativeFeed('黄忠胜2：信息流广告加载状态：$value');
      _logNativeFeed(
        '黄忠胜2：isLoading=$isLoading canShowHint=${!isLoading && (_isViewCreated || !_nativeFeedPlaybackPaused)}',
      );
    } catch (e, st) {
      _logNativeFeed('黄忠胜2：查询失败：$e $st');
    }
  }

  Future<void> _pollHuangZhongsheng3() async {
    try {
      final String value = await ATNativeManager.getNativeValidAds(
        placementID: AppAdConfig.nativePlacementID,
      );
      if (value.isEmpty) {
        _logNativeFeed(
          '黄忠胜3：信息流有效广告列表为空 '
          '(isViewCreated=$_isViewCreated slot=$_nativeSlotState)',
        );
      } else {
        _logNativeFeed('黄忠胜3：信息流有效广告列表：$value');
      }
    } catch (e, st) {
      _logNativeFeed('黄忠胜3：查询失败：$e $st');
    }
  }

  double get _nativeContentWidth => ScreenUtil().screenWidth - 20.w;

  Map<String, dynamic> _nativeLoadExtraMap() {
    return {
      ATCommon.isNativeShow(): false,
      ATCommon.getAdSizeKey(): ATNativeManager.createNativeSubViewAttribute(
        _nativeContentWidth,
        adHeight,
      ),
      ATNativeManager.isAdaptiveHeight(): true,
    };
  }

  Future<void> _invokeNativeLoadPipeline() async {
    await ATNativeManager.loadNativeAd(
      placementID: AppAdConfig.nativePlacementID,
      extraMap: _nativeLoadExtraMap(),
    );
    _logNativeFeed('loadNativeAd 调用已返回（挂载由 nativeAdDidFinishLoading 触发）');
    // 非阻塞 entry：finishLoading 已挂 PlatformView，await entry 完成可能触发二次 renderNativeView（no cache 卡死）
    unawaited(
      () async {
        try {
          await ATNativeManager.entryNativeScenario(
            placementID: AppAdConfig.nativePlacementID,
            sceneID: AppAdConfig.nativeSceneID,
          );
          _logNativeFeed('entryNativeScenario 已调用（非阻塞）');
        } catch (e, st) {
          _logNativeFeed('entryNativeScenario 异常: $e $st');
        }
      }(),
    );
  }

  Future<void> preloadNativeFeedOnce() async {
    if (_preloadInFlight) {
      _logNativeFeed('preloadNativeFeedOnce 跳过：已在执行');
      return;
    }
    try {
      if (await nativeAdReady()) {
        _logNativeFeed('preloadNativeFeedOnce 跳过：nativeAdReady 已为 true');
        if (!_isViewCreated) {
          _setViewCreated(true, reason: 'preloadNativeFeedOnce nativeAdReady');
        }
        _setSlotState(HomeNativeSlotState.ready);
        return;
      }
    } catch (e, st) {
      _logNativeFeed('preloadNativeFeedOnce nativeAdReady 检查异常: $e $st');
    }
    _preloadInFlight = true;
    _logNativeFeed(
      'preloadNativeFeedOnce 开始（paused=$_nativeFeedPlaybackPaused）',
    );
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!_preloadInFlight || !_nativeFeedPlaybackPaused) {
        _logNativeFeed('preloadNativeFeedOnce abort: 用户已开始或已取消');
        return;
      }
      await _invokeNativeLoadPipeline();
    } catch (e, st) {
      _logNativeFeed('preloadNativeFeedOnce 异常: $e\n$st');
      if (_nativeFeedPlaybackPaused) {
        _setSlotState(HomeNativeSlotState.idle);
      }
    } finally {
      _preloadInFlight = false;
    }
  }

  Future<void> loadNativeWith({bool forceShowLoading = false}) async {
    if (_nativeFeedPlaybackPaused) {
      _logNativeFeed(
        'loadNativeWith 跳过：playbackPaused=true placement=${AppAdConfig.nativePlacementID}',
      );
      return;
    }
    if (forceShowLoading || !_isViewCreated) {
      _setSlotState(HomeNativeSlotState.loading);
    }
    _logNativeFeed(
      'loadNativeWith 开始 forceShowLoading=$forceShowLoading '
      'isViewCreated=$_isViewCreated slot=$_nativeSlotState '
      'placement=${AppAdConfig.nativePlacementID} scene=${AppAdConfig.nativeSceneID} '
      'size=($_nativeContentWidth x $adHeight)',
    );
    try {
      await _invokeNativeLoadPipeline();
    } catch (e, st) {
      _logNativeFeed('loadNativeWith 异常: $e\n$st');
      if (!_nativeFeedPlaybackPaused && !_isViewCreated) {
        _setSlotState(HomeNativeSlotState.failed);
      }
    }
  }

  Future<void> startNativeFeedPlayback() async {
    _cancelNativeFeedPostShowReloadTimer();
    _nativeFailReloadToken++;
    _preloadInFlight = false;
    _setPaused(false);
    _logNativeFeed(
      'startNativeFeedPlayback token=$_nativeFailReloadToken（始终 load）',
    );
    _setViewCreated(false, reason: 'startNativeFeedPlayback');
    _setSlotState(HomeNativeSlotState.loading);
    await _pollHuangZhongsheng1And2();
    await loadNativeWith(forceShowLoading: true);
    _startNativeValidAdsPoll();
  }

  Future<void> pauseNativeFeedPlayback() async {
    _stopNativeValidAdsPoll();
    _cancelNativeFeedPostShowReloadTimer();
    _nativeFailReloadToken++;
    _preloadInFlight = false;
    _logNativeFeed('pauseNativeFeedPlayback token=$_nativeFailReloadToken');
    _setPaused(true);
    _setViewCreated(false, reason: 'pauseNativeFeedPlayback');
    _setSlotState(HomeNativeSlotState.idle);
    try {
      await removeNativeAd();
      _logNativeFeed('pauseNativeFeedPlayback removeNativeAd 完成');
    } catch (e, st) {
      _logNativeFeed('pauseNativeFeedPlayback removeNativeAd 异常: $e $st');
    }
  }

  Future<void> startNativePlayback([double? _]) => startNativeFeedPlayback();

  Future<void> pauseNativePlayback() => pauseNativeFeedPlayback();

  Future<bool> nativeAdReady() async {
    try {
      final bool isReady = await ATNativeManager.nativeAdReady(
        placementID: AppAdConfig.nativePlacementID,
      );
      Utils.logError('原生广告：原生广告是否就绪：$isReady');
      return isReady;
    } catch (e) {
      Utils.logError('原生广告：原生广告是否就绪：$e');
      return false;
    }
  }

  Future<bool> getNativeValidAds() async {
    final String res = await ATNativeManager.getNativeValidAds(
      placementID: AppAdConfig.nativePlacementID,
    );
    final bool has = res.isNotEmpty;
    _logNativeFeed(
      'getNativeValidAds placement=${AppAdConfig.nativePlacementID} hasData=$has len=${res.length}',
    );
    if (has) {
      _logNativeFeed('getNativeValidAds 内容预览: ${_nativeFeedExtraPreview(res)}');
    }
    return has;
  }

  Future<bool> checkNativeAdLoadStatus() async {
    try {
      final value = await ATNativeManager.checkNativeAdLoadStatus(
        placementID: AppAdConfig.nativePlacementID,
      );
      Utils.logError('检查加载状态$value');
      final dynamic isLoading = value['isLoading'] ?? 0;
      if (isLoading is bool) return isLoading;
      if (isLoading is num) return isLoading != 0;
      return false;
    } catch (error) {
      Utils.logError('检查原生广告状态失败: $error');
      return false;
    }
  }

  Map<String, dynamic> getAdConfig() {
    final double w = _nativeContentWidth;
    return {
      ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
        w,
        adHeight,
        backgroundColorStr: '#FFFFFF',
      ),
      ATNativeManager.appIcon(): ATNativeManager.createNativeSubViewAttribute(
        50.sp,
        50.sp,
        x: 10.w,
        y: 40.h,
        backgroundColorStr: '#736bba',
      ),
      ATNativeManager.mainTitle(): ATNativeManager.createNativeSubViewAttribute(
        w - 190.w,
        20.h,
        x: 0.w,
        y: 0.h,
        textSize: 8.sp,
        textColorStr: '#f31e17',
      ),
      ATNativeManager.desc(): ATNativeManager.createNativeSubViewAttribute(
        w - 190.w,
        20.h,
        x: 70.w,
        y: 70.h,
        textSize: 13.sp,
        textColorStr: '#736bba',
      ),
      ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
        100.w,
        35.h,
        x: w - 110.w,
        y: 40.h,
        textSize: 14.sp,
        textColorStr: '#FFFFFF',
        backgroundColorStr: '#faa683',
        cornerRadius: 4,
      ),
      ATNativeManager.mainImage(): ATNativeManager.createNativeSubViewAttribute(
        ScreenUtil().screenWidth,
        180.h,
        x: 20.w,
        y: 0.h,
        backgroundColorStr: '#b54747',
        cornerRadius: 4,
      ),
      ATNativeManager.adLogo(): ATNativeManager.createNativeSubViewAttribute(
        40.w,
        18.h,
        x: 10.w,
        y: 10.h,
        textSize: 12.sp,
        textColorStr: '#FFFFFF',
        backgroundColorStr: '#3574f0',
        cornerRadius: 2,
      ),
      ATNativeManager.dislike(): ATNativeManager.createNativeSubViewAttribute(
        20.sp,
        20.sp,
        x: w - 30.w,
        y: 10.h,
        backgroundColorStr: '#139343',
      ),
      ATNativeManager.elementsView():
          ATNativeManager.createNativeSubViewAttribute(
            w - 20.w,
            25.h,
            x: 10.w,
            y: adHeight - 25.h,
            textSize: 10.sp,
            textColorStr: '#FFFFFF',
            backgroundColorStr: '#1e1f22',
          ),
    };
  }

  Future<void> nativeUpDataADFn(ATNativeResponse event) async {
    try {
      if (!_userNotifier.isLoggedIn) return;
      await _adStatsNotifier.getFkConfigFn();

      final UpDataADForm upDataADForm = UpDataADForm();
      final dynamic publisherRevenueCny = event.extraMap['publisher_revenue_cny'];
      final double? amount = double.tryParse(
        publisherRevenueCny?.toString() ?? '0',
      );
      final String reqId = event.extraMap['req_id']?.toString() ?? '';
      final String adsourceId = event.extraMap['adsource_id']?.toString() ?? '';
      final String userId = _userNotifier.userModel.id.toString();
      upDataADForm.extra =
          'userid_${userId}_type_2_amount_${publisherRevenueCny ?? 0}_time_0';
      upDataADForm.transId = event.extraMap['id'];
      upDataADForm.amount = amount;
      upDataADForm.adsourceId = adsourceId;
      upDataADForm.reqId = reqId;
      upDataADForm.sign = Utils.generateEncryptedString(
        userId: userId,
        reqId: reqId,
        adsourceId: adsourceId,
      );
      if (amount == null) return;
      final double amount1 = amount * 10000;
      final UpADModel upADModel = UpADModel(
        adsourceId: adsourceId,
        reqId: reqId,
        adType: '原生（信息流)广告',
        adAmount: amount1,
      );
      if (amount1 > _adStatsNotifier.fkConfig.wactchMaxAmountV1) {
        _adStatsNotifier.addWatchMaxAdList(upADModel);
      }
      if (amount1 < _adStatsNotifier.fkConfig.wactchMinAmountV1) {
        _adStatsNotifier.addWatchMinAdList(upADModel);
      }
    } catch (e) {
      Utils.logError('上报信息流失败：$e');
    }
  }

  void nativeListen() {
    if (_nativeAdSubscription != null) {
      return;
    }
    _nativeAdSubscription = ATListenerManager.nativeEventHandler.listen((
      value,
    ) async {
      _logNativeFeed(
        '<<< 回调 status=${value.nativeStatus} placementID=${value.placementID} '
        'requestMessage=${value.requestMessage} '
        'paused=$_nativeFeedPlaybackPaused '
        'isViewCreated=$_isViewCreated slot=$_nativeSlotState '
        'extra=${_nativeFeedExtraPreview(value.extraMap)}',
      );
      switch (value.nativeStatus) {
        case NativeStatus.nativeAdDidFinishLoading:
          _setViewCreated(true, reason: 'nativeAdDidFinishLoading');
          _setSlotState(HomeNativeSlotState.ready);
          unawaited(_pollHuangZhongsheng1And2());
          if (_nativeFeedPlaybackPaused) {
            _logNativeFeed(
              'nativeAdDidFinishLoading 预加载完成（UI 仍为暂停）placement=${value.placementID} '
              '→ isViewCreated=true 供后续「开始信息流」直接展示',
            );
          } else {
            _logNativeFeed(
              'nativeAdDidFinishLoading → isViewCreated=true slot=ready placement=${value.placementID}',
            );
          }
          break;

        case NativeStatus.nativeAdDidShowNativeAd:
          if (_nativeFeedPlaybackPaused) {
            _logNativeFeed(
              'nativeAdDidShowNativeAd 忽略：playbackPaused=true placement=${value.placementID}',
            );
            return;
          }
          _logNativeFeed(
            'nativeAdDidShowNativeAd 展示成功 placement=${value.placementID} '
            '保持 isViewCreated=true slot=ready（不 notify 槽位，避免二次 renderNativeView）',
          );
          await _adStatsNotifier.addAdInfos(
            AdInfo.fromTakuExtra(
              extraMap: value.extraMap,
              placementID: value.placementID.toString(),
              createdTime: Jiffy.now().format(pattern: 'yyyy-MM-dd HH:mm:ss'),
              adType: AdInfo.typeNative,
            ),
          );
          _logNativeFeed('nativeAdDidShowNativeAd 已写入 AdInfo');
          await nativeUpDataADFn(value);
          final String pid = value.placementID.toString();
          if (pid == AppAdConfig.nativePlacementID) {
            _scheduleNativeFeedPostShowReload();
          } else {
            _logNativeFeed(
              'nativeAdDidShowNativeAd 跳过 postShowReload：placement=$pid '
              '!= ${AppAdConfig.nativePlacementID}',
            );
          }
          break;

        case NativeStatus.nativeAdDidTapCloseButton:
          _logNativeFeed(
            'nativeAdDidTapCloseButton placement=${value.placementID}',
          );
          break;

        case NativeStatus.nativeAdFailToLoadAD:
          final bool wasShowing =
              _isViewCreated && !_nativeFeedPlaybackPaused;
          final bool hasValid = await getNativeValidAds();
          if (wasShowing && !hasValid) {
            // 老项目 show 回调注释：展示后 validAds 可能短暂为空，勿拆掉 PlatformView（一闪而过）
            _logNativeFeed(
              'failToLoad 播放中 validAds 空 → 保持 isViewCreated=true 防一闪 '
              'msg=${value.requestMessage}',
            );
          } else {
            _setViewCreated(
              hasValid,
              reason: 'nativeAdFailToLoadAD hasValid=$hasValid',
            );
            if (!_isViewCreated) {
              if (_nativeFeedPlaybackPaused) {
                _setSlotState(HomeNativeSlotState.idle);
                _logNativeFeed(
                  'nativeAdFailToLoadAD 预加载失败（暂停态）placement=${value.placementID} '
                  'msg=${value.requestMessage}',
                );
              } else {
                _setSlotState(HomeNativeSlotState.failed);
              }
            }
          }
          unawaited(_pollHuangZhongsheng3());
          _logNativeFeed(
            'nativeAdFailToLoadAD placement=${value.placementID} '
            'msg=${value.requestMessage} isViewCreated=$_isViewCreated '
            'slot=$_nativeSlotState wasShowing=$wasShowing hasValid=$hasValid',
          );
          final int token = _nativeFailReloadToken;
          await Future<void>.delayed(const Duration(seconds: 2));
          if (token != _nativeFailReloadToken) {
            _logNativeFeed(
              'nativeAdFailToLoadAD 取消重试：token 已变 ($token != $_nativeFailReloadToken)',
            );
            return;
          }
          if (_nativeFeedPlaybackPaused) {
            _logNativeFeed('nativeAdFailToLoadAD 取消重试：playbackPaused=true');
            return;
          }
          _logNativeFeed('nativeAdFailToLoadAD → 2s 后重试 loadNativeWith');
          await loadNativeWith(forceShowLoading: false);
          break;

        default:
          _logNativeFeed(
            '其它事件 status=${value.nativeStatus} placement=${value.placementID} '
            'msg=${value.requestMessage}',
          );
          break;
      }
    });
    _logNativeFeed(
      'nativeListen 已订阅 nativeEventHandler placement=${AppAdConfig.nativePlacementID}',
    );
  }

  Future<void> removeNativeAd() async {
    _logNativeFeed('removeNativeAd placement=${AppAdConfig.nativePlacementID}');
    await ATNativeManager.removeNativeAd(
      placementID: AppAdConfig.nativePlacementID,
    );
  }

  @override
  void dispose() {
    _stopNativeValidAdsPoll();
    _cancelNativeFeedPostShowReloadTimer();
    _nativeAdSubscription?.cancel();
    super.dispose();
  }
}
