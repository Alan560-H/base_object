import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/app/providers.dart';
import 'package:base_object/data/notifiers/ad_stats_notifier.dart';
import 'package:base_object/data/notifiers/user_notifier.dart';
import 'package:base_object/shared/config/app_ad_config.dart';
import 'package:base_object/data/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/data/models/localModels/UpADModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NativeTool {
  NativeTool({
    required AdStatsNotifier adStatsNotifier,
    required UserNotifier userNotifier,
  }) : _adStatsNotifier = adStatsNotifier,
       _userNotifier = userNotifier;

  final AdStatsNotifier _adStatsNotifier;
  final UserNotifier _userNotifier;

  /// 信息流原生广告是否启用（当前关闭，保留实现供后续开启）
  static const bool _nativeAdEnabled = false;

  static NativeTool get to => globalContainer.read(nativeToolProvider);

  // 加载原生广告（当前不加载信息流）
  loadNativeWith() async {
    if (!_nativeAdEnabled) return;
    Utils.logError("加载原生广告");

    await getNativeValidAds();
    await ATNativeManager.loadNativeAd(
      placementID: AppAdConfig.nativePlacementID,
      extraMap: {
        ATCommon.getAdSizeKey(): ATNativeManager.createNativeSubViewAttribute(
          Get.width - 20.w, // 与 getAdConfig 中的宽度一致
          adHeight, // 与 adHeight 一致
        ),
        ATNativeManager.isAdaptiveHeight(): true,
      },
    );
  }

  Future<bool> nativeAdReady() async {
    try {
      bool isReady = await ATNativeManager.nativeAdReady(
        placementID: AppAdConfig.nativePlacementID,
      );
      Utils.logError('原生广告：原生广告是否就绪：$isReady');
      return isReady;
    } catch (e) {
      Utils.logError('原生广告：原生广告是否就绪：$e');
      return false;
    }
  }

  // 获取当前广告位下所有可用广告的信息,返回true则代表有广告缓存，false，则没有
  Future<bool> getNativeValidAds() async {
    String res = await ATNativeManager.getNativeValidAds(
      placementID: AppAdConfig.nativePlacementID,
    );
    Utils.logError("获取当前广告位下所有可用广告的信息${res.isNotEmpty},广告信息：$res");
    return res.isNotEmpty;
  }

  // 检查加载状态
  Future<bool> checkNativeAdLoadStatus() async {
    try {
      final value = await ATNativeManager.checkNativeAdLoadStatus(
        placementID: AppAdConfig.nativePlacementID,
      );
      Utils.logError("检查加载状态$value");
      final isLoading = value['isLoading'] ?? 0;
      return isLoading;
    } catch (error) {
      Utils.logError('检查原生广告状态失败: $error');
      return false;
    }
  }

  // 统一广告高度，与文档和加载配置保持一致
  double get adHeight => 250.h;

  // 原生广告控件配置
  Map<String, dynamic> getAdConfig() {
    return {
      // 广告父容器（整体尺寸）
      ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 20.w, // 宽度=屏幕宽-20（适配左右边距）
        adHeight,
        // 白色
        backgroundColorStr: '#FFFFFF',
      ),
      // App图标
      ATNativeManager.appIcon(): ATNativeManager.createNativeSubViewAttribute(
        50.sp,
        50.sp,
        x: 10.w,
        y: 40.h,
        // 紫色
        backgroundColorStr: '#736bba',
      ),
      // 广告标题
      ATNativeManager.mainTitle(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 190.w,
        20.h,
        x: 0.w,
        y: 0.h,
        textSize: 8.sp,
        textColorStr: '#f31e17',
      ),
      // 广告描述
      ATNativeManager.desc(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 190.w,
        20.h,
        x: 70.w,
        y: 70.h,
        textSize: 13.sp,
        // 紫色
        textColorStr: '#736bba',
      ),
      // 行动按钮（立即下载）
      ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
        100.w,
        35.h,
        x: Get.width - 110.w,
        y: 40.h,
        textSize: 14.sp,
        textColorStr: '#FFFFFF',
        // 黄色
        backgroundColorStr: '#faa683',
        cornerRadius: 4,
      ),
      // 广告主图
      ATNativeManager.mainImage(): ATNativeManager.createNativeSubViewAttribute(
        Get.width,
        180.h,
        x: 20.w,
        y: 0.h,
        // 红色
        backgroundColorStr: '#b54747',
        cornerRadius: 4,
      ),
      // 广告标签（广告二字）
      ATNativeManager.adLogo(): ATNativeManager.createNativeSubViewAttribute(
        40.w,
        18.h,
        x: 10.w,
        y: 10.h,
        textSize: 12.sp,
        textColorStr: '#FFFFFF',
        // 蓝色
        backgroundColorStr: '#3574f0',
        cornerRadius: 2,
      ),
      // 关闭按钮
      ATNativeManager.dislike(): ATNativeManager.createNativeSubViewAttribute(
        20.sp,
        20.sp,
        x: Get.width - 30.w,
        y: 10.h,
        // 绿色
        backgroundColorStr: '#139343',
      ),
      // 广告合规六要素（Android中国区必需）
      ATNativeManager.elementsView():
          ATNativeManager.createNativeSubViewAttribute(
            Get.width - 20.w,
            25.h,
            x: 10.w,
            y: adHeight - 25.h,
            textSize: 10.sp,
            textColorStr: '#FFFFFF',
            // 黑色区域
            backgroundColorStr: '#1e1f22',
          ),
    };
  }

  bool isViewCreated = false;
  nativeUpDataADFn(dynamic event) async {
    try {
      if (_userNotifier.isLoggedIn) {
        await _adStatsNotifier.getFkConfigFn();

        UpDataADForm upDataADForm = UpDataADForm();

        // 1. 安全获取 publisher_revenue_cny + 处理类型转换（核心改这里）
        // 逐层判空+类型兼容，最终转成 double? 赋值给 amount
        dynamic publisherRevenueCny = event.extraMap?['publisher_revenue_cny'];
        // 先转成 String 再解析 double（兼容 int/String 类型，避免直接赋值类型冲突）
        double? amount = double.tryParse(
          publisherRevenueCny?.toString() ?? "0",
        );
        String reqId = event.extraMap?['req_id'];
        String adsourceId = event.extraMap?['adsource_id'];
        // 2. 拼接 extra 字符串（用原始值的字符串形式，避免类型问题）
        String userId = _userNotifier.userModel.id.toString();
        upDataADForm.extra =
            "userid_${userId}_type_2_amount_${publisherRevenueCny ?? 0}_time_0";
        upDataADForm.transId = event.extraMap?['id'];
        upDataADForm.amount = amount;
        upDataADForm.adsourceId = adsourceId;
        upDataADForm.reqId = reqId;
        upDataADForm.sign = Utils.generateEncryptedString(
          userId: userId,
          reqId: reqId,
          adsourceId: adsourceId,
        );
        Utils.logError("原生广告凑成的字符串${upDataADForm.toJson()}");
        Utils.logError(
          "一：$amount,二：${_adStatsNotifier.fkConfig.wactchMaxAmountV1}，三：原生广告金额$amount，限制金额${_adStatsNotifier.fkConfig.wactchMaxAmountV1}，四：塔酷广告回调信息：${event.extraMap}",
        );
        if (amount == null) return;
        double amount1 = amount * 10000;
        UpADModel upADModel = UpADModel(
          adsourceId: adsourceId,
          reqId: reqId,
          adType: "原生（信息流)广告",
          adAmount: amount1,
        );

        /// 如果广告金额大于风控设置的最高金额
        if (amount1 > _adStatsNotifier.fkConfig.wactchMaxAmountV1) {
          _adStatsNotifier.addWatchMaxAdList(upADModel);
        }

        /// 如果广告金额小于风控设置得最低金额
        if (amount1 < _adStatsNotifier.fkConfig.wactchMinAmountV1) {
          _adStatsNotifier.addWatchMinAdList(upADModel);
        }
      }
    } catch (e) {
      Utils.logError("上报副广失败：$e");
    }
  }

  /// 原生广告监听（当前不加载信息流，不注册监听）
  nativeLisListen() async {
    if (!_nativeAdEnabled) return;
    Utils.logError("原生广告是不是监听哦：$_nativeAdSubscription");
    if (_nativeAdSubscription != null) {
      return;
    }
    _nativeAdSubscription = ATListenerManager.nativeEventHandler.listen((
      value,
    ) async {
      switch (value.nativeStatus) {
        case NativeStatus.nativeAdDidFinishLoading:
          isViewCreated = true;
          Utils.logError("信息流广告加载完成: ${value.placementID}");
          break;

        case NativeStatus.nativeAdDidShowNativeAd:
          isViewCreated = await getNativeValidAds();
          Utils.logError(
            "信息流广告展示成功: ${value.placementID},是否有缓存${isViewCreated}",
          );
          nativeUpDataADFn(value);
          loadNativeWith();
          break;

        case NativeStatus.nativeAdDidTapCloseButton:
          Utils.logError("信息流广告被关闭: ${value.placementID}");
          break;

        case NativeStatus.nativeAdFailToLoadAD:
          isViewCreated = await getNativeValidAds();
          Utils.logError("信息流广告加载失败: ${value.requestMessage}");

          await Future.delayed(const Duration(seconds: 2));
          loadNativeWith();
          break;

        // ... 其他事件可根据需要处理
        default:
          Utils.logError(
            "信息流广告事件: ${value.nativeStatus}, 参数: ${value.extraMap}",
          );
          break;
      }
    });
  }

  removeNativeAd() async {
    await ATNativeManager.removeNativeAd(
      placementID: AppAdConfig.nativePlacementID,
    );
  }

  showNative() async {
    return await ATNativeManager.showNativeAd(
      placementID: AppAdConfig.nativePlacementID,
      extraMap: {
        ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
          Get.width,
          120,
          x: 0,
          y: 30,
          backgroundColorStr: '#FFFFFF',
        ),
        ATNativeManager.appIcon(): ATNativeManager.createNativeSubViewAttribute(
          50,
          50,
          x: 10,
          y: 40,
          backgroundColorStr: 'clearColor',
        ),
        ATNativeManager.mainTitle():
            ATNativeManager.createNativeSubViewAttribute(
              Get.width - 190,
              20,
              x: 70,
              y: 40,
              textSize: 15,
            ),
        ATNativeManager.desc(): ATNativeManager.createNativeSubViewAttribute(
          Get.width - 190,
          20,
          x: 70,
          y: 70,
          textSize: 15,
        ),
        ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
          100,
          50,
          x: Get.width - 110,
          y: 40,
          textSize: 15,
          textColorStr: "#FFFFFF",
          backgroundColorStr: "#2095F1",
        ),
        ATNativeManager.mainImage():
            ATNativeManager.createNativeSubViewAttribute(
              Get.width - 20,
              70,
              x: 10,
              y: 100,
              backgroundColorStr: '#00000000',
            ),
        ATNativeManager.adLogo(): ATNativeManager.createNativeSubViewAttribute(
          20,
          10,
          x: 10,
          y: 10,
          backgroundColorStr: '#00000000',
        ),
        ATNativeManager.dislike(): ATNativeManager.createNativeSubViewAttribute(
          20,
          20,
          x: Get.width - 30,
          y: 10,
        ),
      },
      isAdaptiveHeight: true,
    );
  }

  StreamSubscription<ATNativeResponse>? _nativeAdSubscription;
}
