import 'package:base_object/app/providers.dart';
import 'package:base_object/services/ads/banner_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 首页底部横幅广告占位条（由 [AppShell] 在 Tab 壳层展示）。
class HomeBannerSlot extends ConsumerWidget {
  const HomeBannerSlot({super.key, required this.bannerWidth});

  final double bannerWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerTool = ref.watch(bannerToolProvider);
    final double h = bannerWidth * 50 / 320;

    return ListenableBuilder(
      listenable: bannerTool,
      builder: (context, _) {
        if (bannerTool.bannerPlaybackPaused) {
          return Material(
            color: Colors.grey.shade300,
            child: SizedBox(
              width: double.infinity,
              height: h,
              child: Center(
                child: Text(
                  '点击开始横幅加载广告',
                  style: TextStyle(fontSize: 11.sp, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        final HomeBannerSlotState state = bannerTool.bannerSlotState;
        final String msg = switch (state) {
          HomeBannerSlotState.idle => '等待横幅加载…',
          HomeBannerSlotState.loading => '横幅加载中…',
          HomeBannerSlotState.failed => '暂无广告或加载失败',
          HomeBannerSlotState.ready => '',
        };
        return Material(
          color: Colors.grey.shade300,
          child: SizedBox(
            width: double.infinity,
            height: h,
            child:
                msg.isEmpty
                    ? const SizedBox.shrink()
                    : Center(
                      child: Text(
                        msg,
                        style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
          ),
        );
      },
    );
  }
}
