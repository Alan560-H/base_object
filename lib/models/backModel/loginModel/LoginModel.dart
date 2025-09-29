import 'package:json_annotation/json_annotation.dart';

part 'LoginModel.g.dart';

/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class LoginModel {
  /// 用户id
  int? id = 0;

  /// 微信头像 可有可无
  String? headImage = "";

  /// 账号
  String? account = "";

  /// 昵称
  String? username = "";

  /// token 名字
  String tokenName = "";

  /// token
  String tokenValue = "";

  /// 登录返回数据
  LoginModel();
  //不同的类使用不同的mixin即可
  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}
