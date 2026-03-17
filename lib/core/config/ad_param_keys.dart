/// 广告透传参数 key，供各模块统一使用，避免依赖 login 页面
class Common {
  static String getUserIdKey() => 'userId';
  static String getExtraKey() => 'extra';
}
