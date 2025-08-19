// 消息模型
class ChatMessage {
  final String id;
  final VirtualUser user;
  final String? content; // 为null时显示红包
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.user,
    this.content,
    required this.timestamp,
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