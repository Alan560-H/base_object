import 'dart:async';
import 'dart:convert';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/app/providers.dart';
import 'package:base_object/data/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:base_object/data/models/localModels/UpADModel.dart';
import 'package:base_object/data/notifiers/ad_stats_notifier.dart';
import 'package:base_object/data/notifiers/user_notifier.dart';
import 'package:base_object/shared/config/app_ad_config.dart';
import 'package:base_object/shared/config/screen_layout.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiffy/jiffy.dart';

/// 首页信息流槽位 UI 状态
enum NativeSlotState { idle, loading, ready, failed }

/// load 用途：首载 / 换条预加载 / 首载失败重试
enum _NativeLoadPurpose { initial, refreshPreload, retry }

class NativeTool extends ChangeNotifier {
  NativeTool({
    required AdStatsNotifier adStatsNotifier,
    required UserNotifier userNotifier,
  }) : _adStatsNotifier = adStatsNotifier,
       _userNotifier = userNotifier;

  static const int _maxFailRetries = 3;
  static const Duration _refreshPollInterval = Duration(seconds: 3);

  final AdStatsNotifier _adStatsNotifier;
  final UserNotifier _userNotifier;

  static NativeTool get to => globalContainer.read(nativeToolProvider);

  NativeSlotState _nativeSlotState = NativeSlotState.idle;
  NativeSlotState get nativeSlotState => _nativeSlotState;

  bool _nativePlaybackPaused = true;
  bool get nativePlaybackPaused => _nativePlaybackPaused;

  int _slotGeneration = 0;
  int get slotGeneration => _slotGeneration;

  double _contentLogicalWidth = defaultLogicalWidth();
  double get contentLogicalWidth => _contentLogicalWidth;

  int _failRetryCount = 0;
  final Set<String> _recordedReqIds = <String>{};

  int _impressionRecordedGeneration = -1;

  _NativeLoadPurpose _loadPurpose = _NativeLoadPurpose.initial;
  bool _refreshPreloadInFlight = false;
  bool _swapInProgress = false;
  String? _currentDisplayedReqId;

  Timer? _refreshPollTimer;

  StreamSubscription<ATNativeResponse>? _nativeAdSubscription;

  double get adHeight => 250.h;

  void _setNativeSlotState(NativeSlotState value) {
    _nativeSlotState = value;
    notifyListeners();
  }

  static double contentWidthFromScreen(double screenWidth) => screenWidth - 32.w;

  static bool _isMapFlag(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return false;
  }

  Map<String, dynamic> getAdConfig(double logicalWidth) {
    return {
      ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
        logicalWidth,
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
        logicalWidth - 170.w,
        20.h,
        x: 70.w,
        y: 40.h,
        textSize: 15.sp,
        textColorStr: '#f31e17',
      ),
      ATNativeManager.desc(): ATNativeManager.createNativeSubViewAttribute(
        logicalWidth - 170.w,
        20.h,
        x: 70.w,
        y: 70.h,
        textSize: 13.sp,
        textColorStr: '#736bba',
      ),
      ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
        100.w,
        35.h,
        x: logicalWidth - 110.w,
        y: 40.h,
        textSize: 14.sp,
        textColorStr: '#FFFFFF',
        backgroundColorStr: '#faa683',
        cornerRadius: 4,
      ),
      ATNativeManager.mainImage(): ATNativeManager.createNativeSubViewAttribute(
        logicalWidth - 20.w,
        180.h,
        x: 10.w,
        y: 90.h,
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
        x: logicalWidth - 30.w,
        y: 10.h,
        backgroundColorStr: '#139343',
      ),
      ATNativeManager.elementsView():
          ATNativeManager.createNativeSubViewAttribute(
            logicalWidth,
            25.h,
            x: 0,
            y: adHeight - 25.h,
            textSize: 10.sp,
            textColorStr: '#FFFFFF',
            backgroundColorStr: '#1e1f22',
          ),
    };
  }

  Future<void> startNativePlayback(double logicalWidth) async {
    _contentLogicalWidth = logicalWidth;
    _nativePlaybackPaused = false;
    _failRetryCount = 0;
    _impressionRecordedGeneration = -1;
    _refreshPreloadInFlight = false;
    _swapInProgress = false;

    if (await nativeAdReady()) {
      _slotGeneration++;
      _setNativeSlotState(NativeSlotState.ready);
      _startRefreshPoll();
      unawaited(_captureCurrentReqIdFromCache());
      return;
    }

    _loadPurpose = _NativeLoadPurpose.initial;
    _setNativeSlotState(NativeSlotState.loading);
    await loadNativeWith(logicalWidth);
    _startRefreshPoll();
  }

  Future<void> pauseNativePlayback() async {
    _nativePlaybackPaused = true;
    _failRetryCount = 0;
    _impressionRecordedGeneration = -1;
    _refreshPreloadInFlight = false;
    _swapInProgress = false;
    _currentDisplayedReqId = null;
    _stopRefreshPoll();
    await removeNativeAd();
    _setNativeSlotState(NativeSlotState.idle);
  }

  void _startRefreshPoll() {
    _stopRefreshPoll();
    _refreshPollTimer = Timer.periodic(_refreshPollInterval, (_) {
      unawaited(_evaluateAutoRefresh());
    });
  }

  void _stopRefreshPoll() {
    _refreshPollTimer?.cancel();
    _refreshPollTimer = null;
  }

  Future<void> loadNativeWith(double logicalWidth) async {
    if (_nativePlaybackPaused) return;
    Utils.logError('加载原生信息流 purpose=$_loadPurpose');

    // Android 插件 loadNativeAd 未回传 result，不可 await 否则会卡住后续轮询
    try {
      await ATNativeManager.loadNativeAd(
        placementID: AppAdConfig.nativePlacementID,
        extraMap: {
          ATCommon.getAdSizeKey(): ATNativeManager.createNativeSubViewAttribute(
            logicalWidth,
            adHeight,
          ),
          ATNativeManager.isAdaptiveHeight(): true,
        },
      ).timeout(const Duration(milliseconds: 300));
    } on TimeoutException {
      // 忽略：加载结果由 nativeListen 回调处理
    } catch (e) {
      Utils.logError('loadNativeAd: $e');
    }
  }

  Future<bool> nativeAdReady() async {
    try {
      return await ATNativeManager.nativeAdReady(
        placementID: AppAdConfig.nativePlacementID,
      );
    } catch (e) {
      Utils.logError('原生广告是否就绪: $e');
      return false;
    }
  }

  Future<bool> _isNativeReadyForShow() async {
    try {
      final Map<dynamic, dynamic> status =
          await ATNativeManager.checkNativeAdLoadStatus(
            placementID: AppAdConfig.nativePlacementID,
          );
      return _isMapFlag(status['isReady']) && !_isMapFlag(status['isLoading']);
    } catch (e) {
      Utils.logError('检查信息流状态失败: $e');
      return await nativeAdReady();
    }
  }

  static String _extractReqId(Map<dynamic, dynamic> map) {
    final dynamic value = map['req_id'] ?? map['reqId'];
    return value?.toString() ?? '';
  }

  static bool _isFrequencyFilteredError(String requestMessage) {
    return requestMessage.contains('4005') ||
        requestMessage.toLowerCase().contains('filtered');
  }

  /// 从 [checkNativeAdLoadStatus] 的 adInfo（JSON 字符串或 Map）解析 req_id
  static String? _parseReqIdFromAdInfo(dynamic adInfo) {
    if (adInfo == null) return null;
    try {
      if (adInfo is Map) {
        final String id = _extractReqId(adInfo);
        return id.isEmpty ? null : id;
      }
      if (adInfo is String && adInfo.isNotEmpty) {
        final dynamic decoded = jsonDecode(adInfo);
        if (decoded is Map) {
          final String id = _extractReqId(decoded);
          return id.isEmpty ? null : id;
        }
      }
    } catch (e) {
      Utils.logError('解析 topAdInfo 失败: $e');
    }
    return null;
  }

  Future<void> _captureCurrentReqIdFromCache() async {
    if (_currentDisplayedReqId != null && _currentDisplayedReqId!.isNotEmpty) {
      return;
    }
    try {
      final Map<dynamic, dynamic> status =
          await ATNativeManager.checkNativeAdLoadStatus(
            placementID: AppAdConfig.nativePlacementID,
          );
      final String? topReqId = _parseReqIdFromAdInfo(status['adInfo']);
      if (topReqId == null) return;
      _currentDisplayedReqId = topReqId;
      Utils.logError('信息流当前条 req_id=$_currentDisplayedReqId');
    } catch (e) {
      Utils.logError('读取信息流 topAdInfo 失败: $e');
    }
  }

  /// 轮询 + 预加载完成时调用：以 SDK topAdInfo 为准换条（尊重 Taku 后台展示间隔/频次）
  Future<void> _evaluateAutoRefresh() async {
    if (_nativePlaybackPaused || _swapInProgress) return;
    if (_nativeSlotState != NativeSlotState.ready) return;

    try {
      final Map<dynamic, dynamic> status =
          await ATNativeManager.checkNativeAdLoadStatus(
            placementID: AppAdConfig.nativePlacementID,
          );
      if (_isMapFlag(status['isLoading'])) return;

      await _captureCurrentReqIdFromCache();

      final String? topReqId = _parseReqIdFromAdInfo(status['adInfo']);
      final bool ready = _isMapFlag(status['isReady']);
      final String? current = _currentDisplayedReqId;

      if (ready &&
          topReqId != null &&
          current != null &&
          current.isNotEmpty &&
          topReqId != current &&
          _impressionRecordedGeneration == _slotGeneration) {
        Utils.logError(
          '信息流 SDK 可换下一条 top=$topReqId current=$current',
        );
        await _trySwapToNextAd(nextReqId: topReqId);
        return;
      }

      if (_impressionRecordedGeneration == _slotGeneration &&
          !_refreshPreloadInFlight) {
        unawaited(_startRefreshPreload());
      }
    } catch (e, st) {
      Utils.logError('信息流换条检测失败: $e', error: e, stackTrace: st);
    }
  }

  Future<void> _trySwapToNextAd({required String nextReqId}) async {
    if (_nativePlaybackPaused || _swapInProgress) return;
    if (_nativeSlotState != NativeSlotState.ready) return;
    if (_impressionRecordedGeneration != _slotGeneration) return;
    if (!await _isNativeReadyForShow()) return;

    final Map<dynamic, dynamic> status =
        await ATNativeManager.checkNativeAdLoadStatus(
          placementID: AppAdConfig.nativePlacementID,
        );
    final String? topReqId = _parseReqIdFromAdInfo(status['adInfo']);
    if (topReqId == null || topReqId != nextReqId) return;

    _swapInProgress = true;
    try {
      await removeNativeAd();
      _slotGeneration++;
      _impressionRecordedGeneration = -1;
      _currentDisplayedReqId = nextReqId;
      _nativeSlotState = NativeSlotState.ready;
      notifyListeners();
      Utils.logError('信息流已换条 slotGen=$_slotGeneration req_id=$nextReqId');
    } catch (e, st) {
      Utils.logError('信息流换条失败: $e', error: e, stackTrace: st);
    } finally {
      _swapInProgress = false;
    }
  }

  Future<void> _startRefreshPreload() async {
    if (_nativePlaybackPaused || _refreshPreloadInFlight) return;
    _refreshPreloadInFlight = true;
    _loadPurpose = _NativeLoadPurpose.refreshPreload;
    await loadNativeWith(_contentLogicalWidth);
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
    if (_nativeAdSubscription != null) return;
    _nativeAdSubscription = ATListenerManager.nativeEventHandler.listen((
      value,
    ) async {
      switch (value.nativeStatus) {
        case NativeStatus.nativeAdDidFinishLoading:
          Utils.logError(
            '信息流加载完成 purpose=$_loadPurpose placement=${value.placementID}',
          );
          if (_nativePlaybackPaused) return;
          switch (_loadPurpose) {
            case _NativeLoadPurpose.initial:
            case _NativeLoadPurpose.retry:
              if (_nativeSlotState != NativeSlotState.loading) return;
              _slotGeneration++;
              _failRetryCount = 0;
              _setNativeSlotState(NativeSlotState.ready);
              unawaited(_captureCurrentReqIdFromCache());
            case _NativeLoadPurpose.refreshPreload:
              _refreshPreloadInFlight = false;
              await _evaluateAutoRefresh();
          }
          break;

        case NativeStatus.nativeAdDidShowNativeAd:
        case NativeStatus.nativeAdDidLoadSuccessDraw:
          Utils.logError('信息流展示: ${value.placementID}');
          await _onNativeImpression(value);
          break;

        case NativeStatus.nativeAdDidTapCloseButton:
          Utils.logError('信息流被关闭: ${value.placementID}');
          await pauseNativePlayback();
          break;

        case NativeStatus.nativeAdFailToLoadAD:
          Utils.logError(
            '信息流加载失败 purpose=$_loadPurpose ${value.requestMessage}',
          );
          if (_nativePlaybackPaused) return;
          if (_loadPurpose == _NativeLoadPurpose.refreshPreload) {
            _refreshPreloadInFlight = false;
            if (_isFrequencyFilteredError(value.requestMessage)) {
              Utils.logError('信息流预加载频次限制(4005)，等待轮询再试');
            } else {
              Utils.logError('信息流预加载失败，等待轮询再试');
            }
            return;
          }
          _setNativeSlotState(NativeSlotState.failed);
          if (_failRetryCount >= _maxFailRetries) return;
          _failRetryCount++;
          await Future.delayed(const Duration(seconds: 2));
          if (_nativePlaybackPaused) return;
          _loadPurpose = _NativeLoadPurpose.retry;
          _setNativeSlotState(NativeSlotState.loading);
          await loadNativeWith(_contentLogicalWidth);
          break;

        default:
          Utils.logError(
            '信息流事件: ${value.nativeStatus}, 参数: ${value.extraMap}',
          );
          break;
      }
    });
  }

  Future<void> _onNativeImpression(ATNativeResponse value) async {
    if (_impressionRecordedGeneration == _slotGeneration) return;

    final String reqId = value.extraMap['req_id']?.toString() ?? '';
    if (reqId.isNotEmpty && _recordedReqIds.contains(reqId)) return;
    if (reqId.isNotEmpty) _recordedReqIds.add(reqId);

    _impressionRecordedGeneration = _slotGeneration;

    if (reqId.isNotEmpty) {
      _currentDisplayedReqId = reqId;
    }

    await _adStatsNotifier.addAdInfos(
      AdInfo.fromTakuExtra(
        extraMap: value.extraMap,
        placementID: value.placementID.toString(),
        createdTime: Jiffy.now().format(pattern: 'yyyy-MM-dd HH:mm:ss'),
        adType: AdInfo.typeNative,
      ),
    );
    await nativeUpDataADFn(value);
  }

  Future<void> removeNativeAd() async {
    // anythink_sdk Android 端 removeNativeAd 未调用 result.success，await 会永久挂起
    try {
      await ATNativeManager.removeNativeAd(
        placementID: AppAdConfig.nativePlacementID,
      ).timeout(const Duration(milliseconds: 300));
    } on TimeoutException {
      // 忽略：原生侧通常已执行 removeView
    } catch (e) {
      Utils.logError('removeNativeAd: $e');
    }
  }
}
