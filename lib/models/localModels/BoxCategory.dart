// 定义 BoxCategory 类 ,用来进行首页箱子的分类
class BoxCategory {
  int id;
  String categoryName;

  // 构造函数
  BoxCategory({required this.id, this.categoryName = ""});

  // 重写 toString 方法，方便打印对象信息
  @override
  String toString() {
    return 'ID: $id, 分类名称: $categoryName';
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoxCategory &&
        other.id == id &&
        other.categoryName == categoryName;
  }

  @override
  int get hashCode => id.hashCode ^ categoryName.hashCode;
}
