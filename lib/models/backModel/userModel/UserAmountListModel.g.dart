// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserAmountListModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAmountListModel _$UserAmountListModelFromJson(Map<String, dynamic> json) =>
    UserAmountListModel()
      ..id = (json['id'] as num).toInt()
      ..type = (json['type'] as num).toInt()
      ..initAmount = (json['initAmount'] as num).toDouble()
      ..createTime = json['createTime'] as String;

Map<String, dynamic> _$UserAmountListModelToJson(
  UserAmountListModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'initAmount': instance.initAmount,
  'createTime': instance.createTime,
};
