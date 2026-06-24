// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FKConfigVo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FKConfigVo _$FKConfigVoFromJson(Map<String, dynamic> json) =>
    FKConfigVo()
      ..wactchMaxAmount = (json['wactchMaxAmount'] as num).toInt()
      ..wactchMinAmount = (json['wactchMinAmount'] as num).toInt()
      ..hourMaxAmount = (json['hourMaxAmount'] as num).toInt()
      ..hourMax = (json['hourMax'] as num).toInt()
      ..dayMax = (json['dayMax'] as num).toInt()
      ..wactchMax = (json['wactchMax'] as num).toInt()
      ..wactchMin = (json['wactchMin'] as num).toInt()
      ..adTime = (json['adTime'] as num).toInt()
      ..wactchTime = (json['wactchTime'] as num).toInt()
      ..wactchMaxAmountV1 = (json['wactchMaxAmountV1'] as num).toInt()
      ..wactchMinAmountV1 = (json['wactchMinAmountV1'] as num).toInt()
      ..hourMaxAmountV1 = (json['hourMaxAmountV1'] as num).toInt()
      ..hourMaxV1 = (json['hourMaxV1'] as num).toInt()
      ..dayMaxV1 = (json['dayMaxV1'] as num).toInt()
      ..wactchMaxV1 = (json['wactchMaxV1'] as num).toInt()
      ..wactchMinV1 = (json['wactchMinV1'] as num).toInt()
      ..amountMin = (json['amountMin'] as num).toInt()
      ..adv1Time = (json['adv1Time'] as num).toInt();

Map<String, dynamic> _$FKConfigVoToJson(FKConfigVo instance) =>
    <String, dynamic>{
      'wactchMaxAmount': instance.wactchMaxAmount,
      'wactchMinAmount': instance.wactchMinAmount,
      'hourMaxAmount': instance.hourMaxAmount,
      'hourMax': instance.hourMax,
      'dayMax': instance.dayMax,
      'wactchMax': instance.wactchMax,
      'wactchMin': instance.wactchMin,
      'adTime': instance.adTime,
      'wactchTime': instance.wactchTime,
      'wactchMaxAmountV1': instance.wactchMaxAmountV1,
      'wactchMinAmountV1': instance.wactchMinAmountV1,
      'hourMaxAmountV1': instance.hourMaxAmountV1,
      'hourMaxV1': instance.hourMaxV1,
      'dayMaxV1': instance.dayMaxV1,
      'wactchMaxV1': instance.wactchMaxV1,
      'wactchMinV1': instance.wactchMinV1,
      'amountMin': instance.amountMin,
      'adv1Time': instance.adv1Time,
    };

CurrentCountVo _$CurrentCountVoFromJson(Map<String, dynamic> json) =>
    CurrentCountVo()
      ..dayMaxCount = (json['dayMaxCount'] as num).toInt()
      ..hourMaxAmountV1Count = (json['hourMaxAmountV1Count'] as num).toDouble()
      ..wactchMaxAmountCount = (json['wactchMaxAmountCount'] as num).toDouble()
      ..wactchMaxAmountV1Count =
          (json['wactchMaxAmountV1Count'] as num).toDouble();

Map<String, dynamic> _$CurrentCountVoToJson(CurrentCountVo instance) =>
    <String, dynamic>{
      'dayMaxCount': instance.dayMaxCount,
      'hourMaxAmountV1Count': instance.hourMaxAmountV1Count,
      'wactchMaxAmountCount': instance.wactchMaxAmountCount,
      'wactchMaxAmountV1Count': instance.wactchMaxAmountV1Count,
    };
