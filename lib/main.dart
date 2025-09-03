import 'package:base_object/core/config/app_config.dart';
import 'package:base_object/core/config/app_theme.dart';
import 'package:base_object/core/config/global.dart';
import 'package:base_object/core/routes/app_pages.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/store/di.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'manager/Init_tool.dart';
import 'utils/ChineseLocalizationsDelegate.dart';
import 'utils/Utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 全局依赖注入
  // 等待所有依赖注入完成（尤其是异步注入）
  await DependencyInjection.mainInit();
  AppConfig.instance.init();
  UserInfo.instance.initialize();
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AppTheme {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      enableScaleText: () => false,
      enableScaleWH: () => false,
      designSize: const Size(375, 812),
      builder: (context, child) {
        return GetMaterialApp(
          locale: const Locale('zh', 'CN'),
          // 默认中文
          fallbackLocale: const Locale('zh', 'CN'),
          //  fallback 语言
          localizationsDelegates: [
            DefaultWidgetsLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            // 保留自定义代理以覆盖特定文案
            ChineseLocalizationsDelegate(),
          ],

          // 导航唯一键
          navigatorKey: Global.navigatorKey,
          // 初始化根路由路径
          initialRoute: AppRoutes.firstPage,
          // 路由列表
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
          title: Store.instance.getAppUpLoadModel.appName,
          builder: EasyLoading.init(),
          theme: appTheme,
        );
      },
    );
  }
}
