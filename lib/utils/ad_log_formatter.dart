/// Taku 广告日志：统一三行卡片（类型+code / 广告位 / desc）
class AdLogFormatter {
  static final RegExp _reCode = RegExp(r'code\[\s*([^\]]+?)\s*\]');
  static final RegExp _reDesc = RegExp(r'desc\[\s*([^\]]+?)\s*\]');

  /// 从 SDK requestMessage 文本中解析首个 code[ ... ]
  static String parseCodeFromMessage(String? msg, {dynamic networkFirmFallback}) {
    if (msg != null && msg.isNotEmpty) {
      final Match? m = _reCode.firstMatch(msg);
      if (m != null) {
        final String c = m.group(1)!.trim();
        if (c.isNotEmpty) return c;
      }
    }
    if (networkFirmFallback != null &&
        networkFirmFallback.toString().trim().isNotEmpty) {
      return networkFirmFallback.toString().trim();
    }
    return '-';
  }

  /// 从 SDK requestMessage 文本中解析首个 desc[ ... ]（避免整段 detail）
  static String parseDescFromMessage(String? msg) {
    if (msg == null || msg.isEmpty) return '-';
    final Match? m = _reDesc.firstMatch(msg);
    if (m != null) {
      final String d = m.group(1)!.trim();
      if (d.isNotEmpty) return d;
    }
    return '-';
  }

  static String _firm(Map<dynamic, dynamic>? extraMap) {
    final dynamic v = extraMap?['network_firm_id'];
    if (v == null || v.toString().trim().isEmpty) return '-';
    return v.toString().trim();
  }

  /// 第一行：[类型] code=…  第二行：广告位 …  第三行：desc 文案
  static String formatLogCard({
    required String typeZh,
    required String code,
    required String placementId,
    required String desc,
  }) {
    final String pid = placementId.trim().isEmpty ? '-' : placementId.trim();
    return '[$typeZh] code=$code\n广告位 $pid\n$desc';
  }

  /// 横幅加载/刷新失败
  static String bannerFail({
    required String placementId,
    String? requestMessage,
    Map<dynamic, dynamic>? extraMap,
  }) {
    return formatLogCard(
      typeZh: '横幅',
      code: parseCodeFromMessage(
        requestMessage,
        networkFirmFallback: extraMap?['network_firm_id'],
      ),
      placementId: placementId,
      desc: parseDescFromMessage(requestMessage),
    );
  }

  /// 横幅展示成功
  static String bannerSuccess({
    required String placementId,
    Map<dynamic, dynamic>? extraMap,
  }) {
    return formatLogCard(
      typeZh: '横幅',
      code: _firm(extraMap),
      placementId: placementId,
      desc: '展示成功',
    );
  }

  /// 激励加载失败 / 未知错误
  static String rewardedFail({
    required String placementId,
    String? requestMessage,
    Map<dynamic, dynamic>? extraMap,
  }) {
    return formatLogCard(
      typeZh: '激励视频',
      code: parseCodeFromMessage(
        requestMessage,
        networkFirmFallback: extraMap?['network_firm_id'],
      ),
      placementId: placementId,
      desc: parseDescFromMessage(requestMessage),
    );
  }

  /// 激励完成（发奖）
  static String rewardedSuccess({
    required String placementId,
    Map<dynamic, dynamic>? extraMap,
  }) {
    return formatLogCard(
      typeZh: '激励视频',
      code: _firm(extraMap),
      placementId: placementId,
      desc: '激励完成',
    );
  }
}
