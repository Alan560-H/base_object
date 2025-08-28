import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 圆形进度条组件（无需外部传入控制器）
class CuCircularProgressView extends StatelessWidget {
  // 1. 外部可配置参数（均含默认值，核心参数标记required）
  final String imagePath; // 必传中间图片路径（本地资源）
  final double size; // 进度条整体大小（默认200）
  final double strokeWidth; // 进度条线条宽度（默认8）
  final Color progressColor; // 进度条前景色（默认蓝色）
  final Color backgroundColor; // 进度条背景色（默认浅灰）

  // 构造函数：初始化内置控制器 + 配置参数
  const CuCircularProgressView({
    super.key,
    required this.imagePath,
    this.size = 200.0,
    this.strokeWidth = 8.0,
    this.progressColor = Colors.blue,
    this.backgroundColor = Colors.yellowAccent,
  })  : assert(size > 0, "进度条大小必须大于0"),
        assert(strokeWidth > 0 && strokeWidth < size / 2, "进度条宽度需在0~${size/2}之间");


  @override
  Widget build(BuildContext context) {
    // 响应式监听进度变化，自动刷新UI
    return Obx(
          () => InkWell(
            onTap: (){
              Dialogs.ClaimAdDialogs(data:CuCircularProgressController.to.currentValue);
            },
            child: Stack(
                    alignment: Alignment.center,
                    children: [
            // 1. 圆形进度条（系统组件，基于内置控制器的百分比渲染）
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: CuCircularProgressController.to.progressPercentage,
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                backgroundColor: backgroundColor,
                strokeCap: StrokeCap.round, // 进度条端点圆角，优化视觉
              ),
            ),

            // 2. 中间圆形图片（优化尺寸计算，避免紧贴进度条）
            _buildCenterImage(),
                    ],
                  ),
          ),
    );
  }

  /// 构建中间圆形图片（处理加载中/失败状态）
  Widget _buildCenterImage() {
    // 图片尺寸：整体大小 - 2倍进度条宽度 - 16内边距（避免紧贴进度条）

    return ClipOval(
      child: Container(
        color: backgroundColor,
        width: size,
        height: size,
        child: CachedNetworkImage(imageUrl: imagePath)
      ),
    );
  }

}