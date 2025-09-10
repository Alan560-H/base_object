// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UpDataADForm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpDataADForm _$UpDataADFormFromJson(Map<String, dynamic> json) =>
    UpDataADForm()
      ..locale = json['locale'] as String
      ..playform = (json['playform'] as num).toInt()
      ..sid = (json['sid'] as num).toInt()
      ..channelPackage = json['channelPackage'] as String?
      ..type = json['type']
      ..extra = json['extra'] as String
      ..amount = (json['amount'] as num?)?.toDouble()
      ..transId = json['transId'] as String?
      ..reqId = json['reqId'] as String?
      ..adsourceId = json['adsourceId'] as String?
      ..sign = json['sign'] as String?;

Map<String, dynamic> _$UpDataADFormToJson(UpDataADForm instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'playform': instance.playform,
      'sid': instance.sid,
      'channelPackage': instance.channelPackage,
      'type': instance.type,
      'extra': instance.extra,
      'amount': instance.amount,
      'transId': instance.transId,
      'reqId': instance.reqId,
      'adsourceId': instance.adsourceId,
      'sign': instance.sign,
    };
