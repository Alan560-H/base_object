import 'package:base_object/app/providers.dart';
import 'package:base_object/app/router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 应用启动前初始化；创建 [globalContainer] 并预热 Riverpod。
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  globalContainer = ProviderContainer();
  await warmUpProviders(globalContainer);
  appRouter = createAppRouter();
}
