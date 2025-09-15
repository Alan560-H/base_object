import 'dart:developer';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/Init_tool.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/manager/interstitial_tool.dart';
import 'package:base_object/manager/listener_tool.dart'; // 导入 ListenerTool
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/manager/splash_tool.dart';
import 'package:base_object/models/FormModel/checkDeviceForm/CheckDeviceForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/fKModelConfig/FKConfigVo.dart';
import 'package:base_object/store/di.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  // 用于标记是否已处理跳转（避免重复跳转）
  bool _hasJumped = false;

  Future<void> _init() async {
    try {
      // 1. 检查广告是否已准备好（若之前在 main 中提前加载，这里可快速获取状态）
      bool isReady = await SplashTool.to.splashReady();
      Utils.logError("开屏广告是否准备好: $isReady");

      if (isReady) {
        Utils.logError("开始展示开屏广告");
        await SplashTool.to.showSplash(); // 展示广告（建议加 await 确保执行完成）
      } else {
        Utils.logError("开屏广告未准备好，直接跳转首页");
        _jumpToHome(); // 广告未准备好，兜底跳转
      }
    } catch (e) {
      Utils.logError("开屏广告初始化失败: $e");
      _jumpToHome(); // 异常时兜底跳转，避免卡住
    }
  }

  /// 检查设备封禁
  Future<void> getVer() async {
    try {
      if (Store.instance.isLimit) {
        Get.offAllNamed(AppRoutes.userError);
      }
    } catch (e) {
      Utils.logError("检查设备封禁失败$e");
    }
  }

  Future<void> getFkConfig() async {
    try {
      FKConfigVo data = await Api.to.getFkConfig();
      Store.instance.setFKConfigVo(data);
      Utils.logError("风控设置：${Store.instance.getFkConfig.toJson()}");
    } catch (e) {
      Utils.logError("获取风控配置失败$e");
    }
  }

  Future<void> initAll() async {
    DependencyInjection.adInit();
    InitTool.to.setCustomDataDic({
      "user_id": 0,
      "extra": "userid_0_type_1_amount_0_time_0",
    });
    await Store.instance.initCurrentCount();
    // 初始化广告
    bool isInitAd = await InitTool.to.initTopon();
    Utils.logError("广告初始化完成 $isInitAd ");
  }

  @override
  void onInit() async {
    Utils.logError("开屏页面init初始化");

    Store.instance.getVer().then((value) {
      Utils.logError("返回的数值：$value");
      // 如果被封了，就去错误页面
      if (!value) {
        Get.offAllNamed(AppRoutes.userError);
      } else {}
    });
    // Utils.logError("封禁情况${Store.instance.isLimit}");
    // await initAll();
    //
    // await getFkConfig();
    // super.onInit();
    //
    // // 2. 加载并展示广告（若 main 中未提前加载，这里触发加载）
    // await SplashTool.to.loadSplash();
    // await _init();
  }

  /// 跳转首页（封装兜底逻辑，避免重复跳转）
  void _jumpToHome() async {
    if (_hasJumped) return;
    _hasJumped = true; // 标记为已跳转

    Get.offAllNamed(AppRoutes.home);
  }

  // 页面销毁时取消订阅（避免内存泄漏）
  @override
  void onClose() {
    super.onClose();
    _hasJumped = true;
    // GetX 的 ever 会自动取消订阅，若用其他订阅方式需手动取消
  }
}
