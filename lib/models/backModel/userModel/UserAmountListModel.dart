import 'package:json_annotation/json_annotation.dart';

part 'UserAmountListModel.g.dart';
/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class UserAmountListModel {
  int id = 0;
  /// 收入状态
  int type = 0;
  /// 收入金额
  double initAmount = 0;
  /// 收入时间
  String createTime = "";
  /// 用户收入列表
  UserAmountListModel();
  //不同的类使用不同的mixin即可
  factory UserAmountListModel.fromJson(Map<String, dynamic> json) =>
      _$UserAmountListModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserAmountListModelToJson(this);
  static List<UserAmountListModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserAmountListModel.fromJson(json)).toList();
  }
}
