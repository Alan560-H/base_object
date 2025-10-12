import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:anythink_sdk/at_splash.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class SplashTool extends GetxController {
  static SplashTool get to =>
      Get.isRegistered<SplashTool>()
          ? Get.find<SplashTool>()
          : Get.put(SplashTool());

  /// 加载开屏
  loadSplash() async {
    Utils.logError("加载开屏");
    await ATSplashManager.loadSplash(
      placementID: AppAdConfig.splashID,
      extraMap: {},
    ).then((value) => {Utils.logError("开屏广告加载完成$value")});
  }

  /// 开屏是否准备好（修正后）
  Future<bool> splashReady() async {
    return await ATSplashManager.splashReady(placementID: AppAdConfig.splashID);
  }

  /// 检查开屏是否加载完成
  checkSplashLoadStatus() async {
    await ATSplashManager.checkSplashLoadStatus(
      placementID: AppAdConfig.splashID,
    );
  }

  /// 获取开屏有效广告
  getSplashValidAds() async {
    await ATSplashManager.getSplashValidAds(placementID: AppAdConfig.splashID);
  }

  /// 展示开屏
  showSplash() async {
    await ATSplashManager.showSplash(placementID: AppAdConfig.splashID);
  }

  StreamSubscription<ATSplashResponse>? _splashSubscription;
  // 开屏监听器
  splashListen() {
    if (_splashSubscription != null) {
      return;
    }
    _splashSubscription = ATListenerManager.splashEventHandler.listen((value) {
      Utils.logError("加载开屏状态：${value.splashStatus}");

      switch (value.splashStatus) {
        //广告加载失败
        case SplashStatus.splashDidFailToLoad:
          Utils.logError(
            "开屏广告 splash--splashDidFailToLoad ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          Get.offAllNamed(AppRoutes.home);
          break;
        //广告加载成功
        case SplashStatus.splashDidFinishLoading:
          Utils.logError(
            "开屏广告 splash--splashDidFinishLoading ---- placementID: ${value.placementID} ---- isTimeout：${value.isTimeout}",
          );
          showSplash();
          break;
        //广告加载超时
        case SplashStatus.splashDidTimeout:
          Utils.logError(
            "开屏广告 splash--splashDidTimeout ---- placementID: ${value.placementID}",
          );
          Get.offAllNamed(AppRoutes.home);
          break;
        //广告展示成功
        case SplashStatus.splashDidShowSuccess:
          Utils.logError(
            "开屏广告 splash--splashDidShowSuccess ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告加载失败
        case SplashStatus.splashDidShowFailed:
          Utils.logError(
            "开屏广告 splash--splashDidShowFailed ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          break;
        //广告被点击
        case SplashStatus.splashDidClick:
          Utils.logError(
            "开屏广告 splash--splashDidClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //DeepLink
        case SplashStatus.splashDidDeepLink:
          Utils.logError(
            "开屏广告 splash--splashDidDeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap} ---- isDeeplinkSuccess:${value.isDeeplinkSuccess}",
          );
          break;
        //广告被关闭
        case SplashStatus.splashDidClose:
          Utils.logError(
            "开屏广告 splash--splashDidClose ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          Get.offAllNamed(AppRoutes.home);
          break;

        case SplashStatus.splashUnknown:
          Utils.logError("开屏广告 splash--splashUnknown");
          break;
        case SplashStatus.splashWillClose:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    });
  }
}
