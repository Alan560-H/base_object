import 'package:base_object/app/providers.dart';
import 'package:base_object/services/ads/banner_tool.dart';
import 'package:base_object/services/ads/native_tool.dart';
import 'package:base_object/services/ads/rewarder_tool.dart';
import 'package:base_object/shared/config/home_ui_strings.dart';
import 'package:base_object/shared/config/text_config.dart';
import 'package:base_object/shared/widgets/cu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 首页底部广告操作区：横幅、激励视频、信息流。
class HomeAdControls extends ConsumerWidget {
  const HomeAdControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerTool = ref.watch(bannerToolProvider);
    final nativeTool = ref.watch(nativeToolProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final double contentWidth = NativeTool.contentWidthFromScreen(
      MediaQuery.sizeOf(context).width,
    );
    final double bottomInset = bannerTool.contentBottomInset(context);

    return ListenableBuilder(
      listenable: Listenable.merge([bannerTool, nativeTool]),
      builder: (context, _) {
        final bool bannerPaused = bannerTool.bannerPlaybackPaused;
        final HomeBannerSlotState bannerState = bannerTool.bannerSlotState;
        final bool bannerLoading =
            !bannerPaused && bannerState == HomeBannerSlotState.loading;
        final String bannerBtnText = bannerPaused
            ? HomeUiStrings.startBannerAd
            : bannerLoading
                ? HomeUiStrings.loadingEllipsis
                : HomeUiStrings.stopBannerAd;

        final bool nativePaused = nativeTool.nativePlaybackPaused;
        final NativeSlotState nativeState = nativeTool.nativeSlotState;
        final bool nativeLoading =
            !nativePaused && nativeState == NativeSlotState.loading;
        final String nativeBtnText = _nativeButtonLabel(
          nativeTool: nativeTool,
          paused: nativePaused,
          loading: nativeLoading,
        );

        return Padding(
          padding: EdgeInsets.only(bottom: 16.h + bottomInset),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              CuButton(
                bgColor: TextConfig.primary,
                text: bannerBtnText,
                width: 120.w,
                height: 40.h,
                disable: bannerLoading,
                onPressed: () {
                  if (bannerPaused) {
                    homeNotifier.startBanner();
                  } else {
                    homeNotifier.pauseBanner();
                  }
                },
              ),
              CuButton(
                bgColor: TextConfig.primary,
                text: '观看激励视频',
                width: 140.w,
                height: 40.h,
                onPressed: () => RewarderTool.to.watchRewardedVideo(),
              ),
              CuButton(
                bgColor: TextConfig.primary,
                text: nativeBtnText,
                width: 148.w,
                height: 40.h,
                disable: nativeLoading,
                onPressed: () {
                  if (nativePaused) {
                    homeNotifier.startNative(contentWidth);
                  } else {
                    homeNotifier.pauseNative();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static String _nativeButtonLabel({
    required NativeTool nativeTool,
    required bool paused,
    required bool loading,
  }) {
    if (paused) return HomeUiStrings.startNativeFeed;
    if (loading) return HomeUiStrings.loadingEllipsis;
    if (nativeTool.nativeWaitElapsedSeconds > 0) {
      return HomeUiStrings.stopNativeFeedWaiting(
        nativeTool.nativeWaitElapsedSeconds,
      );
    }
    return HomeUiStrings.stopNativeFeed;
  }
}
