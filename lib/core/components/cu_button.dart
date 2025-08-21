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

  /// 获取内边距（关键修改：宽度小时减小水平内边距，避免挤压内容）
  get getPadding {
    // 若设定了宽度且宽度较小（如≤40.w），减小水平内边距，避免内容被内边距挤压
    if (width != null && width! <= 40.w) {
      return padding ?? EdgeInsets.symmetric(horizontal: 2.w, vertical: 5.h);
    }
    return padding ?? EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h);
  }
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

  /// 获取前缀组件（关键修改：限制前缀最大宽度，避免占用过多空间）
  Widget get getPreffWidget {
    Widget res = const SizedBox.shrink(); // 空组件用SizedBox.shrink()，比Center()更节省空间

    /// 如果loading为true 显示加载中（限制最大宽度）
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

    /// 如果有图标（限制最大宽度）
    else if (icons != null) {
      res = Icon(
        icons,
        color: getTextColor,
        size: getfontSize,
      );
    }

    /// 如果是图片图标（限制最大宽度）
    else if (getIconImg.isNotEmpty) {
      res = CachedNetworkImage(
        fit: BoxFit.fill,
        width: getfontSize,
        height: getfontSize,
        imageUrl: getIconImg,
        errorWidget: (context, url, error) => Icon(Icons.error, size: getfontSize),
      );
    }

    // 关键：给前缀组件加最大宽度限制，避免宽度超标（尤其小宽度场景）
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: getWidth * 0.3), // 前缀最大占按钮宽度的30%
      child: res,
    );
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
        child: IntrinsicWidth(
          child: Row(
            spacing: 2.w,
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
      ),
    );
  }
}
