import 'dart:io';

import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/app/providers.dart';
import 'package:base_object/services/ads/native_tool.dart';
import 'package:base_object/shared/config/app_ad_config.dart';
import 'package:base_object/shared/config/home_ui_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 首页信息流槽位：仅 SDK 回调确认 View 已创建后才挂载 [PlatformNativeWidget]。
class HomeNativeFeedSlot extends ConsumerWidget {
  const HomeNativeFeedSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Platform.isAndroid) {
      return _nativePlaceholder(
        height: 250.h,
        message: HomeUiStrings.nativeAndroidOnly,
      );
    }

    final nativeTool = ref.watch(nativeToolProvider);
    final double contentWidth = NativeTool.contentWidthFromScreen(
      MediaQuery.sizeOf(context).width,
    );

    return ListenableBuilder(
      listenable: nativeTool,
      builder: (context, _) {
        final bool paused = nativeTool.nativePlaybackPaused;
        final NativeSlotState state = nativeTool.nativeSlotState;
        final double slotHeight = nativeTool.adHeight;

        if (paused || state == NativeSlotState.idle) {
          return _nativePlaceholder(
            height: slotHeight,
            message: HomeUiStrings.nativeTapToLoad,
          );
        }

        if (!nativeTool.nativePlatformViewReady) {
          final String msg = switch (state) {
            NativeSlotState.loading => HomeUiStrings.nativeLoading,
            NativeSlotState.failed => HomeUiStrings.nativeFailed,
            NativeSlotState.ready => HomeUiStrings.nativeLoading,
            NativeSlotState.idle => HomeUiStrings.nativeTapToLoad,
          };
          return _nativePlaceholder(height: slotHeight, message: msg);
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SizedBox(
            height: slotHeight,
            width: contentWidth,
            child: KeyedSubtree(
              key: ValueKey<int>(nativeTool.slotGeneration),
              child: PlatformNativeWidget(
                AppAdConfig.nativePlacementID,
                nativeTool.getAdConfig(contentWidth),
                isAdaptiveHeight: true,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _nativePlaceholder({required double height, required String message}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Material(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6.r),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Center(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.sp, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
