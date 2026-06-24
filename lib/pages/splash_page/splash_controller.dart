import 'dart:async';

import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/services/ads/banner_tool.dart';
import 'package:base_object/services/ads/Init_tool.dart';
import 'package:base_object/services/device/DeviceChecker.dart';
import 'package:base_object/services/device/PermissionManager.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// 初始化广告（带超时，避免部分机型 TopOn / 日志开关原生调用长时间不返回导致卡在闪屏）
  Future<void> initAd() async {
    try {
      await InitTool.to
          .setCustomDataDic({
            "user_id": 0,
            "extra": "userid_0_type_1_amount_0_time_0",
          })
          .timeout(const Duration(seconds: 5));
    } catch (e, st) {
      Utils.logError(
        'setCustomDataMap 超时或失败（继续尝试 initTopon）: $e',
        error: e,
        stackTrace: st,
      );
    }

    try {
      final bool isInitAd = await InitTool.to.initTopon().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          Utils.logError('initTopon 超过 5s 未返回，先进入首页');
          return false;
        },
      );
      Utils.logError("广告初始化完成 $isInitAd");
    } catch (e, st) {
      Utils.logError('initTopon 异常: $e', error: e, stackTrace: st);
    }

    // 关闭 Taku 原生调试日志；横幅等业务日志见 [AdLogCollector]
    unawaited(_safeSetSdkDebugLog(true));
  }

  Future<void> _safeSetSdkDebugLog(bool enabled) async {
    try {
      await InitTool.to
          .setSdkDebugLog(enabled)
          .timeout(const Duration(seconds: 5));
    } catch (e, st) {
      Utils.logError('setSdkDebugLog 超时或失败（可忽略）: $e', error: e, stackTrace: st);
    }
  }

  late AnimationController animationController;
  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  void allInit() async {
    EasyLoading.show(status: "检测设备中..");
    try {
      bool isPermission = await PermissionManager.requestAllPermissions();
      Utils.logError(isPermission);

      /// 检测设备
      await DeviceChecker.isAllCheckr();

      /// 须等待 TopOn 初始化完成后再进首页，避免横幅 load 早于 SDK 就绪
      await initAd();
      BannerTool.to.bannerListen();
    } finally {
      EasyLoading.dismiss();
    }
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
