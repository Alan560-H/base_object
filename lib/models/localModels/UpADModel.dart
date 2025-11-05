import 'package:jiffy/jiffy.dart';

/// 上传得广告模型，用来上传被风控得广告
class UpADModel {
  /// 广告位id
  String adsourceId = "";

  /// reqid
  String reqId = "";

  /// 唯一id 查询用reqId+absourceId
  String queryId = "";

  /// 广告类型
  String adType = "";

  /// 广告单价
  double adAmount = 0.0;

  ///创建时间
  Jiffy createTime;

  UpADModel({
    this.adsourceId = "",
    this.reqId = "",
    this.adType = "",
    this.adAmount = 0.0,
    String? queryId, // 允许手动传，不传则自动生成
  }) : queryId = queryId ?? "$reqId$adsourceId",
       createTime = Jiffy.now();
  @override
  String toString() {
    return 'UpADModel('
        'adsourceId: $adsourceId, '
        'reqId: $reqId, '
        'queryId: $queryId, '
        'adType: $adType, '
        'adAmount: $adAmount, '
        'createTime: ${createTime.format(pattern: "yyyy-MM-dd HH:mm:ss")}' // 格式化时间
        ')';
  }
}
