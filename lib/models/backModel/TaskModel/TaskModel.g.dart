// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TaskModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) =>
    TaskModel()
      ..taskId = (json['taskId'] as num).toInt()
      ..taskStatus = (json['taskStatus'] as num).toInt()
      ..taskName = json['taskName'] as String
      ..taskDesc = json['taskDesc'] as String
      ..taskType = (json['taskType'] as num).toInt()
      ..taskProgress = (json['taskProgress'] as num).toInt();

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'taskId': instance.taskId,
  'taskStatus': instance.taskStatus,
  'taskName': instance.taskName,
  'taskDesc': instance.taskDesc,
  'taskType': instance.taskType,
  'taskProgress': instance.taskProgress,
};
