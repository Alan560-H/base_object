// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppUpLoadModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUpLoadModel _$AppUpLoadModelFromJson(Map<String, dynamic> json) =>
    AppUpLoadModel()
      ..needUpdate = json['needUpdate'] as bool?
      ..id = (json['id'] as num).toInt()
      ..channelPackage = json['channelPackage'] as String
      ..channel = json['channel'] as String?
      ..appName = json['appName'] as String
      ..packageName = json['packageName'] as String
      ..buildNumber = json['buildNumber'] as String
      ..version = json['version'] as String
      ..must = json['must'] as String
      ..downUrl = json['downUrl'] as String
      ..sign = json['sign'] as String?
      ..oaid = json['oaid'] as String?
      ..ua = json['ua'] as String?
      ..fingerprint = json['fingerprint'] as String?;

Map<String, dynamic> _$AppUpLoadModelToJson(AppUpLoadModel instance) =>
    <String, dynamic>{
      'needUpdate': instance.needUpdate,
      'id': instance.id,
      'channelPackage': instance.channelPackage,
      'channel': instance.channel,
      'appName': instance.appName,
      'packageName': instance.packageName,
      'buildNumber': instance.buildNumber,
      'version': instance.version,
      'must': instance.must,
      'downUrl': instance.downUrl,
      'sign': instance.sign,
      'oaid': instance.oaid,
      'ua': instance.ua,
      'fingerprint': instance.fingerprint,
    };
