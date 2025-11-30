import 'package:json_annotation/json_annotation.dart';

part 'SignModel.g.dart';

/// 签到模型
@JsonSerializable()
class SignModel {
  /// 活动id
  int id = 0;

  /// 签到的信息
  String label = "";

  /// 签到奖励信息
  String title = "";

  /// status 0.未达成 1.待领取 2.已领取
  int status = 0;

  /// amount 奖励的金币数
  int amount = 0;

  /// num 天数
  int num = 0;

  /// 公告
  SignModel();

  //不同的类使用不同的mixin即可
  factory SignModel.fromJson(Map<String, dynamic> json) =>
      _$SignModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignModelToJson(this);
  // 从 JSON 数组创建 MoviceListModel 列表
  static List<SignModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => SignModel.fromJson(json)).toList();
  }
}
