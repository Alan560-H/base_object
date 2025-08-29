import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/listener_tool.dart'; // 导入 ListenerTool
import 'package:base_object/manager/splash_tool.dart';
import 'package:base_object/models/backModel/fKModelConfig/FKConfigVo.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
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
  void getFkConfig()async {
   try{
     FKConfigVo data = await Api.to.getFkConfig();
     Store.instance.setFKConfigVo(data);
   }catch(e){
     Utils.logError("获取风控配置失败$e");
   }
  }
  @override
  void onInit() async {
    Utils.logError("开屏页面init初始化");
    getFkConfig();
    super.onInit();

    // 1. 先订阅开屏广告事件（关键：确保事件监听在广告展示前生效）
    _subscribeSplashEvent();

    // 2. 加载并展示广告（若 main 中未提前加载，这里触发加载）
    await SplashTool.to.loadSplash();
    await _init();
  }

  /// 订阅 ListenerTool 的开屏广告事件
  void _subscribeSplashEvent() {
    // ever：持续监听 splashEvent 的变化（广告状态更新时触发）
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
    String? isFirst = await LocalStorage.getString("isFirst");
    Utils.logError("执行跳转首页$isFirst");
    if (isFirst == null) {
      Get.offNamed(AppRoutes.firstPage);
    } else {
      Get.offNamed(AppRoutes.home);
    }

    // // 延迟 300ms 跳转，避免页面切换过于生硬
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   if (Get.currentRoute != AppRoutes.home) {
    //     Get.offAllNamed(AppRoutes.home);
    //   }
    // });
  }

  // 页面销毁时取消订阅（避免内存泄漏）
  @override
  void onClose() {
    super.onClose();
    _hasJumped = true;
    // GetX 的 ever 会自动取消订阅，若用其他订阅方式需手动取消
  }
}