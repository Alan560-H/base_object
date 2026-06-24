import 'package:base_object/app/routes.dart';
import 'package:base_object/features/splash/presentation/splash_page.dart';
import 'package:base_object/pages/home/home_view.dart';
import 'package:base_object/pages/user/user_controller.dart';
import 'package:base_object/pages/user/user_view.dart';
import 'package:base_object/shared/config/cu_global.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

late final GoRouter appRouter;

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: CuGlobal.navigatorKey,
    initialLocation: AppPaths.splash,
    routes: [
      GoRoute(
        path: AppPaths.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppPaths.home,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: AppPaths.user,
        builder: (context, state) {
          if (!Get.isRegistered<UserController>()) {
            Get.put(UserController());
          }
          return const UserView();
        },
      ),
    ],
  );
}
