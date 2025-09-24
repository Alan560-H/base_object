import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NativeTool extends GetxService {
  // GetX单例获取方式
  static NativeTool get to =>
      Get.isRegistered<NativeTool>()
          ? Get.find<NativeTool>()
          : Get.put(NativeTool());

  // 加载原生广告
  loadNativeWith() async {
    Utils.logError("加载原生广告");
    await ATNativeManager.loadNativeAd(
      placementID: AppAdConfig.nativePlacementID,
      extraMap: {
        ATCommon.getAdSizeKey(): ATNativeManager.createNativeSubViewAttribute(
          Get.width - 20.w, // 与 _getAdConfig 中的宽度一致
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

  // 获取当前广告位下所有可用广告的信息
  Future<String> getNativeValidAds() async {
    String res = await ATNativeManager.getNativeValidAds(
      placementID: AppAdConfig.nativePlacementID,
    );
    Utils.logError("获取当前广告位下所有可用广告的信息$res");
    return res;
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
  final double adHeight = 320.h;
  Widget? _cachedAdWidget;

  // 构建广告占位容器（承载原生广告）
  // 修复：返回一个稳定的、可复用的 Widget
  Widget getNativeView() {
    _cachedAdWidget ??= Container(
      // 修复：使用 const ValueKey，确保 Widget 的“身份”不变
      key: const ValueKey('SINGLE_NATIVE_AD_CONTAINER'),
      width: double.infinity,
      height: adHeight,
      constraints: BoxConstraints(maxHeight: adHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: PlatformNativeWidget(
        AppAdConfig.nativePlacementID,
        _getAdConfig(),
        isAdaptiveHeight: true, // 启用自适应高度
      ),
    );
    return _cachedAdWidget!;
  }

  // 原生广告控件配置
  Map<String, dynamic> _getAdConfig() {
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

  final isViewCreated = false.obs; // 广告的原生 View 是否已成功创建（最安全的标志）
  // 展示广告
  // 不再返回 Future<Widget>，改为一个“触发”方法
  // UI 层应通过 Obx 监听 isViewCreated 状态来决定是否显示广告
  Future<void> triggerShowNativeAd() async {
    bool isReady = await nativeAdReady();
    String isHasAd = await getNativeValidAds();
    // Utils.logError()
    if (isReady && isHasAd.isNotEmpty) {
      // 如果 View 已创建过，说明非常安全，可以直接使用
      if (isViewCreated.value) {
        Utils.logError("信息流广告View已创建，可安全展示");
        isViewCreated.value = true;
      } else {
        // 如果是首次展示，加入延迟，确保 View 初始化完成
        Utils.logError("信息流广告首次展示，等待150ms");
        await Future.delayed(const Duration(milliseconds: 150));
        isViewCreated.value = true;
      }
    } else {
      bool isLoading = await checkNativeAdLoadStatus();
      Utils.logError("信息流广告加载状态？$isLoading");
      if (!isLoading) {
        Utils.logError('信息流广告正在加载中... + ${AppAdConfig.nativePlacementID}');
      } else {
        Utils.logError('信息流广告还没加载，发起加载 + ${AppAdConfig.nativePlacementID}');
      }
    }
  }

  /// 原生广告监听
  nativeLisListen() async {
    if (_nativeAdSubscription != null) {
      return;
    }
    _nativeAdSubscription = ATListenerManager.nativeEventHandler.listen((
      value,
    ) async {
      switch (value.nativeStatus) {
        case NativeStatus.nativeAdDidFinishLoading:
          Utils.logError("信息流广告加载完成: ${value.placementID}");
          // 可以在这里调用 triggerShowNativeAd 尝试展示
          triggerShowNativeAd();
          break;

        case NativeStatus.nativeAdDidShowNativeAd:
          Utils.logError("信息流广告展示成功: ${value.placementID}");
          // ✅ 关键：广告成功展示，设置安全标志位

          await Future.delayed(const Duration(seconds: 5));
          Utils.logError("开始放下一个");
          // isViewCreated.value = false; // 使用 .value 更新响应式变量
          loadNativeWith();
          break;

        case NativeStatus.nativeAdDidTapCloseButton:
          Utils.logError("信息流广告被关闭: ${value.placementID}");
          // 通常我们不重置 isViewCreated，因为 View 实例可能仍可复用
          // isViewCreated.value = false;
          break;

        case NativeStatus.nativeAdFailToLoadAD:
          Utils.logError("信息流广告加载失败: ${value.requestMessage}");
          // 如果需要，可以在这里重试加载
          await Future.delayed(const Duration(seconds: 5));
          CuToast.error(msg: "信息流广告加载失败: ${value.requestMessage}");
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

  removeNativeAd() async {
    await ATNativeManager.removeNativeAd(
      placementID: AppAdConfig.nativePlacementID,
    );
  }

  StreamSubscription<ATNativeResponse>? _nativeAdSubscription;
}
