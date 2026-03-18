import 'package:get/get.dart';

/// 广告请求日志收集，供首页「日志」按钮展示（错误码、错误原因等）
class AdLogCollector {
  static const int _maxLines = 200;

  static final RxList<String> _lines = <String>[].obs;
  static List<String> get logs => _lines.toList();

  static void addLog(String message) {
    final String line = "${DateTime.now().toString().substring(11, 19)} $message";
    _lines.insert(0, line);
    if (_lines.length > _maxLines) {
      _lines.removeRange(_maxLines, _lines.length);
    }
  }

  static void clear() {
    _lines.clear();
  }

  static RxList<String> get observable => _lines;
}
