import 'dart:async'; // 导入Timer所需的包

import 'package:anythink_sdk/at_native.dart';
import 'package:anythink_sdk/at_platformview/at_native_platform_widget.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ShortVideoController extends GetxController {
  RxString appbarTitle = "短视频页面标题".obs;

  // 1. 声明定时器变量，用于管理定时任务（初始为null）
  Timer? _addAdTimer;

  // 原生广告容器列表（原代码保留）
  RxList<Widget> nativeList = <Widget>[].obs;

  @override
  void onInit() async {
    Utils.logError("短视频页面初始化");
    super.onInit();
  }

  @override
  void onReady() {
    Utils.logError("短视频页面onReady");
    super.onReady();
  }

  // 2. 新增：启动「每6秒添加广告」的定时任务
  Future<void> startPeriodicAddAd() async {
    // 先取消已有的定时器（防止重复启动，比如多次点击按钮）
    if (_addAdTimer != null && _addAdTimer!.isActive) {
      _addAdTimer!.cancel();
    }

    // 启动定时任务：每6秒执行一次回调
    _addAdTimer = Timer.periodic(const Duration(seconds: 6), (timer) async {
      // 判断广告是否准备好，避免添加无效容器
      bool isADReady = await NativeTool.to.nativeAdReady();
      if (isADReady) {
        Utils.logError("6秒定时添加广告容器");
        nativeList.add(nativeAdContainer); // 添加新的广告容器
      } else {
        Utils.logError("广告未准备好，跳过本次添加");
        NativeTool.to.loadNativeWith(); // 未准备好则重新加载广告
      }
    });
  }

  // 3. 新增：停止定时添加（可选，如需手动停止）
  void stopPeriodicAddAd() {
    if (_addAdTimer != null && _addAdTimer!.isActive) {
      _addAdTimer!.cancel();
      Utils.logError("已停止定时添加广告");
    }
  }

  // 原有的广告容器（保留）
  Widget get nativeAdContainer {
    return Container(
      height: 250.h,
      width: Get.width,
      color: Colors.red,
      child: PlatformNativeWidget(AppAdConfig.nativeSceneID, {
        ATNativeManager.isAdaptiveHeight(): true,
        ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
          Get.width,
          250.h,
          backgroundColorStr: "#1e1f22",
        ),
      }),
    );
  }

  // 原有的单次添加广告（可保留，也可整合到定时任务中）
  Future<void> initAd() async {
    bool isADReady = await NativeTool.to.nativeAdReady();
    Utils.logError("原生视频是否准备好$isADReady");
    if (!isADReady) {
      NativeTool.to.loadNativeWith();
      return;
    } else {
      nativeList.add(nativeAdContainer);
    }
  }

  // 4. 页面销毁时取消定时器（关键：防止内存泄漏）
  @override
  void onClose() {
    stopPeriodicAddAd(); // 调用停止方法
    Utils.logError("短视频页面onClose");
    super.onClose();
  }
}
