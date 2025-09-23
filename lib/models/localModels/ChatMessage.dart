import 'package:flutter/cupertino.dart';

class ChatMessage {
  final String id;
  final VirtualUser user;
  final Widget content; // 消息小部件
  final DateTime timestamp;
  ChatMessage({
    required this.id,
    required this.user,
    required this.content,
    required this.timestamp,
  });
}

// 虚拟人物模型
class VirtualUser {
  final String id;
  final String name;
  final String avatarUrl;

  VirtualUser({required this.id, required this.name, required this.avatarUrl});
}
