// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserInviteModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInviteModel _$UserInviteModelFromJson(Map<String, dynamic> json) =>
    UserInviteModel()
      ..id = (json['id'] as num).toInt()
      ..remark = json['remark'] as String
      ..title = json['title'] as String
      ..withdrawal = (json['withdrawal'] as num).toDouble()
      ..benefit = (json['benefit'] as num).toDouble();

Map<String, dynamic> _$UserInviteModelToJson(UserInviteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'remark': instance.remark,
      'title': instance.title,
      'withdrawal': instance.withdrawal,
      'benefit': instance.benefit,
    };
