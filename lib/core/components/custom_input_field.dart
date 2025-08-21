import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 定义输入框类型的枚举，包含普通输入框和密码输入框两种类型
enum InputFieldType {
  normal, // 普通输入框
  password, // 密码输入框
}

// 自定义输入框组件（仅修复键盘唤起问题，无额外功能）
class CustomInputField extends StatefulWidget {
  /// 必须传入的输入框控制器，用于控制输入框的文本内容
  final TextEditingController controller;
  /// 值改变事件（直接使用controller的监听），当输入框内容发生变化时触发
  final void Function(String)? onChanged;
  /// 输入框的宽度
  final double? width;
  /// 输入框的高度
  final double? height;
  /// 输入类型，如文本输入、数字输入等
  final TextInputType inputType;
  /// 输入框允许输入的最大长度
  final int? maxLength;
  /// 验证方法，用于验证输入框内容是否符合要求
  final String? Function(String?)? validator;
  /// 错误提示信息，当输入内容不符合验证规则时显示
  final String? errorText;
  /// 输入提示，显示在输入框内的灰色提示文本
  final String? hintText;
  /// 输入框的背景色
  final Color? bgColor;
  /// 输入框内文字的颜色
  final Color? textColor;
  /// 输入框内文字的大小
  final double? textSize;
  /// 输入框的默认值
  final String? defaultValue;
  /// 输入框类型，通过枚举 InputFieldType 来指定
  final InputFieldType inputFieldType;
  /// 密码可见性图标颜色，仅在输入框类型为密码时生效
  final Color? passwordIconColor;

  // 组件构造函数（完全保留你原有参数）
  const CustomInputField({
    super.key,
    required this.controller, // 必须传入控制器
    this.onChanged,
    this.width,
    this.height,
    this.inputType = TextInputType.text, // 默认输入类型为文本输入
    this.maxLength,
    this.validator,
    this.errorText,
    this.hintText,
    this.bgColor = Colors.transparent, // 默认背景色为透明
    this.textSize,
    this.textColor = Colors.white, // 默认文字颜色为白色
    this.defaultValue,
    this.inputFieldType = InputFieldType.normal, // 默认类型为普通输入框
    this.passwordIconColor = Colors.grey, // 默认图标颜色为灰色
  });

  // 重置输入框内容的方法（保留你原有逻辑）
  void reset() {
    controller.clear();
  }

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

// 自定义输入框组件的状态类（仅补充焦点管理逻辑）
class _CustomInputFieldState extends State<CustomInputField> {
  // 错误信息，用于显示输入内容不符合验证规则时的提示（保留原有）
  String? _error;
  // 【新增】显式焦点节点（修复键盘唤起核心）
  late FocusNode _focusNode;
  // 密码是否隐藏的标志，仅在输入框类型为密码时使用（保留原有）
  bool _obscureText = false;

  // 组件初始化方法（补充焦点节点初始化）
  @override
  void initState() {
    super.initState();
    // 【新增】初始化焦点节点
    _focusNode = FocusNode();
    // 【新增】监听焦点变化：获取焦点时强制唤起键盘
    _focusNode.addListener(_onFocusChange);

    // 保留你原有逻辑：设置默认值
    if (widget.defaultValue != null) {
      widget.controller.text = widget.defaultValue!;
    }
    // 保留你原有逻辑：监听控制器变化
    widget.controller.addListener(_onControllerChanged);
    // 保留你原有逻辑：初始化密码隐藏状态
    _obscureText = widget.inputFieldType == InputFieldType.password;
  }

  // 组件销毁方法（补充焦点节点释放）
  @override
  void dispose() {
    // 保留你原有逻辑：移除控制器监听
    widget.controller.removeListener(_onControllerChanged);
    // 【新增】释放焦点节点资源（避免内存泄漏）
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();

    super.dispose();
  }

  // 【新增】焦点变化监听：获取焦点时主动唤起键盘
  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // 延迟执行：确保焦点注册完成后再唤起键盘
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 1. 显式请求焦点（双重保障）
        FocusScope.of(context).requestFocus(_focusNode);
        // 2. 系统级强制唤起（兜底解决偶发不弹键盘）
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    }
  }

  // 输入框内容变化时的回调方法（完全保留原有逻辑）
  void _onControllerChanged() {
    widget.onChanged?.call(widget.controller.text);
    if (widget.validator != null) {
      setState(() {
        _error = widget.validator!(widget.controller.text);
      });
    }
  }

  // 切换密码可见性的方法（完全保留原有逻辑）
  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // 构建组件的 UI（仅补充焦点节点绑定和点击请求焦点）
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: widget.width,
          height: widget.height ?? 40.h,
          child: TextField(
            controller: widget.controller, // 保留原有
            // 【新增】绑定显式焦点节点
            focusNode: _focusNode,
            // 【新增】点击输入框时主动请求焦点（解决点击无响应）
            onTap: () => FocusScope.of(context).requestFocus(_focusNode),
            // 以下完全保留你原有配置
            style: TextStyle(
              color: widget.textColor,
              fontSize: widget.textSize,
            ),
            textAlignVertical: TextAlignVertical.center,
            keyboardType: widget.inputType,
            maxLength: widget.maxLength,
            obscureText: _obscureText,
            decoration: InputDecoration(
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: widget.textSize,
              ),
              fillColor: widget.bgColor,
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 5.sp,
              ),
              hintText: widget.hintText,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0.sp),
                borderSide: BorderSide(color: widget.bgColor!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0.sp),
                borderSide: BorderSide(color: widget.bgColor!),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0.sp),
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0.sp),
                borderSide: BorderSide(color: Colors.red),
              ),
              suffixIcon: widget.inputFieldType == InputFieldType.password
                  ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: widget.passwordIconColor,
                ),
                onPressed: _toggleObscureText,
              )
                  : null,
            ),
          ),
        ),
        // 错误信息显示（完全保留原有逻辑）
        if (_error != null || widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 4.sp, left: 8.sp),
            child: Text(
              _error ?? widget.errorText!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.sp,
              ),
            ),
          ),
      ],
    );
  }
}