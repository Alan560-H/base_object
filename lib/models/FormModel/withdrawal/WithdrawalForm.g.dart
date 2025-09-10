// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WithdrawalForm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawalForm _$WithdrawalFormFromJson(Map<String, dynamic> json) =>
    WithdrawalForm()
      ..locale = json['locale'] as String
      ..playform = (json['playform'] as num).toInt()
      ..sid = (json['sid'] as num).toInt()
      ..channelPackage = json['channelPackage'] as String?
      ..type = json['type']
      ..payAccount = json['payAccount'] as String
      ..payName = json['payName'] as String
      ..amountId = (json['amountId'] as num?)?.toInt();

Map<String, dynamic> _$WithdrawalFormToJson(WithdrawalForm instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'playform': instance.playform,
      'sid': instance.sid,
      'channelPackage': instance.channelPackage,
      'type': instance.type,
      'payAccount': instance.payAccount,
      'payName': instance.payName,
      'amountId': instance.amountId,
    };
