import 'package:base_object/app/providers.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 首页广告收益列表（最新在上，高度由外层约束，不超过 400.h）。
class HomeAdRevenueListSection extends ConsumerWidget {
  const HomeAdRevenueListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adStatsProvider);
    final List<AdInfo> list = stats.adInfos;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 6.h),
            child: Text(
              '收益列表',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      '暂无记录',
                      style: TextStyle(fontSize: 13.sp, color: Colors.black45),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final AdInfo item = list[i];
                      final String typeLabel =
                          AdInfo.displayTypeLabel(item.adType);
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '类型：$typeLabel',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '预估收益（元）：${AdInfo.formatDisplayRevenue(item.publisherRevenue)}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              '生成时间：${item.createdTime}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
