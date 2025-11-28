import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/components/custom_input_field.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
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
  @override
  void dispose() {
    super.dispose();
  }

  /// 构建单个签到项Widget（金币+奖励+日期）
  Widget _buildCheckInItem({
    required int day,
    required int reward,
    required bool isChecked, // 是否已签到
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      width: 55.w, // 单个签到项宽度
      decoration: BoxDecoration(
        // 已签到/未签到背景色区分
        color: isChecked ? Color(0xFFFEF0E6) : Colors.white70,
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
          Text(
            "+$reward",
            style: TextStyle(
              fontSize: 12.sp,
              color: isChecked ? Color(0xFFFFB800) : Color(0xFF999999),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          // 3. 第N天
          Text("第$day天", style: TextStyle(fontSize: 10.sp)),
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
            children: List.generate(7, (index) {
              // 生成7个签到项
              return _buildCheckInItem(
                day: index + 1, // 第N天
                reward: index * 2, // 奖励数量
                isChecked: index < 3, // 模拟已签到（前3天已签，可根据业务动态改）
              );
            }),
          ),

          CuButton(
            radius: 10.r,
            text: "签到",
            width: 100.w,
            height: 40.h,
            onPressed: () {
              CuToast.success(msg: "签到成功");
            },
            bgColor: TextConfig.primary,
          ),
        ],
      ),
    );
  }
}
