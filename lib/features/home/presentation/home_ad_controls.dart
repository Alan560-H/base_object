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

/// 首页广告操作区：横幅 / 激励 / 信息流（可见性见 [HomeUiStrings] 开关）。
class HomeAdControls extends ConsumerWidget {
  const HomeAdControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerTool = ref.watch(bannerToolProvider);
    final native = ref.watch(nativeToolProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final double bottomInset = bannerTool.contentBottomInset(context);

    final listenables = <Listenable>[bannerTool];
    if (HomeUiStrings.showHomeNativeFeedUi) {
      listenables.add(native);
    }

    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
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

        final bool nativePaused = native.nativeFeedPlaybackPaused;
        final HomeNativeSlotState nativeState = native.nativeSlotState;
        final bool nativeLoading =
            !nativePaused && nativeState == HomeNativeSlotState.loading;
        final String nativeBtnText = nativePaused
            ? HomeUiStrings.startNativeFeed
            : nativeLoading
                ? HomeUiStrings.loadingEllipsis
                : HomeUiStrings.stopNativeFeed;

        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h + bottomInset),
          child: Row(
            children: [
              Expanded(
                child: CuButton(
                  bgColor: TextConfig.primary,
                  text: bannerBtnText,
                  height: 36.h,
                  fontSize: 12.sp,
                  disable: bannerLoading,
                  onPressed: () {
                    if (bannerPaused) {
                      homeNotifier.startBanner();
                    } else {
                      homeNotifier.pauseBanner();
                    }
                  },
                ),
              ),
              if (HomeUiStrings.showHomeRewardedVideoControl) ...[
                SizedBox(width: 8.w),
                Expanded(
                  child: CuButton(
                    bgColor: TextConfig.primary,
                    text: '观看激励视频',
                    height: 36.h,
                    fontSize: 12.sp,
                    onPressed: () => RewarderTool.to.watchRewardedVideo(),
                  ),
                ),
              ],
              if (HomeUiStrings.showHomeNativeFeedUi) ...[
                SizedBox(width: 8.w),
                Expanded(
                  child: CuButton(
                    bgColor: TextConfig.primary,
                    text: nativeBtnText,
                    height: 36.h,
                    fontSize: 12.sp,
                    disable: nativeLoading,
                    onPressed: () {
                      if (nativePaused) {
                        homeNotifier.startNative();
                      } else {
                        homeNotifier.pauseNative();
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
