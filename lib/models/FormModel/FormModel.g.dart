// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FormModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormModel _$FormModelFromJson(Map<String, dynamic> json) =>
    FormModel()
      ..locale = json['locale'] as String
      ..playform = (json['playform'] as num).toInt()
      ..sid = (json['sid'] as num).toInt()
      ..channelPackage = json['channelPackage'] as String?
      ..type = json['type'];

Map<String, dynamic> _$FormModelToJson(FormModel instance) => <String, dynamic>{
  'locale': instance.locale,
  'playform': instance.playform,
  'sid': instance.sid,
  'channelPackage': instance.channelPackage,
  'type': instance.type,
};
