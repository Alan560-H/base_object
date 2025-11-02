import 'dart:async';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/interstitial_tool.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/FormModel/checkDeviceForm/CheckDeviceForm.dart';
import 'package:base_object/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/pages/login/login_controller.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_android_oaid_plugin/flutter_android_oaid_plugin.dart';
import 'package:get/get.dart';

class InterAdDialog extends GetxService {
  // GetX 单例获取方式
  static InterAdDialog get to =>
      Get.isRegistered<InterAdDialog>()
          ? Get.find<InterAdDialog>()
          : Get.put(InterAdDialog());

  @override
  void onInit() {
    Utils.logError("插屏广告初始化触发");
    super.onInit();

    // 初始化插屏广告
    InterstitialTool.to.loadInterstitialAd({
      Common.getUserIdKey(): UserInfo.instance.userModel.id,
      Common.getExtraKey():
          "userid_${UserInfo.instance.userModel.id}_type_2_amount_0_time_0",
    });
    // 初始化逻辑
  }

  interUpDataADFn(dynamic event) async {
    try {
      UserInfo userInfo = UserInfo.instance;
      if (userInfo.isLoginIn) {
        UpDataADForm upDataADForm = UpDataADForm();

        // 1. 安全获取 adsource_price + 处理类型转换（核心改这里）
        // 逐层判空+类型兼容，最终转成 double? 赋值给 amount
        dynamic adSourcePrice = event.extraMap?['adsource_price'];
        // 先转成 String 再解析 double（兼容 int/String 类型，避免直接赋值类型冲突）
        double? amount = double.tryParse(adSourcePrice?.toString() ?? "0");
        String reqId = event.extraMap?['req_id'];
        String adsourceId = event.extraMap?['adsource_id'];
        // 2. 拼接 extra 字符串（用原始值的字符串形式，避免类型问题）
        String userId = UserInfo.instance.userModel.id.toString();
        upDataADForm.extra =
            "userid_${userId}_type_2_amount_${adSourcePrice ?? 0}_time_0";
        upDataADForm.transId = event.extraMap?['id'];
        upDataADForm.amount = (amount! / 1000);
        upDataADForm.adsourceId = adsourceId;
        upDataADForm.reqId = reqId;
        upDataADForm.sign = Utils.generateEncryptedString(
          userId: userId,
          reqId: reqId,
          adsourceId: adsourceId,
        );
        Utils.logError("插屏广告凑成的字符串${upDataADForm.toJson()}");
        Utils.logError(
          "一：$amount,二：${Store.instance.getFkConfig.wactchMaxAmountV1}，三：插屏广告金额$amount，限制金额${Store.instance.getFkConfig.wactchMaxAmountV1}",
        );
        if (amount > Store.instance.getFkConfig.wactchMaxAmountV1) {
          CheckDeviceForm checkDeviceForm = CheckDeviceForm();
          checkDeviceForm.oaid = await FlutterAndroidOaidPlugin.getOAID();
          checkDeviceForm.userId = UserInfo.instance.userModel.id;
          checkDeviceForm.address = Store.instance.locationData?.address;
          checkDeviceForm.latitude = Store.instance.locationData?.latitude;
          checkDeviceForm.longitude = Store.instance.locationData?.longitude;
          checkDeviceForm.msg = "插屏广告金额超出限制${upDataADForm.toJson()}";
          checkDeviceForm.type = 2;
          Utils.debounce(() async {
            await Api.to.getVer(checkDeviceForm);
            Get.offAllNamed(AppRoutes.userError);
          }, duration: Duration(seconds: 2));
        }
      }
    } catch (e) {
      Utils.logError("上报副广失败：$e");
    }
  }

  // 定时器对象
  Timer? _timer;
  // 启动定时器
  void _startTimer() {
    Utils.logError(
      "插屏广告计时器有吗：$_timer,${Store.instance.getFkConfig.wactchTime}",
    );
    if (_timer != null) {
      return;
    }
    _timer = Timer(
      Duration(seconds: Store.instance.getFkConfig.wactchTime),
      () async {
        bool isInterReady = await InterstitialTool.to.hasInterstitialAdReady();
        Utils.logError(
          "开始展示插屏广告，$isInterReady,${Store.instance.getFkConfig.wactchTime},${Store.instance.isLimit}",
        );

        if (isInterReady) {
          if (Store.instance.isLimit) return;
          await InterstitialTool.to.showInterstitialAdFlutter();
        } else {
          Get.snackbar("提示", "插屏广告加载失败");
        }
      },
    );
  }

  // 取消定时器（可选方法，用于手动控制）
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
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
