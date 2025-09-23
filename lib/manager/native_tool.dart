import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/pages/home/home_controller.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NativeTool extends GetxService {
  // GetX单例获取方式
  static NativeTool get to =>
      Get.isRegistered<NativeTool>()
          ? Get.find<NativeTool>()
          : Get.put(NativeTool());

  /// 加载广告
  loadNativeWith() async {
    Utils.logError("加载原生广告咯");
    await ATNativeManager.loadNativeAd(
      placementID: AppAdConfig.nativePlacementID,
      extraMap: {
        ATCommon.isNativeShow(): true,
        ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
          Get.width,
          140.h,
        ),
        ATNativeManager.isAdaptiveHeight(): true,
      },
    );
  }

  Future<bool> nativeAdReady() async {
    try {
      return await ATNativeManager.nativeAdReady(
        placementID: AppAdConfig.nativePlacementID,
      );
    } catch (e) {
      Utils.logError('原生广告：原生广告是否就绪：$e'); // 原"nativeAdReady"→"原生广告是否就绪"
      return false;
    }
  }

  getNativeValidAds() async {
    return await ATNativeManager.getNativeValidAds(
      placementID: AppAdConfig.nativePlacementID,
    );
  }

  /// 获取广告状态
  Future<Map<dynamic, dynamic>> checkNativeLoadStatus() async {
    return await ATNativeManager.checkNativeAdLoadStatus(
      placementID: AppAdConfig.nativePlacementID,
    );
  }

  readyStatus() async {
    await nativeAdReady();
    await checkNativeLoadStatus();
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

  /// 原生广告监听
  nativeLisListen() {
    if (_nativeAdSubscription != null) {
      return;
    }
    _nativeAdSubscription = ATListenerManager.nativeEventHandler.listen((
      value,
    ) {
      switch (value.nativeStatus) {
        //广告加载失败
        case NativeStatus.nativeAdFailToLoadAD:
          Utils.logError(
            "原生广告 nativeAdFailToLoadAD ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          loadNativeWith();
          break;
        //广告加载成功
        case NativeStatus.nativeAdDidFinishLoading:
          Utils.logError(
            "原生广告 nativeAdDidFinishLoading ---- placementID: ${value.placementID}",
          );
          // &&UserInfo.instance.isLoginIn
          if (Get.currentRoute == AppRoutes.home) {
            HomeController homeController = Get.find<HomeController>();
            homeController.setIsNativeReady(true);
          }

          break;
        //广告被点击
        case NativeStatus.nativeAdDidClick:
          Utils.logError(
            "原生广告 nativeAdDidClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //Deeplink
        case NativeStatus.nativeAdDidDeepLink:
          Utils.logError(
            "原生广告 nativeAdDidDeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap} ---- isDeeplinkSuccess:${value.isDeeplinkSuccess}",
          );
          break;
        //广告视频结束播放，部分广告平台有此回调
        case NativeStatus.nativeAdDidEndPlayingVideo:
          Utils.logError(
            "原生广告 nativeAdDidEndPlayingVideo ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          loadNativeWith();
          break;
        //广告进入全屏播放，仅iOS有此回调
        case NativeStatus.nativeAdEnterFullScreenVideo:
          Utils.logError(
            "原生广告 nativeAdEnterFullScreenVideo ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告离开全屏播放，仅iOS有此回调
        case NativeStatus.nativeAdExitFullScreenVideoInAd:
          Utils.logError(
            "原生广告 nativeAdExitFullScreenVideoInAd ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告展示成功
        case NativeStatus.nativeAdDidShowNativeAd:
          Utils.logError(
            "原生广告 nativeAdDidShowNativeAd ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          loadNativeWith();
          break;
        //广告视频开始播放，部分广告平台有此回调
        case NativeStatus.nativeAdDidStartPlayingVideo:
          Utils.logError(
            "原生广告 nativeAdDidStartPlayingVideo ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告关闭按钮被点击，部分广告平台有此回调
        case NativeStatus.nativeAdDidTapCloseButton:
          Utils.logError(
            "原生广告 nativeAdDidTapCloseButton ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        case NativeStatus.nativeAdDidCloseDetailInAdView:
          Utils.logError(
            "原生广告 nativeAdDidCloseDetailInAdView ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告加载Draw成功，仅iOS有此回调
        case NativeStatus.nativeAdDidLoadSuccessDraw:
          Utils.logError(
            "原生广告 nativeAdDidLoadSuccessDraw ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        case NativeStatus.nativeAdUnknown:
          Utils.logError("原生广告 downloadUnknown");
          break;
      }
    });
  }
}
