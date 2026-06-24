import 'package:json_annotation/json_annotation.dart';

part 'UpDataADForm.g.dart';

@JsonSerializable()
class UpDataADForm {
  String locale = '';
  int playform = 0;
  int sid = 0;
  String? channelPackage;
  dynamic type;

  String extra = '';
  double? amount = 0;
  String? transId = '';
  String? reqId = '';
  String? adsourceId = '';
  String? sign = '';

  UpDataADForm();

  factory UpDataADForm.fromJson(Map<String, dynamic> json) =>
      _$UpDataADFormFromJson(json);

  Map<String, dynamic> toJson() => _$UpDataADFormToJson(this);
}
