// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserInviteInfoModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInviteInfoModel _$UserInviteInfoModelFromJson(Map<String, dynamic> json) =>
    UserInviteInfoModel()
      ..inviteNum = (json['inviteNum'] as num).toInt()
      ..todayAmount = (json['todayAmount'] as num).toDouble()
      ..yesterdayNum = (json['yesterdayNum'] as num).toInt()
      ..todayNum = (json['todayNum'] as num).toInt()
      ..inviteAmount = (json['inviteAmount'] as num?)?.toDouble();

Map<String, dynamic> _$UserInviteInfoModelToJson(
  UserInviteInfoModel instance,
) => <String, dynamic>{
  'inviteNum': instance.inviteNum,
  'todayAmount': instance.todayAmount,
  'yesterdayNum': instance.yesterdayNum,
  'todayNum': instance.todayNum,
  'inviteAmount': instance.inviteAmount,
};
