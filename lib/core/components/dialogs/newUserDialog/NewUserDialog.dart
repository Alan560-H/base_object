import 'dart:convert';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_empty.dart';
import 'package:base_object/core/config/app_keys.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/NoticeModel/NoticeModel.dart';
import 'package:base_object/models/backModel/newUserModel/NewUserModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_html/flutter_html.dart';


class NewUserDialog extends StatefulWidget {
  /// 新人红包领取
  const NewUserDialog({super.key});
  @override
  State<NewUserDialog> createState() => _NewUserDialogState();
}

class _NewUserDialogState extends State<NewUserDialog> {
  @override
  void initState() {
    if (!Get.isRegistered<Api>()) {
      Get.put(Api());
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 关闭弹窗的方法
  void closeDialog() {

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.sp),
      ),
      backgroundColor: Colors.transparent,
      child:  Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(10.r),
            ),
            constraints: BoxConstraints(
              maxHeight: Get.height * 0.6,
              maxWidth: Get.width,
            ),
            padding: EdgeInsets.only(
              left: 10.w,
              right: 10.w,
              top: 10.h,
              bottom: 10.h,
            ),
            child: Column(
              spacing: 5.h,
              children: [
                Container(
                  width: Get.width,
                  height: 40.h,
                  decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(5.r)
                  ),
                  padding: EdgeInsets.all(5.h),
                  child: Row(
                    children: [

                      InkWell(
                        onTap: closeDialog,  // 使用统一的关闭方法
                        child: Icon(Icons.close,size: 30.w,),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
