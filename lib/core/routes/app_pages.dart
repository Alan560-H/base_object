import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/core/services/auth_service.dart';
import 'package:base_object/pages/dj_video/dj_video_binding.dart';
import 'package:base_object/pages/dj_video/dj_video_view.dart';
import 'package:base_object/pages/first_entry/first_entry_binding.dart';
import 'package:base_object/pages/first_entry/first_entry_view.dart';
import 'package:base_object/pages/home/home_binding.dart';
import 'package:base_object/pages/home/home_view.dart';
import 'package:base_object/pages/home/sub_page/box_details/details_binding.dart';
import 'package:base_object/pages/home/sub_page/box_details/details_view.dart';
import 'package:base_object/pages/invite/invite_binding.dart';
import 'package:base_object/pages/invite/invite_user/invite_user_binding.dart';
import 'package:base_object/pages/invite/invite_user/invite_user_view.dart';
import 'package:base_object/pages/invite/invite_view.dart';
import 'package:base_object/pages/login/login_binding.dart';
import 'package:base_object/pages/login/login_view.dart';
import 'package:base_object/pages/short_video/short_video_binding.dart';
import 'package:base_object/pages/short_video/short_video_view2.dart';
import 'package:base_object/pages/splash_page/splash_binding.dart';
import 'package:base_object/pages/splash_page/splash_view.dart';
import 'package:base_object/pages/user/leader_recruit/leader_recruit_binding.dart';
import 'package:base_object/pages/user/leader_recruit/leader_recruit_view.dart';
import 'package:base_object/pages/user/tixian/tixian_binding.dart';
import 'package:base_object/pages/user/tixian/tixian_view.dart';
import 'package:base_object/pages/user/transaction_details/transaction_details_binding.dart';
import 'package:base_object/pages/user/transaction_details/transaction_details_view.dart';
import 'package:base_object/pages/user/user_bag/user_bag_binding.dart';
import 'package:base_object/pages/user/user_bag/user_bag_view.dart';
import 'package:base_object/pages/user/user_binding.dart';
import 'package:base_object/pages/user/user_earnings/user_earnings_binding.dart';
import 'package:base_object/pages/user/user_earnings/user_earnings_view.dart';
import 'package:base_object/pages/user/user_edit_info/user_edit_info_binding.dart';
import 'package:base_object/pages/user/user_edit_info/user_edit_info_view.dart';
import 'package:base_object/pages/user/user_invite/user_invite_binding.dart';
import 'package:base_object/pages/user/user_invite/user_invite_view.dart';
import 'package:base_object/pages/user/user_service/user_service_binding.dart';
import 'package:base_object/pages/user/user_service/user_service_view.dart';
import 'package:base_object/pages/user/user_son/user_son_binding.dart';
import 'package:base_object/pages/user/user_son/user_son_view.dart';
import 'package:base_object/pages/user/user_system/user_system_binding.dart';
import 'package:base_object/pages/user/user_system/user_system_view.dart';
import 'package:base_object/pages/user/user_view.dart';
import 'package:base_object/pages/user/withdrawal_history/withdrawal_history_binding.dart';
import 'package:base_object/pages/user/withdrawal_history/withdrawal_history_view.dart';
import 'package:get/get.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splashPage,
      page: () => SplashView(),
      binding: SplashBinding(), // 首页的依赖注入
    ),
    GetPage(
      name: AppRoutes.firstPage,
      page: () => FirstEntryView(),
      binding: FirstEntryBinding(), // 首页的依赖注入
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: LoginBinding(), // 登录的依赖注入
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomeView(),
      binding: HomeBinding(), // 首页的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    GetPage(
      name: AppRoutes.homeDetails,
      page: () => DetailView(),
      binding: DetailBinding(), // 首页的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    GetPage(
      name: AppRoutes.shortVideo,
      page: () => ShortVideoView2(),
      binding: ShortVideoBinding(), // 短视频的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    GetPage(
      name: AppRoutes.djVideo,
      page: () => DjVideoView(),
      binding: DjVideoBinding(), // 短剧的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    GetPage(
      name: AppRoutes.invite,
      page: () => InviteView(),
      binding: InviteBinding(), // 邀请的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    GetPage(
      name: AppRoutes.inviteUser,
      page: () => InviteUserView(),
      binding: InviteUserBinding(), // 邀请好友的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    GetPage(
      name: AppRoutes.user,
      page: () => UserView(),
      binding: UserBinding(), // 首页的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),

    /// 系统设置
    GetPage(
      name: AppRoutes.userSystem,
      page: () => UserSystemView(),
      binding: UserSystemBinding(), // 系统设置的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),

    /// 交易明细
    GetPage(
      name: AppRoutes.userTransaction,
      page: () => TransactionDetailsView(),
      binding: TransactionDetailsBinding(), // 交易明细的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),

    /// 交易明细
    GetPage(
      name: AppRoutes.userTixian,
      page: () => TixianView(),
      binding: TixianBinding(), // 交易明细的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),

    /// 团长招募
    GetPage(
      name: AppRoutes.userLeader,
      page: () => LeaderRecruitView(),
      binding: LeaderRecruitBinding(), // 团长招募的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),

    /// 联系客服
    GetPage(
      name: AppRoutes.userService,
      page: () => UserServiceView(),
      binding: UserServiceBinding(), // 团长招募的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),

    /// 邀请好友
    GetPage(
      name: AppRoutes.userInvite,
      page: () => UserInviteView(),
      binding: UserInviteBinding(), // 团长招募的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    /// 我的钱包
    GetPage(
      name: AppRoutes.userWallet,
      page: () => UserBagView(),
      binding: UserBagBinding(),// 我的钱包的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    /// 我的收益
    GetPage(
      name: AppRoutes.userEarnings,
      page: () => UserEarningsView(),
      binding: UserEarningsBinding(),// 我的收益的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    /// 我的徒弟
    GetPage(
      name: AppRoutes.userSon,
      page: () => UserSonView(),
      binding: UserSonBinding(),// 我的收益的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    /// 我的资料
    GetPage(
      name: AppRoutes.userEditInfo,
      page: () => UserEditInfoView(),
      binding: UserEditInfoBinding(),// 我的资料的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    /// 我的提现记录
    GetPage(
      name: AppRoutes.userWithdrawalHistory,
      page: () => WithdrawalHistoryView(),
      binding: WithdrawalHistoryBinding(),// 我的提现记录的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
  ];
}
