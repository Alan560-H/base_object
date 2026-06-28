import 'package:base_object/app/providers.dart';
import 'package:base_object/services/ads/native_tool.dart';
import 'package:base_object/shared/widgets/cu_nav_bar/cu_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
/// 主 Tab 壳层：统一底栏。
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTabTap(int index) {
    // 方案 A：仅离开首页时暂停信息流
    if (navigationShell.currentIndex == 0 && index != 0) {
      NativeTool.to.pauseNativeFeedPlayback();
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerTool = ref.watch(bannerToolProvider);
    final double bottomViewPadding = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ListenableBuilder(
        listenable: bannerTool,
        builder: (context, _) {
          final double bannerLift = bannerTool.bannerPlaybackPaused
              ? 0
              : bannerTool.bannerBottomLiftHeight(context);

          // 横幅 SDK 固定在屏幕最底；占位须在 Tab 栏下方，否则仍会遮挡「首页/我的」。
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CuNavBar(
                currentIndex: navigationShell.currentIndex,
                onTap: _onTabTap,
              ),
              if (bannerLift > 0) SizedBox(height: bannerLift),
              SizedBox(height: bottomViewPadding),
            ],
          );
        },
      ),
    );
  }
}
