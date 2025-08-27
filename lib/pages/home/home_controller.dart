import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/manager/listener_tool.dart';
import 'package:base_object/manager/native_tool.dart';
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
  // 激励广告奖励提交方法
  upDataADFn(dynamic event) async {
    try {
      UpDataADForm upDataADForm = UpDataADForm();
      DateTime now = DateTime.now();
      int timestampMs = now.millisecondsSinceEpoch;
      upDataADForm.extra =
      "userid_${UserInfo.instance.userModel.id}_type_1_amount_${event['extraMap']['adsource_price']}_time_$timestampMs";
      Utils.logError("主动领取激励视频凑成的字符串${upDataADForm.extra}");
      RewarderModel rewarderModel = await Api.to.getSelectAd(upDataADForm);
      Utils.logError("主动领取激励视频返回的数据${rewarderModel.toJson()}");

      CuToast.success(msg: "恭喜获得${rewarderModel.amount} 金币");
    } catch (e) {
      Utils.logError("领取激励视频奖励失败：$e");
    }
  }

  // 定时器相关
  Timer? _autoMessageTimer; // 普通消息定时器（3秒/条）
  Timer? _placeholderTimer; // 广告消息定时器（6秒/条）
  bool _hasShow = false; // 防止重复跳转标记

  // 新增：原生广告渲染状态（响应式，控制View层显示加载/广告）
  final RxBool isNativeAdReady = false.obs;

  /// 订阅激励广告事件
  void rewarderEvent() async {
    ever(ListenerTool.to.rewarderEvent, (event) {
      if (event == null || _hasShow) return;
      String eventType = event["eventType"] ?? "";
      String placementID = event["placementID"] ?? "";

      Utils.logError("激励广告事件：$eventType，广告位ID：$placementID，参数：$event");

      switch (eventType) {
        case "RewardedStatus.rewardedVideoDidFailToLoad":
          Utils.logError("激励广告加载失败，广告位ID：$placementID");
          break;
        case "RewardedStatus.rewardedVideoDidFinishLoading":
          Utils.logError("激励广告加载完成，广告位ID：$placementID");
          break;
        case "RewardedStatus.rewardedVideoDidStartPlaying":
          Utils.logError("激励广告开始播放，广告位ID：$placementID");
          break;
        case "RewardedStatus.rewardedVideoDidEndPlaying":
          Utils.logError("激励广告结束播放，广告位ID：$placementID");
          break;
        case "RewardedStatus.rewardedVideoDidFailToPlay":
          Utils.logError("激励广告播放失败，广告位ID：$placementID");
          break;
        case "RewardedStatus.rewardedVideoDidRewardSuccess":
          Utils.logError("激励广告奖励成功，广告位ID：$placementID");
          if (Get.isRegistered<UserInfo>()) {
            upDataADFn(event);
          }
          break;
        case "RewardedStatus.rewardedVideoDidClick":
          Utils.logError("激励广告被点击，广告位ID：$placementID");
          break;
        case "RewardedStatus.rewardedVideoDidDeepLink":
          Utils.logError("激励广告深度链接，广告位ID：$placementID");
          break;
        case "RewardedStatus.rewardedVideoDidClose":
          Utils.logError("激励广告被关闭，广告位ID：$placementID");
          break;
      }
    });
  }

  /// 订阅原生广告事件（含广告状态更新）
  void nativeEvent() async {
    ever(ListenerTool.to.nativeEvent, (event) {
      if (event == null || _hasShow) return;
      String eventType = event["eventType"] ?? "";
      String placementID = event["placementID"] ?? "";

      Utils.logError("原生广告事件：$eventType，广告位ID：$placementID，参数：$event");

      switch (eventType) {
        case "NativeStatus.nativeAdFailToLoadAD":
          Utils.logError("原生广告加载失败，广告位ID：$placementID");
          isNativeAdReady.value = false; // 加载失败，重置状态
          break;
        case "NativeStatus.nativeAdDidFinishLoading":
          Utils.logError("原生广告加载完成，广告位ID：$placementID");
          isNativeAdReady.value = true; // 加载失败，重置状态

          // showNatvieAd(); // 触发广告显示（实际渲染后才会更新状态）
          break;
        case "NativeStatus.nativeAdDidClick":
          Utils.logError("原生广告被点击，广告位ID：$placementID");
          break;
        case "NativeStatus.nativeAdDidDeepLink":
          Utils.logError("原生广告深度链接，广告位ID：$placementID");
          break;
        case "NativeStatus.nativeAdDidEndPlayingVideo":
          Utils.logError("原生广告视频结束，广告位ID：$placementID");
          break;
        case "NativeStatus.nativeAdEnterFullScreenVideo":
          Utils.logError("原生广告进入全屏，广告位ID：$placementID");
          break;
        case "NativeStatus.nativeAdExitFullScreenVideoInAd":
          Utils.logError("原生广告退出全屏，广告位ID：$placementID");
          break;
        case "NativeStatus.nativeAdDidShowNativeAd":
          Utils.logError("原生广告展示成功，广告位ID：$placementID");
          break;
        case "NativeStatus.nativeAdDidStartPlayingVideo":
          Utils.logError("原生广告视频开始，广告位ID：$placementID");
          break;
        case "NativeStatus.nativeAdDidTapCloseButton":
          Utils.logError("原生广告被关闭，广告位ID：$placementID");
          // isNativeAdReady.value = false; // 关闭后重置状态
          break;
        case "NativeStatus.nativeAdDidLoadSuccessDraw":
          Utils.logError("原生广告渲染成功，广告位ID：$placementID");
          // isNativeAdReady.value = true; // 渲染成功，标记可显示
          break;
        case "NativeStatus.nativeAdDidCloseDetailInAdView":
          Utils.logError("原生广告关闭详情页，广告位ID：$placementID");
          break;
        case "NativeStatus.nativeAdUnknown":
        default:
          Utils.logError("原生广告未知事件，广告位ID：$placementID");
          break;
      }
    });
  }

  // 显示激励广告
  showRewarder() async {
    bool isReady = await RewarderTool.to.rewardedVideoReady();
    if (isReady) {
      await RewarderTool.to.showRewardedVideo();
    } else {
      CuToast.error(msg: "激励广告加载失败，请稍后重试");
    }
  }

  // 显示原生广告
  showNatvieAd() async {
    bool isReadyNative = await NativeTool.to.nativeAdReady();
    if (isReadyNative) {
      NativeTool.to.showNative();
    }
    Utils.logError("原生广告准备状态：$isReadyNative");
  }

  // 启动普通消息定时器（3秒/条）
  void _startAutoMessageTimer() {
    _autoMessageTimer = Timer.periodic(
      const Duration(seconds: 3),
          (Timer timer) => _addRandomChatMessage(hasPlaceholder: false),
    );
  }

  // 启动广告消息定时器（6秒/条）
  void _startPlaceholderTimer() {
    _placeholderTimer = Timer.periodic(
      const Duration(seconds: 6),
          (Timer timer) => _addRandomChatMessage(hasPlaceholder: true),
    );
  }

  // 生成聊天消息（支持普通/红包/广告消息）
  void _addRandomChatMessage({required bool hasPlaceholder}) {
    // 1. 生成随机用户信息
    final String randomNickname = _generateRandomNickname();
    final int avatarIndex = random.nextInt(31); // 0-30共31张头像
    final String localAvatarPath = ImageConfig.getUrlAvatar(avatarIndex);
    final VirtualUser randomUser = VirtualUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: randomNickname,
      avatarUrl: localAvatarPath,
    );

    // 2. 消息类型逻辑：广告消息不生成红包，普通消息20%概率红包
    final bool isRedPacket = !hasPlaceholder && random.nextDouble() < 0.2;

    // 3. 创建消息对象
    final ChatMessage newMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      user: randomUser,
      content: hasPlaceholder ? null : (isRedPacket ? null : _getRandomRedPacketQuote()),
      timestamp: DateTime.now(),
      hasPlaceholder: hasPlaceholder,
    );

    // 4. 添加消息并限制列表长度（最多20条）
    messages.add(newMessage);
    if (messages.length > 20) {
      messages.removeAt(0);
    }
  }

  // 生成随机昵称
  String _generateRandomNickname() {
    final List<String> surnames = [
      "张", "李", "王", "刘", "陈", "杨", "赵", "黄", "周", "吴",
      "徐", "孙", "胡", "朱", "高", "林", "何", "郭", "马", "罗"
    ];
    final List<String> givenNames = [
      "抢包快", "红包控", "手慢无", "必中君", "好运来", "财气旺",
      "秒抢王", "幸运星", "红包侠", "发财猫", "福气多", "抢不停"
    ];
    final List<String> suffixes = ["", "呀", "啦", "～", "！", "✨"];

    return "${surnames[random.nextInt(surnames.length)]}"
        "${givenNames[random.nextInt(givenNames.length)]}"
        "${suffixes[random.nextInt(suffixes.length)]}";
  }

  // 生成随机抢红包语录
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
      "抢红包太快乐了，根本停不下来！"
    ];
    return redPacketQuotes[random.nextInt(redPacketQuotes.length)];
  }

  // ------------------- 其他工具方法 -------------------
  // 生成MD5
  String generateMD5(String input) {
    final bytes = utf8.encode(input);
    final md5Hash = md5.convert(bytes);
    return md5Hash.toString();
  }

  // 获取渠道标识
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

  // 获取UserAgent
  Future<String?> getUserAgent() async {
    const platform = MethodChannel('ua_channel');
    try {
      final String? ua = await platform.invokeMethod('getUA');
      return ua;
    } on PlatformException catch (e) {
      Utils.logError("getUserAgent 错误: $e");
    }
    return null;
  }

  // 获取App升级信息
  Future<void> getAppUpdata() async {
    String channel = await getAppChannel();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    AppUpLoadForm appUpLoadForm = AppUpLoadForm();

    // 配置渠道包名
    if (channel.isEmpty) {
      appUpLoadForm.channelPackage = packageInfo.packageName;
    } else {
      appUpLoadForm.channelPackage = "${packageInfo.packageName}.$channel";
    }
    appUpLoadForm.channelPackage = "com.test.gf"; // 临时配置

    // 请求升级信息
    AppUpLoadModel appUpLoadModel = await Api.to.postUpApp(appUpLoadForm);
    // 补充设备信息
    appUpLoadModel.oaid = await FlutterAndroidOaidPlugin.getOAID();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    appUpLoadModel.ua = await getUserAgent();
    appUpLoadModel.fingerprint = androidInfo.fingerprint;
    appUpLoadModel.channel = channel;
    appUpLoadModel.channelPackage = appUpLoadForm.channelPackage;

    // 存储升级信息
    Store.instance.updateAppUpLoadModel(appUpLoadModel);

    // 校验版本并弹窗
    if (appUpLoadModel.packageName.isEmpty) return;
    String input = "channelPackage=${appUpLoadForm.channelPackage}&version=${packageInfo.version}";
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

  // ------------------- 生命周期 -------------------
  @override
  void onInit() {
    super.onInit();
    // 初始化广告监听和加载
    rewarderEvent();
    nativeEvent();
    RewarderTool.to.loadRewardedVideo();
    NativeTool.to.loadNativeWith();
    // 初始化用户信息
    UserInfo.instance.initialize();
    // 初始化消息（5条普通消息）
    for (int i = 0; i < 5; i++) {
      _addRandomChatMessage(hasPlaceholder: false);
    }
    // 启动定时器
    _startAutoMessageTimer();
    _startPlaceholderTimer();
  }

  @override
  void onClose() {
    super.onClose();
    // 取消定时器，防止内存泄漏
    _autoMessageTimer?.cancel();
    _placeholderTimer?.cancel();
  }

  // ------------------- 响应式状态 -------------------
  final RxString appbarTitle = "红包群".obs; // 导航栏标题
  final RxList<ChatMessage> messages = <ChatMessage>[].obs; // 聊天消息列表
  final Random random = Random(); // 全局随机数生成器
}