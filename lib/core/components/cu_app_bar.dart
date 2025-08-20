import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CuAppBar extends StatelessWidget {
  // 是否显示返回箭头
  final bool showBackArrow;
  // 标题文本
  final String title;
  // 右侧操作按钮列表
  final List<Widget>? actions;
  // 左侧返回箭头点击事件（可选）
  final VoidCallback? onBackPressed;
  // 背景颜色（可选）
  final Color? backgroundColor;
  // 标题样式（可选）
  final TextStyle? titleStyle;
  // 是否自动添加顶部安全区（刘海屏适配）
  final bool autoAddTopSafeArea;
  // 自定义顶部安全区高度（优先级高于autoAddTopSafeArea）
  final double? customTopSafeHeight;
  final Color textColor;
  const CuAppBar({
    super.key,
    this.showBackArrow = true,
    required this.title,
    this.actions,
    this.onBackPressed,
    this.backgroundColor,
    this.titleStyle,
    this.autoAddTopSafeArea = true,
    this.customTopSafeHeight,
    this.textColor = Colors.black87
  });

  @override
  Widget build(BuildContext context) {
    // 通过GetX获取顶部安全区高度
    final topSafeHeight = customTopSafeHeight ??
        (autoAddTopSafeArea ? Get.mediaQuery.padding.top : 0);

    // 计算总高度（系统工具栏高度 + 顶部安全区高度）
    final totalHeight = topSafeHeight + kToolbarHeight;

    return Container(
      height: totalHeight,
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
      ),
      color: backgroundColor ?? Colors.white,
      child: Stack(
        children: [
          // 左侧返回箭头
          if (showBackArrow)
            Positioned(
              left: 0,
              top: topSafeHeight,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: onBackPressed ?? () => Get.back(), // 使用GetX的返回方法
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 20.w,
                    color: textColor,
                  ),
                ),
              ),
            ),

          // 中间标题（始终居中）
          Positioned(
            left: 0,
            right: 0,
            top: topSafeHeight,
            bottom: 0,
            child: Center(
              child: Text(
                title,
                style: titleStyle ??
                    TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),

          // 右侧操作按钮
          if (actions != null && actions!.isNotEmpty)
            Positioned(
              right: 0,
              top: topSafeHeight,
              bottom: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }
}
