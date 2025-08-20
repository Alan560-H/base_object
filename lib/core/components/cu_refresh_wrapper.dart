import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'CustomClassicLoading.dart';

/// 内置控制器的通用刷新组件
/// 先完成内部状态更新，再触发外部回调（确保动作完成后通知）
class CuRefreshWrapper extends StatefulWidget {
  /// 子组件（列表内容）
  final Widget child;

  /// 下拉刷新回调：外部处理数据逻辑，返回Future（数据加载完成后通知组件）
  final Future<void> Function() onRefresh;

  /// 上拉加载更多回调：外部处理数据逻辑，返回Future<是否有更多数据>（加载完成后通知组件）
  final Future<bool> Function() onLoad;

  /// 【动作完成后触发】刷新全部完成（内部状态+外部数据都完成）
  final VoidCallback? onRefreshFinished;

  /// 【动作完成后触发】加载更多完成（有更多数据，内部状态已更新）
  final VoidCallback? onLoadFinished;

  /// 【动作完成后触发】没有更多数据（内部状态已更新）
  final VoidCallback? onNoMoreDataFinished;

  const CuRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.onLoad,
    this.onRefreshFinished,
    this.onLoadFinished,
    this.onNoMoreDataFinished,
  });

  @override
  State<CuRefreshWrapper> createState() => _CuRefreshWrapperState();
}

class _CuRefreshWrapperState extends State<CuRefreshWrapper> {
  late final EasyRefreshController _controller;
  String _processedText = "";

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      header: CustomClassicHeader(),
      footer: CustomClassicFooter(processedText: _processedText),
      controller: _controller,
      // 下拉刷新：先外部数据→再内部状态→最后触发外部完成回调
      onRefresh: () async {
        try {
          // 1. 先让外部完成数据逻辑（如请求接口、更新列表）
          await widget.onRefresh();

          // 2. 再完成组件内部状态更新（控制器、文本）
          _controller.finishRefresh();
          setState(() => _processedText = ""); // 重置加载文本

          // 3. 【动作全部完成后】触发外部回调（此时内部状态已稳定）
          widget.onRefreshFinished?.call();
        } catch (e) {
          // 异常场景也确保控制器状态正常
          _controller.finishRefresh(IndicatorResult.fail);
          setState(() => _processedText = "刷新失败");
        }
      },
      // 上拉加载：先外部数据→再内部状态→最后触发外部完成回调
      onLoad: () async {
        try {
          // 1. 先让外部完成数据逻辑，获取“是否有更多数据”的结果
          final hasMore = await widget.onLoad();

          // 2. 再完成组件内部状态更新（控制器、文本）
          final loadResult = hasMore ? IndicatorResult.success : IndicatorResult.noMore;
          _controller.finishLoad(loadResult);
          setState(() {
            _processedText = hasMore ? "加载完成" : "没有更多数据了";
          });

          // 3. 【动作全部完成后】根据结果触发对应外部回调
          if (hasMore) {
            widget.onLoadFinished?.call();
          } else {
            widget.onNoMoreDataFinished?.call();
          }
        } catch (e) {
          // 异常场景也确保控制器状态正常
          _controller.finishLoad(IndicatorResult.fail);
          setState(() => _processedText = "加载失败");
        }
      },
      child: widget.child,
    );
  }
}