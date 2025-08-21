// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WithdrawalModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawalModel _$WithdrawalModelFromJson(Map<String, dynamic> json) =>
    WithdrawalModel()
      ..id = (json['id'] as num).toInt()
      ..money = (json['money'] as num).toDouble()
      ..remark = json['remark'] as String;

Map<String, dynamic> _$WithdrawalModelToJson(WithdrawalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'money': instance.money,
      'remark': instance.remark,
    };
