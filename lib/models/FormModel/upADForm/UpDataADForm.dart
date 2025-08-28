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
  /// 预估价格（主广，副广用）
  double? amount = 0;
  /// 激励视频用。
  String? transId = "";


  /// 副广用
  /// 请求id
  String? reqId = "";
  /// 广告源id
  String? adsourceId = "";
  /// 副广 加密参数 sign = MD5(base64(用户id+req_id+adsource_id))
  String? sign = "";
  /// 上报广告
  UpDataADForm();
  //不同的类使用不同的mixin即可
  factory UpDataADForm.fromJson(Map<String, dynamic> json) =>
      _$UpDataADFormFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UpDataADFormToJson(this);
}
