import 'dart:convert';

import 'package:base_object/core/config/app_keys.dart';
import 'package:base_object/models/backModel/appUpLoadModel/AppUpLoadModel.dart';
import 'package:base_object/models/backModel/fKModelConfig/FKConfigVo.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

class Store extends GetxController{
  /// 获取单例
  static Store get instance => Get.find();
  final RxInt _currentIndex = 0.obs;
  void changeIndex(int index){
    _currentIndex.value = index;
  }

  // 应用信息
  final Rx<AppUpLoadModel> _appUpLoadModel = AppUpLoadModel().obs;
  updateAppUpLoadModel(AppUpLoadModel appUpLoadModel){
    _appUpLoadModel.value = appUpLoadModel;
  }
  AppUpLoadModel get getAppUpLoadModel => _appUpLoadModel.value;


//   风控配置
  final Rx<FKConfigVo> _fkConfig = FKConfigVo().obs;
  void setFKConfigVo(FKConfigVo data){
    _fkConfig.value = data;
    Utils.logError("当前配置是：${_fkConfig.toJson()}");
  }
  FKConfigVo get getFkConfig => _fkConfig.value;
  /// 当日计数
  final Rx<CurrentCountVo> _currentCount = CurrentCountVo().obs;
  /// 当日计数
  CurrentCountVo get getCurrentCount => _currentCount.value;
  /// 增加主广计数
  void addCurrentCount(int count)async{
    _currentCount.value.dayMaxCount+=count;
    await LocalStorage.setString(AppKeys.countKey, _currentCount.value);
  }
  Future<void> initCurrentCount()async{
    String? str = await LocalStorage.getString(AppKeys.countKey);

    // 控制弹窗频率（每天一次）
    String? clearTime = await LocalStorage.getString(AppKeys.isClearCount);
    bool isClearCount = false;
    if (clearTime != null ) {
      Jiffy now = Jiffy.now();
      Jiffy last = Jiffy.parse(jsonDecode(clearTime));
      isClearCount = last.isBefore(now, unit: Unit.day);
    }
    Utils.logError("是否要清除本地计数：$isClearCount，是否要获取本地存储数据代替store中的数据：${str !=null&&!isClearCount},本地数据是$str");
    if(str !=null&&!isClearCount){
      _currentCount.value=CurrentCountVo.fromJson(jsonDecode(str)) ;
      await LocalStorage.setString(AppKeys.countKey, _currentCount.value);
      Utils.logError("本地获取到的数据${_currentCount.value.toJson()}");
    }else{
      _currentCount.value = CurrentCountVo();
      Utils.logError("本地即将要存取的数据${_currentCount.value.toJson()}");
      await LocalStorage.setString(AppKeys.isClearCount,Jiffy.now().format());
      await LocalStorage.setString(AppKeys.countKey, _currentCount.value);
    }
  }
}