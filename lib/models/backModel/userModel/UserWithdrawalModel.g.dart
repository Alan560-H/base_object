// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserWithdrawalModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserWithdrawalModel _$UserWithdrawalModelFromJson(Map<String, dynamic> json) =>
    UserWithdrawalModel()
      ..id = (json['id'] as num).toInt()
      ..payMoney = (json['payMoney'] as num).toDouble()
      ..status = (json['status'] as num).toDouble()
      ..payTime = json['payTime'] as String;

Map<String, dynamic> _$UserWithdrawalModelToJson(
  UserWithdrawalModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'payMoney': instance.payMoney,
  'status': instance.status,
  'payTime': instance.payTime,
};
