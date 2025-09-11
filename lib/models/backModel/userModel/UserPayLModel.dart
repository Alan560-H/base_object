import 'package:json_annotation/json_annotation.dart';

part 'UserPayLModel.g.dart';

/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class UserPayLModel {
  int id = 0;
  int userId = 0;

  /// 账户名称
  String payName = "";

  /// 账户
  String payAccount = "";

  /// 绑定的支付宝列表
  UserPayLModel();
  //不同的类使用不同的mixin即可
  factory UserPayLModel.fromJson(Map<String, dynamic> json) =>
      _$UserPayLModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserPayLModelToJson(this);
  static List<UserPayLModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserPayLModel.fromJson(json)).toList();
  }
}
