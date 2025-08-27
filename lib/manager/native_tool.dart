import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


class NativeTool extends GetxService{
  // GetX单例获取方式
  static NativeTool get to => Get.find<NativeTool>();
  //检查加载状态
  Future<int> checkNativeAdLoadStatus() async {
    try {
      final value = await ATNativeManager.checkNativeAdLoadStatus(
        placementID: AppAdConfig.nativePlacementID,
      );
      final isLoading = value['isLoading'] ?? 0;
      return isLoading;
    } catch (error) {
      return -1; // 出现错误时，返回-1
    }
  }
  // 原生广告控件配置（与AnyThink SDK要求匹配）
  Map<String, dynamic> _getAdConfig(double adHeight) {
    return {
      // 广告父容器（整体尺寸）
      ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 20.w, // 宽度=屏幕宽-20（适配左右边距）
        adHeight, // 高度与外层容器一致
        backgroundColorStr: '#FFFFFF',
      ),
      // App图标
      ATNativeManager.appIcon(): ATNativeManager.createNativeSubViewAttribute(
        50.sp, 50.sp,
        x: 10.w, y: 40.h,
        backgroundColorStr: 'clearColor',
      ),
      // 广告标题
      ATNativeManager.mainTitle(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 190.w, 20.h,
        x: 70.w, y: 40.h,
        textSize: 15.sp,
        textColorStr: '#333333',
      ),
      // 广告描述
      ATNativeManager.desc(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 190.w, 20.h,
        x: 70.w, y: 70.h,
        textSize: 13.sp,
        textColorStr: '#666666',
      ),
      // 行动按钮（立即下载）
      ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
        100.w, 35.h,
        x: Get.width - 110.w, y: 40.h,
        textSize: 14.sp,
        textColorStr: '#FFFFFF',
        backgroundColorStr: '#FF6700',
        cornerRadius: 4, // 按钮圆角
      ),
      // 广告主图
      ATNativeManager.mainImage(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 40.w, 180.h,
        x: 20.w, y: 100.h,
        backgroundColorStr: '#F5F5F5',
        cornerRadius: 4,
      ),
      // 广告标签（广告二字）
      ATNativeManager.adLogo(): ATNativeManager.createNativeSubViewAttribute(
        40.w, 18.h,
        x: 10.w, y: 10.h,
        textSize: 12.sp,
        textColorStr: '#FFFFFF',
        backgroundColorStr: '#FF4444',
        cornerRadius: 2,
      ),
      // 关闭按钮
      ATNativeManager.dislike(): ATNativeManager.createNativeSubViewAttribute(
        20.sp, 20.sp,
        x: Get.width - 30.w, y: 10.h,
        backgroundColorStr: 'clearColor',
      ),
      // 广告合规六要素（Android中国区必需）
      ATNativeManager.elementsView(): ATNativeManager.createNativeSubViewAttribute(
        Get.width - 20.w, 25.h,
        x: 10.w, y: adHeight - 25.h, // 贴底部
        textSize: 10.sp,
        textColorStr: '#FFFFFF',
        backgroundColorStr: '#7F000000',
      ),
    };
  }

  // Container(


  // 构建广告占位容器（承载原生广告）
  Widget getNativeView() {
    try{
      final double adHeight = 200.h; // 广告固定高度（与原生广告配置一致）
      return Container(
        key:UniqueKey(),
        width: double.infinity,
        height: adHeight,
        constraints: BoxConstraints(maxHeight: adHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: PlatformNativeWidget(
          AppAdConfig.nativePlacementID, // 广告位ID（需在AppAdConfig中配置）
          _getAdConfig(adHeight), // 广告控件配置
          isAdaptiveHeight: true, // Android自适应高度（避免内容溢出）
        ),
      );
    }catch(e){
      Utils.logError("原生广告出错$e");
      return Placeholder();
    }
  }

//展示广告
 Future<Widget> startShowNativeAd() async {
    bool isReady = await nativeAdReady();
    //到达展示场景，展示前检查是否准备就绪
    if (isReady == true) {
      return getNativeView();
    } else {
      int isLoading = await checkNativeAdLoadStatus();
      Utils.logError("加载状态？$isLoading");
      if (isLoading == 1) {
        Utils.logError('广告正在加载中... + ${AppAdConfig.nativePlacementID}');
      } else {
        Utils.logError('广告还没加载，发起加载 + ${AppAdConfig.nativePlacementID}');
        loadNativeWith(
            {
              ATCommon.isNativeShow() : true,
              ATCommon.getAdSizeKey(): ATNativeManager.createNativeSubViewAttribute(
                Get.width,
                340.w,
              ),
              ATNativeManager.isAdaptiveHeight(): true
            }
        );
      }
      return Placeholder();
    }
  }

  // 加载原生广告
  loadNativeWith(Map<dynamic,dynamic> extraMap) async {
    await ATNativeManager.loadNativeAd(
        placementID: AppAdConfig.nativePlacementID,
        extraMap: extraMap);
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

  Future<String> getNativeValidAds() async {
   return await ATNativeManager.getNativeValidAds(
      placementID: AppAdConfig.nativePlacementID,
    );
  }

  Future<Map> checkNativeLoadStatus() async {
    return await ATNativeManager.checkNativeAdLoadStatus(
      placementID: AppAdConfig.nativePlacementID,
    );
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
              340,
              x: 0,
              y: 200,
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
              Get.width * 0.6,
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

  Future<bool> removeNativeAd() async {
    return await ATNativeManager.removeNativeAd(
        placementID: AppAdConfig.nativePlacementID
    );
  }
}
