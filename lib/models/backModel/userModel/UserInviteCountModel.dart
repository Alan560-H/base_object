import 'package:json_annotation/json_annotation.dart';

part 'UserInviteCountModel.g.dart';
/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class UserInviteCountModel {
  /// 已邀请人数
  double inviteNum = 0;
  /// 已赚金额
  double inviteAmount = 0;
  /// 可提现金额
  double currentAmount = 0;
  /// 邀请好友界面，邀请信息
  UserInviteCountModel();
  //不同的类使用不同的mixin即可
  factory UserInviteCountModel.fromJson(Map<String, dynamic> json) =>
      _$UserInviteCountModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserInviteCountModelToJson(this);
  static List<UserInviteCountModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserInviteCountModel.fromJson(json)).toList();
  }
}
