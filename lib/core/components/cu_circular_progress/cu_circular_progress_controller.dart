import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/listener_tool.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/models/backModel/rewarderModel/RewarderModel.dart';
import 'package:base_object/pages/home/home_controller.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 内置控制器：管理进度状态（对外隐藏实现，仅暴露操作方法）
class CuCircularProgressController extends GetxController {
  // GetX单例获取方式
  static CuCircularProgressController get to => Get.find<CuCircularProgressController>();
  // 进度值（响应式）
  final RxDouble _progress = 0.0.obs;
  int _seconds = 65;
  // 最大进度值（固定100，与原逻辑一致）
   double maxProgress = 6000.0;
  final RxDouble currentValue = (0.0).obs;
  Timer? setStepTimer;
  void resetProgressTimer(){
    setStepTimer?.cancel();
    setStepTimer = null;
    startAutoSetProgressTimer();
  }
  // 启动发财树进度条
  void startAutoSetProgressTimer() {
    Utils.logError("开始倒计时");
    setStepTimer = Timer.periodic(
      const Duration(seconds: 1),
          (Timer timer){
        if(_progress.value<maxProgress&&_seconds>0){
          _progress.value += 100;
          _seconds--;
        }else{
          Utils.logError("进度条满了");
          setStepTimer?.cancel();
        }
          }
    );
  }
  // 获取当前进度（只读）
  double get progress => _progress.value;
  // 获取进度百分比（用于绘制进度条）
  double get progressPercentage => _progress.value / maxProgress;

  /// 设置进度（限制在0~maxProgress范围内）
  void setProgress(double value) {
    _progress.value = value.clamp(0.0, maxProgress);
  }
  /// 增加进度（对外核心操作方法）
  void incrementProgress(double step) {
    if (step <= 0) return; // 步长不能为负
    setProgress(_progress.value + step);
  }
  /// 重置进度到0
  void resetProgress() {
    _progress.value = 0.0;
  }
  void showDialog() async {
    try {
      if(!UserInfo.instance.isLoginIn){
        Get.toNamed(AppRoutes.login);
        return;
      }
      if(!Get.isRegistered<Api>()){
        Get.put(Api());
      }

      if(Get.isRegistered<NativeTool>()){
        NativeTool.to.showNative();
      }
      RewarderModel rewarderModel = await Get.find<Api>().getSelectAdV3();
      currentValue.value = rewarderModel.amount;
      Store.instance.setIsOpenClaim(true);
      Utils.logError("打开的值:${Store.instance.getIsOpenClaim}");
      Dialogs.ClaimAdDialogs(data:CuCircularProgressController.to.currentValue);

      Utils.logError("存钱罐初始化余额: ${currentValue.value}");
    } catch (e) {
      Utils.logError("存钱罐初始化余额失败: $e");
      currentValue.value = 0; // 出错时设为默认值，避免后续异常
    }
  }

  @override
  void onInit() {
    // initCurrentValue();
    _seconds = Store.instance.getFkConfig.adv1Time;
    if(_seconds== 0){
      _seconds = 60;
      maxProgress = 6000.0;
    }else{
      maxProgress = (_seconds*100).toDouble();
      if(!Get.isRegistered<NativeTool>()){
        Get.put(NativeTool());
      }
      NativeTool.to.loadNativeWith();

    }

    startAutoSetProgressTimer();
    // TODO: implement onInit
    super.onInit();
  }
  @override
  void onClose() {
    // TODO: implement onClose
    setStepTimer?.cancel();
    super.onClose();
  }
}