import 'package:get/get.dart';

import '../net/http_client_binding.dart';
import 'api.dart';

class ApiBinding extends Bindings {
  @override
  void dependencies() {
    HttpClientBinding().dependencies();
    Get.lazyPut(() => Api());
  }
}
