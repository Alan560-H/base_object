import 'dart:async';
import 'dart:developer';

import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/Init_tool.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/manager/splash_tool.dart';
import 'package:base_object/models/localModels/LocationData.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/DeviceChecker.dart';
import 'package:base_object/utils/LocationUtil.dart';
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

    /// 初始化开屏广告
    SplashTool.to.splashListen();
    await LocationUtil().getCurrentLocation((Map result) async {
      Utils.logError("定位结果：$result");
      LocationData locationData = LocationData(
        address: result["address"],
        latitude: result["latitude"],
        longitude: result["longitude"],
      );
      Store.instance.setLocationData(locationData);
    });
    bool getVer = await Store.instance.getVer();

    Utils.logError("是否封禁返回的数值：$getVer");
    SplashTool.to.splashListen();
    SplashTool.to.loadSplash();
    // 如果被封了，就去错误页面
    if (getVer) {
      CuToast.error(msg: "该设备禁止登录，但可正常进入");
      if (UserInfo.instance.isLoginIn) {
        UserInfo.instance.loginOut();
      }
      Store.instance.setDisableLogin(true);
    } else {
      Store.instance.setDisableLogin(false);
    }
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
