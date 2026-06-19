import 'dart:io';

import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/utils/oaid_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 弹窗展示设备 OAID（Android）；可复制。
Future<void> showOaidDialog() async {
  final String? oaid = await OaidHelper.readOaidOnce();
  final String display = oaid ??
      (Platform.isAndroid ? '未获取到 OAID' : 'iOS 无 OAID');

  await Get.dialog<void>(
    barrierDismissible: true,
    Dialog(
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
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back<void>(),
                  child: const Text('关闭'),
                ),
                SizedBox(width: 8.w),
                CuButton(
                  text: '复制',
                  width: 72.w,
                  height: 36.h,
                  disable: oaid == null,
                  textColor: Colors.black87,
                  bgColor: const Color(0xFFE8E8E8),
                  radius: 6.r,
                  onPressed: () {
                    if (oaid == null) return;
                    Clipboard.setData(ClipboardData(text: oaid));
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
    ),
  );
}
