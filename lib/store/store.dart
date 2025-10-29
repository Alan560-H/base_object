import 'dart:async';
import 'dart:convert';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/app_keys.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/FormModel/appUpLoadForm/AppUpLoadForm.dart';
import 'package:base_object/models/FormModel/checkDeviceForm/CheckDeviceForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/appUpLoadModel/AppUpLoadModel.dart';
import 'package:base_object/models/backModel/fKModelConfig/FKConfigVo.dart';
import 'package:base_object/models/backModel/serviceModel/ServiceModel.dart';
import 'package:base_object/models/localModels/LocationData.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:flutter_android_oaid_plugin/flutter_android_oaid_plugin.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

class Store extends GetxController {
  /// 获取单例
  static Store get instance => Get.find();
  final RxInt _currentIndex = 0.obs;
  void changeIndex(int index) {
    _currentIndex.value = index;
  }

  final RxString _inviteCode = ''.obs;
  void setInviteCode(String code) {
    _inviteCode.value = code;
  }

  String getInviteCode() {
    return _inviteCode.value;
  }

  // 应用信息
  final Rx<AppUpLoadModel> _appUpLoadModel = AppUpLoadModel().obs;
  updateAppUpLoadModel(AppUpLoadModel appUpLoadModel) {
    _appUpLoadModel.value = appUpLoadModel;
  }

  AppUpLoadModel get getAppUpLoadModel => _appUpLoadModel.value;

  //   风控配置
  final Rx<FKConfigVo> _fkConfig = FKConfigVo().obs;
  void setFKConfigVo(FKConfigVo data) {
    _fkConfig.value = data;
  }

  /// 获取风控配置
  Future<void> getFkConfigFn() async {
    try {
      FKConfigVo data = await Api.to.getFkConfig();
      setFKConfigVo(data);
      Utils.logError("风控设置：${getFkConfig.toJson()}");
    } catch (e) {
      Utils.logError("获取风控配置失败$e");
    }
  }

  FKConfigVo get getFkConfig => _fkConfig.value;

  /// 当日领取红包次数
  final Rx<CurrentCountVo> _currentCount = CurrentCountVo().obs;

  /// 当日领取红包次数
  CurrentCountVo get getCurrentCount => _currentCount.value;
  Timer? _timer;

  /// 倒计时
  Future<void> countDown() async {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        await LocalStorage.setString(
          AppKeys.rewarderTime,
          _remainingSeconds.value,
        );
        Utils.logError("存入间隔时间$_remainingSeconds");
      } else {
        _timer?.cancel();
        _timer = null;
      }
    });
  }

  setRemainingSeconds() async {
    _remainingSeconds.value = _fkConfig.value.adTime;
  }

  setRemainingSeconds2(int val) async {
    _remainingSeconds.value = val;
  }

  RxInt _remainingSeconds = 0.obs;
  int get remainingSeconds => _remainingSeconds.value;

  /// 如果 间隔时间大于0，则表示时间还没到，不可领取
  bool get isTimeOver => _remainingSeconds.value > 0;

  /// 是否可以观看激励广告,true 是可以，false不可以
  Future<bool> canLookReward() async {
    if (Store.instance.isTimeOver) {
      CuToast.error(msg: "广告间隔时间还没到$_remainingSeconds");
      return false;
    }
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

    /// 如果今日观看主广次数已达最大次数
    if (_currentCount.value.dayMaxCount >= _fkConfig.value.dayMax) {
      CuToast.error(msg: "今日领取次数已达上限，请明日再来");
      return false;
    }
    EasyLoading.dismiss();
    return true;
  }

  /// 增加主广计数
  void addCurrentCount(int count) async {
    _currentCount.value.dayMaxCount += count;
    await LocalStorage.setString(AppKeys.countKey, _currentCount.value);
  }

  Future<void> initCurrentCount() async {
    String? str = await LocalStorage.getString(AppKeys.countKey);
    // 控制弹窗频率（每天一次）
    String? clearTime = await LocalStorage.getString(AppKeys.isClearCount);
    bool isClearCount = false;
    if (clearTime != null) {
      Jiffy now = Jiffy.now();
      Jiffy last = Jiffy.parse(jsonDecode(clearTime));
      isClearCount = last.isBefore(now, unit: Unit.day);
    }
    Utils.logError(
      "是否要清除本地计数：$isClearCount，是否要获取本地存储数据代替store中的数据：${str != null && !isClearCount},本地数据是$str",
    );
    if (str != null && !isClearCount) {
      _currentCount.value = CurrentCountVo.fromJson(jsonDecode(str));
      await LocalStorage.setString(AppKeys.countKey, _currentCount.value);
      Utils.logError("本地获取到的数据${_currentCount.value.toJson()}");
    } else {
      _currentCount.value = CurrentCountVo();
      Utils.logError("本地即将要存取的数据${_currentCount.value.toJson()}");
      await LocalStorage.setString(AppKeys.isClearCount, Jiffy.now().format());
      await LocalStorage.setString(AppKeys.countKey, _currentCount.value);
    }
  }

  RxBool _isOpenClaim = false.obs;
  void setIsOpenClaim(bool value) {
    _isOpenClaim.value = value;
  }

  bool get getIsOpenClaim => _isOpenClaim.value;

  /// 获取客服配置
  /// 客服配置
  final RxList<ServiceModel> _serviceList = <ServiceModel>[].obs;
  Future getServerConfig() async {
    AppUpLoadForm form = AppUpLoadForm();
    form.channelPackage = getAppUpLoadModel.channelPackage;
    List<ServiceModel> list = await Api.to.getServerConfig(form);
    _serviceList.value = list;
  }

  // 获取q群链接
  ServiceModel? get getQUrl =>
      _serviceList.isNotEmpty ? _serviceList.first : null;
  // 获取q群二维码
  ServiceModel? get getQCode =>
      _serviceList.length >= 2 ? _serviceList[1] : null;
  // 获取客服电话
  ServiceModel? get getServiceTel =>
      _serviceList.length >= 3 ? _serviceList[2] : null;

  RxBool _isLimit = false.obs;

  /// 是否被封禁
  bool get isLimit => _isLimit.value;

  /// 是否被封禁
  void setIsLimit(bool value) {
    _isLimit.value = value;
  }

  Future<void> upAddress() async {
    if (Store.instance.locationData == null) {
      return;
    }
    CheckDeviceForm checkDeviceForm = CheckDeviceForm();
    checkDeviceForm.oaid = await FlutterAndroidOaidPlugin.getOAID();
    checkDeviceForm.userId = UserInfo.instance.userModel.id;
    checkDeviceForm.address = Store.instance.locationData?.address;
    checkDeviceForm.latitude = Store.instance.locationData?.latitude;
    checkDeviceForm.longitude = Store.instance.locationData?.longitude;
    checkDeviceForm.type = 3;
    if (checkDeviceForm.userId == 0) {
      checkDeviceForm.userId = null;
    }
    // 地理位置异常
    BackModel data = await Api.to.getVer(checkDeviceForm);
    setIsLimit(data.data);
  }

  /// 检查设备封禁
  Future<bool> getVer() async {
    try {
      CheckDeviceForm checkDeviceForm = CheckDeviceForm();
      checkDeviceForm.oaid = await FlutterAndroidOaidPlugin.getOAID();
      checkDeviceForm.userId = UserInfo.instance.userModel.id;
      checkDeviceForm.address = Store.instance.locationData?.address;
      checkDeviceForm.latitude = Store.instance.locationData?.latitude;
      checkDeviceForm.longitude = Store.instance.locationData?.longitude;
      checkDeviceForm.type = 1;
      if (checkDeviceForm.userId == 0) {
        checkDeviceForm.userId = null;
      }
      BackModel data = await Api.to.getVer(checkDeviceForm);
      setIsLimit(data.data);
      return isLimit;
    } catch (e) {
      Utils.logError("获取风控配置失败$e");
      return false;
    }
  }

  /// 位置信息
  LocationData? _locationData;

  /// 获取位置信息
  LocationData? get locationData => _locationData;

  /// 设置位置信息
  void setLocationData(LocationData? value) {
    _locationData = value;
  }

  final RxBool _isClaim = false.obs;
  bool get getIsClaim => _isClaim.value;
  void setIsClaim(bool val) {
    _isClaim.value = val;
  }
}
