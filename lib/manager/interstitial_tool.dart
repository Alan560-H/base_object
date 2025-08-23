import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class InterstitialTool extends GetxService {
  // GetX单例获取方式
  static InterstitialTool get to => Get.find<InterstitialTool>();
  // 初始化服务（GetX生命周期方法）
  static Future<InterstitialTool> init() async {
    return await Get.putAsync(() async {
      return InterstitialTool();
    });
  }

  loadInterstitialAd() async {
    await ATInterstitialManager.loadInterstitialAd(
        placementID: AppAdConfig.interstitialPlacementID,
        extraMap: {
          // Sigmob rewarded video ----> Interstitial ads
          // ATInterstitialManager.useRewardedVideoAsInterstitialKey(): true
        });
  }

  interstitialAdcheck() async {
    hasInterstitialAdReady();
    getInterstitialValidAds();
    checkInterstitialLoadStatus();
  }

  Future<bool> hasInterstitialAdReady() async {
    return await ATInterstitialManager.hasInterstitialAdReady(
      placementID: AppAdConfig.interstitialPlacementID,
    );
  }

  getInterstitialValidAds() async {
    await ATInterstitialManager.getInterstitialValidAds(
      placementID: AppAdConfig.interstitialPlacementID,
    ).then((value) {
      Utils.logError('flutter：插屏有效广告数量：$value'); // 翻译：原"getInterstitialValidAds"→"插屏有效广告数量"
    });
  }

  checkInterstitialLoadStatus() async {
    await ATInterstitialManager.checkInterstitialLoadStatus(
      placementID: AppAdConfig.interstitialPlacementID,
    ).then((value) {
      Utils.logError('flutter：插屏广告加载状态：$value'); // 翻译：原"checkInterstitialLoadStatus"→"插屏广告加载状态"
    });
  }

  showInterstitialAd() async {
    await ATInterstitialManager.showInterstitialAd(
      placementID: AppAdConfig.interstitialPlacementID,
    );
  }

  showSceneInterstitialAd() async {
    await ATInterstitialManager.showSceneInterstitialAd(
      placementID: AppAdConfig.interstitialPlacementID,
      sceneID: AppAdConfig.interstitialSceneID,
    );
  }
}