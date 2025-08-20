// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SendMobileCodeModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendMobileCodeModel _$SendMobileCodeModelFromJson(Map<String, dynamic> json) =>
    SendMobileCodeModel(
        mobile: json['mobile'] as String,
        verifyId: json['verifyId'] as String,
        verifyCode: json['verifyCode'] as String,
      )
      ..locale = json['locale'] as String
      ..playform = (json['playform'] as num).toInt()
      ..sid = (json['sid'] as num).toInt()
      ..type = json['type'];

Map<String, dynamic> _$SendMobileCodeModelToJson(
  SendMobileCodeModel instance,
) => <String, dynamic>{
  'locale': instance.locale,
  'playform': instance.playform,
  'sid': instance.sid,
  'type': instance.type,
  'mobile': instance.mobile,
  'verifyCode': instance.verifyCode,
  'verifyId': instance.verifyId,
};
