import 'package:json_annotation/json_annotation.dart';

part 'TaskModel.g.dart';

/// 公告
@JsonSerializable()
class TaskModel {
  /// 任务id
  int taskId = 0;

  /// 任务状态 0-未完成 1-已完成
  int taskStatus = 0;

  /// 任务名称
  String taskName = "";

  /// 任务描述
  String taskDesc = "";

  /// 任务类型 1：签到任务 2：低保任务
  int taskType = 0;

  /// 任务进度 ：用于低保任务
  int taskProgress = 0;

  /// 任务
  TaskModel();

  //不同的类使用不同的mixin即可
  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
  // 从 JSON 数组创建 MoviceListModel 列表
  static List<TaskModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => TaskModel.fromJson(json)).toList();
  }
}
