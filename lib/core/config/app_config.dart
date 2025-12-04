import 'package:get/get.dart';

class AppConfig extends GetxController {
  static AppConfig get instance => Get.find();

  /// 获取图片地址
  String get getImgUrl => "https://img.ruyimh.com";

  /// 获取wx_appid
  /// 如意开盒
  // String get wxAppId => "wxfb5af9767e77b130";

  /// 如意盒子
  String get wxAppId => "wx5ef2b08e4bb891e4";

  /// 高德appkey(如意开盒 com.ruyimh.www）
  // String get mapKey => "99ee090365d57e359d2a5ceb2dd89a3c";
  /// 高德appkey(如意盒子 com.ruyimh）
  String get mapKey => "a22ed8b3045cde75b1ca581a34f18179";

  /// 获取app 下载地址
  String get appDownUrl => "https://img.ruyimh.com/Rscsgo/app/ruyimh.apk";

  /// 获取app 服务协议
  Uri get protocolUri => Uri.parse("https://www.ruyimh.com/protocol.html");

  /// 获取app 隐私政策
  Uri get policyUri => Uri.parse("https://www.ruyimh.com/policy.html");

  /// 获取app 53客服
  Uri get serviceUri => Uri.parse(
    "https://tb.53kf.com/code/client/0336539cc38692d6e967984a52d8a6ed9/1",
  );

  /// 获取app qq群链接
  String get qQUrl =>
      "http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=oQa4YkADFXhPbT3FJ0nkvXlhlJ6rb54-&authKey=td6mejWblP%2FX%2BgB231w1oj2KQsxM3NH%2BtwLRUAQT1UEEhox5VO%2B9M9Ep2yyS7ex%2F&noverify=0&group_code=1006103675";

  /// 注册中间页地址
  String get registerUrl => "https://ysxy.ruyigx.com/invite_register.html";

  /// 私有变量，存储URL配置

  String _baseUrl = '';
  // String _socketUrl = '';
  /// 公开访问的getter
  String get getBaseUrl => _baseUrl;
  // String get socketUrl => _socketUrl;

  // 初始化配置
  void init() {
    if (const bool.fromEnvironment('dart.vm.product')) {
      // 生产环境（release模式）
      // _baseUrl = 'http://129.211.211.100:39300';
      _baseUrl = 'https://prd.ruyigx.com'; // 如意盒子
      // _baseUrl = 'http://192.168.0.101:39300'; // 周子为
    } else {
      // 开发环境（debug模式）
      // _baseUrl = 'http://129.211.211.100:39300';
      _baseUrl = 'https://prd.ruyigx.com'; // 如意盒子
      // _baseUrl = 'http://192.168.0.101:39300'; // 周子为
    }
  }
}
