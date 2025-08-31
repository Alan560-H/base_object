import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


class NativeTool extends GetxService{
  // GetX单例获取方式
  static NativeTool get to => Get.find<NativeTool>();
  loadNativeWith() async {
    await ATNativeManager.loadNativeAd(
        placementID: AppAdConfig.nativePlacementID,
        extraMap: {
          ATCommon.isNativeShow() : true,
          ATCommon.getAdSizeKey(): ATNativeManager.createNativeSubViewAttribute(
            Get.width,
            340.w,
          ),
          ATNativeManager.isAdaptiveHeight(): true
        });
  }
  Future<bool> nativeAdReady() async {
    try{
      return await ATNativeManager.nativeAdReady(
        placementID: AppAdConfig.nativePlacementID,
      );
    }catch(e){
      Utils.logError('flutter：原生广告是否就绪：$e'); // 原"nativeAdReady"→"原生广告是否就绪"
      return false;
    }

  }

  getNativeValidAds() async {
    await ATNativeManager.getNativeValidAds(
      placementID: AppAdConfig.nativePlacementID,
    ).then((value) {
      Utils.logError('flutter：原生有效广告数量：$value'); // 原"getNativeValidAds"→"原生有效广告数量"
    });
  }

  checkNativeLoadStatus() async {
    await ATNativeManager.checkNativeAdLoadStatus(
      placementID: AppAdConfig.nativePlacementID,
    ).then((value) {
      Utils.logError('flutter：原生广告加载状态：$value'); // 原"checkNativeAdLoadStatus"→"原生广告加载状态"
    });
  }
  readyStatus() async {
    await nativeAdReady();
    await checkNativeLoadStatus();
  }


  showSceneNativeAd() async {
    await ATNativeManager.showSceneNativeAd(
        placementID: AppAdConfig.nativePlacementID,
        sceneID: AppAdConfig.nativeSceneID,
        extraMap: {
          ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
            Get.width,
            Get.height,
            x: 0,
            y: 100,
          ),
          ATNativeManager.appIcon(): ATNativeManager.createNativeSubViewAttribute(
              50, 50,
              x: 20, y: 70, backgroundColorStr: 'clearColor'),
          ATNativeManager.mainTitle():
          ATNativeManager.createNativeSubViewAttribute(
            Get.width - 100,
            40,
            x: 90,
            y: 70,
            textSize: 15,
          ),
          ATNativeManager.desc(): ATNativeManager.createNativeSubViewAttribute(
            Get.width - 100,
            40,
            x: 90,
            y: 120,
            textSize: 15,
          ),
          ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
            50,
            50,
            x: 90,
            y: 170,
            textSize: 15,
          ),
          ATNativeManager.mainImage():
          ATNativeManager.createNativeSubViewAttribute(
            Get.width - 40,
            Get.height - 200,
            x: 20,
            y: 220,
          ),
          ATNativeManager.adLogo(): ATNativeManager.createNativeSubViewAttribute(
            100,
            50,
            x: Get.width - 100,
            y: Get.height - 70,
          ),
          ATNativeManager.dislike(): ATNativeManager.createNativeSubViewAttribute(
            80,
            80,
            x: 20,
            y: 0,
          ),
        });
  }



  showNative() async {
    await ATNativeManager.showNativeAd(
        placementID: AppAdConfig.nativePlacementID,
        extraMap: {
          ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
              Get.width,
              170,
              x: 0,
              y: 0,
              backgroundColorStr: '#FFFFFF'
          ),
          ATNativeManager.appIcon(): ATNativeManager.createNativeSubViewAttribute(
              50,
              50,
              x: 10,
              y: 40,
              backgroundColorStr: 'clearColor'),
          ATNativeManager.mainTitle(): ATNativeManager.createNativeSubViewAttribute(
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
              y:70,
              textSize: 15),
          ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
              100,
              50,
              x: Get.width - 110,
              y: 40,
              textSize: 15,
              textColorStr: "#FFFFFF",
              backgroundColorStr: "#2095F1"
          ),
          ATNativeManager.mainImage(): ATNativeManager.createNativeSubViewAttribute(
              Get.width - 20,
              70,
              x: 10,
              y: 100,
              backgroundColorStr: '#00000000'),
          ATNativeManager.adLogo(): ATNativeManager.createNativeSubViewAttribute(
              20,
              10,
              x: 10,
              y: 10,
              backgroundColorStr: '#00000000'),
          ATNativeManager.dislike(): ATNativeManager.createNativeSubViewAttribute(
            20,
            20,
            x: Get.width - 30,
            y: 10,
          ),
        }, isAdaptiveHeight: true);
  }

  removeNativeAd() async {
    await ATNativeManager.removeNativeAd(
        placementID: AppAdConfig.nativePlacementID
    );
  }
}
