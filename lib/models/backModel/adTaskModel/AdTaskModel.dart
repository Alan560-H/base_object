import 'package:json_annotation/json_annotation.dart';

part 'AdTaskModel.g.dart';

/// 看广告保底奖励配置
@JsonSerializable()
class AdTaskModel {
  ///  保底奖励的金币数量
  int amount = 0;

  /// 保底需要看的广告数量
  int numConfig = 0;

  /// 用户已经看的广告数量
  int userNum = 0;

  /// status 0.未达成 1.待领取 2.已领取
  int status = 0;

  /// 公告
  AdTaskModel();

  //不同的类使用不同的mixin即可
  factory AdTaskModel.fromJson(Map<String, dynamic> json) =>
      _$AdTaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdTaskModelToJson(this);
  // 从 JSON 数组创建 MoviceListModel 列表
  static List<AdTaskModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AdTaskModel.fromJson(json)).toList();
  }
}
