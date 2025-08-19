import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/store/user_info.dart';
import 'package:get/get.dart';

import 'cu_http_client.dart';

class HttpClientBinding extends Bindings {
  @override
  void dependencies() {
    // 注入app配置
    Get.put<AppAdConfig>(AppAdConfig());
    /// 注入用户配置
    Get.put<UserInfo>(UserInfo());
    Get.put<CuHttpClient>(CuHttpClient());
  }
}
