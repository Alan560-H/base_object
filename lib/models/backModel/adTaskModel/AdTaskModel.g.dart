// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AdTaskModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdTaskModel _$AdTaskModelFromJson(Map<String, dynamic> json) =>
    AdTaskModel()
      ..amount = (json['amount'] as num).toInt()
      ..numConfig = (json['numConfig'] as num).toInt()
      ..userNum = (json['userNum'] as num).toInt()
      ..status = (json['status'] as num).toInt();

Map<String, dynamic> _$AdTaskModelToJson(AdTaskModel instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'numConfig': instance.numConfig,
      'userNum': instance.userNum,
      'status': instance.status,
    };
