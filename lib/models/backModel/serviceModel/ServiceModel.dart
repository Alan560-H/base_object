
import 'package:json_annotation/json_annotation.dart';

part 'ServiceModel.g.dart';

/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch

/// 公告
@JsonSerializable()
class ServiceModel {

  /// id
  String code="";
  /// 名称
  String data="";
  /// 图片
  String image="";
  /// 图片
  String imageUrl="";
  /// 新人福利名字
  String remark="";
  /// 通道名称
  String channelPackage = "";
  /// 公告
  ServiceModel();

  //不同的类使用不同的mixin即可
  factory ServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);
  static List<ServiceModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ServiceModel.fromJson(json)).toList();
  }
}