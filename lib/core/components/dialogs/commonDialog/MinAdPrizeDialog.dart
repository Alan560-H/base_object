import 'dart:ffi';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/components/custom_input_field.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/adTaskModel/AdTaskModel.dart';
import 'package:base_object/models/backModel/signModel/SignModel.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MinAdPrizeDialog extends StatefulWidget {
  /// 低保任务弹窗
  const MinAdPrizeDialog({super.key});

  @override
  State<MinAdPrizeDialog> createState() => _MinAdPrizeDialogState();
}

class _MinAdPrizeDialogState extends State<MinAdPrizeDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        constraints: BoxConstraints(minHeight: 150.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10.h,
          children: [
            Text(
              "低保任务一旦开始，就不能关闭此弹窗。",
              style: TextStyle(
                fontSize: TextConfig.textSize_16,
                color: Colors.white,
              ),
            ),
            if (Store.instance.isTaskStatus == 1)
              Text(
                "当前任务完成情况：（${Store.instance.adTaskModel.value.userNum}/${Store.instance.adTaskModel.value.numConfig}）",
                style: TextStyle(
                  fontSize: TextConfig.textSize_14,
                  color: Colors.white,
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10.w,
              children: [
                if (Store.instance.isOverTask)
                  CuButton(
                    radius: 10.r,
                    text: "领取奖励",
                    width: 100.w,
                    height: 40.h,
                    onPressed: () async {
                      /// 领取奖励
                      await Store.instance.postMinAdEnd();
                    },
                    bgColor: TextConfig.primary,
                  ),
                if (Store.instance.isTaskStatus == 1 &&
                    !Store.instance.isOverTask)
                  CuButton(
                    radius: 10.r,
                    text:
                        Store.instance.remainingSeconds > 0
                            ? "${Store.instance.remainingSeconds}秒可观看下一个"
                            : "观看下一个",
                    width: 140.w,
                    height: 40.h,
                    onPressed: () async {
                      /// 开始任务
                      RewarderTool.to.showRewardedVideoFlutter();
                    },
                    bgColor: TextConfig.primary,
                  ),

                if (Store.instance.isTaskStatus == 0 &&
                    !Store.instance.isOverTask)
                  CuButton(
                    radius: 10.r,
                    text: "开始任务",
                    width: 100.w,
                    height: 40.h,
                    onPressed: () async {
                      BackModel backModel = await Api().postMinAdStart();
                      Utils.logError("领取任务返回数据集: ${backModel.toJson()}");
                      if (backModel.code == CuErrorConfig.success) {
                        /// 通知任务开始
                        CuToast.success(msg: backModel.data);

                        /// 刷新任务进度
                        await Store.instance.postMinAdPrizeList();

                        /// 开始任务
                        RewarderTool.to.showRewardedVideoFlutter();
                      }
                    },
                    bgColor: TextConfig.primary,
                  ),
                CuButton(
                  radius: 10.r,
                  text: "关闭弹窗",
                  width: 100.w,
                  height: 40.h,
                  onPressed: () async {
                    if (Store.instance.isTaskStatus == 0) {
                      Get.back();
                    } else {
                      CuToast.error(msg: "任务尚未结束，不能关闭弹窗");
                    }
                  },
                  bgColor: TextConfig.fensePageColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
