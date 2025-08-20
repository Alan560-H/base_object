import 'package:json_annotation/json_annotation.dart';

import '../FormModel.dart';

part 'SendMobileCodeModel.g.dart';

/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch

@JsonSerializable()
class SendMobileCodeModel extends FormModel {
  /// 手机号
  String mobile;
  /// 验证码
  String verifyCode;
  /// 验证码id
  String verifyId;
  /// 发送验证码 type = 0
  SendMobileCodeModel({required this.mobile,required this.verifyId,required this.verifyCode});
  //不同的类使用不同的mixin即可
  factory SendMobileCodeModel.fromJson(Map<String, dynamic> json) =>
      _$SendMobileCodeModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SendMobileCodeModelToJson(this);
}
