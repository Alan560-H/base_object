import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/text_config.dart';

class CuButton extends StatelessWidget {
  final IconData? icons;
  final String? text;
  final String? iconImg;
  final VoidCallback? onPressed;
  final double? width;
  final double? maxwidth;
  final String? bgImage;
  final Color? bgColor;
  final double? height;
  final double? fontSize;
  final Color? textColor;
  final double? radius;
  final double? borderWidth;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final bool? loading;
  final bool? disable;

  const CuButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icons,
    this.width,
    this.maxwidth,
    this.iconImg,
    this.bgImage,
    this.height,
    this.fontSize,
    this.bgColor,
    this.textColor,
    this.radius,
    this.borderWidth,
    this.borderColor,
    this.padding,
    this.loading,
    this.disable,
  });

  /// 获取字体大小
  get getfontSize => fontSize ?? TextConfig.textSize_14;

  /// 获取文字颜色
  get getTextColor => textColor ?? Colors.white;

  /// 获取内边距
  get getPadding =>
      padding ?? EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h);
  get getPaddingHor{
    Utils.logError(getPadding.left+getPadding.right);
    return getPadding.left+getPadding.right;
  }
  /// 获取高度
  get getHeight => height ?? 30.h;

  /// 获取宽度
  get getWidth => width ?? 60.w;

  /// 获取宽度
  get getBgImage => bgImage ?? "";

  /// 获取圆角
  get getRadius => radius ?? 0;

  /// 获取边框颜色
  get getBorderColor => borderColor ?? Colors.transparent;

  /// 获取边框宽度
  get getBorderWidth => borderWidth ?? 0;

  /// 是否禁止使用
  get getDisable => disable ?? false;

  /// 是否启用loading
  get getLoading => loading ?? false;


  /// 获取默认text
  get getText => text ?? "";

  /// 获取默认图片
  get getIconImg => iconImg ?? "";

  BoxDecoration getBoxDecoration() {
    return BoxDecoration(
      image:
          getBgImage.isNotEmpty
              ? DecorationImage(
                image: CachedNetworkImageProvider(getBgImage),
                fit: BoxFit.fill,
              )
              : null,
      color: bgColor,
      borderRadius: BorderRadius.circular(getRadius),
      border: Border.all(color: getBorderColor, width: getBorderWidth),
    );
  }

  /// 获取前缀组件
  Widget get getPreffWidget {
    Widget res = Center();

    /// 如果loading为true 那么就是显示加载中
    if (getLoading) {
      res = SizedBox(
        width: getfontSize,
        height: getfontSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(getTextColor),
        ),
      );
    }

    ///如果有应用图标
    if (icons != null) {
      res = Icon(color: getTextColor, icons, size: getfontSize);
    }

    /// 如果是图片图标
    if (getIconImg.isNotEmpty) {
      res = CachedNetworkImage(
        fit: BoxFit.fill,
        width: getfontSize,
        height: getfontSize,
        imageUrl: getIconImg,
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    }
    return res;
  }

  // 设定背景
  @override
  Widget build(BuildContext context) {
    // 最终返回组件
    return InkWell(
      onTap: getDisable || getLoading ? null : onPressed,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 30.w,
          minHeight: 25.h,
          maxWidth: getWidth,
        ),
        width: double.infinity,
        height: getHeight,
        padding: getPadding,
        decoration: getBoxDecoration(),
        child: Row(
          spacing: 3.w,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            getPreffWidget,
            //  文字部分
            // 关键修改：使用 Flexible 包裹 Text，并设置 flex 权重
            Flexible(
              flex: 1, // 根据需要调整权重
              child: Text(
                getText,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: getfontSize, color: getTextColor,height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
