import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/Init_tool.dart';
import 'package:base_object/manager/splash_tool.dart';
import 'package:base_object/utils/DeviceChecker.dart';
import 'package:base_object/utils/PermissionManager.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// 初始化广告
  Future<void> initAd() async {
    InitTool.to.setCustomDataDic({
      "user_id": 0,
      "extra": "userid_0_type_1_amount_0_time_0",
    });
    // 初始化广告
    bool isInitAd = await InitTool.to.initTopon();
    Utils.logError("广告初始化完成 $isInitAd ");
    // 打开广告插件日志
    await InitTool.to.setLogEnabled();
  }

  late AnimationController animationController;
  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  void allInit() async {
    EasyLoading.show(status: "检测设备中..");
    bool isPermission = await PermissionManager.requestAllPermissions();
    Utils.logError(isPermission);

    /// 检测设备
    await DeviceChecker.isAllCheckr();

    /// 初始化广告
    initAd();
    SplashTool.to.splashListen();
    SplashTool.to.loadSplash();
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onInit() async {
    // TODO: implement initState
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    super.onInit();
    allInit();
  }
}
