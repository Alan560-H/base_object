// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CheckDeviceForm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckDeviceForm _$CheckDeviceFormFromJson(Map<String, dynamic> json) =>
    CheckDeviceForm()
      ..locale = json['locale'] as String
      ..playform = (json['playform'] as num).toInt()
      ..sid = (json['sid'] as num).toInt()
      ..channelPackage = json['channelPackage'] as String?
      ..type = json['type']
      ..oaid = json['oaid'] as String?
      ..userId = (json['userId'] as num?)?.toInt()
      ..reqId = json['reqId'] as String?
      ..adsourceId = json['adsourceId'] as String?
      ..sign = json['sign'] as String?;

Map<String, dynamic> _$CheckDeviceFormToJson(CheckDeviceForm instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'playform': instance.playform,
      'sid': instance.sid,
      'channelPackage': instance.channelPackage,
      'type': instance.type,
      'oaid': instance.oaid,
      'userId': instance.userId,
      'reqId': instance.reqId,
      'adsourceId': instance.adsourceId,
      'sign': instance.sign,
    };
