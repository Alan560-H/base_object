import 'package:base_object/shared/config/app_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:dio/dio.dart';

/// ACE 开放接口统一响应。
class AceApiResult<T> {
  const AceApiResult({
    required this.code,
    required this.msg,
    this.data,
  });

  final int code;
  final String msg;
  final T? data;

  bool get isSuccess => code == 200;

  bool get isPackageNotFound =>
      !isSuccess && msg.contains('包名不存在');
}

/// 轻量 Dio 客户端，专用于 ACE 开放接口。
class AceAppApiClient {
  AceAppApiClient({required AppConfig appConfig})
    : _dio = Dio(
        BaseOptions(
          baseUrl: appConfig.aceOpenApiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          headers: <String, dynamic>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          // 业务码在 body.code；HTTP 4xx/5xx 也要读 body
          validateStatus: (int? status) =>
              status != null && status >= 200 && status < 600,
        ),
      );

  final Dio _dio;

  Future<AceApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic raw)? parseData,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return _parse(response.data, parseData);
    } on DioException catch (e, st) {
      Utils.logError('ACE GET $path 失败: $e', error: e, stackTrace: st);
      return _fromDioException(e, parseData);
    } catch (e, st) {
      Utils.logError('ACE GET $path 异常: $e', error: e, stackTrace: st);
      return AceApiResult<T>(code: -1, msg: e.toString());
    }
  }

  Future<AceApiResult<T>> post<T>(
    String path, {
    Object? data,
    T Function(dynamic raw)? parseData,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        path,
        data: data,
      );
      return _parse(response.data, parseData);
    } on DioException catch (e, st) {
      Utils.logError('ACE POST $path 失败: $e', error: e, stackTrace: st);
      return _fromDioException(e, parseData);
    } catch (e, st) {
      Utils.logError('ACE POST $path 异常: $e', error: e, stackTrace: st);
      return AceApiResult<T>(code: -1, msg: e.toString());
    }
  }

  AceApiResult<T> _fromDioException<T>(
    DioException e,
    T Function(dynamic raw)? parseData,
  ) {
    final dynamic body = e.response?.data;
    if (body is Map) {
      return _parse(body, parseData);
    }
    return AceApiResult<T>(
      code: e.response?.statusCode ?? -1,
      msg: e.message ?? '网络异常',
    );
  }

  AceApiResult<T> _parse<T>(
    dynamic body,
    T Function(dynamic raw)? parseData,
  ) {
    if (body is! Map) {
      return AceApiResult<T>(code: -1, msg: '响应格式错误');
    }
    final Map<dynamic, dynamic> map = body;
    final int code = _asInt(map['code']) ?? -1;
    final String msg = map['msg']?.toString() ?? '';
    final dynamic raw = map['data'];
    T? data;
    if (parseData != null) {
      try {
        data = parseData(raw);
      } catch (_) {
        data = null;
      }
    } else {
      data = raw as T?;
    }
    return AceApiResult<T>(code: code, msg: msg, data: data);
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
