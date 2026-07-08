import 'dart:io';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/app/providers.dart';
import 'package:base_object/services/ads/native_tool.dart';
import 'package:base_object/shared/config/app_ad_config.dart';
import 'package:base_object/shared/config/home_ui_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 首页信息流槽位：[NativeTool.isViewCreated] 为 true 时挂载 PlatformView。
class HomeNativeFeedSlot extends ConsumerWidget {
  const HomeNativeFeedSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Platform.isAndroid) {
      return Center(
        child: Text(
          HomeUiStrings.nativeAndroidOnly,
          style: TextStyle(fontSize: 13.sp, color: Colors.black54),
        ),
      );
    }

    final native = ref.watch(nativeToolProvider);
    return ListenableBuilder(
      listenable: native,
      builder: (_, __) {
        if (native.nativeFeedPlaybackPaused) {
          return _placeholder(
            HomeUiStrings.nativeTapToLoad,
            minH: native.adHeight + 16.h,
          );
        }
        if (native.isViewCreated) {
          return SizedBox(
            key: ValueKey<int>(native.nativeFeedPlatformGeneration),
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
        switch (native.nativeSlotState) {
          case HomeNativeSlotState.idle:
            return _placeholder(
              HomeUiStrings.nativeTapToLoad,
              minH: native.adHeight + 16.h,
            );
          case HomeNativeSlotState.loading:
            return _placeholder(
              HomeUiStrings.nativeLoading,
              minH: native.adHeight + 16.h,
            );
          case HomeNativeSlotState.failed:
            return _placeholder(
              HomeUiStrings.nativeFailed,
              minH: native.adHeight + 16.h,
            );
          case HomeNativeSlotState.noFill:
            return _placeholder(
              HomeUiStrings.nativeNoFill,
              minH: native.adHeight + 16.h,
            );
          case HomeNativeSlotState.ready:
            return _placeholder(
              HomeUiStrings.nativeWaitingShow,
              minH: native.adHeight + 16.h,
            );
        }
      },
    );
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
