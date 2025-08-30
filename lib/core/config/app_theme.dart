import 'package:base_object/core/config/text_config.dart';
import 'package:flutter/material.dart';

mixin AppTheme {
  ThemeData get appTheme => ThemeData(
    // 设置全局主要颜色为黑色
    primaryColor:TextConfig.black333,
    // 配置颜色方案，将主要文本颜色设为黑色
    colorScheme: ColorScheme.light(
      primary:TextConfig.black333,
      onPrimary: Colors.white, // 主要颜色上的文本颜色
      secondary:TextConfig.black333,
      onSecondary: Colors.white, // 次要颜色上的文本颜色
      surface: Colors.white,
      onSurface:TextConfig.black333, // 表面上的文本颜色（最常用的文本颜色）
    ),

    // 按钮主题文字颜色
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor:TextConfig.black333,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor:TextConfig.black333,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor:TextConfig.black333,
      ),
    ),

    // 文本主题 - 配置所有可能的文本样式
    textTheme: TextTheme(
      // 大标题
      displayLarge: TextStyle(color:TextConfig.black333),
      displayMedium: TextStyle(color:TextConfig.black333),
      displaySmall: TextStyle(color:TextConfig.black333),

      // 标题
      headlineLarge: TextStyle(color:TextConfig.black333),
      headlineMedium: TextStyle(color:TextConfig.black333),
      headlineSmall: TextStyle(color:TextConfig.black333),

      // 副标题
      titleLarge: TextStyle(color:TextConfig.black333),
      titleMedium: TextStyle(color:TextConfig.black333),
      titleSmall: TextStyle(color:TextConfig.black333),

      // 正文
      bodyLarge: TextStyle(fontSize: TextConfig.textSize_16, color:TextConfig.black333),
      bodyMedium: TextStyle(fontSize: TextConfig.textSize_14, color:TextConfig.black333),
      bodySmall: TextStyle(fontSize: TextConfig.textSize_12, color:TextConfig.black333),

      // 标签
      labelLarge: TextStyle(color:TextConfig.black333),
      labelMedium: TextStyle(color:TextConfig.black333),
      labelSmall: TextStyle(color:TextConfig.black333),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedItemColor: TextConfig.black333,
      unselectedItemColor: TextConfig.black333,
    ),
    scaffoldBackgroundColor: TextConfig.commonPageColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      // 确保AppBar标题也是黑色
      titleTextStyle: TextStyle(
        color:TextConfig.black333,
        fontSize: TextConfig.textSize_20,
        fontWeight: FontWeight.bold,
      ),
      // 确保AppBar中的图标也是黑色
      iconTheme: IconThemeData(color: TextConfig.black333),
    ),
    // 确保图标默认也是黑色
    iconTheme: IconThemeData(color:TextConfig.black333),
  );
}
