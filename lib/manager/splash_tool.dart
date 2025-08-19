import 'package:anythink_sdk/at_splash.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';


class SplashTool extends GetxService {
  static SplashTool get to => Get.find<SplashTool>();
  /// 加载开屏
  loadSplash() async {
    await ATSplashManager.loadSplash(
        placementID: AppAdConfig.splashID,
        extraMap: {}
    );
  }
  /// 开屏是否准备好（修正后）
  Future<bool> splashReady() async {
    return await ATSplashManager
        .splashReady(
      placementID: AppAdConfig.splashID,
    );
  }
  /// 检查开屏是否加载完成
  checkSplashLoadStatus() async {
    await ATSplashManager
        .checkSplashLoadStatus(
        placementID: AppAdConfig.splashID,
    );
  }
  /// 获取开屏有效广告
  getSplashValidAds() async {
    await ATSplashManager.getSplashValidAds(
        placementID: AppAdConfig.splashID,
    );
  }
  /// 展示开屏
  showSplash() async {
    await ATSplashManager
        .showSplash(
        placementID: AppAdConfig.splashID,
    );
  }
}