// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LoginForm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginForm _$LoginFormFromJson(Map<String, dynamic> json) =>
    LoginForm()
      ..locale = json['locale'] as String
      ..playform = (json['playform'] as num).toInt()
      ..sid = (json['sid'] as num).toInt()
      ..channelPackage = json['channelPackage'] as String?
      ..type = json['type']
      ..oaid = json['oaid'] as String?
      ..ua = json['ua'] as String?
      ..trenchUrl = json['trenchUrl'] as String?
      ..bdId = json['bdId'] as String?
      ..qhId = json['qhId'] as String?
      ..inviteCode = json['inviteCode'] as String?
      ..mobile = json['mobile'] as String?
      ..mobileCode = json['mobileCode'] as String?
      ..account = json['account'] as String?
      ..password = json['password'] as String?
      ..accessToken = json['accessToken'] as String?
      ..wxCode = json['wxCode'] as String?
      ..loginType = (json['loginType'] as num).toInt();

Map<String, dynamic> _$LoginFormToJson(LoginForm instance) => <String, dynamic>{
  'locale': instance.locale,
  'playform': instance.playform,
  'sid': instance.sid,
  'channelPackage': instance.channelPackage,
  'type': instance.type,
  'oaid': instance.oaid,
  'ua': instance.ua,
  'trenchUrl': instance.trenchUrl,
  'bdId': instance.bdId,
  'qhId': instance.qhId,
  'inviteCode': instance.inviteCode,
  'mobile': instance.mobile,
  'mobileCode': instance.mobileCode,
  'account': instance.account,
  'password': instance.password,
  'accessToken': instance.accessToken,
  'wxCode': instance.wxCode,
  'loginType': instance.loginType,
};
