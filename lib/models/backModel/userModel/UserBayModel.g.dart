// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserBayModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBayModel _$UserBayModelFromJson(Map<String, dynamic> json) =>
    UserBayModel()
      ..currentAmount = (json['currentAmount'] as num).toDouble()
      ..todayAmount = (json['todayAmount'] as num).toDouble()
      ..yesterdayAmount = (json['yesterdayAmount'] as num).toDouble()
      ..amount = (json['amount'] as num).toDouble();

Map<String, dynamic> _$UserBayModelToJson(UserBayModel instance) =>
    <String, dynamic>{
      'currentAmount': instance.currentAmount,
      'todayAmount': instance.todayAmount,
      'yesterdayAmount': instance.yesterdayAmount,
      'amount': instance.amount,
    };
