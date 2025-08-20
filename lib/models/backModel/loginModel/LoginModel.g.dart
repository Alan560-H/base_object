// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LoginModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginModel _$LoginModelFromJson(Map<String, dynamic> json) =>
    LoginModel()
      ..id = (json['id'] as num).toInt()
      ..account = json['account'] as String
      ..username = json['username'] as String
      ..tokenName = json['tokenName'] as String
      ..tokenValue = json['tokenValue'] as String;

Map<String, dynamic> _$LoginModelToJson(LoginModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account': instance.account,
      'username': instance.username,
      'tokenName': instance.tokenName,
      'tokenValue': instance.tokenValue,
    };
