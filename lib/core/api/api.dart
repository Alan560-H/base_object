import 'dart:developer';

import 'package:base_object/models/FormModel/FormModel.dart';
import 'package:base_object/models/FormModel/LoginForm/LoginForm.dart';
import 'package:base_object/models/FormModel/appUpLoadForm/AppUpLoadForm.dart';
import 'package:base_object/models/FormModel/sendMobileCode/SendMobileCodeModel.dart';
import 'package:base_object/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/models/FormModel/withdrawal/WithdrawalForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/NoticeModel/NoticeModel.dart';
import 'package:base_object/models/backModel/appUpLoadModel/AppUpLoadModel.dart';
import 'package:base_object/models/backModel/fKModelConfig/FKConfigVo.dart';
import 'package:base_object/models/backModel/loginModel/LoginModel.dart';
import 'package:base_object/models/backModel/newUserModel/NewUserModel.dart';
import 'package:base_object/models/backModel/rewarderModel/RewarderModel.dart';
import 'package:base_object/models/backModel/serviceModel/ServiceModel.dart';
import 'package:base_object/models/backModel/userModel/UserAmountListModel.dart';
import 'package:base_object/models/backModel/userModel/UserBayModel.dart';
import 'package:base_object/models/backModel/userModel/UserInviteCountModel.dart';
import 'package:base_object/models/backModel/userModel/UserInviteInfoModel.dart';
import 'package:base_object/models/backModel/userModel/UserInviteModel.dart';
import 'package:base_object/models/backModel/userModel/UserModel.dart';
import 'package:base_object/models/backModel/userModel/UserPayLModel.dart';
import 'package:base_object/models/backModel/userModel/UserSonModel.dart';
import 'package:base_object/models/backModel/userModel/UserTodayModel.dart';
import 'package:base_object/models/backModel/userModel/UserWithdrawalModel.dart';
import 'package:base_object/models/backModel/userModel/WithdrawalModel.dart';
import 'package:base_object/models/backModel/verifyCodeImgModel/VerifyCodeImgModel.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';
import '../../models/FormModel/checkDeviceForm/CheckDeviceForm.dart';
import '../net/cu_http_client.dart';
import 'api_urls.dart';

class Api extends GetxController {
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

  /// 获取服务器版本信息
  Future<AppUpLoadModel> postUpApp(AppUpLoadForm data) async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getSystemInfo,
        data,
        "post",
      );
      if (backModel.data == null) {
        throw Exception('版本为空,无法解析${backModel.toJson()}');
      }
      AppUpLoadModel appUpLoadModel = AppUpLoadModel.fromJson(backModel.data);
      return appUpLoadModel;
    } catch (e) {
      Utils.logError(e);
      AppUpLoadModel appUpLoadModel = AppUpLoadModel();
      return appUpLoadModel;
    }
  }

  /// 获取新人是否领取过福利
  Future<NewUserModel> getNewcomerConfig() async {
    BackModel backModel = await _sendRequest(
      ApiUrls.getNewcomerConfig,
      FormModel(),
      "post",
    );
    if (backModel.data == null) {
      Utils.logError("新人福利返回为空");
      return NewUserModel();
    }
    return NewUserModel.fromJson(backModel.data);
  }

  /// 领取新人福利
  Future<BackModel> getNewcomer() async {
    return await _sendRequest(ApiUrls.getNewcomer, FormModel(), "post");
  }

  /// 获取首页公告列表
  Future<List<NoticeModel>> postNotice() async {
    BackModel backModel = await _sendRequest(
      ApiUrls.getNotice,
      FormModel(),
      "post",
    );
    if (backModel.data == null) {
      Utils.logError("公告列表返回为空");
      return [];
    }
    return NoticeModel.fromJsonList(backModel.data);
  }

  /// 获取客服配置{"channelPackage":"com.ruyimh.maingf"}
  /// index-0 Q群链接
  /// index-1 客服二维码
  /// index-2 客服联系方式
  Future<List<ServiceModel>> getServerConfig(AppUpLoadForm form) async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getServerConfig,
        form,
        "post",
      );
      if (backModel.data == null) {
        Utils.logError("获取客服配置为空");
        return [];
      }
      return ServiceModel.fromJsonList(backModel.data);
    } catch (e) {
      Utils.logError("getServerConfig请求出错: $e");
      return [];
    }
  }

  /// 获取看广告小技巧
  Future<List<NoticeModel>> getNoticeAD() async {
    BackModel backModel = await _sendRequest(
      ApiUrls.getNoticeAD,
      FormModel(),
      "post",
    );
    if (backModel.data == null) {
      Utils.logError("公告列表返回为空");
      return [];
    }
    return NoticeModel.fromJsonList(backModel.data);
  }

  /// 获取屏蔽快应用
  Future<List<NoticeModel>> getNoticeAPP() async {
    BackModel backModel = await _sendRequest(
      ApiUrls.getNoticeAPP,
      FormModel(),
      "post",
    );
    if (backModel.data == null) {
      Utils.logError("公告列表返回为空");
      return [];
    }
    return NoticeModel.fromJsonList(backModel.data);
  }

  /// 获取图片验证码
  Future<VerifyCodeImgModel> postVerifyCodeImg() async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getImgCode,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return VerifyCodeImgModel();
      }
      return VerifyCodeImgModel.fromJson(backModel.data);
    } catch (e) {
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

  /// 获取设备是否被风控
  Future<BackModel> getVer(CheckDeviceForm checkDeviceForm) async {
    try {
      return await _sendRequest(ApiUrls.getVer, checkDeviceForm, "post");
    } catch (e) {
      Utils.logError("getVer请求出错: $e");
      return BackModel();
    }
  }

  /// 获取风控配置
  Future<FKConfigVo> getFkConfig() async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getFkConfig,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return FKConfigVo();
      }
      return FKConfigVo.fromJson(backModel.data);
    } catch (e) {
      Utils.logError("postSendMobileCode请求出错: $e");
      return FKConfigVo();
    }
  }

  /// 提现方法
  Future<BackModel> getWithdrawalMoney(WithdrawalForm data) async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getWithdrawalMoney,
        data,
        "post",
      );
      return backModel;
    } catch (e) {
      Utils.logError("getWithdrawalMoney: $e");
      return BackModel();
    }
  }

  /// 设置密码
  Future<BackModel> getSetUser(LoginForm data) async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getSetUser,
        data,
        "post",
      );
      return backModel;
    } catch (e) {
      Utils.logError("getSetUser: $e");
      return BackModel();
    }
  }

  /// 副广告上报
  // Future<BackModel> getSelectAdV2(UpDataADForm data) async {
  //   try {
  //     BackModel backModel = await _sendRequest(
  //       ApiUrls.getSelectAdV2,
  //       data,
  //       "post",
  //     );
  //     return backModel;
  //   } catch (e) {
  //     Utils.logError("getSelectAdV2: $e");
  //     return BackModel();
  //   }
  // }
  /// 查询当前存钱罐余额
  Future<RewarderModel> getSelectAdV3() async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getSelectAdV3,
        FormModel(),
        "post",
      );
      Utils.logError("激励视频领取奖励返回的数据${backModel.toJson()}");
      return RewarderModel.fromJson(backModel.data);
    } catch (e) {
      Utils.logError("getSelectAdV3: $e");
      return RewarderModel();
    }
  }

  /// 副广告奖励领取
  Future<BackModel> getAdAmount() async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getAdAmount,
        FormModel(),
        "post",
      );
      return backModel;
    } catch (e) {
      Utils.logError("getSelectAdV2: $e");
      return BackModel();
    }
  }

  /// 激励视频领取奖励
  Future<RewarderModel> getSelectAd(UpDataADForm data) async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getSelectAd,
        data,
        "post",
      );
      Utils.logError("激励视频领取奖励返回的数据${backModel.toJson()}");
      return RewarderModel.fromJson(backModel.data);
    } catch (e) {
      Utils.logError("getSelectAd: $e");
      return RewarderModel();
    }
  }

  /// 绑定邀请码
  Future<BackModel> getBindInviteUser(LoginForm data) async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getBindInviteUser,
        data,
        "post",
      );
      return backModel;
    } catch (e) {
      Utils.logError("getBindInviteUser: $e");
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
    try {
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
    } catch (e) {
      Utils.logError("getUserInfo请求出错: $e");
      return UserModel();
    }
  }

  /// 获取用户今日收益
  Future<UserTodayModel> getTodayAmount() async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getTodayAmount,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return UserTodayModel();
      }
      final UserTodayModel userTodayModel = UserTodayModel.fromJson(
        backModel.data,
      );
      return userTodayModel;
    } catch (e) {
      Utils.logError("getTodayAmount请求出错: $e");
      return UserTodayModel();
    }
  }

  /// 获取用户收入明细
  Future<List<UserAmountListModel>> getUserAmountList() async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getUserAmountList,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return <UserAmountListModel>[];
      }
      final List<UserAmountListModel> userAmountListModel =
          UserAmountListModel.fromJsonList(backModel.data);
      return userAmountListModel;
    } catch (e) {
      Utils.logError("getUserAmountList: $e");
      return <UserAmountListModel>[];
    }
  }

  /// 用户邀新明细表
  Future<List<UserAmountListModel>> getInviteAmountList() async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getInviteAmountList,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return <UserAmountListModel>[];
      }
      final List<UserAmountListModel> userAmountListModel =
          UserAmountListModel.fromJsonList(backModel.data);
      return userAmountListModel;
    } catch (e) {
      Utils.logError("getInviteAmountList: $e");
      return <UserAmountListModel>[];
    }
  }

  /// 获取用户支出明细
  Future<List<UserWithdrawalModel>> getWithdrawalOrderList() async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getWithdrawalOrderList,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return <UserWithdrawalModel>[];
      }
      final List<UserWithdrawalModel> userWithdrawalModel =
          UserWithdrawalModel.fromJsonList(backModel.data);
      return userWithdrawalModel;
    } catch (e) {
      Utils.logError("getUserAmountList: $e");
      return <UserWithdrawalModel>[];
    }
  }

  /// 修改用户绑定的支付宝
  Future<BackModel> getUpdateBindPay(WithdrawalForm data) async {
    try {
      return await _sendRequest(ApiUrls.getUpdateBindPay, data, "post");
    } catch (e) {
      Utils.logError("getUpdateBindPay: $e");
      return BackModel();
    }
  }

  /// 删除用户绑定的支付宝
  Future<BackModel> getRemoveBindPay(WithdrawalForm data) async {
    try {
      return await _sendRequest(ApiUrls.getRemoveBindPay, data, "post");
    } catch (e) {
      Utils.logError("getRemoveBindPay: $e");
      return BackModel();
    }
  }

  /// 新增用户绑定的支付宝
  Future<BackModel> getBindAlipay(WithdrawalForm data) async {
    try {
      return await _sendRequest(ApiUrls.getBindAlipay, data, "post");
    } catch (e) {
      Utils.logError("getBindAlipay: $e");
      return BackModel();
    }
  }

  /// 获取用户绑定的支付包列表
  Future<List<UserPayLModel>> getPayList(FormModel data) async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getPayList,
        data,
        "post",
      );
      if (backModel.data == null) {
        return <UserPayLModel>[];
      }
      final List<UserPayLModel> userPayLModel = UserPayLModel.fromJsonList(
        backModel.data,
      );
      return userPayLModel;
    } catch (e) {
      Utils.logError("getUserAmountList: $e");
      return <UserPayLModel>[];
    }
  }

  /// 邀请好友-邀请信息
  Future<UserInviteCountModel> getInviteInfo() async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getInviteInfo,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return UserInviteCountModel();
      }
      final UserInviteCountModel userInviteCountModel =
          UserInviteCountModel.fromJson(backModel.data);
      return userInviteCountModel;
    } catch (e) {
      Utils.logError("getInviteInfo: $e");
      return UserInviteCountModel();
    }
  }

  /// 我要提现-可选择的提现列表
  Future<List<WithdrawalModel>> getWithdrawalList() async {
    try {
      AppUpLoadForm form = AppUpLoadForm();
      form.channelPackage = Store.instance.getAppUpLoadModel.channelPackage;
      BackModel backModel = await _sendRequest(
        ApiUrls.getWithdrawalList,
        form,
        "post",
      );
      if (backModel.data == null) {
        return <WithdrawalModel>[];
      }
      final List<WithdrawalModel> withdrawalModel =
          WithdrawalModel.fromJsonList(backModel.data);
      return withdrawalModel;
    } catch (e) {
      Utils.logError("getWithdrawalList: $e");
      return <WithdrawalModel>[];
    }
  }

  /// 邀请好友-邀请任务
  Future<List<UserInviteModel>> getInviteList() async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getInviteList,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return <UserInviteModel>[];
      }
      final List<UserInviteModel> userInviteModel =
          UserInviteModel.fromJsonList(backModel.data);
      return userInviteModel;
    } catch (e) {
      Utils.logError("getInviteList: $e");
      return <UserInviteModel>[];
    }
  }

  /// 邀请-我的推广信息
  Future<UserInviteInfoModel> getMyInviteInfo() async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getMyInviteInfo,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return UserInviteInfoModel();
      }
      final UserInviteInfoModel userInviteInfoModel =
          UserInviteInfoModel.fromJson(backModel.data);
      return userInviteInfoModel;
    } catch (e) {
      Utils.logError("getMyInviteInfo: $e");
      return UserInviteInfoModel();
    }
  }

  /// 邀请-我的钱包
  Future<UserBayModel> getInviteMyBag() async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getInviteMyBag,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return UserBayModel();
      }
      final UserBayModel userBayModel = UserBayModel.fromJson(backModel.data);
      return userBayModel;
    } catch (e) {
      Utils.logError("getMyInviteInfo: $e");
      return UserBayModel();
    }
  }

  /// 邀请-我的粉丝列表
  Future<UserSonModel> getInviteMyInvite() async {
    try {
      BackModel backModel = await _sendRequest(
        ApiUrls.getInviteMyInvite,
        FormModel(),
        "post",
      );
      if (backModel.data == null) {
        return UserSonModel();
      }
      final UserSonModel userSonModel = UserSonModel.fromJson(backModel.data);
      return userSonModel;
    } catch (e) {
      Utils.logError("getMyInviteInfo: $e");
      return UserSonModel();
    }
  }
}
