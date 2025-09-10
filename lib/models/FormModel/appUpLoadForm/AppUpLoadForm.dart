import 'package:json_annotation/json_annotation.dart';

import '../FormModel.dart';

part 'AppUpLoadForm.g.dart';

@JsonSerializable()
class AppUpLoadForm extends FormModel {
  /// 设备deviceId
  String? deviceId = "";

  /// 设备oaid
  String? oaid = "";

  /// 设备imei
  String? imei = "";
  AppUpLoadForm();

  //不同的类使用不同的mixin即可
  factory AppUpLoadForm.fromJson(Map<String, dynamic> json) =>
      _$AppUpLoadFormFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AppUpLoadFormToJson(this);
}
