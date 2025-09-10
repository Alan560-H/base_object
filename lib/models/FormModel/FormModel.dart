// ignore: file_names
import 'package:json_annotation/json_annotation.dart';

part 'FormModel.g.dart';

/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class FormModel {
  /// 基础的 语言
  String locale = "CN";

  /// 平台
  int playform = 0;

  ///sid
  int sid = 1100;

  ///通道名字
  String? channelPackage;
  // 任意类型type
  dynamic type;

  FormModel();
  //不同的类使用不同的mixin即可
  factory FormModel.fromJson(Map<String, dynamic> json) =>
      _$FormModelFromJson(json);

  Map<String, dynamic> toJson() => _$FormModelToJson(this);
}
