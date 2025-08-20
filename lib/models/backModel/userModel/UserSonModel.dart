import 'package:json_annotation/json_annotation.dart';

part 'UserSonModel.g.dart';
/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class UserSonModel {
  int id = 0;
  ///
  String username = "";
  ///
  String headImage = "";
  /// 获得金额
  double amount = 0;
  /// 我的粉丝列表
  UserSonModel();
  //不同的类使用不同的mixin即可
  factory UserSonModel.fromJson(Map<String, dynamic> json) =>
      _$UserSonModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserSonModelToJson(this);
  static List<UserSonModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserSonModel.fromJson(json)).toList();
  }
}
