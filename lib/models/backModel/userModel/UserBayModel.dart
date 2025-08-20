import 'package:json_annotation/json_annotation.dart';

part 'UserBayModel.g.dart';
/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class UserBayModel {
  /// 可提现金额
  double currentAmount = 0;
  /// 当日金额
  double todayAmount = 0;
  /// 昨日金额
  double yesterdayAmount = 0;
  /// 累计金额
  double amount = 0;
  /// 我的钱包
  UserBayModel();
  //不同的类使用不同的mixin即可
  factory UserBayModel.fromJson(Map<String, dynamic> json) =>
      _$UserBayModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserBayModelToJson(this);
  static List<UserBayModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserBayModel.fromJson(json)).toList();
  }
}
