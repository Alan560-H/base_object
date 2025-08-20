import 'dart:developer';

import 'package:base_object/models/FormModel/FormModel.dart';
import 'package:base_object/models/FormModel/sendMobileCode/SendMobileCodeModel.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/loginModel/LoginModel.dart';
import 'package:base_object/models/backModel/userModel/UserAmountListModel.dart';
import 'package:base_object/models/backModel/userModel/UserModel.dart';
import 'package:base_object/models/backModel/userModel/UserTodayModel.dart';
import 'package:base_object/models/backModel/userModel/UserWithdrawalModel.dart';
import 'package:base_object/models/backModel/verifyCodeImgModel/VerifyCodeImgModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';
import '../net/cu_http_client.dart';
import 'api_urls.dart';

class Api extends GetxController{
  // GetX单例获取方式
  static Api get to => Get.find<Api>();
  // 发起请求的通用方法
  Future<BackModel> _sendRequest(
      String url,
      FormModel data,
      String requestType,
      ) async {
    try {
      BackModel backModel = await CuHttpClient.instance.request(
        url,
        data.toJson(),
        requestType: requestType,
      );
      return backModel;
    } catch (e) {
      Utils.logError("_sendRequest请求出错: $e");
      rethrow;
    }
  }
  /// 获取图片验证码
  Future<VerifyCodeImgModel> postVerifyCodeImg() async {
    try{
      BackModel backModel = await _sendRequest(
        ApiUrls.getImgCode,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return VerifyCodeImgModel();
      }
      return VerifyCodeImgModel.fromJson(backModel.data);
    }catch(e){
      Utils.logError("postVerifyCodeImg请求出错: $e");
      return VerifyCodeImgModel();
    }
  }
  /// 发送手机验证码
  Future<BackModel> postSendMobileCode(SendMobileCodeModel data) async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getSmsSend,
        data,
        "post",
      );
      return backModel;
    } catch (e) {
      Utils.logError("postSendMobileCode请求出错: $e");
      return BackModel();
    }
  }
  /// 登录
  Future<LoginModel> login(FormModel data) async {
    try {
      BackModel backModel = await _sendRequest(ApiUrls.login, data, "post");
      if (backModel.data == null) {
        final LoginModel loginModel = LoginModel();
        return loginModel;
      }
      return LoginModel.fromJson(backModel.data);
    } catch (e) {
      Utils.logError("login请求出错: $e");
      return LoginModel();
    }
  }
  /// 获取用户信息
  Future<UserModel> getUserInfo() async {
    try{
      BackModel backModel = await _sendRequest(
        ApiUrls.getUserInfo,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return UserModel();
      }
      final UserModel userModel = UserModel.fromJson(backModel.data);
      return userModel;
    }catch(e){
      Utils.logError("getUserInfo请求出错: $e");
      return UserModel();
    }
  }
  /// 获取用户今日收益
  Future<UserTodayModel> getTodayAmount() async {
    try{
      BackModel backModel = await _sendRequest(
        ApiUrls.getTodayAmount,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return UserTodayModel();
      }
      final UserTodayModel userTodayModel = UserTodayModel.fromJson(backModel.data);
      return userTodayModel;
    }catch(e){
      Utils.logError("getTodayAmount请求出错: $e");
      return UserTodayModel();
    }
  }
  /// 获取用户收入明细
  Future<List<UserAmountListModel>> getUserAmountList() async {
    try{
      BackModel backModel = await _sendRequest(
        ApiUrls.getUserAmountList,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return <UserAmountListModel>[];
      }
      final List<UserAmountListModel> userAmountListModel = UserAmountListModel.fromJsonList(backModel.data);
      return userAmountListModel;
    }catch(e){
      Utils.logError("getUserAmountList: $e");
      return <UserAmountListModel>[];
    }
  }
  /// 获取用户支出明细
  Future<List<UserWithdrawalModel>> getWithdrawalOrderList() async {
    try{
      BackModel backModel = await _sendRequest(
        ApiUrls.getWithdrawalOrderList,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return <UserWithdrawalModel>[];
      }
      final List<UserWithdrawalModel> userWithdrawalModel = UserWithdrawalModel.fromJsonList(backModel.data);
      return userWithdrawalModel;
    }catch(e){
      Utils.logError("getUserAmountList: $e");
      return <UserWithdrawalModel>[];
    }
  }

}