/// 收益列表

class AdInfo {
  final double publisherRevenue; // 展示收益
  final String placementID; //广告位id
  final String reqId; // 请求id
  final int networkfirmId; //广告平台来源
  final String adsourceId; //广告源id
  final String createdTime;
  AdInfo(
    this.publisherRevenue,
    this.placementID,
    this.reqId,
    this.networkfirmId,
    this.adsourceId,
    this.createdTime,
  );

  /// 将AdInfo实例转换为JSON格式的Map
  Map<String, dynamic> toJson() {
    return {
      'publisherRevenue': publisherRevenue,
      'placementID': placementID,
      'reqId': reqId,
      'networkfirmId': networkfirmId,
      'adsourceId': adsourceId,
      'createdTime': createdTime,
    };
  }

  /// 从JSON格式的Map创建AdInfo实例（反序列化，读取本地数据时用）
  factory AdInfo.fromJson(Map<String, dynamic> json) {
    return AdInfo(
      json['publisherRevenue'] as double,
      json['placementID'] as String,
      json['reqId'] as String,
      json['networkfirmId'] as int,
      json['adsourceId'] as String,
      json['createdTime'] as String,
    );
  }

  /// 批量将JSON数组转换为AdInfo列表（读取本地数组时用）
  static List<AdInfo> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AdInfo.fromJson(json)).toList();
  }

  @override
  String toString() {
    return 'AdInfo{publisherRevenue: $publisherRevenue, placementID: $placementID, reqId: $reqId, networkfirmId: $networkfirmId, adsourceId: $adsourceId, createdTime: $createdTime}';
  }
}
