import 'package:json_annotation/json_annotation.dart';

part 'UserInviteModel.g.dart';
/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class UserInviteModel {
  int id = 0;
  /// 副标题
  String remark = "";
  /// 主标题
  String title = "";
  /// 提现
  double withdrawal = 0;
  /// 金币
  double benefit = 0;
  /// 用户今日收益
  UserInviteModel();
  //不同的类使用不同的mixin即可
  factory UserInviteModel.fromJson(Map<String, dynamic> json) =>
      _$UserInviteModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserInviteModelToJson(this);
  static List<UserInviteModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserInviteModel.fromJson(json)).toList();
  }
}
