class ApiUrls {
  /// 获取风控配置
  static const String getFkConfig = "/v1/api/fkConfig";

  /// 获取系统信息
  static const String getSystemInfo = "/v1/system/channel";

  /// 获取公告
  static const String getNotice = "/v1/announce/list";

  /// 新人福利
  static const String getNewcomerConfig = "/v1/benefit/newcomerConfig";

  /// 领取新人福利
  static const String getNewcomer = "/v1/benefit/getNewcomer";

  /// 看广告小技巧
  static const String getNoticeAD = "/v1/announce/announceAd";

  /// 屏蔽快应用
  static const String getNoticeAPP = "/v1/announce/announceApp";

  /// 检查设备是否被风控
  static const String getVer = "/v1/api/ver";

  /// 登录
  static const String login = "/v1/login";

  /// 获取图片验证码
  static const String getImgCode = "/v1/getImgCode";

  /// 获取手机号验证码
  static const String getSmsSend = "/v1/smsSend";

  /// 获取用户信息
  static const String getUserInfo = "/v1/user/info";

  /// 设置用户密码
  static const String getSetUser = "/v1/user/setUser";

  /// 设置用户上级邀请人
  static const String getBindInviteUser = "/v1/user/bindInviteUser";

  /// 获取可提现得选项
  static const String getWithdrawalList = "/v1/withdrawal/list";

  /// 用户提现zhifubao
  static const String getWithdrawalMoney = "/v1/withdrawal/money";

  /// 用户提现明细表
  static const String getWithdrawalOrderList = "/v1/withdrawal/orderList";

  /// 用户收入明细表
  static const String getUserAmountList = "/v1/user/amountList";

  /// 用户邀新明细表
  static const String getInviteAmountList = "/v1/user/inviteAmountList";

  /// 用户今日收益统计
  static const String getTodayAmount = "/v1/user/today";

  /// 获取广告配置
  static const String getAdConfig = "/v1/ad/config";

  /// 查询用户获得广告奖励
  static const String getSelectAd = "/v1/user/ad";

  /// 副广上报
  // static const String getSelectAdV2 = "/v1/user/adV2";
  /// 副广收益领取
  static const String getAdAmount = "/v1/user/getAdAmount";

  /// 副广累计收益查询
  static const String getSelectAdV3 = "/v1/user/adSum";

  /// 邀请好友-奖励配置
  static const String getInviteList = "/v1/invite/list";

  /// 邀请好友-邀请信息
  static const String getInviteInfo = "/v1/invite/info";

  /// 邀请-我的推广信息
  static const String getMyInviteInfo = "/v1/invite/myInviteInfo";

  /// 邀请-我的钱包
  static const String getInviteMyBag = "/v1/invite/myBag";

  /// 邀请-我的邀请人
  static const String getInviteMyInvite = "/v1/invite/myInvite";

  /// 获取联系方式
  static const String getServerConfig = "/v1/api/chatConfig";

  /// 获取支付列表（用于提现）
  static const String getPayList = "/v1/user/selectPayList";

  /// 新增支付方式（用于提现）
  static const String getBindAlipay = "/v1/user/bindAlipay";

  /// 删除支付方式（用于提现）
  static const String getRemoveBindPay = "/v1/user/removeBindPay";

  /// 更新支付方式（用于提现）
  static const String getUpdateBindPay = "/v1/user/updateBindPay";
}
