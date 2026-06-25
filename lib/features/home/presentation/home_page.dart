import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/app/providers.dart';
import 'package:base_object/services/ads/banner_tool.dart';
import 'package:base_object/services/ads/native_tool.dart';
import 'package:base_object/services/ads/rewarder_tool.dart';
import 'package:base_object/shared/config/app_ad_config.dart';
import 'package:base_object/services/device/oaid_dialog.dart';
import 'package:base_object/shared/config/text_config.dart';
import 'package:base_object/shared/widgets/cu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: TextConfig.comPageGrey,
        child: Column(
          spacing: 5.h,
          children: [
            const _HomeTopSection(),
            const _HomeNativeSlot(),
            const Expanded(child: _HomeActionSection()),
          ],
        ),
      ),
    );
  }
}

class _HomeTopSection extends ConsumerWidget {
  const _HomeTopSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final double topPad = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: topPad + 8.h,
        bottom: 4.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  home.currentIp,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed:
                    home.ipRefreshing
                        ? null
                        : () => homeNotifier.fetchCurrentIp(showLoading: true),
                icon:
                    home.ipRefreshing
                        ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black87,
                          ),
                        )
                        : Icon(
                          Icons.refresh,
                          size: 24.sp,
                          color: Colors.black87,
                        ),
                tooltip: '刷新 IP',
              ),
              if (home.appDisplayName.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 140.w),
                    child: Text(
                      home.appDisplayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(width: 8.w),
            ],
          ),
          Text(
            home.ipRefreshedAt.isEmpty
                ? '尚未刷新'
                : '刷新时间：${home.ipRefreshedAt}',
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CuButton(
                text: 'OAID',
                width: 70.w,
                height: 32.h,
                textColor: Colors.black87,
                bgColor: const Color(0xFFE8E8E8),
                radius: 6.r,
                onPressed: () => showOaidDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeNativeSlot extends ConsumerWidget {
  const _HomeNativeSlot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            message: '点击开始信息流加载广告',
          );
        }

        if (state == NativeSlotState.loading) {
          return _nativePlaceholder(height: slotHeight, message: '信息流加载中…');
        }

        if (state == NativeSlotState.failed) {
          return _nativePlaceholder(
            height: slotHeight,
            message: '暂无广告或加载失败',
          );
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

class _HomeActionSection extends ConsumerWidget {
  const _HomeActionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerTool = ref.watch(bannerToolProvider);
    final nativeTool = ref.watch(nativeToolProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final double contentWidth = NativeTool.contentWidthFromScreen(
      MediaQuery.sizeOf(context).width,
    );

    return ListenableBuilder(
      listenable: Listenable.merge([bannerTool, nativeTool]),
      builder: (context, _) {
        final bool bannerPaused = bannerTool.bannerPlaybackPaused;
        final HomeBannerSlotState bannerState = bannerTool.bannerSlotState;
        final bool bannerLoading =
            !bannerPaused && bannerState == HomeBannerSlotState.loading;
        final String bannerBtnText =
            bannerPaused
                ? '开始横幅广告'
                : bannerLoading
                ? '加载中…'
                : '停止广告';

        final bool nativePaused = nativeTool.nativePlaybackPaused;
        final NativeSlotState nativeState = nativeTool.nativeSlotState;
        final bool nativeLoading =
            !nativePaused && nativeState == NativeSlotState.loading;
        final String nativeBtnText =
            nativePaused
                ? '开始信息流'
                : nativeLoading
                ? '加载中…'
                : '停止信息流';

        final double bottomInset = bannerTool.contentBottomInset(context);

        return Column(
          children: [
            const Spacer(),
            Padding(
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
                    width: 120.w,
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
            ),
          ],
        );
      },
    );
  }
}
