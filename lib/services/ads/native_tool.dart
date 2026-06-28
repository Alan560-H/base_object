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

/// 黄忠胜1/2 查询结果（决定是否 load / 轮询等待）。
class _NativeHz12Snapshot {
  const _NativeHz12Snapshot({
    required this.nativeAdReady,
    required this.isLoading,
    required this.isReady,
  });

  final bool nativeAdReady;
  final bool isLoading;
  final bool isReady;

  /// 有缓存或可展示：走 loadNativeWith → finishLoading → mount。
  bool get canLoadNativeFeed => nativeAdReady || isReady;

  /// 无填充且未在加载：只轮询，不 mount。
  bool get shouldPollOnly =>
      !nativeAdReady && !isLoading && !isReady;
}

/// Taku 原生信息流；黄忠胜1/2 门控 load，无填充时 3 秒轮询。
class NativeTool extends ChangeNotifier {
  NativeTool({
    required AdStatsNotifier adStatsNotifier,
    required UserNotifier userNotifier,
  }) : _adStatsNotifier = adStatsNotifier,
       _userNotifier = userNotifier;

  /// 无填充时：每 3 秒轮询黄忠胜1/2，直到可 load。
  static const Duration _nativeFeedFillPollInterval = Duration(seconds: 3);

  /// 播放中调试：黄忠胜3 有效广告列表轮询间隔。
  static const Duration _nativeValidAdsPollInterval = Duration(seconds: 3);

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

  int _nativeFailReloadToken = 0;
  int _videoEndReloadToken = 0;
  bool _preloadInFlight = false;
  Map<String, dynamic> _lastNativeShowExtra = <String, dynamic>{};
  Timer? _nativeFeedFillPollTimer;
  int _nativeFeedFillPollToken = 0;
  bool _nativeLoadPipelineRequestedWhileWaiting = false;
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

  void _stopNativeFeedFillPoll() {
    _nativeFeedFillPollTimer?.cancel();
    _nativeFeedFillPollTimer = null;
    _nativeLoadPipelineRequestedWhileWaiting = false;
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

  bool _parseNativeBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return false;
  }

  /// 黄忠胜1 + 黄忠胜2，返回快照供门控 load / 轮询。
  Future<_NativeHz12Snapshot> _checkHuangZhongsheng12() async {
    bool nativeAdReady = false;
    bool isLoading = false;
    bool isReady = false;
    try {
      nativeAdReady = await ATNativeManager.nativeAdReady(
        placementID: AppAdConfig.nativePlacementID,
      );
      _logNativeFeed('黄忠胜1：信息流广告是否就绪（有缓存）：$nativeAdReady');
    } catch (e, st) {
      _logNativeFeed('黄忠胜1：查询失败：$e $st');
    }
    try {
      final dynamic value = await ATNativeManager.checkNativeAdLoadStatus(
        placementID: AppAdConfig.nativePlacementID,
      );
      isLoading = _parseNativeIsLoading(value);
      if (value is Map) {
        isReady = _parseNativeBool(value['isReady']);
      }
      _logNativeFeed('黄忠胜2：信息流广告加载状态：$value');
      _logNativeFeed(
        '黄忠胜2：isLoading=$isLoading isReady=$isReady '
        'canLoad=${nativeAdReady}',
      );
    } catch (e, st) {
      _logNativeFeed('黄忠胜2：查询失败：$e $st');
    }
    return _NativeHz12Snapshot(
      nativeAdReady: nativeAdReady,
      isLoading: isLoading,
      isReady: isReady,
    );
  }

  Future<void> _pollHuangZhongsheng1And2() async {
    await _checkHuangZhongsheng12();
  }

  Future<void> _pollHuangZhongsheng3() async {
    _logNativeFeed(
      '黄忠胜3：开始查询 getNativeValidAds '
      '(isViewCreated=$_isViewCreated slot=$_nativeSlotState paused=$_nativeFeedPlaybackPaused)',
    );
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

  bool _hasNativeRevenueExtra(Map<dynamic, dynamic> extra) {
    return extra['req_id'] != null &&
        extra['req_id'].toString().isNotEmpty;
  }

  Map<String, dynamic> _nativeRevenueExtraFrom(ATNativeResponse value) {
    if (_hasNativeRevenueExtra(value.extraMap)) {
      return Map<String, dynamic>.from(value.extraMap);
    }
    if (_lastNativeShowExtra.isNotEmpty) {
      return Map<String, dynamic>.from(_lastNativeShowExtra);
    }
    return <String, dynamic>{};
  }

  Future<void> _recordNativeAdRevenue(
    Map<String, dynamic> extraMap, {
    required String placementID,
    required String reason,
  }) async {
    if (!_hasNativeRevenueExtra(extraMap)) {
      _logNativeFeed('$reason：extra 无 req_id，跳过记收益');
      return;
    }
    await _adStatsNotifier.addAdInfos(
      AdInfo.fromTakuExtra(
        extraMap: extraMap,
        placementID: placementID,
        createdTime: Jiffy.now().format(pattern: 'yyyy-MM-dd HH:mm:ss'),
        adType: AdInfo.typeNative,
      ),
    );
    _logNativeFeed('$reason：已写入 AdInfo req_id=${extraMap['req_id']}');
    await nativeUpDataADFn(extraMap, placementID: placementID);
  }

  /// 拆容器（等同停止信息流的原生 remove，但 **不** 置 paused=true）。
  Future<void> _tearDownNativeFeedContainer({required String reason}) async {
    _nativeLoadPipelineRequestedWhileWaiting = false;
    _nativeFeedPlatformGeneration++;
    _setViewCreated(false, reason: reason);
    _setSlotState(HomeNativeSlotState.loading);
    try {
      await _removeNativeAdWithTimeout(reason: reason);
    } catch (e, st) {
      _logNativeFeed('$reason tearDown removeNativeAd 异常: $e $st');
    }
  }

  /// remove 在部分机型上 Future 不返回，超时后继续换条流程避免一直「加载中」。
  Future<void> _removeNativeAdWithTimeout({
    required String reason,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    _logNativeFeed('removeNativeAd 开始 reason=$reason timeout=${timeout.inSeconds}s');
    try {
      await removeNativeAd().timeout(timeout);
      _logNativeFeed('$reason removeNativeAd 完成');
    } on TimeoutException {
      _logNativeFeed(
        '$reason removeNativeAd 超时 ${timeout.inSeconds}s，继续后续 load（避免卡 loading）',
      );
    }
  }

  /// 黄忠胜1/2 门控：有缓存则 load；否则 3 秒轮询，不 mount。
  Future<void> _ensureNativeFeedFromHz12({
    bool forceShowLoading = false,
    int? videoEndGuardToken,
  }) async {
    if (_nativeFeedPlaybackPaused) {
      _logNativeFeed('_ensureNativeFeedFromHz12 跳过：playbackPaused=true');
      return;
    }
    if (videoEndGuardToken != null &&
        videoEndGuardToken != _videoEndReloadToken) {
      return;
    }

    final _NativeHz12Snapshot snap = await _checkHuangZhongsheng12();
    if (_nativeFeedPlaybackPaused) return;
    if (videoEndGuardToken != null &&
        videoEndGuardToken != _videoEndReloadToken) {
      return;
    }

    if (snap.canLoadNativeFeed) {
      _stopNativeFeedFillPoll();
      if (_isViewCreated) {
        _logNativeFeed('黄忠胜1/2 已就绪且 isViewCreated=true，跳过重复 loadNativeWith');
        _startNativeValidAdsPoll();
        return;
      }
      _logNativeFeed('黄忠胜1/2 满足 → loadNativeWith');
      await loadNativeWith(forceShowLoading: forceShowLoading);
      _startNativeValidAdsPoll();
      return;
    }

    _logNativeFeed(
      '黄忠胜1/2 无填充（ready=${snap.nativeAdReady} isLoading=${snap.isLoading} '
      'isReady=${snap.isReady}）→ 不 loadNativeWith，启动每 '
      '${_nativeFeedFillPollInterval.inSeconds} 秒轮询',
    );
    _setSlotState(HomeNativeSlotState.loading);
    _startNativeFeedFillPoll(
      forceShowLoading: forceShowLoading,
      videoEndGuardToken: videoEndGuardToken,
    );
  }

  void _startNativeFeedFillPoll({
    required bool forceShowLoading,
    int? videoEndGuardToken,
  }) {
    _stopNativeFeedFillPoll();
    final int pollToken = ++_nativeFeedFillPollToken;
    unawaited(
      _nativeFeedFillPollTick(
        pollToken: pollToken,
        forceShowLoading: forceShowLoading,
        videoEndGuardToken: videoEndGuardToken,
      ),
    );
    _nativeFeedFillPollTimer = Timer.periodic(
      _nativeFeedFillPollInterval,
      (_) => unawaited(
        _nativeFeedFillPollTick(
          pollToken: pollToken,
          forceShowLoading: forceShowLoading,
          videoEndGuardToken: videoEndGuardToken,
        ),
      ),
    );
  }

  Future<void> _nativeFeedFillPollTick({
    required int pollToken,
    required bool forceShowLoading,
    int? videoEndGuardToken,
  }) async {
    if (_nativeFeedPlaybackPaused) return;
    if (pollToken != _nativeFeedFillPollToken) return;
    if (videoEndGuardToken != null &&
        videoEndGuardToken != _videoEndReloadToken) {
      return;
    }

    final _NativeHz12Snapshot snap = await _checkHuangZhongsheng12();
    if (_nativeFeedPlaybackPaused || pollToken != _nativeFeedFillPollToken) {
      return;
    }

    if (snap.canLoadNativeFeed) {
      _stopNativeFeedFillPoll();
      if (_isViewCreated) {
        _logNativeFeed('轮询：黄忠胜1 已就绪且 isViewCreated=true，跳过重复 load');
        _startNativeValidAdsPoll();
        return;
      }
      _logNativeFeed('轮询：黄忠胜1 已就绪 → loadNativeWith');
      await loadNativeWith(forceShowLoading: forceShowLoading);
      _startNativeValidAdsPoll();
      return;
    }

    if (snap.shouldPollOnly && !_nativeLoadPipelineRequestedWhileWaiting) {
      _nativeLoadPipelineRequestedWhileWaiting = true;
      _logNativeFeed('轮询：仍无填充 → loadNativeWith 拉取下一条');
      await loadNativeWith(forceShowLoading: forceShowLoading);
      return;
    }

    if (!snap.canLoadNativeFeed &&
        _nativeLoadPipelineRequestedWhileWaiting &&
        !snap.isLoading) {
      _logNativeFeed('轮询：上次 load 未就绪，重置后重试 loadNativeWith');
      _nativeLoadPipelineRequestedWhileWaiting = false;
    }
  }

  /// 视频播完：记收益 → 拆容器 → 黄忠胜1/2 → **始终 loadNativeWith** 换下一条。
  Future<void> _handleNativeAdVideoEndPlayback(ATNativeResponse value) async {
    if (_nativeFeedPlaybackPaused) {
      _logNativeFeed(
        'nativeAdDidEndPlayingVideo 忽略：playbackPaused=true placement=${value.placementID}',
      );
      return;
    }
    final int token = ++_videoEndReloadToken;
    _logNativeFeed(
      'nativeAdDidEndPlayingVideo 视频播完 placement=${value.placementID} '
      '→ 记收益 → tearDown → 黄忠胜1/2 → loadNativeWith',
    );

    final Map<String, dynamic> revenueExtra = _nativeRevenueExtraFrom(value);
    await _recordNativeAdRevenue(
      revenueExtra,
      placementID: value.placementID.toString(),
      reason: 'nativeAdDidEndPlayingVideo',
    );

    if (token != _videoEndReloadToken || _nativeFeedPlaybackPaused) {
      return;
    }

    await _tearDownNativeFeedContainer(
      reason: 'nativeAdDidEndPlayingVideo',
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (token != _videoEndReloadToken || _nativeFeedPlaybackPaused) {
      _logNativeFeed('nativeAdDidEndPlayingVideo 后续已取消（token 或 paused）');
      return;
    }

    final _NativeHz12Snapshot snap = await _checkHuangZhongsheng12();
    if (token != _videoEndReloadToken || _nativeFeedPlaybackPaused) {
      return;
    }

    if (snap.canLoadNativeFeed && !_isViewCreated) {
      _logNativeFeed('视频播完换条：黄忠胜1/2 已就绪 → loadNativeWith');
      await loadNativeWith(forceShowLoading: false);
      _startNativeValidAdsPoll();
      return;
    }

    _logNativeFeed(
      '视频播完换条：黄忠胜1/2 未就绪（ready=${snap.nativeAdReady} isReady=${snap.isReady} '
      'isLoading=${snap.isLoading}）→ loadNativeWith + 3 秒轮询兜底',
    );
    await loadNativeWith(forceShowLoading: false);
    if (token != _videoEndReloadToken || _nativeFeedPlaybackPaused) {
      return;
    }
    if (!_isViewCreated) {
      _startNativeFeedFillPoll(
        forceShowLoading: false,
        videoEndGuardToken: token,
      );
    } else {
      _startNativeValidAdsPoll();
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
    _videoEndReloadToken++;
    _nativeFailReloadToken++;
    _preloadInFlight = false;
    _stopNativeFeedFillPoll();
    _stopNativeValidAdsPoll();
    _setPaused(false);
    _logNativeFeed(
      'startNativeFeedPlayback token=$_nativeFailReloadToken（黄忠胜1/2 门控）',
    );
    _setViewCreated(false, reason: 'startNativeFeedPlayback');
    _setSlotState(HomeNativeSlotState.loading);
    await _ensureNativeFeedFromHz12(forceShowLoading: true);
  }

  Future<void> pauseNativeFeedPlayback() async {
    _stopNativeFeedFillPoll();
    _stopNativeValidAdsPoll();
    _videoEndReloadToken++;
    _nativeFailReloadToken++;
    _preloadInFlight = false;
    _logNativeFeed('pauseNativeFeedPlayback token=$_nativeFailReloadToken');
    _setPaused(true);
    _setViewCreated(false, reason: 'pauseNativeFeedPlayback');
    _setSlotState(HomeNativeSlotState.idle);
    try {
      await _removeNativeAdWithTimeout(reason: 'pauseNativeFeedPlayback');
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

  Future<void> nativeUpDataADFn(
    Map<String, dynamic> extraMap, {
    String? placementID,
  }) async {
    try {
      if (!_userNotifier.isLoggedIn) return;
      await _adStatsNotifier.getFkConfigFn();

      final UpDataADForm upDataADForm = UpDataADForm();
      final dynamic publisherRevenueCny = extraMap['publisher_revenue_cny'];
      final double? amount = double.tryParse(
        publisherRevenueCny?.toString() ?? '0',
      );
      final String reqId = extraMap['req_id']?.toString() ?? '';
      final String adsourceId = extraMap['adsource_id']?.toString() ?? '';
      final String userId = _userNotifier.userModel.id.toString();
      upDataADForm.extra =
          'userid_${userId}_type_2_amount_${publisherRevenueCny ?? 0}_time_0';
      upDataADForm.transId = extraMap['id'];
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
      Utils.logError('上报信息流失败：$e placementID=$placementID');
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
          _stopNativeFeedFillPoll();
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
          _lastNativeShowExtra = Map<String, dynamic>.from(value.extraMap);
          _logNativeFeed(
            'nativeAdDidShowNativeAd 展示成功 placement=${value.placementID} '
            '保持 isViewCreated=true slot=ready（不 notify 槽位，避免二次 renderNativeView）',
          );
          await _recordNativeAdRevenue(
            _nativeRevenueExtraFrom(value),
            placementID: value.placementID.toString(),
            reason: 'nativeAdDidShowNativeAd',
          );
          break;

        case NativeStatus.nativeAdDidEndPlayingVideo:
          unawaited(_handleNativeAdVideoEndPlayback(value));
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
    _stopNativeFeedFillPoll();
    _stopNativeValidAdsPoll();
    _nativeAdSubscription?.cancel();
    super.dispose();
  }
}
