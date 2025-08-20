// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserSonModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSonModel _$UserSonModelFromJson(Map<String, dynamic> json) =>
    UserSonModel()
      ..id = (json['id'] as num).toInt()
      ..username = json['username'] as String
      ..headImage = json['headImage'] as String
      ..amount = (json['amount'] as num).toDouble();

Map<String, dynamic> _$UserSonModelToJson(UserSonModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'headImage': instance.headImage,
      'amount': instance.amount,
    };
