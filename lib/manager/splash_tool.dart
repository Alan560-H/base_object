import 'package:anythink_sdk/at_index.dart';
import 'package:anythink_sdk/at_splash.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:get/get.dart';

class SplashTool extends GetxController {
  static SplashTool get to => Get.find<SplashTool>();

  /// 加载开屏
  loadSplash() async {
    await ATSplashManager.loadSplash(
      placementID: AppAdConfig.splashID,
      extraMap: {},
    );
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

  splashListen() {
    ATListenerManager.splashEventHandler.listen((value) {
      switch (value.splashStatus) {
        //广告加载失败
        case SplashStatus.splashDidFailToLoad:
          print(
            "flutter splash--splashDidFailToLoad ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          break;
        //广告加载成功
        case SplashStatus.splashDidFinishLoading:
          print(
            "flutter splash--splashDidFinishLoading ---- placementID: ${value.placementID} ---- isTimeout：${value.isTimeout}",
          );
          break;
        //广告加载超时
        case SplashStatus.splashDidTimeout:
          print(
            "flutter splash--splashDidTimeout ---- placementID: ${value.placementID}",
          );
          break;
        //广告展示成功
        case SplashStatus.splashDidShowSuccess:
          print(
            "flutter splash--splashDidShowSuccess ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告加载失败
        case SplashStatus.splashDidShowFailed:
          print(
            "flutter splash--splashDidShowFailed ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          break;
        //广告被点击
        case SplashStatus.splashDidClick:
          print(
            "flutter splash--splashDidClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //DeepLink
        case SplashStatus.splashDidDeepLink:
          print(
            "flutter splash--splashDidDeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap} ---- isDeeplinkSuccess:${value.isDeeplinkSuccess}",
          );
          break;
        //广告被关闭
        case SplashStatus.splashDidClose:
          print(
            "flutter splash--splashDidClose ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;

        case SplashStatus.splashUnknown:
          print("flutter splash--splashUnknown");
          break;
        case SplashStatus.splashWillClose:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    });
  }
}
