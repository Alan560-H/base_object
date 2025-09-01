import 'package:json_annotation/json_annotation.dart';

import '../FormModel.dart';

part 'CheckDeviceForm.g.dart';

/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
// type:1查询
// type:2上传
@JsonSerializable()
class CheckDeviceForm extends FormModel {
  /// 手机号
  String? oaid = "";
  /// 预估价格（主广，副广用）
  double? userId = 0;



  /// 副广用
  /// 请求id
  String? reqId = "";
  /// 广告源id
  String? adsourceId = "";
  /// 副广 加密参数 sign = MD5(base64(用户id+req_id+adsource_id))
  String? sign = "";
  /// 上报广告
  CheckDeviceForm();
  //不同的类使用不同的mixin即可
  factory CheckDeviceForm.fromJson(Map<String, dynamic> json) =>
      _$CheckDeviceFormFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CheckDeviceFormToJson(this);
}
