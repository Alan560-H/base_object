import 'package:json_annotation/json_annotation.dart';

part 'UserModel.g.dart';
/// 手动构建： flutter packages pub run build_runner build
/// 全部构建:  flutter packages pub run build_runner build --delete-conflicting-outputs
/// 自动构建:  flutter packages pub run build_runner watch
@JsonSerializable()
class UserModel {
  /// 推广码
  @JsonKey(name: 'inviteCode')
  String inviteCode = "";
  /// 推广相关  不知道干啥
  @JsonKey(name: 'inviteCodeModify')
  int inviteCodeModify = 0;
  /// 消息数量
  @JsonKey(name: 'msgNum')
  int msgNum = 0;
  /// 推广相关  不知道干啥
  @JsonKey(name: 'inviteUserModify')
  int inviteUserModify = 0;
  /// 是否绑定微信
  @JsonKey(name: 'isBindWechat')
  int isBindWechat = 0;
  /// 上级推广人id
  @JsonKey(name: 'fatherId')
  int fatherId = 0;
  /// 上级推广人头像
  @JsonKey(name: 'otherHeadImage')
  String otherHeadImage = "";
  /// 上级推广码
  @JsonKey(name: 'otherInviteCode')
  String otherInviteCode = "";
  /// 上级推广级别
  @JsonKey(name: 'otherLevel')
  int otherLevel = 0;
  /// 上级推广人昵称
  @JsonKey(name: 'otherSteamName')
  String otherSteamName = "";

  /// 密码
  @JsonKey(name: 'password')
  String password="";
  /// 日冲
  @JsonKey(name: 'payStatus')
  int payStatus = 0;
  /// 周冲
  @JsonKey(name: 'payWeek')
  int payWeek = 0;
  /// 不知道
  @JsonKey(name: 'rechargeAmount')
  int rechargeAmount = 0;
  /// 不知道
  @JsonKey(name: 'rechargeNum')
  int rechargeNum = 0;
  /// 实名验证
  @JsonKey(name: 'authentication')
  int authentication = 0;
  /// steamNewId
  @JsonKey(name: 'steamNewId')
  String steamNewId = "";
  /// 测试余额？
  @JsonKey(name: 'testBalance')
  int testBalance = 0;
  /// 测试时间
  @JsonKey(name: 'timeCreate')
  String timeCreate = DateTime.now().toString();
  /// 取货地址
  @JsonKey(name: 'transactionUrl')
  String transactionUrl = "";
  /// 用户uid
  @JsonKey(name: 'uid')
  int uid = 0;
  /// 用户类型
  @JsonKey(name: 'userType')
  int userType = 0;
  /// 用户类型
  @JsonKey(name: 'vip')
  int vip = 0;
  /// 賬號
  @JsonKey(name: "account")
  String account = "";
  /// 昵称
  @JsonKey(name: 'steamName')
  String steamName = "登录注册";
  /// 元宝余额
  @JsonKey(name: 'balance')
  int balance = 0;
  /// 如意币余额
  @JsonKey(name: 'mallAmount')
  double mallAmount = 0;
  /// 经验
  @JsonKey(name: 'exp')
  int exp = 0;
  /// 是否开启自动转化金额
  @JsonKey(name: 'isOpenConversion')
  int isOpenConversion = 0;
  /// 等级
  @JsonKey(name: 'level')
  int level = 0;
  /// 手机号
  @JsonKey(name: 'mobile')
  String mobile = "";
  /// 推广URL
  @JsonKey(name: 'inviteUrl')
  String inviteUrl="";
  /// 头像
  @JsonKey(name: 'headImage')
  String headImage = "";
  /// 用户类型
  @JsonKey(name: 'type')
  int type = 0;
  /// 用户id
  @JsonKey(name: 'userId')
  int userId = 0;
  /// 用户信息
  UserModel();
  //不同的类使用不同的mixin即可
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
