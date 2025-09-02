


import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'AppMaintenanceDialog.dart';
import 'AppUpLoadDialog.dart';
import 'AuthenticationDialog.dart';
import 'BindViteCodeDialog.dart';
import 'ConfirmDialog.dart';
import 'DeregisterDialog.dart';
/// 如果调用通用模态框，请调用showCustomDialog,如果是特殊模态框，请直接调用其静态方法
class BaseDialog extends StatefulWidget {
  final dynamic data;
  final String dialogType;
  final String dialogTitle;
  final bool barrierDismissible;// 禁止关闭 true是禁止，false是可以
  /// tabChange事件
  final void Function(dynamic sonData)? onClick;
  final void Function()? onClose;
  const BaseDialog({super.key,required this.dialogType,this.dialogTitle="提示",this.onClick, this.data,required this.barrierDismissible,this.onClose});

  @override
  State<BaseDialog> createState() => _BaseDialogState();
}

class _BaseDialogState extends State<BaseDialog> {

  /// 定义对话框构建器映射
  final Map<String, Widget Function()> _dialogBuilders = {
    // 注销帮助说明
    'DeregisterDialog': () => DeregisterDialog(),
    // 实名认证
    'AuthenticationDialog': () => AuthenticationDialog(),
    // 绑定邀请码
    'BindViteCodeDialog': () => BindViteCodeDialog(),

    // 维护中
    'AppMaintenanceDialog': () => AppMaintenanceDialog(),
  };
  /// 如果有需要回调再这里单独引入组件
  @override
  void initState() {

    /// 确认通用狂
    _dialogBuilders["ConfirmDialog"] = () => ConfirmDialog(onClick: (i) { widget.onClick!.call(i);  },data:widget.data);
    super.initState();
  }
  /// 定义需要数据的对话框构建器映射
  final Map<String, Widget Function(dynamic)> _dialogBuildersWithData = {
    /// 应用升级框
    'AppUpLoadDialog': (data) => AppUpLoadDialog(appUpLoadModel: data,),

  };

  /// 根据分类返回不同的dialog
  Widget get getDialogTypeWidget {
    // 优先查找无数据的对话框
    final builder = _dialogBuilders[widget.dialogType];
    if (builder != null) {
      return builder();
    }

    // 查找需要数据的对话框
    final builderWithData = _dialogBuildersWithData[widget.dialogType];
    if (builderWithData != null && widget.data != null) {
      return builderWithData(widget.data);
    }

    Utils.logError('未找到匹配的对话框类型: ${widget.dialogType}');
    Get.back();
    return Container();
  }
  /// 获取对话框旁边的图片
  Widget get titleSideImg {
    return CachedNetworkImage(
      width: 40.w,
      imageUrl: ImageConfig.dialogTitleSide,
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  /// 标题组件
  Widget get title {
    return Stack(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Transform.scale(
            //   scaleX: -1, // 垂直方向缩放为 -1 实现反转
            //   child: titleSideImg,
            // ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0),
              child: Text(
                widget.dialogTitle,
                style: TextStyle(fontSize: TextConfig.textSize_20,color: Colors.white),
              ),
            ),
            // titleSideImg,
          ],
        ),
        Positioned(
          right: 0,
          top: 0.h,
          child: GestureDetector(
            onTap: (){
              if(widget.barrierDismissible){
                Get.back();
                if(widget.onClose!=null){
                  widget.onClose!();
                }
              }
            },
            child:Icon(Icons.close,size: TextConfig.textSize_30,color: Colors.white,),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        // 设置圆角半径
        borderRadius: BorderRadius.circular(5.sp),
      ),
      backgroundColor:Colors.transparent,
      child: Container(

        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(ImageConfig.dialogBodyBg),
            fit: BoxFit.fill,
          ),
        ),

        constraints: BoxConstraints(
          minHeight:Get.height * 0.3,
          maxHeight: Get.height * 0.8,
          maxWidth: Get.width * 0.9,
        ),
        padding: EdgeInsets.symmetric(horizontal: 30.w,vertical: 20.sp),
        child: Column(
          spacing: 10.h,
          mainAxisSize: MainAxisSize.min,
          children: [
            title,
            // Flexible(child: Container(height: 20.h,color: Colors.red,))
            LimitedBox(
              maxHeight: Get.height * 0.5,
              child: SingleChildScrollView(
                child: getDialogTypeWidget,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

