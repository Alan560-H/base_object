
import 'package:json_annotation/json_annotation.dart';

part 'FKConfigVo.g.dart';
/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class FKConfigVo {
  //————————————主广风控————————————————
  /// 用户禁看广告的触发值金额,最高 (主广）
  int wactchMaxAmount = 0;
  /// 用户禁看广告的触发值金额,最低 (主广）
  int wactchMinAmount = 0;
  /// 每小时观看的累计触发值(主广）
  int hourMaxAmount = 0;
  /// 每小时限制的条数(主广）
  int hourMax = 0;
  /// 每天限制条数(主广）
  int dayMax = 0;
  /// 最大观看次数(主广）
  int wactchMax = 0;
  /// 主广连续最低禁看条数(主广）
  int wactchMin = 0;
  /// 主广主广间隔事件(主广）
  int adTime = 0;
  //————————————副广风控————————————————
  /// 用户禁看广告的触发值金额,最高 (副广）
  int wactchMaxAmountV1 = 0;
  /// 用户禁看广告的触发值金额,最低 (副广）
  int wactchMinAmountV1 = 0;
  /// 每小时观看的累计触发值(副广）
  int hourMaxAmountV1 = 0;
  /// 每小时限制的条数(副广）
  int hourMaxV1 = 0;
  /// 每天限制条数(副广）
  int dayMaxV1 = 0;
  /// 最大观看次数(副广）
  int wactchMaxV1 = 0;
  /// 主广连续最低禁看条数(副广）
  int wactchMinV1 = 0;
  //————————————存钱罐风控————————————————
  /// 低于这个值,不打开存钱罐
  int amountMin = 0;
  /// 存钱罐间隔时间
  int adv1Time = 0;


  /// 风控配置数据
  FKConfigVo();
  //不同的类使用不同的mixin即可
  factory FKConfigVo.fromJson(Map<String, dynamic> json) =>
      _$FKConfigVoFromJson(json);

  Map<String, dynamic> toJson() => _$FKConfigVoToJson(this);
}
@JsonSerializable()
class CurrentCountVo{
  /// 当日激励视频观看次数
  int dayMaxCount = 0;
  /// 每小时观看副广累计收益
  double hourMaxAmountV1Count = 0;
  /// 超过此数值，禁止观看主广
  double wactchMaxAmountCount = 0;
  /// 超过此数值，禁止观看副广
  double wactchMaxAmountV1Count = 0;
  CurrentCountVo();

  factory CurrentCountVo.fromJson(Map<String, dynamic> json) =>
      _$CurrentCountVoFromJson(json);
  Map<String, dynamic> toJson() => _$CurrentCountVoToJson(this);
}
