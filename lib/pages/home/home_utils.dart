import 'dart:convert';
import 'dart:math';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/models/FormModel/appUpLoadForm/AppUpLoadForm.dart';
import 'package:base_object/models/backModel/appUpLoadModel/AppUpLoadModel.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_android_oaid_plugin/flutter_android_oaid_plugin.dart';
import 'package:jiffy/jiffy.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeUtils {
  // 获取UserAgent
  static Future<String?> getUserAgent() async {
    const platform = MethodChannel('uaChannel');
    try {
      final String? ua = await platform.invokeMethod('getUA');
      return ua;
    } on PlatformException catch (e) {
      Utils.logError("getUserAgent 错误: $e");
    }
    return null;
  }

  // 获取渠道标识
  static Future<String> getAppChannel() async {
    try {
      var platform = MethodChannel('com.example.base_object/channel');
      String channel = await platform.invokeMethod('getChannel');
      return channel;
    } catch (e) {
      Utils.logError('获取渠道信息失败: $e');
      return 'unknown';
    }
  }

  // 生成MD5
  static String generateMD5(String input) {
    final bytes = utf8.encode(input);
    final md5Hash = md5.convert(bytes);
    return md5Hash.toString();
  }

  // 检查是否为广告消息  // 获取App升级信息
  static Future<void> getAppUpdata({bool isReturn = false}) async {
    String channel = await getAppChannel();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    AppUpLoadForm appUpLoadForm = AppUpLoadForm();

    // 配置渠道包名
    if (channel.isEmpty) {
      appUpLoadForm.channelPackage = packageInfo.packageName;
    } else {
      appUpLoadForm.channelPackage = "${packageInfo.packageName}.$channel";
    }
    Utils.logError("设备信息提交：${appUpLoadForm.toJson()}，$channel,通道");
    // 请求升级信息
    AppUpLoadModel appUpLoadModel = await Api.to.postUpApp(appUpLoadForm);
    Utils.logError("返回的版本信息：${appUpLoadModel.toJson()}");
    // 补充设备信息
    appUpLoadModel.oaid = await FlutterAndroidOaidPlugin.getOAID();
    Utils.logError("oaid是：${appUpLoadModel.oaid}");
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    appUpLoadModel.ua = await getUserAgent();
    appUpLoadModel.fingerprint = androidInfo.fingerprint;
    appUpLoadModel.channel = channel;
    appUpLoadModel.channelPackage = appUpLoadForm.channelPackage ?? "";

    // 存储升级信息
    Store.instance.updateAppUpLoadModel(appUpLoadModel);
    if (isReturn) return;
    // 获取客服配置
    Store.instance.getServerConfig();
    // 校验版本并弹窗
    if (appUpLoadModel.packageName.isEmpty) return;
    String input = "${appUpLoadForm.channelPackage}${packageInfo.version}";
    String sign = generateMD5(input);

    if (sign == appUpLoadModel.sign) return;
    if ((sign != appUpLoadModel.sign && appUpLoadModel.sign != null) ||
        Store.instance.getAppUpLoadModel.must == '1') {
      appUpLoadModel.needUpdate = true;
      Store.instance.updateAppUpLoadModel(appUpLoadModel);

      // 控制弹窗频率（每天一次）
      String? lastTime = await LocalStorage.getString("isUpApp");
      bool isShowUpDialog = true;
      if (lastTime != null && Store.instance.getAppUpLoadModel.must != '1') {
        Jiffy now = Jiffy.now();
        Jiffy last = Jiffy.parse(jsonDecode(lastTime));
        isShowUpDialog = last.isBefore(now, unit: Unit.day);
      }

      if (isShowUpDialog) {
        Dialogs.showCommonDialog(
          barrierDismissible: false,
          dialogType: "AppUpLoadDialog",
          data: appUpLoadModel,
          dialogTitle: "升级提示",
        );
      }
    }
  }

  static final Random random = Random(); // 全局随机数生成器
  // 生成随机昵称
  static String generateRandomNickname() {
    final List<String> surnames = [
      "张",
      "李",
      "王",
      "刘",
      "陈",
      "杨",
      "赵",
      "黄",
      "周",
      "吴",
      "徐",
      "孙",
      "胡",
      "朱",
      "高",
      "林",
      "何",
      "郭",
      "马",
      "罗",
    ];
    final List<String> givenNames = [
      "抢包快",
      "红包控",
      "手慢无",
      "必中君",
      "好运来",
      "财气旺",
      "秒抢王",
      "幸运星",
      "红包侠",
      "发财猫",
      "福气多",
      "抢不停",
    ];
    final List<String> suffixes = ["", "呀", "啦", "～", "！", "✨"];

    return "${surnames[random.nextInt(surnames.length)]}"
        "${givenNames[random.nextInt(givenNames.length)]}"
        "${suffixes[random.nextInt(suffixes.length)]}";
  }

  // 生成随机抢红包语录
  static String getRandomRedPacketQuote() {
    final List<String> redPacketQuotes = [
      "谁发的红包？我火速赶来！",
      "刚看到红包通知，手速必须拉满！",
      "谢谢老板的红包，祝您生意兴隆！",
      "有没有漏网的红包？求@我一下！",
      "今天手气绝了，又抢到大的了！",
      "谁再补一个红包？没抢够呢～",
      "刚进群就有红包，这运气没谁了！",
      "红包在哪？我刷新半天没看到！",
      "谢谢大佬发红包，下次还来蹲！",
      "手慢了只抢到一点，下次一定快！",
      "发红包的都是好心人，必须点赞！",
      "睡醒就有红包，今天心情满分！",
      "有没有连发红包的？我准备好啦！",
      "抢到了抢到了，太感谢啦！",
      "谁又发红包了？快踢我一下！",
      "今天红包不断，运气爆棚！",
      "没抢到的别慌，下一个就是你！",
      "老板大气！再来一个呗～",
      "终于抢到了，不容易啊！",
      "红包雨什么时候再来？太期待了！",
      "谢谢发红包的朋友，祝你发大财！",
      "我的手速可不是白练的，抢包从没输！",
      "刚看到群通知，赶紧冲进来抢红包！",
      "小红包也是爱，谢谢老板！",
      "不管是谁的红包，我先抢为敬！",
      "今天抢的红包够买杯奶茶了，开心！",
      "红包提醒太及时了，差点就错过了！",
      "有没有大红包？我已经准备好冲刺了！",
      "谢谢老板，祝您天天开心！",
      "抢红包太快乐了，根本停不下来！",
    ];
    return redPacketQuotes[random.nextInt(redPacketQuotes.length)];
  }
}
