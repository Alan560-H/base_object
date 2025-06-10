import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/core/config/global.dart';
import 'package:base_object/pages/home/home_view.dart';
import 'package:base_object/pages/user/user_view.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gtads/gtads.dart';

class SplashController extends GetxController {
  final loading = true.obs;
  void _init() async {
    Utils.logError("初始化前:");
    // //isDebug 是否开启debug日志
    GTAds.addProviders(AppAdConfig.providers);
    var a = await GTAds.init(isDebug: true);
    loading.value = false;
    Utils.logError("初始化后$a");

  }
  @override
  void onInit() {
    // TODO: implement onInit

    super.onInit();
    _init();
  }

}