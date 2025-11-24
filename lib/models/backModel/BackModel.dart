import 'package:json_annotation/json_annotation.dart';

part 'BackModel.g.dart';

/// 手动构建： dart pub run build_runner build
/// 全部构建:  dart run build_runner build --delete-conflicting-outputs
/// 自动构建:  dart pub run build_runner watch
@JsonSerializable()
class BackModel {
  String code = '';
  String msg = '';
  dynamic data;

  BackModel();

  //不同的类使用不同的mixin即可
  factory BackModel.fromJson(Map<String, dynamic> json) =>
      _$BackModelFromJson(json);

  Map<String, dynamic> toJson() => _$BackModelToJson(this);
}
