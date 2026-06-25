import 'package:base_object/app/providers.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 激励/横幅 总计与今日 四行统计。
class AdStatsSummary extends ConsumerWidget {
  const AdStatsSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adStatsProvider);
    final TextStyle lineStyle = TextStyle(
      fontSize: 13.sp,
      color: Colors.black87,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '激励（总计）：${stats.rewardedAdCount}次，约${stats.rewardedRevenueTotalDisplayCny.toStringAsFixed(AdInfo.displayRevenueFractionDigits)}元',
            style: lineStyle,
          ),
          Text(
            '横幅（总计）：${stats.bannerAdCount}次，约${stats.bannerRevenueTotalDisplayCny.toStringAsFixed(AdInfo.displayRevenueFractionDigits)}元',
            style: lineStyle,
          ),
          Text(
            '激励（今日）：${stats.rewardedCountToday}次，约${stats.rewardedRevenueTodayDisplayCny.toStringAsFixed(AdInfo.displayRevenueFractionDigits)}元',
            style: lineStyle,
          ),
          Text(
            '横幅（今日）：${stats.bannerCountToday}次，约${stats.bannerRevenueTodayDisplayCny.toStringAsFixed(AdInfo.displayRevenueFractionDigits)}元',
            style: lineStyle,
          ),
        ],
      ),
    );
  }
}
