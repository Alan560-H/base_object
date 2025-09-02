
import 'package:json_annotation/json_annotation.dart';

part 'NewUserModel.g.dart';

/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch

/// 公告
@JsonSerializable()
class NewUserModel {

  /// id
  int? id=0;
  /// 名称
  String name="";
  /// 新人福利名字
  String remark="";
  /// 状态 0 未领取 1 已领取
  int status = 0;
  /// 公告
  NewUserModel();

  //不同的类使用不同的mixin即可
  factory NewUserModel.fromJson(Map<String, dynamic> json) =>
      _$NewUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$NewUserModelToJson(this);

}