import 'package:json_annotation/json_annotation.dart';

part 'UserModel.g.dart';
/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class UserModel {
  /// 用户id
  int id = 0;
  /// 账号
  String account = "";
  /// 昵称
  String username = "";
  /// 头像
  String headImage = "";
  /// 认证状态
  int authentication = 0;
  /// 推广码
  String inviteCode = "";
  /// 手机号
  String mobile = "";
  /// 当前收益
  double currentAmount = 0;
  /// 累计收益
  double amount = 0;
  /// 可提现金额
  double money = 0;
  /// 今日收益
  double? todayAmount = 0;
  /// 用户信息
  UserModel();
  //不同的类使用不同的mixin即可
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
