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
      ..type = json['type']
      ..extra = json['extra'] as String
      ..amount = (json['amount'] as num?)?.toDouble();

Map<String, dynamic> _$UpDataADFormToJson(UpDataADForm instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'playform': instance.playform,
      'sid': instance.sid,
      'type': instance.type,
      'extra': instance.extra,
      'amount': instance.amount,
    };
