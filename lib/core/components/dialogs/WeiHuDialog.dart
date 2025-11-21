import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_empty.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/NoticeModel/NoticeModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_html/flutter_html.dart';

class WeiHuDialog extends StatefulWidget {
  /// 维护中
  const WeiHuDialog({super.key});

  @override
  State<WeiHuDialog> createState() => _WeiHuDialogState();
}

class _WeiHuDialogState extends State<WeiHuDialog> {
  List<NoticeModel> noticeList = [];
  bool _loadding = true;
  // 当前条目索引
  int index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (UserInfo.instance.isLoginIn) {
        UserInfo.instance.loginOut();
      }
      Future.delayed(Duration(seconds: 6), () {
        SystemNavigator.pop();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 关闭弹窗的方法
  void closeDialog() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.sp),
        ),
        backgroundColor: Colors.transparent,
        child:
            !_loadding
                ? Placeholder()
                : Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: TextConfig.primary,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      constraints: BoxConstraints(
                        maxHeight: Get.height * 0.6,
                        maxWidth: Get.width,
                      ),
                      padding: EdgeInsets.only(
                        left: 10.w,
                        right: 10.w,
                        top: 10.h,
                        bottom: 10.h,
                      ),
                      child: Column(
                        spacing: 5.h,
                        children: [
                          Container(
                            width: Get.width,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            padding: EdgeInsets.all(5.h),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      "重要通知",
                                      style: TextStyle(
                                        fontSize: TextConfig.textSize_20,
                                      ),
                                    ),
                                  ),
                                ),
                                // InkWell(
                                //   onTap: closeDialog, // 使用统一的关闭方法
                                //   child: Icon(Icons.close, size: 30.w),
                                // ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 10.h,
                              children: [
                                Text(
                                  "当前版本维护中，暂不支持使用",
                                  style: TextStyle(
                                    fontSize: TextConfig.textSize_20,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "系统于6秒后自动退出",
                                  style: TextStyle(
                                    fontSize: TextConfig.textSize_20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
