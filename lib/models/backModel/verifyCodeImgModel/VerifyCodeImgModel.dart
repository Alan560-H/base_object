import 'package:json_annotation/json_annotation.dart';

part 'VerifyCodeImgModel.g.dart';

// ignore: slash_for_doc_comments
/**
 * 手动构建： flutter packages pub run build_runner build
 * 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
 * 自动构建:  flutter packages pub run build_runner watch
 */
/// 获取图片验证码
@JsonSerializable()
class VerifyCodeImgModel {
  /// 图片base64
  String? img;
  /// 图片验证码id
  String? verifyId;

  /// 获取图片验证码
  VerifyCodeImgModel();

  //不同的类使用不同的mixin即可
  factory VerifyCodeImgModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyCodeImgModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyCodeImgModelToJson(this);
}
