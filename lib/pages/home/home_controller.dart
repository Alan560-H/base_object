
import 'dart:async';
import 'dart:math';

import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/models/localModels/ChatMessage.dart';
import 'package:base_object/store/user_info.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // 定时器对象，控制自动添加消息的周期
  Timer? _autoMessageTimer;

  // 页面初始化：添加初始消息 + 启动自动消息定时器
  @override
  void onInit() {
    super.onInit();
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
      "张", "李", "王", "刘", "陈", "杨", "赵", "黄", "周", "吴",
      "徐", "孙", "胡", "朱", "高", "林", "何", "郭", "马", "罗"
    ];
    // 抢红包场景专属名字
    final List<String> givenNames = [
      "抢包快", "红包控", "手慢无", "必中君", "好运来", "财气旺",
      "秒抢王", "幸运星", "红包侠", "发财猫", "福气多", "抢不停"
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
      "抢红包太快乐了，根本停不下来！"
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
}