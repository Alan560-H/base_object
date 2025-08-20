import 'package:json_annotation/json_annotation.dart';

part 'UserWithdrawalModel.g.dart';
/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class UserWithdrawalModel {
  int id = 0;
  /// 提现金额
  double payMoney = 0;
  /// 提现状态
  double status = 0;
  /// 提现时间
  String payTime = "";
  /// 用户提现列表
  UserWithdrawalModel();
  //不同的类使用不同的mixin即可
  factory UserWithdrawalModel.fromJson(Map<String, dynamic> json) =>
      _$UserWithdrawalModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserWithdrawalModelToJson(this);
  static List<UserWithdrawalModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserWithdrawalModel.fromJson(json)).toList();
  }
}
