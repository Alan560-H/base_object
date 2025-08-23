
import 'package:json_annotation/json_annotation.dart';

part 'AppUpLoadModel.g.dart';
@JsonSerializable()
class AppUpLoadModel {
  /// 是否有可用更新
  bool? needUpdate = false;
  /// 通道报名
  int id = 0;
  /// 渠道包名
  String channelPackage = "";
  /// 渠道名称
  String? channel = "";
  /// app名称
  String appName = "";
  /// 主包名
  String packageName = "";
  /// 构建号
  String buildNumber = "";
  /// 版本号
  String version = "";
  /// 是否强制更新，1是0否
  String must = "";
  /// 下载地址
  String downUrl = "";
  /// 签名
  String? sign = "";
  /// oaid
  String? oaid = "";
  /// 浏览器标识
  String? ua = "";
  /// fingerprint
  String? fingerprint = "";
  AppUpLoadModel();

  //不同的类使用不同的mixin即可
  factory AppUpLoadModel.fromJson(Map<String, dynamic> json) =>
      _$AppUpLoadModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppUpLoadModelToJson(this);
}