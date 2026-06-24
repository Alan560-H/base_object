import 'package:base_object/utils/Utils.dart';

/// 广告请求日志收集，供首页「日志」按钮展示（错误码、错误原因等）
class AdLogCollector {
  static const int _maxLines = 200;

  static final List<String> _lines = <String>[];

  static List<String> get logs => List<String>.unmodifiable(_lines);

  static void addLog(String message) {
    final String line =
        '${DateTime.now().toString().substring(11, 19)} $message';
    _lines.insert(0, line);
    if (_lines.length > _maxLines) {
      _lines.removeRange(_maxLines, _lines.length);
    }
  }

  static void clear() {
    _lines.clear();
  }

  /// 将当前弹窗中展示的日志逐行输出到控制台（打开弹窗时调用）
  static void printLogsToConsole() {
    final List<String> list = _lines.toList();
    Utils.logError('======== 广告日志（与弹窗一致，共 ${list.length} 条）========');
    if (list.isEmpty) {
      Utils.logError('[广告日志] （暂无）');
    } else {
      for (var i = 0; i < list.length; i++) {
        Utils.logError('[广告日志 ${i + 1}/${list.length}] ${list[i]}');
      }
    }
    Utils.logError('======== 广告日志 输出结束 ========');
  }
}
