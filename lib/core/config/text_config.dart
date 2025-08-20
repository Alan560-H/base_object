import 'dart:ui';

import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextConfig {
  // 主动激活颜色 为金黄色
  static Color primary = Utils.fromHex('#ff6d20');
  // 默认按钮颜色，没有选中得颜色
  static Color defualtBtn = Utils.fromHex("#504b44");
  // 概率颜色，紫色
  static Color prodColor = Utils.fromHex("#dda8ff");
  // 蓝色，qq弹窗用
  static Color blueColor = Utils.fromHex("#7ee6fa");
  // 黑色可以当字体颜色
  static Color black333 = Utils.fromHex("#333333");
  // 通用背景色
  static Color commonPageColor = Utils.fromHex("#f5f5f5");
  // 淡黄色背景
  static Color commonYellowPageColor = Utils.fromHex("#ffe2b4");
  static Color fensePageColor = Utils.fromHex("#f5e5e6");

  /// 模态框 或单元格颜色
  static Color dialogColor = Utils.fromHex("#806b53");
  // 灰色
  static Color grey = Utils.fromHex('#999999');

  // 灰色
  static Color inputBgcolor = Utils.fromHex('#4f4738');

  // 字体相关
  static double textSize_8 = 8.sp; //超级小提示文本
  static double textSize_10 = 10.sp; //按钮文本
  static double textSize_12 = 12.sp; //普通文本
  static double textSize_14 = 14.sp; //普通标题
  static double textSize_16 = 16.sp; //最大标题
  static double textSize_20 = 20.sp; //最大标题
  static double textSize_24 = 24.sp; //最大标题
  static double textSize_30 = 30.sp; //最大标题
  static double textSize_36 = 36.sp; //最大标题
}
