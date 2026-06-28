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

class HomeAdControls extends ConsumerWidget {
  const HomeAdControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerTool = ref.watch(bannerToolProvider);
    final native = ref.watch(nativeToolProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final double bottomInset = bannerTool.contentBottomInset(context);

    return ListenableBuilder(
      listenable: Listenable.merge([
        bannerTool,
        native,
        native.reloadCountdownListenable,
      ]),
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
        final int? reloadCd = native.nativeFeedAutoReloadCountdown;
        final String nativeBtnText = nativePaused
            ? HomeUiStrings.startNativeFeed
            : nativeLoading
                ? HomeUiStrings.loadingEllipsis
                : (reloadCd != null && reloadCd > 0)
                    ? '${HomeUiStrings.stopNativeFeed}（$reloadCd）'
                    : HomeUiStrings.stopNativeFeed;

        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h + bottomInset),
          child: Row(
            children: [
              Expanded(
                child: CuButton(
                  bgColor: TextConfig.primary,
                  text: bannerBtnText,
                  height: 40.h,
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
              SizedBox(width: 8.w),
              Expanded(
                child: CuButton(
                  bgColor: TextConfig.primary,
                  text: '观看激励视频',
                  height: 40.h,
                  fontSize: 12.sp,
                  onPressed: () => RewarderTool.to.watchRewardedVideo(),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CuButton(
                  bgColor: TextConfig.primary,
                  text: nativeBtnText,
                  height: 40.h,
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
          ),
        );
      },
    );
  }
}
