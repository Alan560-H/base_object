import 'package:json_annotation/json_annotation.dart';

part 'UserInviteInfoModel.g.dart';
/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class UserInviteInfoModel {
  /// 总邀请人数
  int inviteNum = 0;
  /// 今日收益
  double todayAmount = 0;
  /// 昨日邀请人数
  int yesterdayNum = 0;
  /// 今日邀请人数
  int todayNum = 0;
  /// 我的推广信息
  UserInviteInfoModel();
  //不同的类使用不同的mixin即可
  factory UserInviteInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInviteInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserInviteInfoModelToJson(this);
  static List<UserInviteInfoModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserInviteInfoModel.fromJson(json)).toList();
  }
}
