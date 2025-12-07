import 'dart:developer';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/components/custom_input_field.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/adTaskModel/AdTaskModel.dart';
import 'package:base_object/models/backModel/signModel/SignModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CheckInDialog extends StatefulWidget {
  /// 实名认证
  const CheckInDialog({super.key});

  @override
  State<CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<CheckInDialog> {
  List<SignModel> signList = [];
  Future<void> _getCheckInList() async {
    signList = await Api.to.postSignList();
    Utils.logError("签到列表:$signList");
    setState(() {});
  }

  @override
  void initState() {
    _getCheckInList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 构建单个签到项Widget（金币+奖励+日期）
  Widget _buildCheckInItem(SignModel signModel) {
    bool isChecked = signModel.status == 2;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      width: 55.w, // 单个签到项宽度
      decoration: BoxDecoration(
        // 已签到/未签到背景色区分
        color: isChecked ? Color(0xFFFEF0E6) : Colors.white30,
        border: Border.all(
          color: isChecked ? TextConfig.primary : Color(0xFFEEEEEE),
          width: 1.w,
        ),
        borderRadius: BorderRadius.circular(8.r), // 签到项圆角
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. 金币图片（替换为你项目中的金币图标）
          CachedNetworkImage(
            imageUrl: ImageConfig.coinsIcon,
            width: 30.w,
            height: 30.h,
          ),
          SizedBox(height: 4.h),
          // 2. 奖励数量
          isChecked
              ? Text(
                "+${signModel.label}",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: TextConfig.primary,
                  fontWeight: FontWeight.w600,
                ),
              )
              : Text(
                "+${signModel.amount}",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10.h,
        children: [
          Wrap(
            // 横向间距（签到项之间的水平距离）
            spacing: 5.w,
            // 纵向间距（两行之间的垂直距离）
            runSpacing: 5.h,
            // 整体居中对齐
            alignment: WrapAlignment.center,
            children: List.generate(signList.length, (index) {
              // 生成7个签到项
              return _buildCheckInItem(signList[index]);
            }),
          ),

          CuButton(
            radius: 10.r,
            text: "签到",
            width: 100.w,
            height: 40.h,
            onPressed: () async {
              // CuToast.error(msg: "功能暂未开放");
              BackModel backModel = await Api().postCheckIn();
              Utils.logError(
                "签到返回信息：${backModel.toJson()}，${backModel.code == CuErrorConfig.success}",
              );
              if (backModel.code == CuErrorConfig.success) {
                await UserInfo.instance.getUserInfoFn();
                await _getCheckInList();
                CuToast.success(msg: backModel.msg);
              }
            },
            bgColor: TextConfig.primary,
          ),
        ],
      ),
    );
  }
}
