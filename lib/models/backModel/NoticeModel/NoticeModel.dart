
import 'package:json_annotation/json_annotation.dart';

part 'NoticeModel.g.dart';
/// 公告
@JsonSerializable()
class NoticeModel {

  /// id
  String content = "";
  /// 活动id
  int id=0;
  /// 公告名称
  String name="";
  /// 公告名称
  String timeCreate="";
  /// 公告
  NoticeModel();

  //不同的类使用不同的mixin即可
  factory NoticeModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeModelFromJson(json);

  Map<String, dynamic> toJson() => _$NoticeModelToJson(this);
  // 从 JSON 数组创建 MoviceListModel 列表
  static List<NoticeModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => NoticeModel.fromJson(json)).toList();
  }
}