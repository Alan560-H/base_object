import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/app_keys.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
                      Text(
                        "今日已提高奖励${Store.instance.getCurrentCount.dayMaxCount}/${Store.instance.getFkConfig.dayMax}次",
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
                      Obx(() {
                        return Store.instance.isTimeOver
                            ? CuButton(
                              text: "${Store.instance.remainingSeconds}秒后可提升奖励",
                              width: 200.w,
                              height: 40.h,
                              radius: 10.r,
                              textColor: TextConfig.primary,
                              bgColor: TextConfig.comPageGrey,
                              onPressed: () => {},
                            )
                            : CuButton(
                              text: "",
                              width: 120.w,
                              height: 40.h,
                              radius: 10.r,
                              bgImage: ImageConfig.upClaim,
                              onPressed:
                                  () => Utils.debounce(() async {
                                    Store.instance.setIsClaim(false);
                                    Get.back();
                                    RewarderTool.to.showRewardedVideoFlutter();
                                  }),
                            );
                      }),

                      SizedBox(height: 10.h),
                      // 6. 核心：倒计时按钮（Obx监听倒计时状态）
                      CuButton(
                        text: "立即领取",
                        width: 120.w,
                        height: 40.h,
                        radius: 10.r,
                        textColor: Colors.white,
                        bgColor: TextConfig.primary,
                        onPressed:
                            () => Utils.debounce(() async {
                              if (widget.data.value <=
                                  Store.instance.getFkConfig.amountMin) {
                                CuToast.error(msg: "金额太少，请耐心等待");
                                return;
                              }
                              await RewarderTool.to.checkClaim();
                              bool isOk = Store.instance.isTimeOver;
                              if (isOk) {
                                return;
                              } else {
                                Store.instance.setIsClaim(true);
                                RewarderTool.to.showRewardedVideoFlutter();
                              }
                            }),
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
