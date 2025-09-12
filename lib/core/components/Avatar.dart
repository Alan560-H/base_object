import 'package:base_object/core/config/text_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 支持圆形和方形的头像组件
class Avatar extends StatelessWidget {
  final String headImage;
  final double size;
  final bool isCircle; // 新增参数：是否为圆形，默认true
  final double? borderRadius; // 新增参数：方形时的圆角半径，默认8

  const Avatar({
    super.key,
    required this.headImage,
    this.size = 40,
    this.isCircle = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // 计算实际的圆角半径，如果是圆形则忽略该值
    final double effectiveBorderRadius = isCircle
        ? size
        : (borderRadius ?? 8.r);

    return Container(
      width: size.w*2,
      height: size.h*2,
      decoration: BoxDecoration(
        color: TextConfig.primary,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        fit: BoxFit.fill, // 建议使用cover而不是fill，保持图片比例
        imageUrl: headImage,
        errorWidget: (context, url, error) => _buildErrorWidget(),
      ),
    );
  }

  // 构建错误时显示的widget
  Widget _buildErrorWidget() {
    return Container(
      color: TextConfig.grey,
      child: Icon(
        Icons.person,
        size: size / 2, // 图标大小适应头像尺寸
        color: Colors.white,
      ),
    );
  }
}
