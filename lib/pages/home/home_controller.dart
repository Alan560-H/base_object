import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/manager/listener_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/FormModel/appUpLoadForm/AppUpLoadForm.dart';
import 'package:base_object/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/models/backModel/appUpLoadModel/AppUpLoadModel.dart';
import 'package:base_object/models/backModel/rewarderModel/RewarderModel.dart';
import 'package:base_object/models/localModels/ChatMessage.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_android_oaid_plugin/flutter_android_oaid_plugin.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeController extends GetxController {
  upDataADFn(dynamic event)async{
    try{
      UpDataADForm upDataADForm = UpDataADForm();
      DateTime now = DateTime.now();
      int timestampMs  = now.millisecondsSinceEpoch;
      upDataADForm.extra = "userid_${UserInfo.instance.userModel.id}_type_1_amount_${event['extraMap']['adsource_price']}_time_$timestampMs";
      // upDataADForm.amount = event['extraMap']['adsource_price'];
      Utils.logError("主动领取激励视频凑成的字符串${ upDataADForm.extra }");
      RewarderModel rewarderModel = await Api.to.getSelectAd(upDataADForm);
      Utils.logError("主动领取激励视频返回的数据${rewarderModel.toJson()}");

        CuToast.success(msg: "恭喜获得${rewarderModel.amount} 金币");
    }catch(e){
      Utils.logError("领取激励视频奖励失败：$e");
    }
  }
  // 用于标记是否已处理跳转（避免重复跳转）
  bool _hasShow = false;

  /// 订阅 ListenerTool 的开屏广告事件
  void rewarderEvent() async {
    // ever：持续监听 splashEvent 的变化（广告状态更新时触发）
    ever(ListenerTool.to.rewarderEvent, (event) {
      if (event == null || _hasShow) return; // 过滤空事件或重复跳转

      // 获取事件类型（从 event 中解析，与 ListenerTool 中转发的格式对应）
      String eventType = event["eventType"] ?? "";
      String placementID = event["placementID"] ?? "";

      Utils.logError("激励广告收到激励视频广告事件：$eventType，广告位ID：$placementID，事件参数：$event");

      // 根据事件类型执行业务逻辑
      switch (eventType) {
        // 激励视频广告加载失败
        case "RewardedStatus.rewardedVideoDidFailToLoad":
          Utils.logError("激励广告激励视频广告加载失败，广告位ID：$placementID，事件参数：$event");
          break;
        // 广告加载成功
        case "RewardedStatus.rewardedVideoDidFinishLoading":
          Utils.logError("激励广告激励视频广告加载完成，广告位ID：$placementID，事件参数：$event");
          break;
        // 广告开始播放
        case "RewardedStatus.rewardedVideoDidStartPlaying":
          Utils.logError("激励广告激励视频广告开始播放，广告位ID：$placementID，事件参数：$event");
          break;
      // 广告结束播放
        case "RewardedStatus.rewardedVideoDidEndPlaying":
          Utils.logError("激励广告激励视频广告结束播放，广告位ID：$placementID，事件参数：$event");
          break;
      // 广告播放失败
        case "RewardedStatus.rewardedVideoDidFailToPlay":
          Utils.logError("激励广告广告播放失败，广告位ID：$placementID，事件参数：$event");
          break;
      // 激励成功，建议在此回调中下发奖励
        case "RewardedStatus.rewardedVideoDidRewardSuccess":
          Utils.logError("激励广告激励成功，建议在此回调中下发奖励 ，广告位ID：$placementID，事件参数：$event ");
          if(Get.isRegistered<UserInfo>()){
            upDataADFn(event);
          }
          break;
      // 广告被点击
        case "RewardedStatus.rewardedVideoDidClick":
          Utils.logError(" 激励广告广告被点击  ，广告位ID：$placementID，事件参数：$event");
          break;
      // 深度链接
        case "RewardedStatus.rewardedVideoDidDeepLink":
          Utils.logError("激励广告深度链接 ，广告位ID：$placementID，事件参数：$event ");
          break;
      // 激励广告被关闭
        case "RewardedStatus.rewardedVideoDidClose":
          Utils.logError("激励广告被关闭，广告位ID：$placementID，事件参数：$event");
          break;
      }
    });
  }

  showRewarder() async {
    bool isReady = await RewarderTool.to.rewardedVideoReady();
    if (isReady) {
      await RewarderTool.to.showRewardedVideo();
    } else {
      CuToast.error(msg: "激励广告加载失败。请稍后重试");
    }
  }

  // 定时器对象，控制自动添加消息的周期
  Timer? _autoMessageTimer;

  // 页面初始化：添加初始消息 + 启动自动消息定时器
  @override
  void onInit() {
    rewarderEvent();
    super.onInit();
    RewarderTool.to.loadRewardedVideo();
    UserInfo.instance.initialize();
    // 初始化添加5条随机消息
    for (int i = 0; i < 5; i++) {
      _addRandomChatMessage();
    }
    // 启动每3秒添加一条消息的定时器
    _startAutoMessageTimer();
  }

  // 生成并添加随机消息（核心逻辑：随机昵称、本地头像、抢红包语录）
  void _addRandomChatMessage() {
    // 1. 生成随机网络昵称
    final String randomNickname = _generateRandomNickname();
    // 2. 随机选择本地头像（0~30.png，需确保assets路径正确）
    final int avatarIndex = random.nextInt(31); // 0-30共31张头像
    final String localAvatarPath = ImageConfig.getUrlAvatar(avatarIndex);

    // 3. 创建用户（使用已定义的VirtualUser类，仅传参）
    final VirtualUser randomUser = VirtualUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(), // 时间戳确保ID唯一
      name: randomNickname,
      avatarUrl: localAvatarPath,
    );

    // 4. 20%概率生成红包消息（content为null时显示红包提示）
    final bool hasRedPacket = random.nextDouble() < 0.2;

    // 5. 创建聊天消息对象
    final ChatMessage newMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      user: randomUser,
      content: hasRedPacket ? null : _getRandomRedPacketQuote(),
      timestamp: DateTime.now(),
    );

    // 6. 添加消息并限制列表最大长度为20条
    messages.add(newMessage);
    if (messages.length > 20) {
      messages.removeAt(0); // 超出20条时删除最早的消息
    }
  }

  // 随机昵称生成器（姓氏+抢红包场景名+后缀，模拟真实网络昵称）
  String _generateRandomNickname() {
    // 常见姓氏库
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
    // 抢红包场景专属名字
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
    // 昵称后缀（增加多样性）
    final List<String> suffixes = ["", "呀", "啦", "～", "！", "✨"];

    // 组合生成昵称
    return "${surnames[random.nextInt(surnames.length)]}"
        "${givenNames[random.nextInt(givenNames.length)]}"
        "${suffixes[random.nextInt(suffixes.length)]}";
  }

  // 获取随机抢红包语录（从30条中选1条）
  String _getRandomRedPacketQuote() {
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

  // 启动自动添加消息的定时器（每3秒触发一次）
  void _startAutoMessageTimer() {
    _autoMessageTimer = Timer.periodic(
      const Duration(seconds: 3),
      (Timer timer) => _addRandomChatMessage(),
    );
  }

  // 控制器销毁时取消定时器，防止内存泄漏
  @override
  void onClose() {
    super.onClose();
    _autoMessageTimer?.cancel();
  }

  // ------------------- 状态管理相关 -------------------
  // 导航栏标题（响应式）
  final RxString appbarTitle = "红包群".obs;
  // 聊天消息列表（响应式，自动更新UI）
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  // 随机数生成器（全局唯一）
  final Random random = Random();

  String generateMD5(String input) {
    // 将输入字符串转换为 UTF-8 字节
    final bytes = utf8.encode(input);
    // 计算 MD5 哈希
    final md5Hash = md5.convert(bytes);
    // 将哈希结果转换为字符串
    return md5Hash.toString();
  }

  /// 获取渠道标识
  Future<String> getAppChannel() async {
    try {
      var platform = MethodChannel('com.example.base_object/channel');
      String channel = await platform.invokeMethod('getChannel');
      return channel;
    } catch (e) {
      Utils.logError('获取渠道信息失败: $e');
      return 'unknown';
    }
  }

  Future<String?> getUserAgent() async {
    const platform = MethodChannel('ua_channel');
    try {
      final String? ua = await platform.invokeMethod('getUA');
      return ua;
    } on PlatformException catch (e) {
      Utils.logError("getUserAgent in error $e");
    }
    return null;
  }

  /// 获取app 升级信息
  Future<void> getAppUpdata() async {
    String channel = await getAppChannel();

    /// 获取包信息
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    /// 构建服务器版本信息请求载荷
    AppUpLoadForm appUpLoadForm = AppUpLoadForm();

    if (channel.isEmpty) {
      /// 渠道包名，主包名+渠道标识， 比如com.ruyimh.xiaomi
      appUpLoadForm.channelPackage = packageInfo.packageName;
    } else {
      /// 渠道包名，主包名+渠道标识， 比如com.ruyimh.xiaomi
      appUpLoadForm.channelPackage = "${packageInfo.packageName}.$channel";
    }

    /// 暂时性的
    appUpLoadForm.channelPackage = "com.test.gf";
    // Utils.logError("提交的标识符渠道名称${appUpLoadForm.toJson()}");

    /// 返回的服务器版本信息
    AppUpLoadModel appUpLoadModel = await Api.to.postUpApp(appUpLoadForm);

    // 获取oaid
    appUpLoadModel.oaid = await FlutterAndroidOaidPlugin.getOAID();
    // 获取设备信息
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    // 获取ua
    appUpLoadModel.ua = await getUserAgent();
    appUpLoadModel.fingerprint = androidInfo.fingerprint;
    appUpLoadModel.channel = channel;
    appUpLoadModel.channelPackage = appUpLoadForm.channelPackage;

    /// 将版本信息 存储到仓库
    Store.instance.updateAppUpLoadModel(appUpLoadModel);

    // Utils.logError("包信息：${packageInfo.toString()}");
    // Utils.logError("服务器版本信息${appUpLoadModel.toJson()}");

    /// 如果需要升级  ，那么就弹出升级框
    if (appUpLoadModel.packageName.isEmpty) return;
    String input =
        "channelPackage=${appUpLoadForm.channelPackage}&version=${packageInfo.version}";
    // 生成 MD5 签名
    String sign = generateMD5(input);

    /// 当本地版本与服务器版本一致时，直接返回。
    if (sign == appUpLoadModel.sign) return;

    /// 当本地版本与服务器版本不一致或者must为强制更新时，显示更新框
    if ((sign != appUpLoadModel.sign && appUpLoadModel.sign != null) ||
        Store.instance.getAppUpLoadModel.must == '1') {
      appUpLoadModel.needUpdate = true;

      /// 将版本信息 存储到仓库
      Store.instance.updateAppUpLoadModel(appUpLoadModel);
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
}
