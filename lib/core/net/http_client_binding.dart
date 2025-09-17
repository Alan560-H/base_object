import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/store/user_info.dart';
import 'package:get/get.dart';

import 'cu_http_client.dart';

class HttpClientBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CuHttpClient>(CuHttpClient());
  }
}
