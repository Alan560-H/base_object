// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) =>
    UserModel()
      ..id = (json['id'] as num).toInt()
      ..account = json['account'] as String
      ..username = json['username'] as String
      ..headImage = json['headImage'] as String
      ..authentication = (json['authentication'] as num).toInt()
      ..inviteCode = json['inviteCode'] as String
      ..mobile = json['mobile'] as String
      ..currentAmount = (json['currentAmount'] as num).toDouble()
      ..amount = (json['amount'] as num).toDouble()
      ..money = (json['money'] as num).toDouble()
      ..todayAmount = (json['todayAmount'] as num?)?.toDouble();

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'account': instance.account,
  'username': instance.username,
  'headImage': instance.headImage,
  'authentication': instance.authentication,
  'inviteCode': instance.inviteCode,
  'mobile': instance.mobile,
  'currentAmount': instance.currentAmount,
  'amount': instance.amount,
  'money': instance.money,
  'todayAmount': instance.todayAmount,
};
