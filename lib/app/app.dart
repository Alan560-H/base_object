import 'package:base_object/core/config/app_theme.dart';
import 'package:base_object/core/config/cu_global.dart';
import 'package:base_object/core/routes/app_pages.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/ChineseLocalizationsDelegate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 根 Widget；步骤 4 起由 [MaterialApp.router] + go_router 替代 GetMaterialApp。
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with AppTheme {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: ScreenUtilInit(
        enableScaleText: () => false,
        enableScaleWH: () => false,
        designSize: const Size(375, 812),
        builder: (context, child) {
          return GetMaterialApp(
            locale: const Locale('zh', 'CN'),
            fallbackLocale: const Locale('zh', 'CN'),
            localizationsDelegates: const [
              DefaultWidgetsLocalizations.delegate,
              DefaultMaterialLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
              ChineseLocalizationsDelegate(),
            ],
            navigatorKey: CuGlobal.navigatorKey,
            initialRoute: AppRoutes.splashPage,
            getPages: AppPages.routes,
            debugShowCheckedModeBanner: true,
            title:
                Store.instance.getAppUpLoadModel.appName.isEmpty
                    ? '小新日记'
                    : Store.instance.getAppUpLoadModel.appName,
            builder: EasyLoading.init(),
            theme: appTheme,
          );
        },
      ),
    );
  }
}
