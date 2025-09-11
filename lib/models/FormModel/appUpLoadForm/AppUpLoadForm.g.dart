// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppUpLoadForm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUpLoadForm _$AppUpLoadFormFromJson(Map<String, dynamic> json) =>
    AppUpLoadForm()
      ..locale = json['locale'] as String
      ..playform = (json['playform'] as num).toInt()
      ..sid = (json['sid'] as num).toInt()
      ..channelPackage = json['channelPackage'] as String?
      ..type = json['type']
      ..deviceId = json['deviceId'] as String?
      ..oaid = json['oaid'] as String?
      ..imei = json['imei'] as String?;

Map<String, dynamic> _$AppUpLoadFormToJson(AppUpLoadForm instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'playform': instance.playform,
      'sid': instance.sid,
      'channelPackage': instance.channelPackage,
      'type': instance.type,
      'deviceId': instance.deviceId,
      'oaid': instance.oaid,
      'imei': instance.imei,
    };
