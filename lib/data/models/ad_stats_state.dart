import 'package:base_object/data/models/backModel/appUpLoadModel/AppUpLoadModel.dart';
import 'package:base_object/data/models/backModel/fKModelConfig/FKConfigVo.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:base_object/data/models/localModels/UpADModel.dart';
import 'package:flutter/foundation.dart';
import 'package:jiffy/jiffy.dart';

/// 广告统计与风控相关全局状态（替代原 GetX [Store]）。
@immutable
class AdStatsState {
  AdStatsState({
    AppUpLoadModel? appUpLoadModel,
    List<AdInfo>? adInfos,
    FKConfigVo? fkConfig,
    List<UpADModel>? watchMaxAdList,
    List<UpADModel>? watchMinAdList,
  }) : appUpLoadModel = appUpLoadModel ?? AppUpLoadModel(),
       adInfos = adInfos ?? const <AdInfo>[],
       fkConfig = fkConfig ?? FKConfigVo(),
       watchMaxAdList = watchMaxAdList ?? const <UpADModel>[],
       watchMinAdList = watchMinAdList ?? const <UpADModel>[];

  final AppUpLoadModel appUpLoadModel;
  final List<AdInfo> adInfos;
  final FKConfigVo fkConfig;
  final List<UpADModel> watchMaxAdList;
  final List<UpADModel> watchMinAdList;

  AdStatsState copyWith({
    AppUpLoadModel? appUpLoadModel,
    List<AdInfo>? adInfos,
    FKConfigVo? fkConfig,
    List<UpADModel>? watchMaxAdList,
    List<UpADModel>? watchMinAdList,
  }) {
    return AdStatsState(
      appUpLoadModel: appUpLoadModel ?? this.appUpLoadModel,
      adInfos: adInfos ?? this.adInfos,
      fkConfig: fkConfig ?? this.fkConfig,
      watchMaxAdList: watchMaxAdList ?? this.watchMaxAdList,
      watchMinAdList: watchMinAdList ?? this.watchMinAdList,
    );
  }

  int get rewardedAdCount =>
      adInfos.where((e) => e.adType == AdInfo.typeRewarded).length;

  int get bannerAdCount =>
      adInfos.where((e) => e.adType == AdInfo.typeBanner).length;

  int get nativeAdCount =>
      adInfos.where((e) => e.adType == AdInfo.typeNative).length;

  double get rewardedRevenueTotalCny => adInfos
      .where((e) => e.adType == AdInfo.typeRewarded)
      .fold(0.0, (double sum, AdInfo e) => sum + e.publisherRevenue);

  double get bannerRevenueTotalCny => adInfos
      .where((e) => e.adType == AdInfo.typeBanner)
      .fold(0.0, (double sum, AdInfo e) => sum + e.publisherRevenue);

  int get rewardedCountToday => adInfos
      .where((e) => e.adType == AdInfo.typeRewarded && _isLocalToday(e))
      .length;

  int get bannerCountToday => adInfos
      .where((e) => e.adType == AdInfo.typeBanner && _isLocalToday(e))
      .length;

  int get nativeCountToday => adInfos
      .where((e) => e.adType == AdInfo.typeNative && _isLocalToday(e))
      .length;

  double get rewardedRevenueTodayCny => adInfos
      .where((e) => e.adType == AdInfo.typeRewarded && _isLocalToday(e))
      .fold(0.0, (double sum, AdInfo e) => sum + e.publisherRevenue);

  double get bannerRevenueTodayDisplayCny => adInfos
      .where((e) => e.adType == AdInfo.typeBanner && _isLocalToday(e))
      .fold(
        0.0,
        (double s, AdInfo e) =>
            s + AdInfo.displayRevenueLineSumTerm(e.publisherRevenue),
      );

  double get rewardedRevenueTotalDisplayCny => adInfos
      .where((e) => e.adType == AdInfo.typeRewarded)
      .fold(
        0.0,
        (double s, AdInfo e) =>
            s + AdInfo.displayRevenueLineSumTerm(e.publisherRevenue),
      );

  double get bannerRevenueTotalDisplayCny => adInfos
      .where((e) => e.adType == AdInfo.typeBanner)
      .fold(
        0.0,
        (double s, AdInfo e) =>
            s + AdInfo.displayRevenueLineSumTerm(e.publisherRevenue),
      );

  double get nativeRevenueTotalDisplayCny => adInfos
      .where((e) => e.adType == AdInfo.typeNative)
      .fold(
        0.0,
        (double s, AdInfo e) =>
            s + AdInfo.displayRevenueLineSumTerm(e.publisherRevenue),
      );

  double get rewardedRevenueTodayDisplayCny => adInfos
      .where((e) => e.adType == AdInfo.typeRewarded && _isLocalToday(e))
      .fold(
        0.0,
        (double s, AdInfo e) =>
            s + AdInfo.displayRevenueLineSumTerm(e.publisherRevenue),
      );

  double get nativeRevenueTodayDisplayCny => adInfos
      .where((e) => e.adType == AdInfo.typeNative && _isLocalToday(e))
      .fold(
        0.0,
        (double s, AdInfo e) =>
            s + AdInfo.displayRevenueLineSumTerm(e.publisherRevenue),
      );

  double get adInfosTotal => adInfos.fold(
    0.0,
    (double sum, AdInfo adInfo) => sum + adInfo.publisherRevenue,
  );

  static bool _isLocalToday(AdInfo e) {
    try {
      final Jiffy t = Jiffy.parse(e.createdTime);
      return t.isSame(Jiffy.now(), unit: Unit.day);
    } catch (_) {
      return false;
    }
  }
}
