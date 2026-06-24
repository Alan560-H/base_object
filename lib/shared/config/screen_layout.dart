import 'package:base_object/shared/config/cu_global.dart';
import 'package:flutter/material.dart';

/// 无 [BuildContext] 时获取屏宽逻辑像素（如广告 SDK 回调线程）。
double defaultLogicalWidth({double fallback = 375}) {
  final BuildContext? ctx = CuGlobal.navigatorKey.currentContext;
  if (ctx != null) {
    return MediaQuery.sizeOf(ctx).width;
  }
  return fallback;
}
