import 'package:base_object/core/config/app_config.dart';

class ImageConfig {
  /// 启动页背景 背景
  static String firstTitle =
      "${AppConfig.instance.getImgUrl}/AdObject/common/first_title.png";
  /// 启动页背景 背景
  static String firstBotton =
      "${AppConfig.instance.getImgUrl}/AdObject/common/first_botton.png";
  /// logo
  static String logo =
      "${AppConfig.instance.getImgUrl}/AdObject/common/logo.png";
  /// 登录背景
  static String loginBg1 =
      "${AppConfig.instance.getImgUrl}/AdObject/login/login_bg1.png";
  /// 登录背景
  static String loginBg2 =
      "${AppConfig.instance.getImgUrl}/AdObject/login/login_bg2.png";
  /// 登录背景
  static String loginBtn =
      "${AppConfig.instance.getImgUrl}/AdObject/login/login_btn.png";

  /// 登录背景
  static String hongbao =
      "${AppConfig.instance.getImgUrl}/AdObject/common/hongbao.png";
  /// 空数据
  static String empty =
      "${AppConfig.instance.getImgUrl}/AdObject/common/empty.png";
//   ————————————————————底部导航——————————————————————
  /// 首页激活
  static String redBagActive =
      "${AppConfig.instance.getImgUrl}/AdObject/navIcon/redBagActive.png";
  /// 首页默认
  static String redBagDefatult =
      "${AppConfig.instance.getImgUrl}/AdObject/navIcon/redBagDefatult.png";
  /// 短视频激活
  static String videoActive =
      "${AppConfig.instance.getImgUrl}/AdObject/navIcon/videoActive.png";
  /// 短视频默认
  static String videoDefault =
      "${AppConfig.instance.getImgUrl}/AdObject/navIcon/videoDefault.png";
  /// 短剧激活
  static String shortVideoActive =
      "${AppConfig.instance.getImgUrl}/AdObject/navIcon/shortVideoActive.png";
  /// 短剧默认
  static String shortVideoDefault =
      "${AppConfig.instance.getImgUrl}/AdObject/navIcon/shortVideoDefault.png";
  /// 邀请激活
  static String inviteActive =
      "${AppConfig.instance.getImgUrl}/AdObject/navIcon/inviteActive.png";
  /// 邀请默认
  static String inviteDefault =
      "${AppConfig.instance.getImgUrl}/AdObject/navIcon/inviteDefault.png";
  /// 我的激活
  static String myActive =
      "${AppConfig.instance.getImgUrl}/AdObject/navIcon/myActive.png";
  /// 立刻邀请
  static String inviteBtn =
      "${AppConfig.instance.getImgUrl}/AdObject/invite/invite_btn.png";

  /// 我的默认
  static String myDefatult =
      "${AppConfig.instance.getImgUrl}/AdObject/navIcon/myDefatult.png";
//   ————————————————————底部导航结束——————————————————————
//   ————————————————————user结束——————————————————————
  /// 我的金币概括
  static String userMenoyCardBg =
      "${AppConfig.instance.getImgUrl}/AdObject/user/userMenoyCardBg.png";
  /// 招募团长
  static String leaderRecruit =
      "${AppConfig.instance.getImgUrl}/AdObject/common/leader_recruit.jpg";
  /// 招募团长
  static String userService =
      "${AppConfig.instance.getImgUrl}/AdObject/common/user_service.png";

  /// 去提现按钮
  static String goTiXian =
      "${AppConfig.instance.getImgUrl}/AdObject/user/go_ti_xian.png";

  /// 邀请好友背景
  static String userInviteBg =
      "${AppConfig.instance.getImgUrl}/AdObject/user/user_invite_bg.png";

  /// 邀请好友背景
  static String currentAmount =
      "${AppConfig.instance.getImgUrl}/AdObject/common/current_amount.png";

  /// 邀请好友背景
  static String tiJiaobiao =
      "${AppConfig.instance.getImgUrl}/AdObject/common/ti_jiaobiao.png";

//   ————————————————————user结束——————————————————————
//   ————————————————————邀请开始——————————————————————
  /// 邀请好友海报背景
  static String commonBg =
      "${AppConfig.instance.getImgUrl}/AdObject/invite/common_bg.png";
  /// 邀请好友海报背景
  static String inviteBanner3 =
      "${AppConfig.instance.getImgUrl}/AdObject/invite/invite_banner_3.png";
  /// 邀请好友海报背景
  static String inviteBanner1 =
      "${AppConfig.instance.getImgUrl}/AdObject/invite/invite_banner_1.png";

//   ————————————————————邀请结束——————————————————————
  /// 头像
  static String getUrlAvatar(int index) {
    return "${AppConfig.instance.getImgUrl}/avatars/$index.jpg";
  }

}