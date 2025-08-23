import 'package:json_annotation/json_annotation.dart';

part 'RewarderModel.g.dart';

// ignore: slash_for_doc_comments
/**
 * 手动构建： flutter packages pub run build_runner build
 * 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
 * 自动构建:  flutter packages pub run build_runner watch
 */
/// 查询广告奖励
@JsonSerializable()
class RewarderModel {
  /// 图片base64
  double amount = 0;

  /// 查询广告奖励
  RewarderModel();

  //不同的类使用不同的mixin即可
  factory RewarderModel.fromJson(Map<String, dynamic> json) =>
      _$RewarderModelFromJson(json);

  Map<String, dynamic> toJson() => _$RewarderModelToJson(this);
}
