import 'dart:async';

import 'package:base_object/data/models/ace/ace_app_report_request.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:base_object/data/notifiers/ad_stats_notifier.dart';
import 'package:base_object/data/remote/ace_app_api_client.dart';
import 'package:base_object/data/remote/ace_app_open_api.dart';
import 'package:base_object/services/device/device_identity.dart';
import 'package:base_object/services/device/public_ip_helper.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/services.dart';

/// 首页收益上报：进页立即报一次，之后整点起每小时上报（Debug / Release 相同）。
class AceIncomeReportService {
  AceIncomeReportService({
    required AceAppOpenApi api,
    required AdStatsNotifierGetter adStats,
  }) : _api = api,
       _adStats = adStats;

  /// 今日原始收益（未乘分成）低于该值不上报。
  static const double minReportTodayIncomeCny = 1.0;

  final AceAppOpenApi _api;
  final AdStatsNotifierGetter _adStats;

  DeviceIdentity? _identity;
  bool _started = false;
  bool _starting = false;
  Timer? _hourlyTimer;
  Timer? _firstHourTimer;

  bool get isStarted => _started;

  /// 幂等启动。无 OAID 时按未知设备（oaid=`unkown`）继续上报。
  Future<void> start() async {
    if (_started || _starting) return;
    _starting = true;
    try {
      final DeviceIdentity identity = await DeviceIdentityResolver.resolve();
      _identity = identity;
      _started = true;
      Utils.logError(
        '[AceReport] start package=${identity.packageName} '
        'device=${identity.deviceName} oaid=${identity.oaid}',
      );

      final bool packageMissing = await reportNow(reason: 'homeEnter');
      if (packageMissing) return;

      _scheduleHourly();
    } finally {
      _starting = false;
    }
  }

  void stop() {
    _hourlyTimer?.cancel();
    _hourlyTimer = null;
    _firstHourTimer?.cancel();
    _firstHourTimer = null;
    _started = false;
    _identity = null;
  }

  /// 返回 `true` 表示因包名不存在已触发退出。
  Future<bool> reportNow({required String reason}) async {
    final DeviceIdentity? identity = _identity;
    if (!_started || identity == null) return false;

    final double todayIncome = _adStats().adInfosRawTodayCny;
    if (todayIncome < minReportTodayIncomeCny) {
      Utils.logError(
        '[AceReport] 跳过上报 reason=$reason '
        'todayIncome=$todayIncome < $minReportTodayIncomeCny',
      );
      return false;
    }

    final String ipAddress = await PublicIpHelper.resolve();
    final AceAppReportRequest body = AceAppReportRequest(
      packageName: identity.packageName,
      deviceName: identity.deviceName,
      oaid: identity.oaid,
      todayIncome: double.parse(todayIncome.toStringAsFixed(4)),
      revenueShare: AdInfo.displayRevenueShare,
      ipAddress: ipAddress,
    );

    Utils.logError(
      '[AceReport] POST report reason=$reason '
      'todayIncome=${body.todayIncome} share=${body.revenueShare} '
      'ip=${body.ipAddress}',
    );

    final AceApiResult<int> result = await _api.reportIncome(body);
    if (result.isPackageNotFound) {
      Utils.logError('[AceReport] 包名不存在，退出 App msg=${result.msg}');
      stop();
      SystemNavigator.pop();
      return true;
    }
    if (!result.isSuccess) {
      Utils.logError(
        '[AceReport] 上报失败 code=${result.code} msg=${result.msg}',
      );
      return false;
    }
    Utils.logError('[AceReport] 上报成功 data=${result.data}');
    return false;
  }

  void _scheduleHourly() {
    final DateTime now = DateTime.now();
    final DateTime floorHour = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    );
    final DateTime firstFire = floorHour.add(const Duration(hours: 1));
    Duration delay = firstFire.difference(now);
    if (delay.isNegative) {
      delay = Duration.zero;
    }
    Utils.logError(
      '[AceReport] 整点调度 floor=$floorHour firstFire=$firstFire '
      'delayMs=${delay.inMilliseconds}',
    );
    _firstHourTimer?.cancel();
    _firstHourTimer = Timer(delay, () {
      unawaited(reportNow(reason: 'hourlyFirst'));
      _hourlyTimer?.cancel();
      _hourlyTimer = Timer.periodic(const Duration(hours: 1), (_) {
        unawaited(reportNow(reason: 'hourly'));
      });
    });
  }
}

typedef AdStatsNotifierGetter = AdStatsNotifier Function();
