import 'package:base_object/features/home/presentation/home_notifier.dart';
import 'package:base_object/features/home/presentation/home_state.dart';
import 'package:base_object/data/notifiers/ad_stats_notifier.dart';
import 'package:base_object/data/notifiers/user_notifier.dart';
import 'package:base_object/data/models/ad_stats_state.dart';
import 'package:base_object/data/models/user_state.dart';
import 'package:base_object/services/ads/Init_tool.dart';
import 'package:base_object/services/ads/banner_tool.dart';
import 'package:base_object/services/ads/native_tool.dart';
import 'package:base_object/services/ads/rewarder_tool.dart';
import 'package:base_object/shared/config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全局 [ProviderContainer]，供 bootstrap 与无 BuildContext 的广告回调使用。
late ProviderContainer globalContainer;

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig());

final adStatsProvider = NotifierProvider<AdStatsNotifier, AdStatsState>(
  AdStatsNotifier.new,
);

final userProvider = NotifierProvider<UserNotifier, UserState>(
  UserNotifier.new,
);

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

final initToolProvider = Provider<InitTool>((ref) => InitTool());

final bannerToolProvider = Provider<BannerTool>((ref) {
  return BannerTool(adStatsNotifier: ref.read(adStatsProvider.notifier));
});

final rewarderToolProvider = Provider<RewarderTool>((ref) {
  return RewarderTool(
    adStatsNotifier: ref.read(adStatsProvider.notifier),
    userNotifier: ref.read(userProvider.notifier),
  );
});

final nativeToolProvider = Provider<NativeTool>((ref) {
  return NativeTool(
    adStatsNotifier: ref.read(adStatsProvider.notifier),
    userNotifier: ref.read(userProvider.notifier),
  );
});

/// 预热 Riverpod 与本地持久化数据。
Future<void> warmUpProviders(ProviderContainer container) async {
  container.read(appConfigProvider).init();
  await container.read(adStatsProvider.notifier).initAdInfos();
  await container.read(adStatsProvider.notifier).getFkConfigFn();
  await container.read(userProvider.notifier).loadFromStorage();
  container.read(initToolProvider);
  container.read(bannerToolProvider);
  container.read(rewarderToolProvider);
  container.read(nativeToolProvider);
}
