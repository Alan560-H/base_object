import 'package:base_object/app/app_shell.dart';
import 'package:base_object/app/routes.dart';
import 'package:base_object/features/home/presentation/home_page.dart';
import 'package:base_object/features/splash/presentation/splash_page.dart';
import 'package:base_object/features/user/presentation/user_page.dart';
import 'package:base_object/shared/config/cu_global.dart';
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.user,
                builder: (context, state) => const UserPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
