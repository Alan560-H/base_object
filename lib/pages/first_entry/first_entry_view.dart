import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/config/app_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'first_entry_controller.dart';

class FirstEntryView extends GetView<FirstEntryController> {
  const FirstEntryView({super.key});

  /// 服务协议和隐私协议
  Widget get checkedXieyi {
    return SingleChildScrollView(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text:
                  '       请你务必审慎阅读、充分理解“服务协议”和“隐私政策”各条款，包括但不限于：为了更好的向你提供服务，我们需要收集你的设备标识、操作日志等信息用于分析、优化应用性能。',
              style: TextStyle(color: TextConfig.black333),
            ),
            TextSpan(
              text: '《服务协议》',
              style: TextStyle(color: TextConfig.primary),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () {
                      Utils.openUrl(AppConfig.instance.protocolUri);
                    },
            ),
            TextSpan(text: ' 和 ', style: TextStyle(color: TextConfig.black333)),
            TextSpan(
              text: '《隐私政策》',
              style: TextStyle(color: TextConfig.primary),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () {
                      Utils.openUrl(AppConfig.instance.policyUri);
                    },
            ),
            TextSpan(
              text: '了解详细信息。如果你同意，请点击下面按钮开始接受我们的服务',
              style: TextStyle(color: TextConfig.black333),
            ),
            TextSpan(
              text: '点击同意按钮，代表你已同意前述协议及以下约定。',
              style: TextStyle(color: TextConfig.black333),
            ),

            TextSpan(
              text:
                  '1，为保障您能正常使用我们的 APP 服务，以及提升您的使用体验和保障账户安全，在您使用 APP 过程中，我们可能会收集您的相关手机设备信息，包括IMEI、IMSI、设备MAC地址、软件安装列表、位置、日志信息等 。这些信息将用于识别设备、进行广告推荐以及安全风控，确保服务稳定、安全运行。',
              style: TextStyle(color: TextConfig.black333),
            ),
            TextSpan(
              text:
                  '2，在仅浏览时，我们可能会手机设备信息，如网络设备硬件地址，日志信息，用于识别设备，进行消息推送和安全风控。并申请存储权限，用于更新软件应用',
              style: TextStyle(color: TextConfig.black333),
            ),
            TextSpan(
              text:
                  '3，我们承诺严格遵守相关法律法规，对您的个人信息进行妥善保护，不会将您的信息用于上述目的之外的其他用途，也不会在未经您同意的情况下与第三方共享您的个人信息。',
              style: TextStyle(color: TextConfig.black333),
            ),
            TextSpan(
              text:
                  '4，为实现信息分享，参加相关活动，综合统计分析等目的所必须，我们可能会调用剪切板并使用与功能相关的最小必要信息（口令，链接，统计参数等）',
              style: TextStyle(color: TextConfig.black333),
            ),
          ],
        ),
      ),
    );
  }

  get logoAndBanner {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 30.h),
      constraints: BoxConstraints(maxHeight: 380.h, maxWidth: Get.width),
      alignment: Alignment.topCenter,
      child: CachedNetworkImage(imageUrl: ImageConfig.logo, height: 150.h),
    );
  }

  Widget get splachView {
    return SizedBox(
      width: Get.width,
      height: Get.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CachedNetworkImage(imageUrl: ImageConfig.firstTitle),
          CachedNetworkImage(imageUrl: ImageConfig.firstBotton),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () =>
            controller.loading.value
                ? splachView
                : Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(top: 0, child: logoAndBanner),
                    Positioned(
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 30.w),
                          constraints: BoxConstraints(
                            maxWidth: Utils.getScreenWidth(context),
                            maxHeight: 380.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                          padding: EdgeInsets.all(20.sp),

                          child: Column(
                            spacing: 10.h,
                            children: [
                              Text(
                                "服务协议和隐私政策",
                                style: TextStyle(
                                  fontSize: TextConfig.textSize_20,
                                  color: TextConfig.black333,
                                ),
                              ),
                              Expanded(child: checkedXieyi),
                              CuButton(
                                width: 1.sw,
                                height: 40.h,
                                bgColor: TextConfig.primary,
                                radius: 5.sp,
                                fontSize: TextConfig.textSize_16,
                                text: "同意并接受",
                                onPressed: controller.goHome,
                              ),
                              CuButton(
                                width: 1.sw,
                                textColor: TextConfig.black333,
                                fontSize: TextConfig.textSize_16,
                                text: "退出应用",
                                onPressed: () async {
                                  SystemNavigator.pop();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
