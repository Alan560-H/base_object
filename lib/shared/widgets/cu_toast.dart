import 'package:base_object/shared/config/cu_global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:toastification/toastification.dart';

class CuToast {
  static BuildContext? get _overlayContext =>
      CuGlobal.navigatorKey.currentContext;

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

  static void _showToast(
    String title,
    String msg,
    ToastificationType type, {
    Duration autoCloseDuration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final BuildContext? ctx = _overlayContext;
    if (ctx == null || !ctx.mounted) return;

    toastification.show(
      context: ctx,
      title: Text(title),
      style: ToastificationStyle.flat,
      type: type,
      alignment: Alignment.topCenter,
      description: Text(msg),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      autoCloseDuration: autoCloseDuration,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black,
    );
  }

  static success({
    String title = '提示',
    String msg = '',
    Duration autoCloseDuration = const Duration(seconds: 3),
  }) {
    _showToast(
      title,
      msg,
      ToastificationType.success,
      autoCloseDuration: autoCloseDuration,
      backgroundColor: Colors.white,
    );
  }

  static error({
    String title = '提示',
    String msg = '',
    Duration autoCloseDuration = const Duration(seconds: 3),
  }) {
    _showToast(
      title,
      msg,
      ToastificationType.error,
      autoCloseDuration: autoCloseDuration,
    );
  }

  static void toast(
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
