// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NoticeModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoticeModel _$NoticeModelFromJson(Map<String, dynamic> json) =>
    NoticeModel()
      ..content = json['content'] as String
      ..id = (json['id'] as num?)?.toInt()
      ..name = json['name'] as String
      ..timeCreate = json['timeCreate'] as String?;

Map<String, dynamic> _$NoticeModelToJson(NoticeModel instance) =>
    <String, dynamic>{
      'content': instance.content,
      'id': instance.id,
      'name': instance.name,
      'timeCreate': instance.timeCreate,
    };
