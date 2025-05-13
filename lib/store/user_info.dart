import 'dart:convert';

import 'package:base_object/core/config/app_keys.dart';
import 'package:base_object/models/backModel/userModel/UserModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:get/get.dart';

class UserInfo extends GetxController{
  /// 获取单例
  static UserInfo get instance => Get.find();
  final Rx<UserModel> _userModel = UserModel().obs;
  /// 获取登录状态
  bool get isLoginIn => userModel.userId>0;
  /// 获取余额
  double get yuE => userModel.mallAmount;
  /// 判断是不是模拟战用户
  bool get isMockUser => userModel.userType == 6;
  /// 获取UserModel
  UserModel get userModel {
    try {
      return _userModel.value;
    } catch (e) {
      return UserModel(); // 返回默认实例
    }
  }
  /// 重置为默认用户数据
  void initUserInfo() => updateUserModel(UserModel());
  /// 标记是否已经初始化
  bool _initialized = false;
  /// 初始化用户数据（从本地加载或设置默认值）
  Future<void> initialize() async {
    if (!_initialized) {
      await _initialize();
    }
  }

  /// 私有初始化方法
  Future<void> _initialize() async {
    try {
      /// 从本地存储加载用户数据
      final String? userInfoJson = await LocalStorage.getString(AppKeys.userKey);
      if (userInfoJson!=null) {
        // 解析 JSON 并更新用户模型
        final Map<String, dynamic> userInfoMap = jsonDecode(userInfoJson);
        final cachedUser = UserModel.fromJson(userInfoMap);
        updateUserModel(cachedUser);
      } else {
        // 没有缓存，使用默认值
        initUserInfo();
      }

      _initialized = true;
    } catch (e) {
      Utils.logError('初始化用户数据失败: $e');
      // 出错时使用默认值
      initUserInfo();
      _initialized = true;
    }
  }
  /// 更新用户数据
  void updateUserModel(UserModel newModel) {
    try{
      _userModel.value = newModel; // 直接更新 Rx 的值，自动触发响应式更新
      LocalStorage.setString(AppKeys.userKey,newModel);
    }catch(e){
      Utils.logError(e);
    }
  }
  /// 退出登录
  void loginOut(){
    initUserInfo();
    LocalStorage.removeString(AppKeys.userKey);
  }
}