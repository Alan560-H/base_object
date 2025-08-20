// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserInviteCountModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInviteCountModel _$UserInviteCountModelFromJson(
  Map<String, dynamic> json,
) =>
    UserInviteCountModel()
      ..id = (json['id'] as num).toInt()
      ..inviteNum = (json['inviteNum'] as num).toDouble()
      ..inviteAmount = (json['inviteAmount'] as num).toDouble()
      ..currentAmount = (json['currentAmount'] as num).toDouble();

Map<String, dynamic> _$UserInviteCountModelToJson(
  UserInviteCountModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'inviteNum': instance.inviteNum,
  'inviteAmount': instance.inviteAmount,
  'currentAmount': instance.currentAmount,
};
