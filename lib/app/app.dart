import 'package:base_object/app/providers.dart';
import 'package:base_object/app/router.dart';
import 'package:base_object/shared/config/app_theme.dart';
import 'package:base_object/utils/ChineseLocalizationsDelegate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with AppTheme {
  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: globalContainer,
      child: ScreenUtilInit(
        enableScaleText: () => false,
        enableScaleWH: () => false,
        designSize: const Size(375, 812),
        builder: (context, child) {
          return MaterialApp.router(
            locale: const Locale('zh', 'CN'),
            localizationsDelegates: const [
              DefaultWidgetsLocalizations.delegate,
              DefaultMaterialLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
              ChineseLocalizationsDelegate(),
            ],
            supportedLocales: const [Locale('zh', 'CN')],
            routerConfig: appRouter,
            debugShowCheckedModeBanner: true,
            title:
                globalContainer
                        .read(adStatsProvider)
                        .appUpLoadModel
                        .appName
                        .isEmpty
                    ? ''
                    : globalContainer
                        .read(adStatsProvider)
                        .appUpLoadModel
                        .appName,
            builder: EasyLoading.init(),
            theme: appTheme,
          );
        },
      ),
    );
  }
}
