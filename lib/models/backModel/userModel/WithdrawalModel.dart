import 'package:json_annotation/json_annotation.dart';

part 'WithdrawalModel.g.dart';
/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class WithdrawalModel {
  int id = 0;
  /// 提现金额
  double money = 0;
  /// 提现描述
  String remark = "";
  /// 用户提现列表
  WithdrawalModel();
  //不同的类使用不同的mixin即可
  factory WithdrawalModel.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalModelFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawalModelToJson(this);
  static List<WithdrawalModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => WithdrawalModel.fromJson(json)).toList();
  }
}
