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
import 'package:base_object/utils/local_storage.dart';
import 'package:flutter_android_oaid_plugin/flutter_android_oaid_plugin.dart';
import 'package:flutter_pangrowth/flutter_pangrowth.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> getVer()async {
    try{
     await Store.instance.getVer();
     if(Store.instance.isLimit) {
       Get.offAllNamed(AppRoutes.userError);
       NativeTool.to.removeNativeAd();
       BannerTool.to.removeBannerAd();
       Get.delete<NativeTool>();
       Get.delete<RewarderTool>();
       Get.delete<InitTool>();
       Get.delete<SplashTool>();
     }
    }catch(e){
      Utils.logError("检查设备封禁失败$e");
    }
  }
  Future<void> getFkConfig()async {
   try{
     FKConfigVo data = await Api.to.getFkConfig();
     Store.instance.setFKConfigVo(data);
     Utils.logError("风控设置：${Store.instance.getFkConfig.toJson()}");
   }catch(e){
     Utils.logError("获取风控配置失败$e");
   }
  }
  Future _pangrowthInit() async {
    final status = await Permission.phone.request();
    print("phone 权限状态 $status");
    await PangrowthVideo.registerVideo(
      appName: "",
      ////appid 必填
      ///demo 使用
      // andoridAppId: "5713596",
      andoridAppId: "5670418",
      appLogAppId :"751081",
      iosAppId: "",
      debug: true,
    );
  }

  Future<void> initAll()async{
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
    await getVer();
    await initAll();

    await getFkConfig();
    super.onInit();
    ///同意隐私政策之后调用
    await _pangrowthInit();
    // 1. 先订阅开屏广告事件（关键：确保事件监听在广告展示前生效）
    _subscribeSplashEvent();
    if(!Get.isRegistered<SplashTool>()){
      Get.put(SplashTool());
    }
    // 2. 加载并展示广告（若 main 中未提前加载，这里触发加载）
    await SplashTool.to.loadSplash();
    await _init();
  }

  /// 订阅 ListenerTool 的开屏广告事件
  void _subscribeSplashEvent() {
    // ever：持续监听 splashEvent 的变化（广告状态更新时触发）
    if(!Get.isRegistered<ListenerTool>()){
      Get.put(ListenerTool());
      return;
    }
    ever(ListenerTool.to.splashEvent, (event) {
      if (event == null || _hasJumped) return; // 过滤空事件或重复跳转

      // 获取事件类型（从 event 中解析，与 ListenerTool 中转发的格式对应）
      String eventType = event["eventType"] ?? "";
      String placementID = event["placementID"] ?? "";

      Utils.logError("收到开屏广告事件：$eventType，广告位ID：$placementID，事件参数：$event");
      // 根据事件类型执行业务逻辑
      switch (eventType) {
      // 开屏广告加载完成
        case "SplashStatus.splashDidFinishLoading":
          Utils.logError("开屏广告加载成功，展示广告");
          SplashTool.to.showSplash();
          break;
      // 开屏广告加载失败
        case "SplashStatus.splashDidFailToLoad":
          Utils.logError("开屏广告失败，跳转首页");
          _jumpToHome();
          break;

      // 广告加载超时：跳转首页
        case "SplashStatus.splashDidTimeout":
          Utils.logError("开屏广告加载超时，跳转首页");
          _jumpToHome();
          break;
      // 展示成功
        case "SplashStatus.splashDidShowSuccess":
          Utils.logError("开屏广告展示成功");
          break;
      // 展示失败
        case "SplashStatus.splashDidShowFailed":
          Utils.logError("开屏广告展示失败");
          break;
          /// 点击
        case "SplashStatus.splashDidClick":
          Utils.logError("开屏广告点击");
          break;
      /// 关闭
        case "SplashStatus.splashDidClose":
          Utils.logError("开屏广告关闭");
          _jumpToHome();
          break;
      /// 即将关闭
        case "SplashStatus.splashWillClose":
          Utils.logError("开屏广告即将关闭");
          break;
      /// 深度链接呗触发
        case "SplashStatus.splashDidDeepLink":
          Utils.logError("开屏广告深度链接呗触发");
          break;
        case "SplashStatus.splashUnknown":
          Utils.logError("开屏广告状态未知");
          break;
      }
    });
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