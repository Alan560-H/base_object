import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/models/backModel/rewarderModel/RewarderModel.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
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
  // 启动普通消息定时器（3秒/条）
  void startAutoSetProgressTimer() {
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
  // /// 增加存钱罐余额
  // void addCurrentValue(int value) {
  //   setCurrentValue(currentValue.value += value);
  // }
  /// 设定存钱罐余额
  // void setCurrentValue(double value) {
  //   currentValue.value = value;
  //   // LocalStorage.setString("currentValue", value.toString());
  // }
  void showDialog() async {
    try {
      // onTap: ()async{getSelectAdV3
      //
      // },
      if(!Get.isRegistered<Api>()){
        Get.put(Api());
      }
      RewarderModel rewarderModel = await Get.find<Api>().getSelectAdV3();
      currentValue.value = rewarderModel.amount;
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
    maxProgress = (_seconds*100).toDouble();
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