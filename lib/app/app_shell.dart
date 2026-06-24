import 'package:base_object/features/home/presentation/home_banner_slot.dart';
import 'package:base_object/services/ads/native_tool.dart';
import 'package:base_object/shared/widgets/cu_nav_bar/cu_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 主 Tab 壳层：统一底栏 + 首页横幅占位。
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTabTap(int index) {
    NativeTool.to.removeNativeAd();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isHome = navigationShell.currentIndex == 0;
    final double screenW = MediaQuery.sizeOf(context).width;
    final double bottomViewPadding = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHome) HomeBannerSlot(bannerWidth: screenW),
          CuNavBar(
            currentIndex: navigationShell.currentIndex,
            onTap: _onTabTap,
          ),
          SizedBox(height: bottomViewPadding),
        ],
      ),
    );
  }
}
