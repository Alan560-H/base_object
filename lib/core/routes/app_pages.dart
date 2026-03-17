import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/pages/first_entry/first_entry_binding.dart';
import 'package:base_object/pages/first_entry/first_entry_view.dart';
import 'package:base_object/pages/home/home_view.dart';
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
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.firstPage,
      page: () => FirstEntryView(),
      binding: FirstEntryBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomeView(),
    ),
    GetPage(
      name: AppRoutes.user,
      page: () => UserView(),
      binding: UserBinding(),
    ),
  ];
}
