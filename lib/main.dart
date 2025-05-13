import 'package:base_object/core/config/app_theme.dart';
import 'package:base_object/core/config/global.dart';
import 'package:base_object/core/routes/app_pages.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/store/di.dart';
import 'package:base_object/store/user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'utils/Utils.dart';

// 自定义本地化代理
class _ChineseLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _ChineseLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return const _ChineseMaterialLocalizations();
  }

  @override
  bool shouldReload(_ChineseLocalizationsDelegate old) => false;
}

// 自定义 MaterialLocalizations
class _ChineseMaterialLocalizations extends DefaultMaterialLocalizations {
  const _ChineseMaterialLocalizations();

  @override
  String get copyButtonLabel => '复制';

  @override
  String get pasteButtonLabel => '粘贴';

  @override
  String get cutButtonLabel => '剪切';
  @override
  String get shareButtonLabel => '分享';
  @override
  String get selectAllButtonLabel => '全选';
}
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DependencyInjection.init();
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
    return  ScreenUtilInit(
enableScaleText: ()=> false,
enableScaleWH: ()=>false,
designSize: const Size(375, 812),
builder: (context,child){
return Obx(() {
  return  ColorFiltered(
    colorFilter: UserInfo.instance.userModel.userType==6?ColorFilter.matrix(Utils.hueRotationMatrix(200)):ColorFilter.mode(
      Colors.transparent,
      BlendMode.srcOver, // 更换混合模式
    ),
    child: MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: GetMaterialApp(
          localizationsDelegates: const [
            _ChineseLocalizationsDelegate(),
            DefaultWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],

          // 导航唯一键
          navigatorKey: Global.navigatorKey,
          // 初始化根路由路径
          initialRoute: AppRoutes.root,
          // 路由列表
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
          title: '基础项目',
          builder: EasyLoading.init(),
          theme:appTheme
      ),
    ),
  );
});
},
    );
  }
}

