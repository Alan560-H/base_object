import 'dart:async';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/components/dialogs/interAdDialog/interAdDialog.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/pages/login/login_controller.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class InterstitialTool extends GetxService {
  // GetX单例获取方式
  static InterstitialTool get to =>
      Get.isRegistered<InterstitialTool>()
          ? Get.find<InterstitialTool>()
          : Get.put<InterstitialTool>(InterstitialTool());
  // 初始化服务（GetX生命周期方法）
  static Future<InterstitialTool> init() async {
    return await Get.putAsync(() async {
      return InterstitialTool();
    });
  }

  loadInterstitialAd(Map<String, dynamic> extraMap) async {
    await ATInterstitialManager.loadInterstitialAd(
      placementID: AppAdConfig.interstitialPlacementID,
      extraMap: extraMap,
    );
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
      Utils.logError(
        '插屏广告：插屏有效广告数量：$value',
      ); // 翻译：原"getInterstitialValidAds"→"插屏有效广告数量"
    });
  }

  checkInterstitialLoadStatus() async {
    await ATInterstitialManager.checkInterstitialLoadStatus(
      placementID: AppAdConfig.interstitialPlacementID,
    ).then((value) {
      Utils.logError(
        '插屏广告：插屏广告加载状态：$value',
      ); // 翻译：原"checkInterstitialLoadStatus"→"插屏广告加载状态"
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

  StreamSubscription<ATInterstitialResponse>? _intertStreamSubscription;
  interstitialListen() {
    if (_intertStreamSubscription != null) {
      return;
    }
    _intertStreamSubscription = ATListenerManager.interstitialEventHandler.listen((
      value,
    ) {
      switch (value.interstatus) {
        //广告加载失败
        case InterstitialStatus.interstitialAdFailToLoadAD:
          Utils.logError(
            "插屏广告 interstitialAdFailToLoadAD ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          loadInterstitialAd({
            Common.getUserIdKey(): UserInfo.instance.userModel.id,
            Common.getExtraKey():
                "userid_${UserInfo.instance.userModel.id}_type_2_amount_0_time_0",
          });
          break;
        //广告加载成功
        case InterstitialStatus.interstitialAdDidFinishLoading:
          Utils.logError(
            "插屏广告 interstitialAdDidFinishLoading ---- placementID: ${value.placementID}",
          );
          break;
        //广告视频开始播放，部分平台有此回调
        case InterstitialStatus.interstitialAdDidStartPlaying:
          Utils.logError(
            "插屏广告 interstitialAdDidStartPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告视频播放结束，部分广告平台有此回调
        case InterstitialStatus.interstitialAdDidEndPlaying:
          Utils.logError(
            "插屏广告 interstitialAdDidEndPlaying ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告视频播放失败，部分广告平台有此回调
        case InterstitialStatus.interstitialDidFailToPlayVideo:
          Utils.logError(
            "插屏广告 interstitialDidFailToPlayVideo ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          break;
        //广告展示成功
        case InterstitialStatus.interstitialDidShowSucceed:
          Utils.logError(
            "插屏广告 interstitialDidShowSucceed ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告展示失败
        case InterstitialStatus.interstitialFailedToShow:
          Utils.logError(
            "插屏广告 interstitialFailedToShow ---- placementID: ${value.placementID} ---- errStr:${value.requestMessage}",
          );
          break;
        //广告被点击
        case InterstitialStatus.interstitialAdDidClick:
          Utils.logError(
            "插屏广告 interstitialAdDidClick ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //Deeplink
        case InterstitialStatus.interstitialAdDidDeepLink:
          Utils.logError(
            "插屏广告 interstitialAdDidDeepLink ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          break;
        //广告被关闭
        case InterstitialStatus.interstitialAdDidClose:
          Utils.logError(
            "插屏广告 interstitialAdDidClose ---- placementID: ${value.placementID} ---- extra:${value.extraMap}",
          );
          InterAdDialog.to.upDataADFn(value);
          InterAdDialog.to.restartTimer();
          break;

        case InterstitialStatus.interstitialUnknown:
          Utils.logError("插屏广告 interstitialUnknown");
          break;
      }
    });
  }
}
