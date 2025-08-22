// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserSonModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SonModel _$SonModelFromJson(Map<String, dynamic> json) =>
    SonModel()
      ..id = (json['id'] as num).toInt()
      ..amount = (json['amount'] as num).toDouble()
      ..username = json['username'] as String
      ..headImage = json['headImage'] as String;

Map<String, dynamic> _$SonModelToJson(SonModel instance) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'username': instance.username,
  'headImage': instance.headImage,
};

UserSonModel _$UserSonModelFromJson(Map<String, dynamic> json) =>
    UserSonModel()
      ..inviteNum = (json['inviteNum'] as num).toInt()
      ..inviteAmount = (json['inviteAmount'] as num).toDouble()
      ..userList =
          (json['userList'] as List<dynamic>)
              .map((e) => SonModel.fromJson(e as Map<String, dynamic>))
              .toList();

Map<String, dynamic> _$UserSonModelToJson(UserSonModel instance) =>
    <String, dynamic>{
      'inviteNum': instance.inviteNum,
      'inviteAmount': instance.inviteAmount,
      'userList': instance.userList,
    };
