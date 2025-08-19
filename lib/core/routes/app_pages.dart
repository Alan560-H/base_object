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
import 'package:base_object/pages/invite/invite_view.dart';
import 'package:base_object/pages/login/login_binding.dart';
import 'package:base_object/pages/login/login_view.dart';
import 'package:base_object/pages/short_video/short_video_binding.dart';
import 'package:base_object/pages/short_video/short_video_view.dart';
import 'package:base_object/pages/splash_page/splash_binding.dart';
import 'package:base_object/pages/splash_page/splash_view.dart';
import 'package:base_object/pages/user/user_binding.dart';
import 'package:base_object/pages/user/user_view.dart';
import 'package:get/get.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splashPage,
      page: () => SplashView(),
      binding: SplashBinding(),// 首页的依赖注入
    ),
    GetPage(
      name: AppRoutes.firstPage,
      page: () => FirstEntryView(),
      binding: FirstEntryBinding(),// 首页的依赖注入
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: LoginBinding(),// 登录的依赖注入
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomeView(),
      binding: HomeBinding(),// 首页的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    GetPage(
      name: AppRoutes.homeDetails,
      page: () => DetailView(),
      binding: DetailBinding(),// 首页的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    GetPage(
      name: AppRoutes.shortVideo,
      page: () => ShortVideoView(),
      binding: ShortVideoBinding(),// 短视频的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    GetPage(
      name: AppRoutes.djVideo,
      page: () => DjVideoView(),
      binding: DjVideoBinding(),// 短剧的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    GetPage(
      name: AppRoutes.invite,
      page: () => InviteView(),
      binding: InviteBinding(),// 邀请的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
    GetPage(
      name: AppRoutes.user,
      page: () => UserView(),
      binding: UserBinding(),// 首页的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
  ];
}
