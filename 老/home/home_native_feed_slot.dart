import 'dart:io';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 首页中部：Taku 原生信息流（PlatformView），与 [NativeTool] 启停联动
class HomeNativeFeedSlot extends StatelessWidget {
  const HomeNativeFeedSlot({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Text(
            '信息流广告当前仅支持 Android',
            style: TextStyle(fontSize: 13.sp, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final NativeTool native = NativeTool.to;
    return Obx(() {
      if (native.nativeFeedPlaybackPaused.value) {
        return _placeholder(
          '点击开始信息流加载广告',
          minH: native.adHeight + 16.h,
        );
      }
      if (native.isViewCreated.value) {
        return SizedBox(
          key: ValueKey<int>(native.nativeFeedPlatformGeneration.value),
          height: native.adHeight + 16.h,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: PlatformNativeWidget(
              AppAdConfig.nativePlacementID,
              native.getAdConfig(),
              sceneID: AppAdConfig.nativeSceneID,
              isAdaptiveHeight: true,
            ),
          ),
        );
      }
      switch (native.nativeSlotState.value) {
        case HomeNativeSlotState.idle:
          return _placeholder('点击开始信息流加载广告', minH: native.adHeight + 16.h);
        case HomeNativeSlotState.loading:
          return _placeholder('信息流加载中…', minH: native.adHeight + 16.h);
        case HomeNativeSlotState.failed:
          return _placeholder('暂无广告或加载失败', minH: native.adHeight + 16.h);
        case HomeNativeSlotState.ready:
          return _placeholder('等待信息流展示…', minH: native.adHeight + 16.h);
      }
    });
  }

  Widget _placeholder(String text, {required double minH}) {
    return Material(
      color: Colors.grey.shade300,
      child: SizedBox(
        width: double.infinity,
        height: minH,
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 11.sp, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
