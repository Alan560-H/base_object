import 'dart:async';
import 'dart:developer';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/manager/listener_tool.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/rewarderModel/RewarderModel.dart';
import 'package:base_object/pages/home/home_controller.dart';
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
  // 2. 倒计时状态（6秒，用RxInt方便Obx监听）
  final RxInt _countdown = 6.obs;
  // 计时器对象（用于控制倒计时，防止内存泄漏）
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // 3. 初始化倒计时：每秒减1，到0时停止
    _startCountdown();
  }

  @override
  void dispose() {
    // 4. 页面销毁时取消计时器（关键：防止内存泄漏）
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// 启动倒计时
  void _startCountdown() {
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1), // 每秒执行一次
      (timer) {
        if (_countdown.value > 0) {
          _countdown.value--; // 倒计时减1
        } else {
          timer.cancel(); // 倒计时结束，取消计时器
        }
      },
    );
  }

  // 显示激励广告（修改：调用实例方法checkClaim）
  showRewarder() async {
    if (await Store.instance.canLookReward()) {
      await RewarderTool.to.showRewardedVideo();
    } else {
      checkClaim();
    }
  }

  // 5. 改为实例方法（原static去掉，避免无法访问State内属性）
  Future<void> checkClaim() async {
    if (Get.isRegistered<Api>()) {
      BackModel backModel = await Api.to.getAdAmount();
      Utils.logError("领取存钱罐奖励返回数据：${backModel.toJson()}");
      if (backModel.code == CuErrorConfig.success) {
        CuToast.success(msg: "存钱罐领取成功");
        UserInfo.instance.getUserInfoFn();
        Store.instance.setIsOpenClaim(false);

        Utils.logError(
          "是否有进度条${Get.isRegistered<CuCircularProgressController>()}",
        );
        if (Get.isRegistered<CuCircularProgressController>()) {
          CuCircularProgressController.to.resetProgressTimer();
          NativeTool.to.removeNativeAd();
          NativeTool.to.loadNativeWith();
          Get.back();
        }
      }
    }
  }

  // 激励广告奖励提交方法（修改：用Get.find获取控制器，而非new）
  upDataADFn(dynamic event) async {
    try {
      checkClaim();
      if (Get.isRegistered<HomeController>()) {
        // 规范：用Get.find获取已注册的控制器，避免重复创建
        Get.find<HomeController>().upDataADFn(event);
      }
    } catch (e) {
      Utils.logError("领取激励视频奖励失败：$e");
    } finally {
      checkClaim();
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
          SizedBox(height: 260.h),
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
                      SizedBox(height: 30.h),
                      Text(
                        "温馨提示：建议累计到2000以上再领取哦",
                        style: TextStyle(
                          fontSize: TextConfig.textSize_12,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // 6. 核心：倒计时按钮（Obx监听倒计时状态）
                      Obx(
                        () => CuButton(
                          // 按钮文字：倒计时中显示“立即领取(6s)”，结束后显示“立即领取”
                          text:
                              _countdown.value > 0
                                  ? "${_countdown.value}秒后可以领取"
                                  : "立即领取",
                          width: 120.w,
                          height: 40.h,
                          radius: 10.r,
                          textColor:
                              _countdown.value > 0
                                  ? TextConfig.primary
                                  : Colors.white,
                          // 按钮颜色：倒计时中灰色（禁用），结束后用原主题色
                          bgColor:
                              _countdown.value > 0
                                  ? Colors.white
                                  : TextConfig.primary,
                          // 关键：倒计时未结束时，onPressed为null（禁用点击）
                          onPressed:
                              _countdown.value == 0
                                  ? () async {
                                    // 原点击逻辑保留（加widget.前缀）
                                    if (widget.data.value >=
                                        Store.instance.getFkConfig.amountMin) {
                                      showRewarder();
                                    } else {
                                      EasyLoading.showInfo("金额太少，请耐心等待");
                                    }
                                  }
                                  : null,
                        ),
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
                      NativeTool.to.removeNativeAd();
                      NativeTool.to.loadNativeWith();
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
