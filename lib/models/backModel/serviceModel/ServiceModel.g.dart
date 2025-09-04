// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ServiceModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceModel _$ServiceModelFromJson(Map<String, dynamic> json) =>
    ServiceModel()
      ..code = json['code'] as String
      ..data = json['data'] as String
      ..image = json['image'] as String
      ..imageUrl = json['imageUrl'] as String
      ..remark = json['remark'] as String
      ..channelPackage = json['channelPackage'] as String;

Map<String, dynamic> _$ServiceModelToJson(ServiceModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'image': instance.image,
      'imageUrl': instance.imageUrl,
      'remark': instance.remark,
      'channelPackage': instance.channelPackage,
    };
