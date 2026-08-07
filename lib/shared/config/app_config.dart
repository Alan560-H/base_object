class AppConfig {
  AppConfig();

  /// 获取图片地址
  String get getImgUrl => 'https://img.ruyimh.com';

  /// 获取wx_appid — 如意开盒
  String get wxAppId => 'wxfb5af9767e77b130';

  String get appDownUrl => 'https://img.ruyimh.com/Rscsgo/app/ruyimh.apk';

  Uri get protocolUri => Uri.parse('https://www.ruyimh.com/protocol.html');

  Uri get policyUri => Uri.parse('https://www.ruyimh.com/policy.html');

  Uri get serviceUri => Uri.parse(
    'https://tb.53kf.com/code/client/0336539cc38692d6e967984a52d8a6ed9/1',
  );

  String get qQUrl =>
      'http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=oQa4YkADFXhPbT3FJ0nkvXlhlJ6rb54-&authKey=td6mejWblP%2FX%2BgB231w1oj2KQsxM3NH%2BtwLRUAQT1UEEhox5VO%2B9M9Ep2yyS7ex%2F&noverify=0&group_code=1006103675';

  String get registerUrl => 'https://ysxy.ruyigx.com/invite_register.html';

  String _baseUrl = '';

  String get getBaseUrl => _baseUrl;

  /// ACE App 开放接口基址（启用校验 / 收益上报），与如意 [getBaseUrl] 分离。
  String get aceOpenApiBaseUrl => 'http://hzsdemo.cn/prod-api';

  void init() {
    if (const bool.fromEnvironment('dart.vm.product')) {
      _baseUrl = 'https://prd.ruyigx.com';
    } else {
      _baseUrl = 'https://prd.ruyigx.com';
    }
  }
}
