// 收益列表（publisherRevenue 存人民币口径，与 Taku publisher_revenue_cny 一致）

class AdInfo {
  static const String typeRewarded = 'rewarded';
  static const String typeBanner = 'banner';
  static const String typeNative = 'native';

  /// 列表/卡片展示用类型文案
  static String displayTypeLabel(String adType) {
    switch (adType) {
      case typeBanner:
        return '横幅';
      case typeNative:
        return '信息流';
      default:
        return '激励视频';
    }
  }

  /// 界面「预估收益」与首页汇总使用的系数（持久化仍为完整 [publisherRevenue]）分成
  static const double displayRevenueShare = 0.7;
  // static const double displayRevenueShare = 0.2;

  /// [formatDisplayRevenue] 小数位数；汇总金额再对该和做一次同位数格式化
  static const int displayRevenueFractionDigits = 4;

  /// 列表单行展示的「预估收益」字符串，与 [displayRevenueLineSumTerm] 成对使用以保证可逐项对账
  static String formatDisplayRevenue(double rawPublisherRevenue) {
    return (rawPublisherRevenue * displayRevenueShare).toStringAsFixed(
      displayRevenueFractionDigits,
    );
  }

  /// 将单行展示值解析为 double，供 Store 汇总（等于各 [formatDisplayRevenue] 之和的数值部分）
  static double displayRevenueLineSumTerm(double rawPublisherRevenue) {
    return double.parse(formatDisplayRevenue(rawPublisherRevenue));
  }

  final double publisherRevenue; // 展示收益（人民币）
  final String placementID; // 广告位id
  final String reqId; // 请求id
  final int networkfirmId; // 广告平台来源
  final String adsourceId; // 广告源id
  final String createdTime;

  /// [typeRewarded] / [typeBanner] / [typeNative]
  final String adType;

  AdInfo(
    this.publisherRevenue,
    this.placementID,
    this.reqId,
    this.networkfirmId,
    this.adsourceId,
    this.createdTime, {
    this.adType = typeRewarded,
  });

  /// 按 [createdTime] 降序（最新在前）；格式为 `yyyy-MM-dd HH:mm:ss` 时可字符串比较。
  static List<AdInfo> sortedByCreatedTimeDesc(Iterable<AdInfo> items) {
    final List<AdInfo> list = List<AdInfo>.from(items);
    list.sort((AdInfo a, AdInfo b) {
      final int byTime = b.createdTime.compareTo(a.createdTime);
      if (byTime != 0) return byTime;
      return b.reqId.compareTo(a.reqId);
    });
    return list;
  }

  /// 将AdInfo实例转换为JSON格式的Map
  Map<String, dynamic> toJson() {
    return {
      'publisherRevenue': publisherRevenue,
      'placementID': placementID,
      'reqId': reqId,
      'networkfirmId': networkfirmId,
      'adsourceId': adsourceId,
      'createdTime': createdTime,
      'adType': adType,
    };
  }

  static double _parseRevenue(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _parseNetworkFirmId(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static String _parseString(dynamic v) {
    if (v == null) return '';
    return v.toString();
  }

  /// 从JSON格式的Map创建AdInfo实例（反序列化，读取本地数据时用）
  factory AdInfo.fromJson(Map<String, dynamic> json) {
    return AdInfo(
      _parseRevenue(json['publisherRevenue']),
      _parseString(json['placementID']),
      _parseString(json['reqId']),
      _parseNetworkFirmId(json['networkfirmId']),
      _parseString(json['adsourceId']),
      _parseString(json['createdTime']),
      adType: json['adType'] as String? ?? typeRewarded,
    );
  }

  /// 批量将JSON数组转换为AdInfo列表（读取本地数组时用）
  static List<AdInfo> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => AdInfo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Taku 回调 extraMap 构建记录（人民币、字段安全解析）
  factory AdInfo.fromTakuExtra({
    required Map<dynamic, dynamic>? extraMap,
    required String placementID,
    required String createdTime,
    required String adType,
  }) {
    return AdInfo(
      _parseRevenue(extraMap?['publisher_revenue_cny']),
      placementID,
      _parseString(extraMap?['req_id']),
      _parseNetworkFirmId(extraMap?['network_firm_id']),
      _parseString(extraMap?['adsource_id']),
      createdTime,
      adType: adType,
    );
  }

  @override
  String toString() {
    return 'AdInfo{publisherRevenue: $publisherRevenue, placementID: $placementID, reqId: $reqId, networkfirmId: $networkfirmId, adsourceId: $adsourceId, createdTime: $createdTime, adType: $adType}';
  }
}
