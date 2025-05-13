// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) =>
    UserModel()
      ..inviteCode = json['inviteCode'] as String
      ..inviteCodeModify = (json['inviteCodeModify'] as num).toInt()
      ..msgNum = (json['msgNum'] as num).toInt()
      ..inviteUserModify = (json['inviteUserModify'] as num).toInt()
      ..isBindWechat = (json['isBindWechat'] as num).toInt()
      ..fatherId = (json['fatherId'] as num).toInt()
      ..otherHeadImage = json['otherHeadImage'] as String
      ..otherInviteCode = json['otherInviteCode'] as String
      ..otherLevel = (json['otherLevel'] as num).toInt()
      ..otherSteamName = json['otherSteamName'] as String
      ..password = json['password'] as String
      ..payStatus = (json['payStatus'] as num).toInt()
      ..payWeek = (json['payWeek'] as num).toInt()
      ..rechargeAmount = (json['rechargeAmount'] as num).toInt()
      ..rechargeNum = (json['rechargeNum'] as num).toInt()
      ..authentication = (json['authentication'] as num).toInt()
      ..steamNewId = json['steamNewId'] as String
      ..testBalance = (json['testBalance'] as num).toInt()
      ..timeCreate = json['timeCreate'] as String
      ..transactionUrl = json['transactionUrl'] as String
      ..uid = (json['uid'] as num).toInt()
      ..userType = (json['userType'] as num).toInt()
      ..vip = (json['vip'] as num).toInt()
      ..account = json['account'] as String
      ..steamName = json['steamName'] as String
      ..balance = (json['balance'] as num).toInt()
      ..mallAmount = (json['mallAmount'] as num).toDouble()
      ..exp = (json['exp'] as num).toInt()
      ..isOpenConversion = (json['isOpenConversion'] as num).toInt()
      ..level = (json['level'] as num).toInt()
      ..mobile = json['mobile'] as String
      ..inviteUrl = json['inviteUrl'] as String
      ..headImage = json['headImage'] as String
      ..type = (json['type'] as num).toInt()
      ..userId = (json['userId'] as num).toInt();

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'inviteCode': instance.inviteCode,
  'inviteCodeModify': instance.inviteCodeModify,
  'msgNum': instance.msgNum,
  'inviteUserModify': instance.inviteUserModify,
  'isBindWechat': instance.isBindWechat,
  'fatherId': instance.fatherId,
  'otherHeadImage': instance.otherHeadImage,
  'otherInviteCode': instance.otherInviteCode,
  'otherLevel': instance.otherLevel,
  'otherSteamName': instance.otherSteamName,
  'password': instance.password,
  'payStatus': instance.payStatus,
  'payWeek': instance.payWeek,
  'rechargeAmount': instance.rechargeAmount,
  'rechargeNum': instance.rechargeNum,
  'authentication': instance.authentication,
  'steamNewId': instance.steamNewId,
  'testBalance': instance.testBalance,
  'timeCreate': instance.timeCreate,
  'transactionUrl': instance.transactionUrl,
  'uid': instance.uid,
  'userType': instance.userType,
  'vip': instance.vip,
  'account': instance.account,
  'steamName': instance.steamName,
  'balance': instance.balance,
  'mallAmount': instance.mallAmount,
  'exp': instance.exp,
  'isOpenConversion': instance.isOpenConversion,
  'level': instance.level,
  'mobile': instance.mobile,
  'inviteUrl': instance.inviteUrl,
  'headImage': instance.headImage,
  'type': instance.type,
  'userId': instance.userId,
};
