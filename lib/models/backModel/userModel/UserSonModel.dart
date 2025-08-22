import 'package:json_annotation/json_annotation.dart';

part 'UserSonModel.g.dart';
/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
///
@JsonSerializable()
class SonModel{
  int id = 0;
  /// 粉丝收入金额
  double amount = 0;
  /// 粉丝昵称
  String username = "";
  /// 粉丝头像
  String headImage = "";
  /// 徒弟模型
  SonModel();
  //不同的类使用不同的mixin即可
  factory SonModel.fromJson(Map<String, dynamic> json) =>
      _$SonModelFromJson(json);

  Map<String, dynamic> toJson() => _$SonModelToJson(this);
  static List<SonModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => SonModel.fromJson(json)).toList();
  }
}
///
@JsonSerializable()
class UserSonModel {
  /// 徒弟数量
  int inviteNum = 0;
  /// 已赚金额
  double inviteAmount = 0;
  /// 我的粉丝列表
  List<SonModel> userList = <SonModel>[];
  /// 我的徒弟列表
  UserSonModel();
  //不同的类使用不同的mixin即可
  factory UserSonModel.fromJson(Map<String, dynamic> json) =>
      _$UserSonModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserSonModelToJson(this);

}
