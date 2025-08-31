import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// 尝试直接用Get.dialog显示
class NoteDialog extends GetView{
  const NoteDialog({super.key});

  @override
  Widget build(BuildContext context){
    return Dialog(
      // 1. 去除屏幕边缘的默认外边距（margin）
      insetPadding: EdgeInsets.zero, // 关键：消除Dialog与屏幕边缘的间距
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Container(
        color: Colors.red,
        constraints: BoxConstraints(
          maxHeight: Get.height*0.7,
          maxWidth: Get.width
        ),
        child: Column(
          children: [
            Text("这是导航框")
          ],
        ),
      ),
    );
  }
}