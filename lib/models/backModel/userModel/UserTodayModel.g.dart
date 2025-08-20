// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserTodayModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTodayModel _$UserTodayModelFromJson(Map<String, dynamic> json) =>
    UserTodayModel()
      ..todayAmount = (json['todayAmount'] as num).toDouble()
      ..currentAmount = (json['currentAmount'] as num).toDouble();

Map<String, dynamic> _$UserTodayModelToJson(UserTodayModel instance) =>
    <String, dynamic>{
      'todayAmount': instance.todayAmount,
      'currentAmount': instance.currentAmount,
    };
