// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BackModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackModel _$BackModelFromJson(Map<String, dynamic> json) =>
    BackModel()
      ..code = json['code'] as String
      ..msg = json['msg'] as String
      ..data = json['data'];

Map<String, dynamic> _$BackModelToJson(BackModel instance) => <String, dynamic>{
  'code': instance.code,
  'msg': instance.msg,
  'data': instance.data,
};
