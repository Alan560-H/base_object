import 'package:json_annotation/json_annotation.dart';

import '../FormModel.dart';

part 'WithdrawalForm.g.dart';

/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch

@JsonSerializable()
class WithdrawalForm extends FormModel {
  /// 手机号
  String payAccount = "";

  /// 名字
  String payName = "";

  /// 金额id
  int? amountId;

  /// id
  int? id;

  /// 发送验证码 type = 0
  WithdrawalForm();
  //不同的类使用不同的mixin即可
  factory WithdrawalForm.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalFormFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WithdrawalFormToJson(this);
}
