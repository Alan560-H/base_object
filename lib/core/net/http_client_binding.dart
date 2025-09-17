import 'package:get/get.dart';

import 'cu_http_client.dart';

class HttpClientBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CuHttpClient>(CuHttpClient());
  }
}
