import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 内置控制器：管理进度状态（对外隐藏实现，仅暴露操作方法）
class CuCircularProgressController extends GetxController {
  // GetX单例获取方式
  static CuCircularProgressController get to => Get.find<CuCircularProgressController>();
  // 进度值（响应式）
  final RxDouble _progress = 0.0.obs;
  // 最大进度值（固定100，与原逻辑一致）
  final double maxProgress = 2000.0;

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
    Utils.logError("增加进度：$step，上一进度");
    if (step <= 0) return; // 步长不能为负
    setProgress(_progress.value + step);
  }

  /// 重置进度到0
  void resetProgress() {
    _progress.value = 0.0;
  }
}