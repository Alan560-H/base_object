import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  var isLoggedIn = false.obs;
}

// 路由守卫
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // final auth = Get.find<AuthService>();
    // return auth.isLoggedIn.value ? null : const RouteSettings(name: AppRoutes.user);
    return super.redirect(route);
  }
}