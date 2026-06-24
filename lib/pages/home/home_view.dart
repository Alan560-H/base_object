import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/models/localModels/AdInfo.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/oaid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller =
        Get.isRegistered<HomeController>()
            ? Get.find<HomeController>()
            : Get.put(HomeController());
    final double bottomViewPadding = MediaQuery.viewPaddingOf(context).bottom;
    final double screenW = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Container(
        color: TextConfig.comPageGrey,
        child: Column(
          spacing: 5.h,
          children: [
            _HomeTopSection(controller: controller),
            Expanded(child: controller.buildChatList()),
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

/// 顶部：IP、刷新、刷新时间、统计、日志按钮
class _HomeTopSection extends StatelessWidget {
  const _HomeTopSection({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
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
                child: Obx(
                  () => Text(
                    controller.currentIp.value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Obx(() {
                final bool busy = controller.ipRefreshing.value;
                return IconButton(
                  onPressed:
                      busy
                          ? null
                          : () => controller.fetchCurrentIp(showLoading: true),
                  icon:
                      busy
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
                );
              }),
              Obx(() {
                final String name = controller.appDisplayName.value;
                if (name.isEmpty) {
                  return SizedBox(width: 8.w);
                }
                return Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 140.w),
                    child: Text(
                      name,
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
                );
              }),
            ],
          ),
          Obx(
            () => Text(
              controller.ipRefreshedAt.value.isEmpty
                  ? '尚未刷新'
                  : '刷新时间：${controller.ipRefreshedAt.value}',
              style: TextStyle(fontSize: 12.sp, color: Colors.black54),
            ),
          ),
          SizedBox(height: 6.h),
          Obx(() {
            final s = Store.instance;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '激励（总计）：${s.rewardedAdCount}次，约${s.rewardedRevenueTotalDisplayCny.toStringAsFixed(AdInfo.displayRevenueFractionDigits)}元',
                  style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                ),
                Text(
                  '横幅（总计）：${s.bannerAdCount}次，约${s.bannerRevenueTotalDisplayCny.toStringAsFixed(AdInfo.displayRevenueFractionDigits)}元',
                  style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                ),
                Text(
                  '激励（今日）：${s.rewardedCountToday}次，约${s.rewardedRevenueTodayDisplayCny.toStringAsFixed(AdInfo.displayRevenueFractionDigits)}元',
                  style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                ),
                Text(
                  '横幅（今日）：${s.bannerCountToday}次，约${s.bannerRevenueTodayDisplayCny.toStringAsFixed(AdInfo.displayRevenueFractionDigits)}元',
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
            );
          }),
        ],
      ),
    );
  }
}

/// 底栏上方横幅占位（高度 320:50）
class _HomeBannerPlaceholder extends StatelessWidget {
  const _HomeBannerPlaceholder({required this.bannerWidth});

  final double bannerWidth;

  @override
  Widget build(BuildContext context) {
    final double h = bannerWidth * 50 / 320;
    return Obx(() {
      if (BannerTool.to.bannerPlaybackPaused.value) {
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
      final HomeBannerSlotState state = BannerTool.to.bannerSlotState.value;
      String msg;
      switch (state) {
        case HomeBannerSlotState.idle:
          msg = '等待横幅加载…';
          break;
        case HomeBannerSlotState.loading:
          msg = '横幅加载中…';
          break;
        case HomeBannerSlotState.failed:
          msg = '暂无广告或加载失败';
          break;
        case HomeBannerSlotState.ready:
          msg = '';
          break;
      }
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
    });
  }
}
