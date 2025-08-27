import 'package:json_annotation/json_annotation.dart';

import '../FormModel.dart';

part 'UpDataADForm.g.dart';

/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch

@JsonSerializable()
class UpDataADForm extends FormModel {
  /// 手机号
  String extra = "";
  /// 名字
  double? amount = 0;
  String? transId = "";
  /// 上报广告
  UpDataADForm();
  //不同的类使用不同的mixin即可
  factory UpDataADForm.fromJson(Map<String, dynamic> json) =>
      _$UpDataADFormFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UpDataADFormToJson(this);
}
