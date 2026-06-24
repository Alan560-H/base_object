import 'package:base_object/app/providers.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:base_object/features/home/presentation/home_notifier.dart';
import 'package:base_object/services/ads/banner_tool.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).init();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomViewPadding = MediaQuery.viewPaddingOf(context).bottom;
    final double screenW = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Container(
        color: TextConfig.comPageGrey,
        child: Column(
          spacing: 5.h,
          children: [
            const _HomeTopSection(),
            Expanded(child: _HomeAdListSection(scrollController: _scrollController)),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HomeBannerPlaceholder(bannerWidth: screenW),
          SizedBox(height: bottomViewPadding),
        ],
      ),
    );
  }
}

class _HomeTopSection extends ConsumerWidget {
  const _HomeTopSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);
    final stats = ref.watch(adStatsProvider);
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '激励（总计）：${stats.rewardedAdCount}次，约${stats.rewardedRevenueTotalDisplayCny.toStringAsFixed(AdInfo.displayRevenueFractionDigits)}元',
                style: TextStyle(fontSize: 13.sp, color: Colors.black87),
              ),
              Text(
                '横幅（总计）：${stats.bannerAdCount}次，约${stats.bannerRevenueTotalDisplayCny.toStringAsFixed(AdInfo.displayRevenueFractionDigits)}元',
                style: TextStyle(fontSize: 13.sp, color: Colors.black87),
              ),
              Text(
                '激励（今日）：${stats.rewardedCountToday}次，约${stats.rewardedRevenueTodayDisplayCny.toStringAsFixed(AdInfo.displayRevenueFractionDigits)}元',
                style: TextStyle(fontSize: 13.sp, color: Colors.black87),
              ),
              Text(
                '横幅（今日）：${stats.bannerCountToday}次，约${stats.bannerRevenueTodayDisplayCny.toStringAsFixed(AdInfo.displayRevenueFractionDigits)}元',
                style: TextStyle(fontSize: 13.sp, color: Colors.black87),
              ),
              SizedBox(height: 4.h),
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
                    onPressed: showOaidDialog,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeAdListSection extends ConsumerWidget {
  const _HomeAdListSection({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adStatsProvider);
    final bannerTool = ref.watch(bannerToolProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final raw = stats.adInfos;
    final list =
        raw.length <= HomeNotifier.kAdRecordDisplayMax
            ? raw
            : raw.sublist(raw.length - HomeNotifier.kAdRecordDisplayMax);
    final double listWidth = MediaQuery.sizeOf(context).width;

    return ListenableBuilder(
      listenable: bannerTool,
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

        return Column(
          spacing: 10.h,
          children: [
            Expanded(
              child: SizedBox(
                width: listWidth,
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final AdInfo item = list[i];
                    final String typeLabel =
                        item.adType == AdInfo.typeBanner ? '横幅' : '激励视频';
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.h,
                        vertical: 5.w,
                      ),
                      margin: EdgeInsets.only(bottom: 10.h),
                      width: 100.w,
                      color: Colors.white70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '类型：$typeLabel',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '预估收益（元）：${AdInfo.formatDisplayRevenue(item.publisherRevenue)}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          Text('生成时间：${item.createdTime}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Wrap(
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
              ],
            ),
          ],
        );
      },
    );
  }
}

class _HomeBannerPlaceholder extends ConsumerWidget {
  const _HomeBannerPlaceholder({required this.bannerWidth});

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
