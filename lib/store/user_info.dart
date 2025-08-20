import 'dart:convert';
import 'dart:developer';

import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_binding.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_controller.dart';
import 'package:base_object/core/config/app_keys.dart';
import 'package:base_object/models/backModel/userModel/UserModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:get/get.dart';

class UserInfo extends GetxController{
  /// 获取单例
  static UserInfo get instance => Get.find<UserInfo>();
  final Rx<UserModel> _userModel = UserModel().obs;
  /// 优化登录状态判断：同时验证 userId 和 token
  bool get isLoginIn {
    // 1. 基础判断：userId 有效
    final hasValidUserId = userModel.id > 0;
    // 2. 补充判断：token 存在（内存中）
    final hasToken = _token.isNotEmpty;
    // 两者同时满足才视为登录状态有效
    return hasValidUserId && hasToken;
  }
  /// 获取余额
  double get yuE => userModel.currentAmount;
  /// 获取UserModel
  UserModel get userModel {
    try {
      return _userModel.value;
    } catch (e) {
      return UserModel(); // 返回默认实例
    }
  }
  String _token = "";

  /// 设置token
  void setToken({String value ="",String key = "token"}){
    _token = value;
    LocalStorage.setString(AppKeys.tokenName,value);
  }
  /// 获取token
  Future<String> get getToken async {
    // 优先从内存中获取（如果已缓存）
    if (_token.isNotEmpty) {
      return _token;
    }
    // 内存中没有则从本地存储读取，并更新内存缓存
    final token = await LocalStorage.getString(AppKeys.tokenName);
    _token = token ?? "";
    return _token;
  }

  /// 重置为默认用户数据
  void initUserInfo() => updateUserModel(UserModel());
  /// 标记是否已经初始化
  bool _initialized = false;
  /// 初始化用户数据（从本地加载或设置默认值）
  Future<void> initialize() async {
    final String token = await getToken;
    Utils.logError("token哈哈是$token");
    if(token.isNotEmpty){
      setToken(value: token);
      /// 从本地存储加载用户数据
      final String? userInfoJson = await LocalStorage.getString(AppKeys.userKey);

      if (userInfoJson!=null) {
        // 解析 JSON 并更新用户模型
        final Map<String, dynamic> userInfoMap = jsonDecode(userInfoJson);
        final cachedUser = UserModel.fromJson(userInfoMap);
        updateUserModel(cachedUser);
        _initialized = true;
      }
    }
    if (!_initialized) {
      // 没有缓存，使用默认值
      initUserInfo();
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
  Future<void> loginOut() async{
    initUserInfo();
    await LocalStorage.removeString(AppKeys.userKey);
    setToken(value: '');
    bool isRegistered = Get.isRegistered<CuNavBarController>();
    if(!isRegistered){
      CuNavBarBinding().dependencies();
    }
    Get.find<CuNavBarController>().onTabChange(0);
  }
}