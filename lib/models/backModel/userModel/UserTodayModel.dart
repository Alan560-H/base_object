import 'package:json_annotation/json_annotation.dart';

part 'UserTodayModel.g.dart';
/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class UserTodayModel {
  /// 今日收益
  double todayAmount = 0;
  /// 当前收益
  double currentAmount = 0;
  /// 用户今日收益
  UserTodayModel();
  //不同的类使用不同的mixin即可
  factory UserTodayModel.fromJson(Map<String, dynamic> json) =>
      _$UserTodayModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserTodayModelToJson(this);
}
