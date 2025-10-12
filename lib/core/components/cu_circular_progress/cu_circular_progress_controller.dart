import 'dart:async';
import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/models/backModel/rewarderModel/RewarderModel.dart';
import 'package:base_object/pages/home/home_group_chat.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

/// 内置控制器：管理进度状态（对外隐藏实现，仅暴露操作方法）
class CuCircularProgressController extends GetxService {
  // GetX单例获取方式
  static CuCircularProgressController get to =>
      Get.isRegistered<CuCircularProgressController>()
          ? Get.find<CuCircularProgressController>()
          : Get.put(CuCircularProgressController());
  // 进度值（响应式）
  final RxDouble _progress = 0.0.obs;
  int _seconds = 65;
  // 最大进度值（固定100，与原逻辑一致）
  double maxProgress = 6000.0;
  final RxDouble currentValue = (0.0).obs;
  Timer? setStepTimer;
  void resetProgressTimer() {
    Utils.logError("触发了重置方法");
    setStepTimer?.cancel();
    setStepTimer = null;
    _seconds = Store.instance.getFkConfig.adv1Time;
    resetProgress();
    startAutoSetProgressTimer();
  }

  RxBool timeEnd = false.obs; // 倒计时是否结束
  // 启动发财树进度条
  void startAutoSetProgressTimer() {
    Utils.logError("启动发财树进度条$setStepTimer $_seconds");
    if (setStepTimer != null) return;
    setStepTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_progress.value < maxProgress && _seconds > 0) {
        _progress.value += 100;
        _seconds--;
        timeEnd.value = false;
      } else {
        timeEnd.value = true;
        timer.cancel();
      }
    });
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

  Future<void> getCurrentValue() async {
    if (UserInfo.instance.isLoginIn) {
      RewarderModel rewarderModel = await Api.to.getSelectAdV3();
      currentValue.value = rewarderModel.amount;
    }
  }

  // 打开存钱罐
  void showDialog({isShowRedBag = true}) async {
    try {
      if (!UserInfo.instance.isLoginIn) {
        Get.toNamed(AppRoutes.login);
        return;
      }
      if (!timeEnd.value && isShowRedBag) {
        CuToast.error(msg: "奖励还未准备好");
        return;
      }
      await getCurrentValue();

      Store.instance.setIsOpenClaim(true);
      Utils.logError("打开的值:${Store.instance.getIsOpenClaim}");
      Dialogs.claimAdDialogs(
        data: CuCircularProgressController.to.currentValue,
      );
      Utils.logError("存钱罐初始化余额: ${currentValue.value}");
    } catch (e) {
      Utils.logError("存钱罐初始化余额失败: $e");
      currentValue.value = 0; // 出错时设为默认值，避免后续异常
    }
  }

  @override
  void onInit() {
    Utils.logError("初始化倒计时时间: $_seconds");
    _seconds = Store.instance.getFkConfig.adv1Time;
    if (_seconds == 0) {
      _seconds = 60;
      maxProgress = 6000.0;
    } else {
      maxProgress = (_seconds * 100).toDouble();
    }

    startAutoSetProgressTimer();
    // TODO: implement onInit
    super.onInit();
  }

  @override
  void onClose() {
    Utils.logError("关闭了");
    // TODO: implement onClose
    super.onClose();
  }
}
