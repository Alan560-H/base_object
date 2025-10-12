import 'dart:async';
import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/pages/home/home_group_chat.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// 1. 改为 StatefulWidget（需要管理倒计时状态）
class ClaimAdDialog extends StatefulWidget {
  final RxDouble data;

  /// 回调
  final void Function(dynamic callBackData)? onClick;

  /// 领取存钱罐
  const ClaimAdDialog({super.key, required this.onClick, required this.data});

  @override
  State<ClaimAdDialog> createState() => _ClaimAdDialogState();
}

class _ClaimAdDialogState extends State<ClaimAdDialog> {
  /// 领取存钱罐奖励
  Future<void> checkClaim() async {
    try {
      if (widget.data.value <= Store.instance.getFkConfig.amountMin) {
        EasyLoading.showInfo("金额太少，请耐心等待");
        return;
      }
      EasyLoading.show(status: "正在领取中...");

      BackModel backModel = await Api.to.getAdAmount();
      Utils.logError("领取存钱罐奖励返回数据：${backModel.toJson()}");
      if (backModel.code == CuErrorConfig.success) {
        CuToast.success(msg: "存钱罐领取成功");
        UserInfo.instance.getUserInfoFn();
        Store.instance.setIsOpenClaim(false);
        CuCircularProgressController.to.resetProgressTimer();
        Get.back();
      }
    } catch (e) {
      Utils.logError("领取存钱罐失败$e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.sp)),
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(ImageConfig.redBagBg),
              ),
            ),
            height: 350.h,
            width: 300.w,
            child: Stack(
              children: [
                SizedBox(
                  width: Get.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 100.h),
                      // 监听data变化（原代码保留，加widget.前缀）
                      Obx(
                        () => Text(
                          widget.data.value.toString(),
                          style: TextStyle(
                            fontSize: TextConfig.textSize_36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "今日已领取${Store.instance.getCurrentCount.dayMaxCount}/${Store.instance.getFkConfig.dayMax}",
                        style: TextStyle(
                          fontSize: TextConfig.textSize_20,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "温馨提示：建议累计到2000以上再领取哦",
                        style: TextStyle(
                          fontSize: TextConfig.textSize_12,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // 6. 核心：倒计时按钮（Obx监听倒计时状态）
                      CuButton(
                        text: "立即领取",
                        width: 120.w,
                        height: 40.h,
                        radius: 10.r,
                        textColor: Colors.white,
                        bgColor: TextConfig.primary,
                        onPressed: () => Utils.debounce(checkClaim),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0.h,
                  right: 0.w,
                  child: CuButton(
                    text: "",
                    icons: Icons.close,
                    fontSize: TextConfig.textSize_24,
                    onPressed: () {
                      HomeGroupChat.to.removeAdContainer();
                      HomeGroupChat.to.startTimer();
                      Get.back();
                    },
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
