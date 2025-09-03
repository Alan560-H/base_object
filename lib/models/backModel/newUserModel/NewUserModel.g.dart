// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NewUserModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewUserModel _$NewUserModelFromJson(Map<String, dynamic> json) =>
    NewUserModel()
      ..id = (json['id'] as num?)?.toInt()
      ..name = json['name'] as String
      ..remark = json['remark'] as String
      ..status = (json['status'] as num).toInt();

Map<String, dynamic> _$NewUserModelToJson(NewUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'remark': instance.remark,
      'status': instance.status,
    };
