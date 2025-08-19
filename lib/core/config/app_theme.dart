import 'package:base_object/core/config/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

mixin AppTheme {
  ThemeData get appTheme=>  ThemeData(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, // 设置 ElevatedButton 文字颜色
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black, // 设置 TextButton 文字颜色
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black, // 设置 OutlinedButton 文字颜色
      ),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(fontSize: 14.sp, color: Colors.black),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent, // 设置导航栏背景透明
      elevation: 0, // 去除导航栏的阴影
      selectedItemColor: TextConfig.primary, // 选中时的颜色
      unselectedItemColor: TextConfig.grey, // 未选中时的颜色
    ),
    scaffoldBackgroundColor: TextConfig.commonPageColor,
    appBarTheme: AppBarTheme(backgroundColor: Colors.transparent),
  );
}