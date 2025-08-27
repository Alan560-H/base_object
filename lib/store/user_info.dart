import 'dart:convert';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_binding.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_controller.dart';
import 'package:base_object/core/config/app_keys.dart';
import 'package:base_object/manager/Init_tool.dart';
import 'package:base_object/models/backModel/userModel/UserModel.dart';
import 'package:base_object/models/backModel/userModel/UserTodayModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  /// 获取token（关键：用 jsonDecode 解转义）
  Future<String> get getToken async {
    if (_token.isNotEmpty) {
      return _token;
    }
    // 1. 从本地读取（此时是被 jsonEncode 后的字符串，如 "\"abc123\""）
    final String? encodedToken = await LocalStorage.getString(AppKeys.tokenName);
    if (encodedToken == null) {
      _token = "";
      return _token;
    }
    // 2. 用 jsonDecode 解转义，还原成原始字符串（如 "abc123"）
    final decodedToken = jsonDecode(encodedToken) as String;
    _token = decodedToken;
    Utils.logError("解码后的token：$decodedToken"); // 此时已无多余斜杠
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
        DateTime now = DateTime.now();
        int timestampMs  = now.millisecondsSinceEpoch;
        Get.delete<InitTool>();
        // Get.delete<BannerTool>();
        // 等待当前帧结束（约16ms），让GetX完成实际销毁
        await Future.delayed(const Duration(milliseconds: 20));
        // 此时检查，返回 false（旧实例已被移除）
        Utils.logError("是否注册：${Get.isRegistered<InitTool>()}");
        Get.put<InitTool>(InitTool());

        await Future.delayed(const Duration(milliseconds: 20));
        bool isInitAd = await InitTool.to.initTopon();
        InitTool.to.setCustomDataDic({
          "userId": UserInfo.instance.userModel.id,
          "extra": "userid_${UserInfo.instance.userModel.id}_type_1_amount_0_time_$timestampMs",
        });
        _initialized = true;
      }
    }
    if (!_initialized) {
      Utils.logError("没有缓存，使用默认值");
      initUserInfo();
    }
  }
  /// 请求最新用户信息
  Future<void> getUserInfoFn() async {
    try{
      EasyLoading.show(status: "请求用户信息中...");
      if(!Get.isRegistered<Api>()){
        Get.put(Api());
      }
      UserModel userModel = await Api.to.getUserInfo();
      if (userModel.id != 0) {
        UserInfo.instance.updateUserModel(userModel);
        UserTodayModel userTodayModel = await Api.to.getTodayAmount();
        UserInfo.instance.updateUserTodayModel(userTodayModel);
        Utils.logError("用户今日收益：${userTodayModel.toJson()}");
      }
    }catch(e){
      Utils.logError("请求最新用户信息失败$e");
    }finally{
      EasyLoading.dismiss();
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
  void updateUserTodayModel(UserTodayModel newModel){
    try{
      _userModel.value.currentAmount = newModel.currentAmount;
      _userModel.value.todayAmount = newModel.todayAmount;
      LocalStorage.setString(AppKeys.userKey,_userModel);
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