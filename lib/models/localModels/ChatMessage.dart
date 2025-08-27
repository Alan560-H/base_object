class ChatMessage {
  final String id;
  final VirtualUser user;
  final String? content; // null = 红包消息
  final DateTime timestamp;
  final bool hasPlaceholder; // 新增：标记是否为Placeholder消息

  ChatMessage({
    required this.id,
    required this.user,
    this.content,
    required this.timestamp,
    this.hasPlaceholder = false, // 默认false（普通消息/红包消息）
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