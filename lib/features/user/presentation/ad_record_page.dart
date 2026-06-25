import 'package:base_object/app/providers.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 收益记录二级页：展示全部广告记录（最新在上）。
class AdRecordPage extends ConsumerWidget {
  const AdRecordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adStatsProvider);
    final bannerTool = ref.watch(bannerToolProvider);
    final List<AdInfo> list = stats.adInfos.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('收益列表')),
      body: ListenableBuilder(
        listenable: bannerTool,
        builder: (context, _) {
          final double bottomInset = bannerTool.contentBottomInset(context);

          if (list.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: const Center(child: Text('暂无记录')),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h + bottomInset),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final AdInfo item = list[i];
                  final String typeLabel = AdInfo.displayTypeLabel(item.adType);
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 8.h,
                ),
                margin: EdgeInsets.only(bottom: 10.h),
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
          );
        },
      ),
    );
  }
}
