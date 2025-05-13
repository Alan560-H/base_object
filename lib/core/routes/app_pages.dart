import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/core/services/auth_service.dart';
import 'package:base_object/pages/home/home_binding.dart';
import 'package:base_object/pages/home/home_view.dart';
import 'package:base_object/pages/home/sub_page/box_details/details_binding.dart';
import 'package:base_object/pages/home/sub_page/box_details/details_view.dart';
import 'package:base_object/pages/index_binding.dart';
import 'package:base_object/pages/index_view.dart';
import 'package:base_object/pages/user/user_binding.dart';
import 'package:base_object/pages/user/user_view.dart';
import 'package:get/get.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.root,
      page: () => IndexView(),
      binding: IndexBinding(),// 首页的依赖注入
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
      name: AppRoutes.user,
      page: () => UserView(),
      binding: UserBinding(),// 首页的依赖注入
      middlewares: [AuthMiddleware()], // 路由守卫
    ),
  ];
}
