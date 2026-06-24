import 'package:base_object/core/config/app_config.dart';
import 'package:base_object/store/di.dart';
import 'package:flutter/widgets.dart';

/// 应用启动前初始化（GetX DI、配置等）；步骤 3 起扩展 Riverpod [ProviderContainer]。
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.mainInit();
  AppConfig.instance.init();
}
