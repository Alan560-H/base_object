import 'package:flutter/cupertino.dart';

class ChatMessage {
  final String id;
  final VirtualUser user;
  final Widget content; // 消息小部件
  final DateTime timestamp;
  final bool isHasNative;
  ChatMessage({
    required this.id,
    required this.user,
    required this.content,
    required this.timestamp,
    required this.isHasNative,
  });
}
// 虚拟人物模型
class VirtualUser {
  final String id;
  final String name;
  final String avatarUrl;

  VirtualUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });
}