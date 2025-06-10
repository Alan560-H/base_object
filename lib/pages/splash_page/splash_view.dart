import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/pages/index_controller.dart';
import 'package:base_object/pages/splash_page/splash_controller.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gtads/gtads.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      controller.loading.value?Center(child:
      // CircularProgressIndicator(color: Colors.white,),
        Text(controller.loading.value.toString())
      ):
      GTAdsSplashWidget(
        //需要的广告位组
        codes: AppAdConfig.splashCodes,
        width: Utils.getScreenWidth(context),
        height:Utils.getScreenHeight(context),
        //超时时间 当广告失败后会依次重试其他广告 直至所有广告均加载失败 设置超时时间可提前取消
        timeout: 5,
        //广告加载模式 [GTAdsModel.PRIORITY]优先级模式 [GTAdsModel.RANDOM]随机模式
        //默认随机模式
        model: GTAdsModel.PRIORITY,
        callBack: GTAdsCallBack(
          onShow: (code) {
            Utils.logError("onShow:$code");
          },
          onClick: (code) {
            Utils.logError("onClick:$code");
            Get.offAllNamed(AppRoutes.root);
          },
          onFail: (code, message) {
            Utils.logError("onFail:${code.toString()},Msg:$message");
            Get.offAllNamed(AppRoutes.root);
          },
          onClose: (code) {
            Utils.logError("onClose:$code");
            Get.offAllNamed(AppRoutes.root);
          },
          onTimeout: () {
            Utils.logError("onTimeout");
            Get.offAllNamed(AppRoutes.root);
          },
          onEnd: () {
            Utils.logError("onEnd");
          },
        ),
      ),
    );
  }


}
