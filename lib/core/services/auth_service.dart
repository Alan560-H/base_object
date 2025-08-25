import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/store/user_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
// 路由守卫
class AuthMiddleware extends GetMiddleware {
  // 优先级：数字越小优先级越高
  @override
  int? get priority => 1;
  @override
  RouteSettings? redirect(String? route) {
    // 获取用户信息实例（使用你已有的UserInfo）
    final userInfo = UserInfo.instance;

    // 判断是否已登录（使用你现有的isLoginIn逻辑）
    final isLoggedIn = userInfo.isLoginIn;

    // 定义需要登录的路由列表
    var needAuthRoutes = [
      AppRoutes.user, // 个人中心
      AppRoutes.invite,
    ];

    // 如果访问的是需要登录的路由且未登录，重定向到登录页
    if (needAuthRoutes.contains(route) && !isLoggedIn) {
      // 记录当前路由，登录后可跳回（可选功能）
      return RouteSettings(
        name: AppRoutes.login,
        arguments: {'redirect': route}, // 传递需要跳转回来的路由
      );
    }

    // 已登录或访问的是无需登录的路由，正常跳转
    return super.redirect(route);
  }
}