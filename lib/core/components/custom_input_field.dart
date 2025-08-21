import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 定义输入框类型的枚举，包含普通输入框和密码输入框两种类型
enum InputFieldType {
  normal, // 普通输入框
  password, // 密码输入框
}

// 自定义输入框组件
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

  // 组件构造函数
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

  // 创建组件状态
  @override
  State<CustomInputField> createState() => _CustomInputFieldState();

  // 重置输入框内容的方法
  void reset() {
    // 直接通过外部控制器重置输入框内容
    controller.clear();
    // 移除了使用 key.currentState 的代码
  }
}

// 自定义输入框组件的状态类
class _CustomInputFieldState extends State<CustomInputField> {
  // 错误信息，用于显示输入内容不符合验证规则时的提示
  String? _error;
  // // 焦点节点，用于监听输入框的焦点状态
  // late FocusNode _focusNode;
  // 密码是否隐藏的标志，仅在输入框类型为密码时使用
  bool _obscureText = false;

  // 组件初始化方法
  @override
  void initState() {
    super.initState();
    // 设置默认值，如果传入了默认值，则将其设置到输入框控制器中
    if (widget.defaultValue != null) {
      widget.controller.text = widget.defaultValue!;
    }
    // 监听外部控制器的变化，当输入框内容变化时调用 _onControllerChanged 方法
    widget.controller.addListener(_onControllerChanged);

    // // 初始化焦点节点，并添加焦点变化监听
    // _focusNode = FocusNode();
    // _focusNode.addListener(_onFocusChange);

    // 根据输入框类型设置密码是否隐藏的标志
    _obscureText = widget.inputFieldType == InputFieldType.password;
  }

  // 组件销毁方法，用于释放资源
  @override
  void dispose() {
    // 移除输入框控制器的监听，避免内存泄漏
    widget.controller.removeListener(_onControllerChanged);
    // // 移除焦点节点的监听，避免内存泄漏
    // _focusNode.removeListener(_onFocusChange);
    // // 释放焦点节点资源
    // _focusNode.dispose();
    super.dispose();
  }

  // 输入框内容变化时的回调方法
  void _onControllerChanged() {
    // 调用外部传入的 onChanged 方法
    widget.onChanged?.call(widget.controller.text);
    // 如果传入了验证方法，则进行验证并更新错误信息
    if (widget.validator != null) {
      setState(() {
        _error = widget.validator!(widget.controller.text);
      });
    }
  }

  // // 输入框焦点变化时的回调方法
  // void _onFocusChange() {
  //   // 当输入框失去焦点时，清除错误信息
  //   if (!_focusNode.hasFocus) {
  //     setState(() {
  //       _error = null;
  //     });
  //   }
  // }

  // 切换密码可见性的方法
  void _toggleObscureText() {
    setState(() {
      // 取反密码是否隐藏的标志
      _obscureText = !_obscureText;
    });
  }

  // 构建组件的 UI
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: widget.width,
          height: widget.height ?? 40.h, // 固定高度，如果未传入高度则使用默认值
          child: TextField(
            controller: widget.controller, // 直接使用外部控制器
            // focusNode: _focusNode,
            style: TextStyle(
              color: widget.textColor, // 设置输入文本颜色为白色
              fontSize: widget.textSize,
            ),
            textAlignVertical: TextAlignVertical.center,
            keyboardType: widget.inputType,
            maxLength: widget.maxLength,
            obscureText: _obscureText, // 根据标志设置密码是否隐藏
            decoration: InputDecoration(
              hintStyle: TextStyle(
                color: Colors.grey, // 设置提示语颜色为灰色
                fontSize: widget.textSize,
              ),
              fillColor: widget.bgColor,
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 5.sp,
              ),
              hintText: widget.hintText,
              // 移除 errorText，改为在外部显示
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
                borderSide: BorderSide(color: Colors.red), // 错误边框颜色
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0.sp),
                borderSide: BorderSide(color: Colors.red),
              ),
              suffixIcon: widget.inputFieldType == InputFieldType.password
                  ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: widget.passwordIconColor, // 设置图标颜色
                ),
                onPressed: _toggleObscureText,
              )
                  : null,
            ),
          ),
        ),
        // 单独显示错误信息，如果有错误信息则显示
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