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
      ..address = json['address'] as String?
      ..reqId = json['reqId'] as String?
      ..adsourceId = json['adsourceId'] as String?
      ..sign = json['sign'] as String?
      ..latitude = (json['latitude'] as num?)?.toDouble()
      ..longitude = (json['longitude'] as num?)?.toDouble()
      ..msg = json['msg'] as String?;

Map<String, dynamic> _$CheckDeviceFormToJson(CheckDeviceForm instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'playform': instance.playform,
      'sid': instance.sid,
      'channelPackage': instance.channelPackage,
      'type': instance.type,
      'oaid': instance.oaid,
      'userId': instance.userId,
      'address': instance.address,
      'reqId': instance.reqId,
      'adsourceId': instance.adsourceId,
      'sign': instance.sign,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'msg': instance.msg,
    };
