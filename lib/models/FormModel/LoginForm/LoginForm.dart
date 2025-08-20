import 'package:json_annotation/json_annotation.dart';

import '../FormModel.dart';

part 'LoginForm.g.dart';

/**
 * 手动构建： flutter packages pub run build_runner build
 * 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
 * 自动构建:  flutter packages pub run build_runner watch
 */



/// 账号登录
@JsonSerializable()
class LoginForm extends FormModel {
  /// 密码
  String? oaid ="";
  /// ua
  String? ua="";
  /// 返回url
  String? trenchUrl ="";
  /// 渠道包名
  String? channelPackage = "";
  /// ?
  String? bdId = "";
  String? qhId = "";
  String? inviteCode = "";
  /// 手机号
  String? mobile = "";
  /// 手机号验证码
  String? mobileCode = "";
  /// 账号
  String? account = "";
  /// 密码
  String? password = "";
  /// 一键登录/注册accessToken
  String? accessToken = "";

  /// 密码
  /// //loginType是1的情况下 账号密码登录,account, password 是必传
  // //loginType是2的情况下 手机验证码登录/注册,mobile,mobileCode 是必传
  // //loginType是3的情况下 一键登录/注册accessToken 是必传的
  // //loginType是4的情况下 落地页手机号验证码注册,mobile,mobileCode 是必传
  int loginType = 1;



  /// 账号登录
  LoginForm();
  //不同的类使用不同的mixin即可
  factory LoginForm.fromJson(Map<String, dynamic> json) =>
      _$LoginFormFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LoginFormToJson(this);
}
