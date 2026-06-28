import 'package:base_object/app/repository_providers.dart';
import 'package:base_object/data/models/ad_stats_state.dart';
import 'package:base_object/data/models/backModel/fKModelConfig/FKConfigVo.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:base_object/data/models/localModels/UpADModel.dart';
import 'package:base_object/data/repositories/ad_stats_repository.dart';
import 'package:base_object/shared/widgets/cu_toast.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/jiffy.dart';

class AdStatsNotifier extends Notifier<AdStatsState> {
  late final AdStatsRepository _repository;

  @override
  AdStatsState build() {
    _repository = ref.read(adStatsRepositoryProvider);
    return AdStatsState();
  }

  FKConfigVo get fkConfig => state.fkConfig;
  List<AdInfo> get adInfos => state.adInfos;

  Future<void> initAdInfos() async {
    final List<AdInfo>? adInfoList = await _repository.loadAdInfos();
    Utils.logError('到底是什么$adInfoList');
    if (adInfoList != null) {
      state = state.copyWith(
        adInfos: AdInfo.sortedByCreatedTimeDesc(adInfoList),
      );
    }
  }

  Future<void> getFkConfigFn() async {
    final FKConfigVo defaultConfig = FKConfigVo();
    defaultConfig.adTime = 60;
    await setFkConfig(defaultConfig);
  }

  Future<void> setFkConfig(FKConfigVo data) async {
    state = state.copyWith(fkConfig: data);
    await _repository.saveFkConfig(data);
  }

  Future<void> addAdInfos(AdInfo value) async {
    final List<AdInfo> next = AdInfo.sortedByCreatedTimeDesc([
      ...state.adInfos,
      value,
    ]);
    state = state.copyWith(adInfos: next);
    await _repository.saveAdInfos(next);
    Utils.logError('当前记录：${state.adInfos}');
  }

  void addWatchMaxAdList(UpADModel model) {
    final List<UpADModel> list = List<UpADModel>.from(state.watchMaxAdList);
    if (list.length > state.fkConfig.wactchMaxV1) {
      final UpADModel firstModel = list.first;
      final UpADModel lastModel = list.last;
      final num hourDiff = firstModel.createTime.diff(
        lastModel.createTime,
        unit: Unit.hour,
      );
      if (hourDiff.abs() > 1) {
        state = state.copyWith(watchMaxAdList: <UpADModel>[]);
      } else {
        Utils.logError(
          '当前：${list.length}条广告收益超出了最高限制，请联系管理员或明日再来',
        );
        CuToast.error(msg: '今日广告已达上限，请明日再来');
      }
    } else {
      list.add(model);
      state = state.copyWith(watchMaxAdList: list);
      Utils.logError('副广最高数组长度：${list.length}');
    }
  }

  void addWatchMinAdList(UpADModel model) {
    final List<UpADModel> list = List<UpADModel>.from(state.watchMinAdList);
    if (list.length > state.fkConfig.wactchMinV1) {
      final UpADModel firstModel = list.first;
      final UpADModel lastModel = list.last;
      final num hourDiff = firstModel.createTime.diff(
        lastModel.createTime,
        unit: Unit.hour,
      );
      if (hourDiff.abs() > 1) {
        state = state.copyWith(watchMinAdList: <UpADModel>[]);
      } else {
        Utils.logError(
          '当前：${list.length}条广告收益超出了最低限制，请联系管理员或明日再来',
        );
        CuToast.error(msg: '今日广告已达上限，请明日再来');
      }
    } else {
      list.add(model);
      state = state.copyWith(watchMinAdList: list);
      Utils.logError('副广最低数组长度：${list.length}');
    }
  }
}
