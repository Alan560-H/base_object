import 'dart:convert';

import 'package:base_object/core/config/app_config.dart';
import 'package:base_object/core/config/app_keys.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart' as Getx;
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';


class CuHttpClient extends Getx.GetxService  {
  final Dio _dio = Dio();
  DioAdapter? _dioAdapter; // 模拟适配器

  // 通过Get.find()获取单例实例
  static CuHttpClient get instance => Getx.Get.find<CuHttpClient>();
  /// 获取单例

  // 初始化方法，在应用启动时通过Get.putAsync()调用
  Future<CuHttpClient> init() async {
    // 可以在这里进行一些初始化操作
    return this;
  }

  // 设置是否使用模拟数据
  void setUseMock(bool useMock) {
    if (useMock) {
      _dioAdapter = DioAdapter(dio: _dio);
      _dio.httpClientAdapter = _dioAdapter!;
    } else {
      _dio.httpClientAdapter = IOHttpClientAdapter();
    }
  }

  // 设置模拟响应
  void setupMockResponse(
      String apiPath,
      Map<String, dynamic> mockData, {
        String requestType = 'post',
        int delaySeconds = 1,
      }) {
    if (_dioAdapter == null) {
      throw Exception("模拟适配器未初始化，请先调用setUseMock(true)");
    }
    String url = AppConfig.instance.getBaseUrl + apiPath;
    switch (requestType.toLowerCase()) {
      case 'post':
        _dioAdapter!.onPost(
          url,
              (server) => server.reply(
            200,
            mockData,
            delay: Duration(seconds: delaySeconds),
          ),
        );
        break;
      case 'get':
        _dioAdapter!.onGet(
          url,
              (server) => server.reply(
            200,
            mockData,
            delay: Duration(seconds: delaySeconds),
          ),
        );
        break;
      default:
        throw Exception("不支持的请求类型: $requestType");
    }
  }

  Future<BackModel> request(
      String apiPath,
      Map<String, dynamic> data, {
        String requestType = 'post',
      }) async {
    try {
      // 将 data 转换为 JSON 字符串
      String jsonData = jsonEncode(data);
      /// 获取token
      String token = await UserInfo.instance.getToken;
      Map<String, dynamic> httpHeaders = {AppKeys.tokenName: token};
      Utils.logDebug("token是：$token");

      // 设置请求头
      Options options = Options(headers: httpHeaders);
      Response? response;
      String url = AppConfig.instance.getBaseUrl + apiPath;
      Utils.logDebug("data的数据是$jsonData,访问地址是：$url");

      switch (requestType) {
        case "post":
          response = await _dio.post(url, data: jsonData, options: options);
          break;
        case "get":
          response = await _dio.get(
            url,
            queryParameters: data,
            options: options,
          );
          break;
        default:
          throw Exception("不支持的请求类型: $requestType");
      }

      return await _parseData(response, url);
    } catch (e) {
      // 处理其他异常
      BackModel backModel = BackModel();
      backModel.code = '500';
      backModel.msg = "网络发生错误，稍后再试: $e";
      return backModel;
    }
  }

  /// 格式化返回数据
  Future<BackModel> _parseData(Response response, String url) async {
    try {
      Map<String, dynamic> scores;
      if (response.data is String) {
        scores = json.decode(response.data);
      } else if (response.data is Map<String, dynamic>) {
        scores = Map.from(response.data);
      } else {
        throw Exception('Invalid response data type');
      }

      BackModel backModel = BackModel.fromJson(scores);

      /// 不是100 就代表出错
      if (backModel.code != CuErrorConfig.success) {
        BackModel errorModel = BackModel();
        errorModel.code = backModel.code;
        errorModel.msg = backModel.msg;
        errorModel.data = backModel.data;

        /// 处理token过期
        if (
        backModel.code == CuErrorConfig.err_1000
            || backModel.code == CuErrorConfig.err10001
            || backModel.code == CuErrorConfig.err_502
        ) {
          await UserInfo.instance.loginOut();
        }

        Utils.debounce(() {
          Utils.logError("$url接口发生错误,${errorModel.msg}，错误代码${backModel.code}");
          // CuToast.error(msg: errorModel.msg);
          Getx.Get.snackbar("提示", errorModel.msg);
        });
      }

      return backModel;
    } catch (e) {
      BackModel backModel = BackModel();
      backModel.code = '500';
      backModel.msg = "格式化返回数据有误: $e";
      return backModel;
    }
  }
}
