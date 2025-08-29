import 'package:base_object/models/backModel/appUpLoadModel/AppUpLoadModel.dart';
import 'package:base_object/models/backModel/fKModelConfig/FKConfigVo.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

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

}