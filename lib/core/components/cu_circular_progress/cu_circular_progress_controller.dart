import 'package:get/get.dart';

class CuCircularProgressController extends GetxController {
  // 进度值，使用RxDouble使其具有响应性
  final RxDouble _progress = 0.0.obs;

  // 最大进度值，固定写死
  final double maxProgress = 100.0;

  // 获取当前进度
  double get progress => _progress.value;

  // 设置进度
  void setProgress(double value) {
    // 确保进度不超过最大值，也不小于0
    if (value >= 0 && value <= maxProgress) {
      _progress.value = value;
    } else if (value > maxProgress) {
      _progress.value = maxProgress;
    } else {
      _progress.value = 0;
    }
  }

  // 增加进度
  void incrementProgress(double value) {
    setProgress(_progress.value + value);
  }

  // 重置进度
  void resetProgress() {
    _progress.value = 0;
  }

  // 获取进度百分比（用于绘制进度条）
  double get progressPercentage => _progress.value / maxProgress;
}
