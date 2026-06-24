import 'package:base_object/shared/widgets/cu_toast.dart';
import 'package:base_object/shared/config/app_keys.dart';
import 'package:base_object/services/ads/rewarder_tool.dart';
import 'package:base_object/data/models/backModel/appUpLoadModel/AppUpLoadModel.dart';
import 'package:base_object/data/models/backModel/fKModelConfig/FKConfigVo.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:base_object/data/models/localModels/UpADModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/services/storage/local_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

class Store extends GetxController {
  static Store get instance => Get.find();

  final Rx<AppUpLoadModel> _appUpLoadModel = AppUpLoadModel().obs;
  AppUpLoadModel get getAppUpLoadModel => _appUpLoadModel.value;

  final RxList<UpADModel> _wactchMaxADList = <UpADModel>[].obs;

  void addWactchMaxADList(UpADModel model) {
    if (_wactchMaxADList.length > _fkConfig.value.wactchMaxV1) {
      final UpADModel firstModel = _wactchMaxADList.first;
      final UpADModel lastModel = _wactchMaxADList.last;
      final num hourDiff = firstModel.createTime.diff(
        lastModel.createTime,
        unit: Unit.hour,
      );
      if (hourDiff.abs() > 1) {
        _wactchMaxADList.clear();
      } else {
        Utils.logError("当前：${_wactchMaxADList.length}条广告收益超出了最高限制，请联系管理员或明日再来");
        CuToast.error(msg: "今日广告已达上限，请明日再来");
      }
    } else {
      _wactchMaxADList.add(model);
      Utils.logError("副广最高数组长度：${_wactchMaxADList.length}");
    }
  }

  final RxList<UpADModel> _wactchMinADList = <UpADModel>[].obs;

  void addWactchMinADList(UpADModel model) {
    if (_wactchMinADList.length > _fkConfig.value.wactchMinV1) {
      final UpADModel firstModel = _wactchMinADList.first;
      final UpADModel lastModel = _wactchMinADList.last;
      final num hourDiff = firstModel.createTime.diff(
        lastModel.createTime,
        unit: Unit.hour,
      );
      if (hourDiff.abs() > 1) {
        _wactchMinADList.clear();
      } else {
        Utils.logError("当前：${_wactchMinADList.length}条广告收益超出了最低限制，请联系管理员或明日再来");
        CuToast.error(msg: "今日广告已达上限，请明日再来");
      }
    } else {
      _wactchMinADList.add(model);
      Utils.logError("副广最低数组长度：${_wactchMinADList.length}");
    }
  }

  final Rx<FKConfigVo> _fkConfig = FKConfigVo().obs;

  Future<void> setFKConfigVo(FKConfigVo data) async {
    _fkConfig.value = data;
    await LocalStorage.setString(AppKeys.fkConfig, data);
  }

  Future<void> getFkConfigFn() async {
    final FKConfigVo defaultConfig = FKConfigVo();
    defaultConfig.adTime = 60;
    await setFKConfigVo(defaultConfig);
  }

  FKConfigVo get getFkConfig => _fkConfig.value;

  final RxList<AdInfo> _adInfos = <AdInfo>[].obs;
  List<AdInfo> get getAdInfos => _adInfos;

  int get rewardedAdCount =>
      _adInfos.where((e) => e.adType == AdInfo.typeRewarded).length;

  int get bannerAdCount =>
      _adInfos.where((e) => e.adType == AdInfo.typeBanner).length;

  double get rewardedRevenueTotalCny => _adInfos
      .where((e) => e.adType == AdInfo.typeRewarded)
      .fold(0.0, (double sum, AdInfo e) => sum + e.publisherRevenue);

  double get bannerRevenueTotalCny => _adInfos
      .where((e) => e.adType == AdInfo.typeBanner)
      .fold(0.0, (double sum, AdInfo e) => sum + e.publisherRevenue);

  bool _isLocalToday(AdInfo e) {
    try {
      final Jiffy t = Jiffy.parse(e.createdTime);
      return t.isSame(Jiffy.now(), unit: Unit.day);
    } catch (_) {
      return false;
    }
  }

  int get rewardedCountToday => _adInfos
      .where(
        (e) => e.adType == AdInfo.typeRewarded && _isLocalToday(e),
      )
      .length;

  int get bannerCountToday => _adInfos
      .where((e) => e.adType == AdInfo.typeBanner && _isLocalToday(e))
      .length;

  double get rewardedRevenueTodayCny => _adInfos
      .where((e) => e.adType == AdInfo.typeRewarded && _isLocalToday(e))
      .fold(0.0, (double sum, AdInfo e) => sum + e.publisherRevenue);

  double get bannerRevenueTodayDisplayCny => _adInfos
      .where((e) => e.adType == AdInfo.typeBanner && _isLocalToday(e))
      .fold(
        0.0,
        (double s, AdInfo e) =>
            s + AdInfo.displayRevenueLineSumTerm(e.publisherRevenue),
      );

  double get rewardedRevenueTotalDisplayCny => _adInfos
      .where((e) => e.adType == AdInfo.typeRewarded)
      .fold(
        0.0,
        (double s, AdInfo e) =>
            s + AdInfo.displayRevenueLineSumTerm(e.publisherRevenue),
      );

  double get bannerRevenueTotalDisplayCny => _adInfos
      .where((e) => e.adType == AdInfo.typeBanner)
      .fold(
        0.0,
        (double s, AdInfo e) =>
            s + AdInfo.displayRevenueLineSumTerm(e.publisherRevenue),
      );

  double get rewardedRevenueTodayDisplayCny => _adInfos
      .where((e) => e.adType == AdInfo.typeRewarded && _isLocalToday(e))
      .fold(
        0.0,
        (double s, AdInfo e) =>
            s + AdInfo.displayRevenueLineSumTerm(e.publisherRevenue),
      );

  double get bannerRevenueTodayCny => _adInfos
      .where((e) => e.adType == AdInfo.typeBanner && _isLocalToday(e))
      .fold(0.0, (double sum, AdInfo e) => sum + e.publisherRevenue);

  double get getAdInfosTotal {
    return _adInfos.fold(
      0.0,
      (double sum, AdInfo adInfo) => sum + adInfo.publisherRevenue,
    );
  }

  /// 是否可以观看激励广告：true 可以，false 不可以
  Future<bool> canLookReward() async {
    bool isReady = await RewarderTool.to.rewardedVideoReady();
    Utils.logError("准备状态：$isReady}");
    if (!isReady) {
      EasyLoading.show(status: "广告还没准备好，请稍后再试");
      RewarderTool.to.loadRewardedVideoFlutter(
        userID: "${UserInfo.instance.userModel.id}",
        extra:
            "userid_${UserInfo.instance.userModel.id}_type_1_amount_0_time_0",
      );
      await Future.delayed(const Duration(seconds: 3));
      EasyLoading.dismiss();
      return false;
    }

    EasyLoading.dismiss();
    return true;
  }

  void addAdInfos(AdInfo value) async {
    _adInfos.add(value);
    await LocalStorage.setString(AppKeys.adInfosKey, _adInfos);
    Utils.logError("当前记录：$getAdInfos");
  }

  void setAdInfos(List<AdInfo> value) async {
    _adInfos.value = value;
    await LocalStorage.setString(AppKeys.adInfosKey, _adInfos);
    Utils.logError("有值，初始化成功：$RxList");
  }

  Future<void> initAdInfos() async {
    final List<AdInfo>? adInfoList = await LocalStorage.getObjectList(
      AppKeys.adInfosKey,
      AdInfo.fromJson,
    );
    Utils.logError("到底是什么$adInfoList");
    if (adInfoList != null) {
      setAdInfos(adInfoList);
    }
  }
}
