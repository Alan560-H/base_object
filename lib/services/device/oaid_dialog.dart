import 'dart:io';

import 'package:base_object/shared/config/cu_global.dart';
import 'package:base_object/shared/widgets/cu_button.dart';
import 'package:base_object/shared/widgets/cu_toast.dart';
import 'package:base_object/services/device/oaid_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 弹窗展示设备 OAID（Android）；可复制。
Future<void> showOaidDialog([BuildContext? context]) async {
  final BuildContext? ctx = context ?? CuGlobal.navigatorKey.currentContext;
  if (ctx == null || !ctx.mounted) return;

  EasyLoading.show(status: '正在读取 OAID…', maskType: EasyLoadingMaskType.clear);
  final String display = await OaidHelper.readOaidForDisplay();
  EasyLoading.dismiss();

  if (!ctx.mounted) return;

  final bool canCopy =
      display != '未获取到 OAID' &&
      display != 'OAID 获取失败' &&
      display != 'iOS 无 OAID';

  await showDialog<void>(
    context: ctx,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('设备 OAID', style: TextStyle(fontSize: 18.sp)),
              SizedBox(height: 12.h),
              SelectableText(
                display,
                style: TextStyle(fontSize: 14.sp, height: 1.35),
              ),
              if (!Platform.isAndroid)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    '当前平台无 OAID',
                    style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                  ),
                ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('关闭'),
                  ),
                  SizedBox(width: 8.w),
                  CuButton(
                    text: '复制',
                    width: 72.w,
                    height: 36.h,
                    disable: !canCopy,
                    textColor: Colors.black87,
                    bgColor: const Color(0xFFE8E8E8),
                    radius: 6.r,
                    onPressed: () {
                      if (!canCopy) return;
                      Clipboard.setData(ClipboardData(text: display));
                      CuToast.success(
                        msg: '已复制到剪贴板',
                        autoCloseDuration: const Duration(seconds: 2),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
