import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/models/localModels/AdInfo.dart';
import 'package:base_object/models/localModels/UpADModel.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

/// 首页信息流槽位状态（与 [HomeBannerSlotState] 用法类似）
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

class NativeTool extends GetxService {
  static NativeTool get to =>
      Get.isRegistered<NativeTool>()
          ? Get.find<NativeTool>()
          : Get.put(NativeTool());

  /// 单次展示成功后，延迟自动先停再开（与 [nativeAdDidShowNativeAd] 联动）
  static const Duration _nativeFeedPostShowReloadDelay = Duration(seconds: 16);

  /// 未点「开始信息流」前为 true；开始后为 false，直至停止
  final RxBool nativeFeedPlaybackPaused = true.obs;

  final Rx<HomeNativeSlotState> nativeSlotState = HomeNativeSlotState.idle.obs;

  /// 展示成功后自动刷新前的剩余秒数；`null` 表示未在倒计时（未展示或未排期）。
  final Rx<int?> nativeFeedAutoReloadCountdown = Rx<int?>(null);

  int _nativeFailReloadToken = 0;

  bool _preloadInFlight = false;

  Timer? _nativeFeedPostShowReloadTimer;

  void _cancelNativeFeedPostShowReloadTimer() {
    _nativeFeedPostShowReloadTimer?.cancel();
    _nativeFeedPostShowReloadTimer = null;
    nativeFeedAutoReloadCountdown.value = null;
  }

  void _onNativeFeedPostShowReloadPeriodicTick(Timer t) {
    final int? cur = nativeFeedAutoReloadCountdown.value;
    if (cur == null) {
      t.cancel();
      _nativeFeedPostShowReloadTimer = null;
      return;
    }
    if (cur <= 1) {
      _nativeFeedPostShowReloadTimer?.cancel();
      _nativeFeedPostShowReloadTimer = null;
      nativeFeedAutoReloadCountdown.value = null;
      if (!nativeFeedPlaybackPaused.value) {
        unawaited(_nativeFeedPostShowReloadTick());
      }
      return;
    }
    nativeFeedAutoReloadCountdown.value = cur - 1;
  }

  /// 每次新的「展示成功」都会重排：旧计时作废，从本次展示起再倒计时 [_nativeFeedPostShowReloadDelay]。
  void _scheduleNativeFeedPostShowReload() {
    _cancelNativeFeedPostShowReloadTimer();
    final int total = _nativeFeedPostShowReloadDelay.inSeconds;
    nativeFeedAutoReloadCountdown.value = total;
    _logNativeFeed(
      '已启动 ${total}s 自动刷新倒计时（每秒更新），到时 remove→startNativeFeedPlayback 全自动',
    );
    _nativeFeedPostShowReloadTimer = Timer.periodic(
      const Duration(seconds: 1),
      _onNativeFeedPostShowReloadPeriodicTick,
    );
  }

  Future<void> _nativeFeedPostShowReloadTick() async {
    Utils.logError("倒计时结束");
    if (nativeFeedPlaybackPaused.value) {
      _logNativeFeed('postShowReload：已跳过（playbackPaused=true）');
      return;
    }
    _logNativeFeed(
      'postShowReload：${_nativeFeedPostShowReloadDelay.inSeconds}s 到，'
      'remove → 短延迟 → startNativeFeedPlayback（与手动「开始」相同：始终 load+展示）',
    );
    // 禁止 pauseNativeFeedPlayback：会把 paused 置 true，槽位/按钮误停。
    _preloadInFlight = false;
    nativeFeedPlatformGeneration.value++;
    isViewCreated.value = false;
    nativeSlotState.value = HomeNativeSlotState.loading;
    try {
      removeNativeAd();
      _logNativeFeed('postShowReload removeNativeAd 完成');
    } catch (e, st) {
      _logNativeFeed('postShowReload removeNativeAd 异常: $e $st');
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
    Utils.logError("要触发方法了");
    // 等当前帧布局完成（PlatformView 已从树移除）再发起 load，避免与原生 remove 竞态导致无回调/崩溃。
    await startNativeFeedPlayback();
  }

  @override
  void onClose() {
    _cancelNativeFeedPostShowReloadTimer();
    super.onClose();
  }

  Map<String, dynamic> _nativeLoadExtraMap() {
    return {
      ATCommon.isNativeShow(): false,
      ATCommon.getAdSizeKey(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 20.w,
        adHeight,
      ),
      ATNativeManager.isAdaptiveHeight(): true,
    };
  }

  /// 仅发起原生 load + entry（不检查 paused）。供 [loadNativeWith] 与 [preloadNativeFeedOnce] 共用。
  Future<void> _invokeNativeLoadPipeline() async {
    await ATNativeManager.loadNativeAd(
      placementID: AppAdConfig.nativePlacementID,
      extraMap: _nativeLoadExtraMap(),
    );
    _logNativeFeed('loadNativeAd 调用已返回（等待原生回调）');
    await ATNativeManager.entryNativeScenario(
      placementID: AppAdConfig.nativePlacementID,
      sceneID: AppAdConfig.nativeSceneID,
    );
    _logNativeFeed('entryNativeScenario 已调用（位于 load 之后）');
  }

  /// 进首页后后台拉一次广告（暂停态不占信息流 UI）。
  /// 用户点「开始信息流」仍会走 [startNativeFeedPlayback] 再 load 一次，与「无 hasCache、全自动刷新」策略一致。
  Future<void> preloadNativeFeedOnce() async {
    if (_preloadInFlight) {
      _logNativeFeed('preloadNativeFeedOnce 跳过：已在执行');
      return;
    }
    try {
      if (await nativeAdReady()) {
        _logNativeFeed('preloadNativeFeedOnce 跳过：nativeAdReady 已为 true');
        if (!isViewCreated.value) {
          isViewCreated.value = true;
        }
        nativeSlotState.value = HomeNativeSlotState.ready;
        return;
      }
    } catch (e, st) {
      _logNativeFeed('preloadNativeFeedOnce nativeAdReady 检查异常: $e $st');
    }
    _preloadInFlight = true;
    _logNativeFeed(
      'preloadNativeFeedOnce 开始（paused=${nativeFeedPlaybackPaused.value}）',
    );
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await _invokeNativeLoadPipeline();
    } catch (e, st) {
      _logNativeFeed('preloadNativeFeedOnce 异常: $e\n$st');
      if (nativeFeedPlaybackPaused.value) {
        nativeSlotState.value = HomeNativeSlotState.idle;
      }
    } finally {
      _preloadInFlight = false;
    }
  }

  /// 发起加载；[forceShowLoading] 为 true 时（用户点击开始）始终显示加载态；预加载且已有展示时不切回 loading，避免闪屏。
  Future<void> loadNativeWith({bool forceShowLoading = false}) async {
    if (nativeFeedPlaybackPaused.value) {
      _logNativeFeed(
        'loadNativeWith 跳过：playbackPaused=true placement=${AppAdConfig.nativePlacementID}',
      );
      return;
    }
    if (forceShowLoading || !isViewCreated.value) {
      nativeSlotState.value = HomeNativeSlotState.loading;
    }
    _logNativeFeed(
      'loadNativeWith 开始 forceShowLoading=$forceShowLoading '
      'isViewCreated=${isViewCreated.value} slot=${nativeSlotState.value} '
      'placement=${AppAdConfig.nativePlacementID} scene=${AppAdConfig.nativeSceneID} '
      'size=(${Get.width - 20.w} x $adHeight)',
    );
    try {
      // 须先 load 再 entry：否则原生侧 placement 未创建会报
      // "The xxx object has not been created yet!"（与 Taku 文档 1.1→1.3 顺序一致）
      await _invokeNativeLoadPipeline();
    } catch (e, st) {
      _logNativeFeed('loadNativeWith 异常: $e\n$st');
      if (!nativeFeedPlaybackPaused.value && !isViewCreated.value) {
        nativeSlotState.value = HomeNativeSlotState.failed;
      }
    }
  }

  /// 开始播放信息流：与首页「开始信息流」按钮一致。
  /// **始终** `loadNativeWith`（不再根据 `nativeAdReady` / 槽位走 hasCache 短路）。
  /// 展示成功后倒计时结束会先 [removeNativeAd] 再调本方法，实现自动换下一条。
  Future<void> startNativeFeedPlayback() async {
    _cancelNativeFeedPostShowReloadTimer();
    _nativeFailReloadToken++;
    nativeFeedPlaybackPaused.value = false;
    _logNativeFeed(
      'startNativeFeedPlayback token=$_nativeFailReloadToken（始终 load）',
    );
    isViewCreated.value = false;
    nativeSlotState.value = HomeNativeSlotState.loading;
    await loadNativeWith(forceShowLoading: true);
  }

  Future<void> pauseNativeFeedPlayback() async {
    _cancelNativeFeedPostShowReloadTimer();
    _nativeFailReloadToken++;
    _preloadInFlight = false;
    _logNativeFeed('pauseNativeFeedPlayback token=$_nativeFailReloadToken');
    nativeFeedPlaybackPaused.value = true;
    isViewCreated.value = false;
    nativeSlotState.value = HomeNativeSlotState.idle;
    try {
      await removeNativeAd();
      _logNativeFeed('pauseNativeFeedPlayback removeNativeAd 完成');
    } catch (e, st) {
      _logNativeFeed('pauseNativeFeedPlayback removeNativeAd 异常: $e $st');
    }
  }

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

  final double adHeight = 250.h;

  Map<String, dynamic> getAdConfig() {
    return {
      ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 20.w,
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
        Get.width - 190.w,
        20.h,
        x: 0.w,
        y: 0.h,
        textSize: 8.sp,
        textColorStr: '#f31e17',
      ),
      ATNativeManager.desc(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 190.w,
        20.h,
        x: 70.w,
        y: 70.h,
        textSize: 13.sp,
        textColorStr: '#736bba',
      ),
      ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
        100.w,
        35.h,
        x: Get.width - 110.w,
        y: 40.h,
        textSize: 14.sp,
        textColorStr: '#FFFFFF',
        backgroundColorStr: '#faa683',
        cornerRadius: 4,
      ),
      ATNativeManager.mainImage(): ATNativeManager.createNativeSubViewAttribute(
        Get.width,
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
        x: Get.width - 30.w,
        y: 10.h,
        backgroundColorStr: '#139343',
      ),
      ATNativeManager.elementsView():
          ATNativeManager.createNativeSubViewAttribute(
            Get.width - 20.w,
            25.h,
            x: 10.w,
            y: adHeight - 25.h,
            textSize: 10.sp,
            textColorStr: '#FFFFFF',
            backgroundColorStr: '#1e1f22',
          ),
    };
  }

  final RxBool isViewCreated = false.obs;

  /// 每次 remove 后重新挂载 [PlatformNativeWidget] 时递增，用于 [ValueKey] 强制新建 PlatformView。
  final RxInt nativeFeedPlatformGeneration = 0.obs;

  nativeUpDataADFn(dynamic event) async {
    try {
      final UserInfo userInfo = UserInfo.instance;
      if (userInfo.isLoginIn) {
        await Store.instance.checkFkConfig();

        final UpDataADForm upDataADForm = UpDataADForm();

        dynamic publisherRevenueCny = event.extraMap?['publisher_revenue_cny'];
        final double? amount = double.tryParse(
          publisherRevenueCny?.toString() ?? '0',
        );
        final String reqId = event.extraMap?['req_id']?.toString() ?? '';
        final String adsourceId =
            event.extraMap?['adsource_id']?.toString() ?? '';
        final String userId = UserInfo.instance.userModel.id.toString();
        upDataADForm.extra =
            'userid_${userId}_type_2_amount_${publisherRevenueCny ?? 0}_time_0';
        upDataADForm.transId = event.extraMap?['id']?.toString();
        upDataADForm.amount = amount;
        upDataADForm.adsourceId = adsourceId;
        upDataADForm.reqId = reqId;
        upDataADForm.sign = Utils.generateEncryptedString(
          userId: userId,
          reqId: reqId,
          adsourceId: adsourceId,
        );
        Utils.logError('原生广告凑成的字符串${upDataADForm.toJson()}');
        Utils.logError(
          '一：$amount,二：${Store.instance.getFkConfig.wactchMaxAmountV1}，三：原生广告金额$amount，限制金额${Store.instance.getFkConfig.wactchMaxAmountV1}，四：塔酷广告回调信息：${event.extraMap}',
        );
        if (!UserInfo.instance.isLoginIn) return;
        if (amount == null) return;
        final double amount1 = amount * 10000;
        final UpADModel upADModel = UpADModel(
          adsourceId: adsourceId,
          reqId: reqId,
          adType: '原生（信息流)广告',
          adAmount: amount1,
        );

        if (amount1 > Store.instance.getFkConfig.wactchMaxAmountV1) {
          Store.instance.addWactchMaxADList(upADModel);
        }

        if (amount1 < Store.instance.getFkConfig.wactchMinAmountV1) {
          Store.instance.addWactchMinADList(upADModel);
        }
      }
    } catch (e) {
      Utils.logError('上报副广失败：$e');
    }
  }

  nativeLisListen() async {
    _logNativeFeed(
      'nativeLisListen 调用 subscription=${_nativeAdSubscription != null ? "已存在跳过" : "将注册"}',
    );
    if (_nativeAdSubscription != null) {
      return;
    }
    _nativeAdSubscription = ATListenerManager.nativeEventHandler.listen((
      value,
    ) async {
      _logNativeFeed(
        '<<< 回调 status=${value.nativeStatus} placementID=${value.placementID} '
        'requestMessage=${value.requestMessage} '
        'paused=${nativeFeedPlaybackPaused.value} '
        'isViewCreated=${isViewCreated.value} slot=${nativeSlotState.value} '
        'extra=${_nativeFeedExtraPreview(value.extraMap)}',
      );
      switch (value.nativeStatus) {
        case NativeStatus.nativeAdDidFinishLoading:
          isViewCreated.value = true;
          nativeSlotState.value = HomeNativeSlotState.ready;
          if (nativeFeedPlaybackPaused.value) {
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
          if (nativeFeedPlaybackPaused.value) {
            _logNativeFeed(
              'nativeAdDidShowNativeAd 忽略：playbackPaused=true placement=${value.placementID}',
            );
            return;
          }
          // 不要用 getNativeValidAds() 在这里覆盖 isViewCreated：展示后 SDK 侧可能短暂返回空，
          // 会拆掉 PlatformNativeWidget 并配合下方 load 形成「一闪 → 加载中 → 再 load」死循环。
          isViewCreated.value = true;
          nativeSlotState.value = HomeNativeSlotState.ready;
          _logNativeFeed(
            'nativeAdDidShowNativeAd 展示成功 placement=${value.placementID} '
            '保持 isViewCreated=true slot=ready（不在此处链式 loadNativeWith，避免打断当前 PlatformView）',
          );
          Store.instance.addAdInfos(
            AdInfo.fromTakuExtra(
              extraMap: value.extraMap,
              placementID: value.placementID.toString(),
              createdTime: Jiffy.now().format(pattern: 'yyyy-MM-dd HH:mm:ss'),
              adType: AdInfo.typeNativeFeed,
            ),
          );
          _logNativeFeed('nativeAdDidShowNativeAd 已写入 Store 一条 AdInfo');
          nativeUpDataADFn(value);
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
          isViewCreated.value = await getNativeValidAds();
          if (!isViewCreated.value) {
            if (nativeFeedPlaybackPaused.value) {
              nativeSlotState.value = HomeNativeSlotState.idle;
              _logNativeFeed(
                'nativeAdFailToLoadAD 预加载失败（暂停态）placement=${value.placementID} '
                'msg=${value.requestMessage}',
              );
            } else {
              nativeSlotState.value = HomeNativeSlotState.failed;
            }
          }
          _logNativeFeed(
            'nativeAdFailToLoadAD placement=${value.placementID} '
            'msg=${value.requestMessage} isViewCreated=$isViewCreated.value '
            'slot=${nativeSlotState.value}',
          );
          final int token = _nativeFailReloadToken;
          await Future<void>.delayed(const Duration(seconds: 2));
          if (token != _nativeFailReloadToken) {
            _logNativeFeed(
              'nativeAdFailToLoadAD 取消重试：token 已变 ($token != $_nativeFailReloadToken)',
            );
            return;
          }
          if (nativeFeedPlaybackPaused.value) {
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
      'nativeLisListen 已订阅 nativeEventHandler placement=${AppAdConfig.nativePlacementID}',
    );
  }

  Future<void> removeNativeAd() async {
    _logNativeFeed('removeNativeAd placement=${AppAdConfig.nativePlacementID}');
    await ATNativeManager.removeNativeAd(
      placementID: AppAdConfig.nativePlacementID,
    );
  }

  StreamSubscription<ATNativeResponse>? _nativeAdSubscription;
}
