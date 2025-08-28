import 'dart:async';
import 'dart:developer';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/interstitial_tool.dart';
import 'package:base_object/manager/listener_tool.dart';
import 'package:base_object/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/pages/login/login_controller.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class InterAdDialog extends GetxService {
  // GetX 单例获取方式
  static InterAdDialog get to => Get.find<InterAdDialog>();
  /// 插屏广告定时器
  final InterstitialTool interstitialTool = Get.find<InterstitialTool>();
  @override
  void onInit() {
    Utils.logError("插屏广告初始化触发");
    rewarderEvent();
    super.onInit();
    // 初始化插屏广告
    interstitialTool.loadInterstitialAd({
      Common.getUserIdKey(): UserInfo.instance.userModel.id,
      Common.getExtraKey(): "userid_${UserInfo.instance.userModel.id}_type_2_amount_0_time_0",
    });
    // 初始化逻辑
  }
  upDataADFn(dynamic event)async{
    try{
      UserInfo userInfo = UserInfo.instance;
      if(userInfo.isLoginIn){
        UpDataADForm upDataADForm = UpDataADForm();

        // 1. 安全获取 adsource_price + 处理类型转换（核心改这里）
        // 逐层判空+类型兼容，最终转成 double? 赋值给 amount
        dynamic adSourcePrice = event?['extraMap']?['adsource_price'];
        // 先转成 String 再解析 double（兼容 int/String 类型，避免直接赋值类型冲突）
        double? amount = double.tryParse(adSourcePrice?.toString() ?? "0");
        String reqId = event?['extraMap']?['req_id'];
        String adsourceId = event?['extraMap']?['adsource_id'];
        // 2. 拼接 extra 字符串（用原始值的字符串形式，避免类型问题）
        String userId = UserInfo.instance.userModel.id.toString();
        upDataADForm.extra = "userid_${userId}_type_2_amount_${adSourcePrice ?? 0}_time_0";
        upDataADForm.transId = event?['extraMap']?['id'];
        upDataADForm.amount = (amount!/1000);
        upDataADForm.adsourceId = adsourceId;
        upDataADForm.reqId = reqId;
        upDataADForm.sign=Utils.generateEncryptedString(userId: userId,reqId:reqId,adsourceId: adsourceId);
        Utils.logError("插屏广告凑成的字符串${upDataADForm.toJson()}");
        int pross = amount.toInt();
        Utils.logError("插屏广告金额$pross");
        CuCircularProgressController.to.addCurrentValue(pross);

        if(Get.isRegistered<Api>()){
          Get.put(Api());
        }
        BackModel backModel = await Api.to.getSelectAdV2(upDataADForm);
        Utils.logError("插屏广告返回的数据${ backModel.toJson() }");
        if(backModel.code == CuErrorConfig.success){
          CuToast.success(msg: "上报副广成功");
        }
      }
    }catch(e){
      Utils.logError("上报副广失败：$e");
    }
  }
  // 用于标记是否已处理跳转（避免重复跳转）
  bool _hasShow = false;

  /// 订阅 ListenerTool 的开屏广告事件
  void rewarderEvent() async {
    // ever：持续监听 splashEvent 的变化（广告状态更新时触发）
    ever(ListenerTool.to.interEvent, (event) {
      if (event == null || _hasShow) return; // 过滤空事件或重复跳转

      // 获取事件类型（从 event 中解析，与 ListenerTool 中转发的格式对应）
      String eventType = event["eventType"] ?? "";
      String placementID = event["placementID"] ?? "";

      Utils.logError("激励广告收到激励视频广告事件：$eventType，广告位ID：$placementID，事件参数：$event");
      // 根据事件类型执行业务逻辑
      switch (eventType) {
      // 插屏广告加载失败
        case "InterstitialStatus.interstitialAdFailToLoadAD":
          Utils.logError("插屏广告加载失败，广告位ID：$placementID，事件参数：$event");
          break;
      // 插屏广告加载成功
        case "InterstitialStatus.interstitialAdDidFinishLoading":
          Utils.logError("插屏广告加载完成，广告位ID：$placementID，事件参数：$event");
          Utils.logError("当前路由：${Get.currentRoute}");
          /// 展示插屏广告
          if(Get.currentRoute.isNotEmpty&&Get.currentRoute!=AppRoutes.splashPage){
            interstitialTool.showInterstitialAd();
          }else{
            _startTimer();
          }

          break;
      // 插屏广告深度链接
        case "InterstitialStatus.interstitialAdDidDeepLink":
          Utils.logError("插屏广告深度链接，广告位ID：$placementID，事件参数：$event");
          break;
      // 插屏广告被点击
        case "InterstitialStatus.interstitialAdDidClick":
          Utils.logError("插屏广告被点击，广告位ID：$placementID，事件参数：$event");
          break;
      // 插屏广告被关闭
        case "InterstitialStatus.interstitialAdDidClose":
          Utils.logError("插屏广告被关闭，广告位ID：$placementID，事件参数：$event");
          upDataADFn(event);
          _startTimer();
          break;
      // 插屏广告开始播放
        case "InterstitialStatus.interstitialAdDidStartPlaying":
          Utils.logError("插屏广告开始播放，广告位ID：$placementID，事件参数：$event");
          break;
      // 插屏广告结束播放
        case "InterstitialStatus.interstitialAdDidEndPlaying":
          Utils.logError("插屏广告结束播放，广告位ID：$placementID，事件参数：$event");
          break;
      // 插屏广告播放失败
        case "InterstitialStatus.interstitialDidFailToPlayVideo":
          Utils.logError("插屏广告播放失败，广告位ID：$placementID，事件参数：$event");
          break;
      // 插屏广告展示成功
        case "InterstitialStatus.interstitialDidShowSucceed":
          Utils.logError("插屏广告展示成功，广告位ID：$placementID，事件参数：$event");
          break;
      // 插屏广告展示失败
        case "InterstitialStatus.interstitialFailedToShow":
          Utils.logError("插屏广告展示失败，广告位ID：$placementID，事件参数：$event");
          break;
      // 插屏广告未知状态
        case "InterstitialStatus.interstitialUnknown":
          Utils.logError("插屏广告未知状态，广告位ID：$placementID，事件参数：$event");
          break;
      }
    });
  }





  // 定时器对象
  Timer? _timer;



  // 启动定时器
  void _startTimer() {
    // 先取消可能存在的定时器，避免重复
    _timer?.cancel();

    // 关键修改：用 Timer() 替代 Timer.periodic()，仅延迟6秒后执行一次
    _timer = Timer(const Duration(seconds: 40), () async {
      bool isInterReady = await interstitialTool.hasInterstitialAdReady();
      if (isInterReady) {
        Utils.logError("60秒后检查到广告就绪，尝试展示一次");
        await interstitialTool.showInterstitialAd();
      } else {
        Utils.logError("60秒后检查到广告未就绪，不展示");
        // 可选：只提示一次“加载失败”，避免频繁弹窗骚扰用户
        CuToast.error(msg: "插屏广告加载失败");
      }

      // 单次触发后，定时器自动失效（无需手动取消，也不会重复执行）
    });
  }



  // 取消定时器（可选方法，用于手动控制）
  void cancelTimer() {
    _timer?.cancel();
  }

  // 重新启动定时器（可选方法，用于手动控制）
  void restartTimer() {
    _startTimer();
  }

  // 服务销毁时清理资源
  @override
  void onClose() {
    _timer?.cancel(); // 取消定时器，防止内存泄漏
    super.onClose();
  }
}
