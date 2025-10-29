import 'dart:async';

import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/Init_tool.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/manager/splash_tool.dart';
import 'package:base_object/models/localModels/LocationData.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/DeviceChecker.dart';
import 'package:base_object/utils/LocationUtil.dart';
import 'package:base_object/utils/PermissionManager.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
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
    bool isLog = await InitTool.to.setLogEnabled();
    // Utils.logError("日志打印是否开启 $isLog");
  }

  @override
  void onInit() async {
    EasyLoading.show(status: "检测设备中..");

    /// 初始化广告
    initAd();

    /// 初始化开屏广告
    SplashTool.to.splashListen();
    bool isPermission = await PermissionManager.requestAllPermissions();
    Utils.logError(isPermission);
    bool isAllCheck = await DeviceChecker.isAllCheckr();

    if (isAllCheck) {
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
      // 如果被封了，就去错误页面
      if (getVer) {
        BannerTool.to.removeBannerAd();
        await Store.instance.getServerConfig();
        Get.offAllNamed(AppRoutes.userError);
      } else {
        /// 上传地址
        await Store.instance.upAddress();

        /// 获取风控配置
        await Store.instance.getFkConfigFn();

        /// 获取今日领取了多少个红包
        await Store.instance.initCurrentCount();
        SplashTool.to.splashListen();
        SplashTool.to.loadSplash();
      }
    }
    super.onInit();
  }
}
