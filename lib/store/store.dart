import 'dart:async';
import 'dart:convert';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/app_keys.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/FormModel/FormModel.dart';
import 'package:base_object/models/FormModel/appUpLoadForm/AppUpLoadForm.dart';
import 'package:base_object/models/FormModel/checkDeviceForm/CheckDeviceForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/TaskModel/TaskModel.dart';
import 'package:base_object/models/backModel/adTaskModel/AdTaskModel.dart';
import 'package:base_object/models/backModel/appUpLoadModel/AppUpLoadModel.dart';
import 'package:base_object/models/backModel/fKModelConfig/FKConfigVo.dart';
import 'package:base_object/models/backModel/serviceModel/ServiceModel.dart';
import 'package:base_object/models/localModels/AdInfo.dart';
import 'package:base_object/models/localModels/LocationData.dart';
import 'package:base_object/models/localModels/UpADModel.dart';
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

  /// 保底任务模型
  Rx<AdTaskModel> adTaskModel = AdTaskModel().obs;

  /// 0 :未接取 ，1：已接 ，2：已完成
  int get isTaskStatus => adTaskModel.value.status;
  bool get isOverTask =>
      adTaskModel.value.numConfig - adTaskModel.value.userNum <= 0;
  Future<void> postMinAdEnd() async {
    BackModel backModel = await Api.to.postMinAdEnd();
    if (backModel.code == CuErrorConfig.success) {
      CuToast.success(msg: "任务完成，获得金币${backModel.data}");

      /// 刷新任务状态
      await Store.instance.postMinAdPrizeList();
      Get.back();
    }
  }

  /// 任务保底详情
  Future<void> postMinAdPrizeList() async {
    if (!UserInfo.instance.isLoginIn) return;
    FormModel formModel = FormModel();
    formModel.channelPackage = Store.instance.getAppUpLoadModel.channelPackage;
    adTaskModel.value = await Api.to.postMinAdPrizeList(formModel);
    Utils.logError("任务保底详情${adTaskModel.value.toJson()}");
  }

  final RxBool _disableLogin = false.obs;
  bool get getDisableLogin => _disableLogin.value;

  /// 设置禁止登录
  void setDisableLogin(bool val) {
    _disableLogin.value = val;
  }

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

  /// 副广封禁数组（最高）
  final RxList<UpADModel> _wactchMaxADList = <UpADModel>[].obs;

  /// 添加副广封禁（最高）
  void addWactchMaxADList(UpADModel model) async {
    /// 当副广封禁数组长度大于风控配置的最大封禁数时上传封禁数组。
    if (_wactchMaxADList.length > _fkConfig.value.wactchMaxV1) {
      UpADModel firstModel = _wactchMaxADList.first;
      UpADModel lastModel = _wactchMaxADList.last;
      num hourDiff = firstModel.createTime.diff(
        lastModel.createTime,
        unit: Unit.hour,
      );
      bool isOverOneHour = hourDiff.abs() > 1;
      if (isOverOneHour) {
        _wactchMaxADList.clear();
      } else {
        Utils.logError("当前：${_wactchMaxADList.length}条广告收益超出了最高限制，请联系管理员或明日再来");
        String msg =
            "这是副广超出了最高限制：一：最高限制：${getFkConfig.wactchMaxAmountV1}最低限制：${getFkConfig.wactchMinAmountV1}，三：超出最高限制，以及封禁数组情况：${_wactchMaxADList.toString()}";
        await getVer(type: 2, msg: msg);
        Get.offAllNamed(AppRoutes.userError);
      }
    } else {
      _wactchMaxADList.add(model);
      // CuToast.error(msg: "副广最高数组长度：${_wactchMaxADList.length}");
      Utils.logError("副广最高数组长度：${_wactchMaxADList.length}");
    }
  }

  /// 副广封禁数组（最低）
  final RxList<UpADModel> _wactchMinADList = <UpADModel>[].obs;

  /// 添加副广封禁（最低）
  void addWactchMinADList(UpADModel model) async {
    /// 当副广封禁数组长度大于风控配置的最大封禁数时上传封禁数组。
    if (_wactchMinADList.length > _fkConfig.value.wactchMinV1) {
      UpADModel firstModel = _wactchMinADList.first;
      UpADModel lastModel = _wactchMinADList.last;
      num hourDiff = firstModel.createTime.diff(
        lastModel.createTime,
        unit: Unit.hour,
      );
      bool isOverOneHour = hourDiff.abs() > 1;
      if (isOverOneHour) {
        _wactchMinADList.clear();
      } else {
        Utils.logError("当前：${_wactchMinADList.length}条广告收益超出了最低限制，请联系管理员或明日再来");
        String msg =
            "这是副广超出了最低限制：一：最高限制：${getFkConfig.wactchMaxAmountV1}最低限制：${getFkConfig.wactchMinAmountV1}，三：超出最低限制，以及封禁数组情况：${_wactchMinADList.toString()}";
        await getVer(type: 2, msg: msg);
        Get.offAllNamed(AppRoutes.userError);
      }
    } else {
      _wactchMinADList.add(model);
      // CuToast.error(msg: "副广最低数组长度：${_wactchMinADList.length}");
      Utils.logError("副广最低数组长度：${_wactchMinADList.length}");
    }
  }

  /// 主广封禁数组（最低）
  final RxList<UpADModel> _wactchMainMinADList = <UpADModel>[].obs;

  /// 添加主广封禁（最低）
  void addWactchMainMinADList(UpADModel model) async {
    /// 当主广封禁数组长度大于风控配置的最大封禁数时上传封禁数组。
    if (_wactchMainMinADList.length > _fkConfig.value.wactchMin) {
      UpADModel firstModel = _wactchMainMinADList.first;
      UpADModel lastModel = _wactchMainMinADList.last;
      num hourDiff = firstModel.createTime.diff(
        lastModel.createTime,
        unit: Unit.hour,
      );
      bool isOverOneHour = hourDiff.abs() > 1;
      if (isOverOneHour) {
        _wactchMainMinADList.clear();
      } else {
        Utils.logError(
          "当前：${_wactchMainMinADList.length}条广告收益超出了最低限制，请联系管理员或明日再来",
        );
        String msg =
            "这是主广超出了最低限制：一：最高限制：${getFkConfig.wactchMaxAmount}最低限制：${getFkConfig.wactchMinAmount}，三：超出最低限制，以及封禁数组情况：${_wactchMainMinADList.toString()}";
        await getVer(type: 2, msg: msg);
        Get.offAllNamed(AppRoutes.userError);
      }
    } else {
      _wactchMainMinADList.add(model);
      // CuToast.error(msg: "主广最低数组长度：${_wactchMainMinADList.length}");
    }
  }

  /// 主广封禁数组（最高）
  final RxList<UpADModel> _wactchMainMaxADList = <UpADModel>[].obs;

  /// 添加主广封禁（最高）
  void addWactchMainMaxADList(UpADModel model) async {
    /// 当主广封禁数组长度大于风控配置的最大封禁数时上传封禁数组。
    if (_wactchMainMaxADList.length > _fkConfig.value.wactchMax) {
      UpADModel firstModel = _wactchMainMaxADList.first;
      UpADModel lastModel = _wactchMainMaxADList.last;
      num hourDiff = firstModel.createTime.diff(
        lastModel.createTime,
        unit: Unit.hour,
      );
      bool isOverOneHour = hourDiff.abs() > 1;
      if (isOverOneHour) {
        _wactchMainMaxADList.clear();
      } else {
        Utils.logError(
          "当前：${_wactchMainMaxADList.length}条广告收益超出了最高限制，请联系管理员或明日再来",
        );
        String msg =
            "这是主广超出了最高限制：一：最高限制：${getFkConfig.wactchMaxAmount}最低限制：${getFkConfig.wactchMinAmount}，三：超出最高限制，以及封禁数组情况：${_wactchMainMaxADList.toString()}";
        await getVer(type: 2, msg: msg);
        Get.offAllNamed(AppRoutes.userError);
      }
    } else {
      _wactchMainMaxADList.add(model);
    }
  }

  //   风控配置
  final Rx<FKConfigVo> _fkConfig = FKConfigVo().obs;
  Future<void> setFKConfigVo(FKConfigVo data) async {
    _fkConfig.value = data;
    await LocalStorage.setString(AppKeys.fkConfig, data);
  }

  Future<void> checkFkConfig() async {
    if (getFkConfig.wactchMaxAmountV1 >= 0) {
      FKConfigVo? cachedConfig = await LocalStorage.getObject<FKConfigVo>(
        AppKeys.fkConfig,
        (json) => FKConfigVo.fromJson(json),
      );
      Utils.logError("本地存储得风控配置是${cachedConfig?.toJson()}");
      if (cachedConfig == null) return;
      if (cachedConfig.wactchMaxAmountV1 > 0) {
        setFKConfigVo(cachedConfig);
      } else {
        LocalStorage.removeString(AppKeys.fkConfig);
        getFkConfigFn();
      }
    }
  }

  /// 获取风控配置
  Future<void> getFkConfigFn() async {
    try {
      FKConfigVo data = await Api.to.getFkConfig();
      await setFKConfigVo(data);
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
    // if (Store.instance.isTimeOver) {
    //   CuToast.error(msg: "广告间隔时间还没到$_remainingSeconds");
    //   return false;
    // }
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
    // if (_currentCount.value.dayMaxCount >= _fkConfig.value.dayMax) {
    //   CuToast.error(msg: "今日领取次数已达上限，请明日再来");
    //   return false;
    // }
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

  /// 检查设备封禁
  /// type 1 检查设备是否封禁，2 金额异常上报，3 上传位置
  /// msg 传递得信息
  Future<bool> getVer({int type = 1, String msg = "主动查询封禁信息"}) async {
    try {
      CheckDeviceForm checkDeviceForm = CheckDeviceForm();
      checkDeviceForm.oaid = await FlutterAndroidOaidPlugin.getOAID();
      checkDeviceForm.userId = UserInfo.instance.userModel.id;
      checkDeviceForm.address = locationData?.address;
      checkDeviceForm.latitude = locationData?.latitude;
      checkDeviceForm.longitude = locationData?.longitude;
      checkDeviceForm.type = type;
      checkDeviceForm.msg = msg;
      Utils.logError(
        "上传的地理位置：${checkDeviceForm.address}，纬度：${checkDeviceForm.latitude}，经度：${checkDeviceForm.longitude}",
      );
      if (checkDeviceForm.userId == 0) {
        checkDeviceForm.userId = null;
      }
      BackModel data = await Api.to.getVer(checkDeviceForm);
      // 如果类型是1，就设置限定
      if (type == 1) {
        setIsLimit(data.data);
      }

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

  final RxList<AdInfo> _adInfos = <AdInfo>[].obs;
  List<AdInfo> get getAdInfos => _adInfos;

  /// 核心方法：计算所有广告收益的总和（getter形式，自动响应列表变化）
  double get getAdInfosTotal {
    // 使用Dart集合的fold方法累加，简洁高效
    // fold(初始值, 累加器)：sum是当前总和，adInfo是遍历的每个元素
    return _adInfos.fold(
      0.0, // 初始值必须是double（0.0），避免int和double类型混合
      (double sum, AdInfo adInfo) => sum + adInfo.publisherRevenue,
    );
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

  initAdInfos() async {
    List<AdInfo>? adInfoList = await LocalStorage.getObjectList(
      AppKeys.adInfosKey,
      AdInfo.fromJson, // 传入单个对象的反序列化方法
    );
    Utils.logError("到底是什么$adInfoList");
    if (adInfoList != null) {
      setAdInfos(adInfoList);
    }
  }
}
