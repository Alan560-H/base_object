import 'package:base_object/models/FormModel/FormModel.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';
import '../net/cu_http_client.dart';

class Api extends GetxController{
  // GetX单例获取方式
  static Api get to => Get.find<Api>();
  // 发起请求的通用方法
  Future<BackModel> _sendRequest(
      String url,
      FormModel data,
      String requestType,
      ) async {
    try {
      BackModel backModel = await CuHttpClient.instance.request(
        url,
        data.toJson(),
        requestType: requestType,
      );
      return backModel;
    } catch (e) {
      Utils.logError("_sendRequest请求出错: $e");
      rethrow;
    }
  }
}