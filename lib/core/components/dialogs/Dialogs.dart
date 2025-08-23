import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'commonDialog/BaseDialog.dart';

/// 如果需要调用通用模态框，请调用showCommonDialog，否则直接调用其特殊模态框静态方法
class Dialogs {
  /// 通用模态框 调用示例: Dialogs.showCommonDialog(context,dialogType: 'ChangeDialog', dialogTitle: '自定义标题');
  static Future<Widget?> showCommonDialog(
     {
    required String dialogType,
    String dialogTitle = "提示",
    dynamic data,
    void Function(dynamic sonData)? onClick,
    void Function()? onClose,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      barrierDismissible: barrierDismissible,
      context: Get.context!,
      builder: (BuildContext dialogContext) {
        return BaseDialog(
          barrierDismissible:barrierDismissible,
          dialogType: dialogType,
          dialogTitle: dialogTitle,
          data: data,
          onClick: onClick,
          onClose: onClose,
        );
      },
    );
  }


  // /// 领取红包
  // static Future<Widget?> redBagDialog(BuildContext context) {
  //   return showDialog(
  //     context: context,
  //     builder: (BuildContext dialogContext) {
  //       return RedBagDialog();
  //     },
  //   );
  // }

  // /// 公告框
  // static Future<Widget?> noticeDialog(BuildContext context) {
  //   return showDialog(
  //     barrierDismissible: false, // 禁用遮罩层点击
  //     context: context,
  //     builder: (BuildContext dialogContext) {
  //       return NoticeDialog();
  //     },
  //   );
  // }
  /// 看广告得框
  // /// 公告框
  // static Future<Widget?> lookADDialog(BuildContext context,{
  //   void Function(dynamic sonData)? onClick,
  //   bool barrierDismissible = true,
  // }) {
  //   return showDialog(
  //     barrierDismissible: barrierDismissible, // 禁用遮罩层点击
  //     context: context,
  //     builder: (BuildContext dialogContext) {
  //       return LookADDialog(onClick: onClick);
  //     },
  //   );
  // }
}
