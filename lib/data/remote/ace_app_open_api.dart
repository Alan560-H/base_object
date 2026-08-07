import 'package:base_object/data/models/ace/ace_app_report_request.dart';
import 'package:base_object/data/remote/ace_app_api_client.dart';

/// ACE App 开放接口封装。
class AceAppOpenApi {
  AceAppOpenApi({required AceAppApiClient client}) : _client = client;

  final AceAppApiClient _client;

  /// `GET /open/app/enabled?packageName=`
  Future<AceApiResult<bool>> fetchEnabled({required String packageName}) {
    return _client.get<bool>(
      '/open/app/enabled',
      queryParameters: <String, dynamic>{'packageName': packageName},
      parseData: (raw) {
        if (raw is bool) return raw;
        if (raw is String) return raw.toLowerCase() == 'true';
        if (raw is num) return raw != 0;
        return false;
      },
    );
  }

  /// `POST /open/app/report`
  Future<AceApiResult<int>> reportIncome(AceAppReportRequest request) {
    return _client.post<int>(
      '/open/app/report',
      data: request.toJson(),
      parseData: (raw) {
        if (raw is int) return raw;
        if (raw is num) return raw.toInt();
        if (raw is String) return int.tryParse(raw) ?? 0;
        return 0;
      },
    );
  }
}
