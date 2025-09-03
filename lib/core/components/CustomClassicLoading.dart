import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

// 自定义 EasyRefresh Header
class CustomClassicHeader extends ClassicHeader {
  CustomClassicHeader({
    super.key,
    super.triggerOffset = 70.0,
    super.clamping = false,
    // 配置 Header 样式和文本
    IconThemeData super.iconTheme = const IconThemeData(color: Colors.black87),
    super.showText,
    super.showMessage,
    super.dragText = "下拉刷新",
    super.armedText = "",
    super.readyText = "",
    super.processingText = "努力加载中...",
    super.processedText = "加载完成",
    super.messageText = "",
    super.textStyle = const TextStyle(color: Colors.black87),
    super.messageStyle = const TextStyle(color: Colors.black87),
  });
}

// 自定义 EasyRefresh Footer
class CustomClassicFooter extends ClassicFooter {
  CustomClassicFooter({
    super.key,
    super.triggerOffset = 70.0,
    super.clamping = false,
    // 配置 Footer 样式和文本
    IconThemeData super.iconTheme = const IconThemeData(color: Colors.black87),
    super.showText,
    super.showMessage,
    super.dragText = "上拉加载",
    super.armedText = "",
    super.readyText = "",
    super.processingText = "努力加载中...",
    super.processedText = "加载完成",
    super.messageText = "",
    super.textStyle = const TextStyle(color: Colors.black87),
    super.messageStyle = const TextStyle(color: Colors.black87),
    super.noMoreText = "没有更多数据了",
  });
}