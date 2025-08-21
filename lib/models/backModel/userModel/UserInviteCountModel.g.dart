// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserInviteCountModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInviteCountModel _$UserInviteCountModelFromJson(
  Map<String, dynamic> json,
) =>
    UserInviteCountModel()
      ..inviteNum = (json['inviteNum'] as num).toDouble()
      ..inviteAmount = (json['inviteAmount'] as num).toDouble()
      ..currentAmount = (json['currentAmount'] as num).toDouble();

Map<String, dynamic> _$UserInviteCountModelToJson(
  UserInviteCountModel instance,
) => <String, dynamic>{
  'inviteNum': instance.inviteNum,
  'inviteAmount': instance.inviteAmount,
  'currentAmount': instance.currentAmount,
};
