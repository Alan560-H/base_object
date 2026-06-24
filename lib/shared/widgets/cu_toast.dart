import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

class CuToast {
  // 初始化 EasyLoading 配置
  static void initEasyLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.yellow
      ..backgroundColor = Colors.green
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.yellow
      ..toastPosition = EasyLoadingToastPosition.bottom
      ..maskColor = Colors.blue.withAlpha(128)
      ..userInteractions = true
      ..dismissOnTap = false;
  }

  // 封装通用的 toast 显示方法，并检查上下文有效性
  static void _showToast(
      String title, String msg, ToastificationType type,
      {Duration autoCloseDuration = const Duration(seconds: 3),Color? backgroundColor,Color? foregroundColor}) {

      toastification.show(
        context: Get.context,
        title: Text(title),
        style: ToastificationStyle.flat,
        type: type,
        alignment: Alignment.topCenter,
        description: Text(msg),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
        autoCloseDuration: autoCloseDuration,
        backgroundColor: backgroundColor??Colors.white,
          foregroundColor: foregroundColor??Colors.black
      );
  }

  static success({String title = "提示", String msg = "",Duration autoCloseDuration = const Duration(seconds: 3)}) {
    _showToast(title, msg, ToastificationType.success,autoCloseDuration:autoCloseDuration,backgroundColor: Colors.white);
  }

  static error({String title = "提示", String msg = "",Duration autoCloseDuration = const Duration(seconds: 3)}) {
    _showToast(title, msg, ToastificationType.error,autoCloseDuration:autoCloseDuration,);
  }

  // 通知提示，并统一参数结构
  static toast(
      BuildContext context,
      String msg, {
        EasyLoadingToastPosition toastPosition = EasyLoadingToastPosition.bottom,
      }) {
    if (context.mounted) {
      EasyLoading.instance.toastPosition = toastPosition;
      EasyLoading.showToast(msg);
    }
  }
}