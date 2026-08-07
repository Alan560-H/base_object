/// ACE `POST /open/app/report` 请求体。
class AceAppReportRequest {
  const AceAppReportRequest({
    required this.packageName,
    required this.deviceName,
    required this.oaid,
    required this.todayIncome,
    required this.revenueShare,
  });

  final String packageName;
  final String deviceName;
  final String oaid;
  final double todayIncome;

  /// 客户端展示分成系数；后端可忽略。
  final double revenueShare;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'packageName': packageName,
    'deviceName': deviceName,
    'oaid': oaid,
    'todayIncome': todayIncome,
    'revenueShare': revenueShare,
  };
}
