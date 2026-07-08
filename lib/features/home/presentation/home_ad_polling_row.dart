import 'dart:async';

import 'package:base_object/app/providers.dart';
import 'package:base_object/features/home/presentation/home_ad_polling_notifier.dart';
import 'package:base_object/features/home/presentation/home_ad_polling_state.dart';
import 'package:base_object/services/ads/banner_tool.dart';
import 'package:base_object/services/ads/native_tool.dart';
import 'package:base_object/shared/config/home_ui_strings.dart';
import 'package:base_object/shared/widgets/cu_toast.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 首页顶部：信息流 / 横幅轮询秒数与开关。
class HomeAdPollingRow extends ConsumerStatefulWidget {
  const HomeAdPollingRow({super.key});

  @override
  ConsumerState<HomeAdPollingRow> createState() => _HomeAdPollingRowState();
}

class _HomeAdPollingRowState extends ConsumerState<HomeAdPollingRow> {
  static const Duration _intervalDebounce = Duration(milliseconds: 600);

  Timer? _bannerIntervalDebounce;
  Timer? _nativeIntervalDebounce;
  int _bannerIntervalRestartToken = 0;
  int _nativeIntervalRestartToken = 0;

  @override
  void dispose() {
    _bannerIntervalDebounce?.cancel();
    _nativeIntervalDebounce?.cancel();
    super.dispose();
  }

  /// 轮询开关或间隔变更：停止当前流程，按新配置重新开始（轮询开启时）并提示。
  Future<void> _restartBannerPollingFlow({
    required String toastMessage,
    required bool restartPlayback,
    bool showToast = true,
  }) async {
    final BannerTool banner = ref.read(bannerToolProvider);
    try {
      await banner.pauseBannerPlayback();
      banner.onPollingConfigChanged();
      if (restartPlayback) {
        await banner.startBannerPlayback();
      }
      if (showToast) {
        CuToast.success(
          msg: toastMessage,
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    } catch (e, st) {
      Utils.logError('[BannerPoll] 配置变更后重启失败: $e $st');
      CuToast.error(msg: '横幅轮询重启失败');
    }
  }

  Future<void> _restartNativePollingFlow({
    required String toastMessage,
    required bool restartPlayback,
    bool showToast = true,
  }) async {
    final NativeTool native = ref.read(nativeToolProvider);
    try {
      await native.pauseNativeFeedPlayback();
      native.onPollingConfigChanged();
      if (restartPlayback) {
        await native.startNativeFeedPlayback();
      }
      if (showToast) {
        CuToast.success(
          msg: toastMessage,
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    } catch (e, st) {
      Utils.logError('[NativePoll] 配置变更后重启失败: $e $st');
      CuToast.error(msg: '信息流轮询重启失败');
    }
  }

  void _scheduleBannerIntervalEffect(int before) {
    _bannerIntervalDebounce?.cancel();
    final int token = ++_bannerIntervalRestartToken;
    _bannerIntervalDebounce = Timer(_intervalDebounce, () {
      if (!mounted || token != _bannerIntervalRestartToken) return;
      final HomeAdPollingState polling = ref.read(homeAdPollingProvider);
      final int after = polling.bannerIntervalSeconds;
      if (before == after) return;
      Utils.logError('[BannerPoll] 间隔变更 $before→${after}s（防抖后生效）');
      if (polling.bannerPollingEnabled) {
        unawaited(
          _restartBannerPollingFlow(
            toastMessage: HomeUiStrings.bannerPollingIntervalRestarted(after),
            restartPlayback: true,
          ),
        );
      } else {
        CuToast.success(
          msg: HomeUiStrings.bannerIntervalSavedWhenPollingOff(after),
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    });
  }

  void _scheduleNativeIntervalEffect(int before) {
    _nativeIntervalDebounce?.cancel();
    final int token = ++_nativeIntervalRestartToken;
    _nativeIntervalDebounce = Timer(_intervalDebounce, () {
      if (!mounted || token != _nativeIntervalRestartToken) return;
      final HomeAdPollingState polling = ref.read(homeAdPollingProvider);
      final int after = polling.nativeIntervalSeconds;
      if (before == after) return;
      Utils.logError('[NativePoll] 间隔变更 $before→${after}s（防抖后生效）');
      if (polling.nativePollingEnabled) {
        unawaited(
          _restartNativePollingFlow(
            toastMessage: HomeUiStrings.nativePollingIntervalRestarted(after),
            restartPlayback: true,
          ),
        );
      } else {
        CuToast.success(
          msg: HomeUiStrings.nativeIntervalSavedWhenPollingOff(after),
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    });
  }

  void _applyBannerIntervalChange(
    void Function(HomeAdPollingNotifier notifier) update,
  ) {
    final int before = ref.read(homeAdPollingProvider).bannerIntervalSeconds;
    final HomeAdPollingNotifier notifier =
        ref.read(homeAdPollingProvider.notifier);
    update(notifier);
    final int after = ref.read(homeAdPollingProvider).bannerIntervalSeconds;
    if (before == after) return;
    _scheduleBannerIntervalEffect(before);
  }

  void _applyNativeIntervalChange(
    void Function(HomeAdPollingNotifier notifier) update,
  ) {
    final int before = ref.read(homeAdPollingProvider).nativeIntervalSeconds;
    final HomeAdPollingNotifier notifier =
        ref.read(homeAdPollingProvider.notifier);
    update(notifier);
    final int after = ref.read(homeAdPollingProvider).nativeIntervalSeconds;
    if (before == after) return;
    _scheduleNativeIntervalEffect(before);
  }

  void _applyBannerSwitchChange(bool enabled) {
    final bool before = ref.read(homeAdPollingProvider).bannerPollingEnabled;
    if (before == enabled) return;
    _bannerIntervalDebounce?.cancel();
    ref.read(homeAdPollingProvider.notifier).setBannerPollingEnabled(enabled);
    Utils.logError('[BannerPoll] 轮询开关 $before→$enabled');
    unawaited(
      _restartBannerPollingFlow(
        toastMessage: HomeUiStrings.bannerPollingSwitchRestarted(enabled),
        restartPlayback: enabled,
      ),
    );
  }

  void _applyNativeSwitchChange(bool enabled) {
    final bool before = ref.read(homeAdPollingProvider).nativePollingEnabled;
    if (before == enabled) return;
    _nativeIntervalDebounce?.cancel();
    ref.read(homeAdPollingProvider.notifier).setNativePollingEnabled(enabled);
    Utils.logError('[NativePoll] 轮询开关 $before→$enabled');
    unawaited(
      _restartNativePollingFlow(
        toastMessage: HomeUiStrings.nativePollingSwitchRestarted(enabled),
        restartPlayback: enabled,
        showToast: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeAdPollingState polling = ref.watch(homeAdPollingProvider);

    return Row(
      children: [
        Expanded(
          child: _PollingColumn(
            label: '信息流',
            seconds: polling.nativeIntervalSeconds,
            enabled: polling.nativePollingEnabled,
            onDecrement: () {
              _applyNativeIntervalChange((n) => n.decrementNativeInterval());
            },
            onIncrement: () {
              _applyNativeIntervalChange((n) => n.incrementNativeInterval());
            },
            onSecondsCommitted: (value) {
              _applyNativeIntervalChange(
                (n) => n.setNativeIntervalSeconds(value),
              );
            },
            onEnabledChanged: _applyNativeSwitchChange,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _PollingColumn(
            label: '横幅',
            seconds: polling.bannerIntervalSeconds,
            enabled: polling.bannerPollingEnabled,
            onDecrement: () {
              _applyBannerIntervalChange((n) => n.decrementBannerInterval());
            },
            onIncrement: () {
              _applyBannerIntervalChange((n) => n.incrementBannerInterval());
            },
            onSecondsCommitted: (value) {
              _applyBannerIntervalChange(
                (n) => n.setBannerIntervalSeconds(value),
              );
            },
            onEnabledChanged: _applyBannerSwitchChange,
          ),
        ),
      ],
    );
  }
}

class _PollingColumn extends StatelessWidget {
  const _PollingColumn({
    required this.label,
    required this.seconds,
    required this.enabled,
    required this.onDecrement,
    required this.onIncrement,
    required this.onSecondsCommitted,
    required this.onEnabledChanged,
  });

  final String label;
  final int seconds;
  final bool enabled;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<int> onSecondsCommitted;
  final ValueChanged<bool> onEnabledChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 12.sp, color: Colors.black87),
              ),
            ),
            Transform.scale(
              scale: 0.85,
              child: Switch(
                value: enabled,
                onChanged: onEnabledChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        _IntervalStepper(
          key: ValueKey(label),
          seconds: seconds,
          onDecrement: onDecrement,
          onIncrement: onIncrement,
          onSecondsCommitted: onSecondsCommitted,
        ),
      ],
    );
  }
}

class _IntervalStepper extends StatefulWidget {
  const _IntervalStepper({
    super.key,
    required this.seconds,
    required this.onDecrement,
    required this.onIncrement,
    required this.onSecondsCommitted,
  });

  final int seconds;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<int> onSecondsCommitted;

  @override
  State<_IntervalStepper> createState() => _IntervalStepperState();
}

class _IntervalStepperState extends State<_IntervalStepper> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.seconds}');
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _syncControllerFromWidget() {
    final String text = '${widget.seconds}';
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  void didUpdateWidget(covariant _IntervalStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seconds != widget.seconds && !_focusNode.hasFocus) {
      _syncControllerFromWidget();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_focusNode.hasFocus) return;
        Scrollable.ensureVisible(
          context,
          alignment: 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
      return;
    }
    _commitInput();
  }

  void _commitInput() {
    final String raw = _controller.text.trim();
    if (raw.isEmpty) {
      _syncControllerFromWidget();
      return;
    }
    final int? parsed = int.tryParse(raw);
    if (parsed == null) {
      _syncControllerFromWidget();
      return;
    }
    final int clamped = HomeAdPollingState.clampInterval(parsed);
    _controller.text = '$clamped';
    if (clamped != widget.seconds) {
      widget.onSecondsCommitted(clamped);
    }
  }

  void _handleDecrement() {
    _focusNode.unfocus();
    widget.onDecrement();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncControllerFromWidget();
    });
  }

  void _handleIncrement() {
    _focusNode.unfocus();
    widget.onIncrement();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncControllerFromWidget();
    });
  }

  void _onFieldTap() {
    final String text = '${widget.seconds}';
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: 0, extentOffset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          _StepperButton(icon: Icons.remove, onPressed: _handleDecrement),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              scrollPadding: EdgeInsets.only(bottom: 120.h),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                isCollapsed: true,
              ),
              onTap: _onFieldTap,
              onSubmitted: (_) {
                _commitInput();
                _focusNode.unfocus();
              },
            ),
          ),
          _StepperButton(icon: Icons.add, onPressed: _handleIncrement),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36.w,
      height: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Icon(icon, size: 18.sp, color: Colors.black54),
        ),
      ),
    );
  }
}
