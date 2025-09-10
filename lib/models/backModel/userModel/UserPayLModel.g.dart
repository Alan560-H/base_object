// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserPayLModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPayLModel _$UserPayLModelFromJson(Map<String, dynamic> json) =>
    UserPayLModel()
      ..id = (json['id'] as num).toInt()
      ..userId = (json['userId'] as num).toInt()
      ..payName = json['payName'] as String
      ..payAccount = json['payAccount'] as String;

Map<String, dynamic> _$UserPayLModelToJson(UserPayLModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'payName': instance.payName,
      'payAccount': instance.payAccount,
    };
