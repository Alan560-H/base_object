// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SignModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignModel _$SignModelFromJson(Map<String, dynamic> json) =>
    SignModel()
      ..id = (json['id'] as num).toInt()
      ..label = json['label'] as String
      ..title = json['title'] as String
      ..status = (json['status'] as num).toInt()
      ..amount = (json['amount'] as num).toInt()
      ..num = (json['num'] as num).toInt();

Map<String, dynamic> _$SignModelToJson(SignModel instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'title': instance.title,
  'status': instance.status,
  'amount': instance.amount,
  'num': instance.num,
};
