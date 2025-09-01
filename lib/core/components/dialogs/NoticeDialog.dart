import 'dart:developer';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_empty.dart';
import 'package:base_object/core/config/app_keys.dart';
import 'package:base_object/models/backModel/NoticeModel/NoticeModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_html/flutter_html.dart';

import '../../../utils/local_storage.dart';
import '../../config/image_config.dart';
import '../../config/text_config.dart';

class NoticeDialog extends StatefulWidget {
  /// 公告弹窗
  const NoticeDialog({super.key});

  // 添加一个静态方法检查是否需要显示弹窗
  static Future<bool> shouldShow() async {
    String? lastTimeStr = await LocalStorage.getString(AppKeys.noteLastTimeKey);
    if (lastTimeStr != null && lastTimeStr.isNotEmpty) {
      try {
        int lastTime = int.parse(lastTimeStr);
        int now = DateTime.now().millisecondsSinceEpoch;
        // 计算时间差（一周 = 7 * 24 * 60 * 60 * 1000 毫秒）
        int weekInMilliseconds = 7 * 24 * 60 * 60 * 1000;

        // 如果在一周内，则不显示

        if (now - lastTime < weekInMilliseconds) {
          return false;
        }
      } catch (e) {
        Utils.logDebug("解析时间戳错误: $e");
      }
    }
    return true;
  }

  @override
  State<NoticeDialog> createState() => _NoticeDialogState();
}

class _NoticeDialogState extends State<NoticeDialog> {
  List<NoticeModel> noticeList = [];
  bool _loadding = true;
  // 当前条目索引
  int index = 0;

  /// 是否同意用户隐私协议
  bool isChecked = false;

  void postNotice() async {
    noticeList = await Api.to.postNotice();
    setState(() {
      _loadding = false;
    });
    Utils.logDebug("公告列表：${noticeList.toList()},$_loadding");
  }

  @override
  void initState() {
    if (!Get.isRegistered<Api>()) {
      Get.put(Api());
    }
    postNotice();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 关闭弹窗的方法
  void closeDialog() {
    // 如果勾选了一周内不显示，存储当前时间戳
    if (isChecked) {
      LocalStorage.setString(
        AppKeys.noteLastTimeKey,
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.sp),
      ),
      backgroundColor: Colors.transparent,
      child: _loadding
          ? Center()
          : Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white60,
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
                      borderRadius: BorderRadius.circular(5.r)
                  ),
                  padding: EdgeInsets.all(5.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: noticeList.length,
                          itemBuilder: (BuildContext _, int i) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  index = i;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5.sp),
                                decoration: BoxDecoration(
                                    color: index==i?Colors.white:Colors.transparent,
                                    borderRadius: BorderRadius.circular(5.w)
                                ),
                                margin: EdgeInsets.symmetric(
                                  horizontal: 5.h,
                                ),
                                alignment: Alignment.center,
                                child: Text(noticeList[i].name),
                              ),
                            );
                          },
                        ),
                      ),
                      InkWell(
                        onTap: closeDialog,  // 使用统一的关闭方法
                        child: Icon(Icons.close,size: 30.w,),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: noticeList.isNotEmpty
                      ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    padding: EdgeInsets.all(5.r),
                    child: SingleChildScrollView(
                      child: Html(
                        data: md.markdownToHtml(
                          noticeList[index].content,
                        ),
                      ),
                    ),
                  )
                      : CuEmpty(),
                ),

                /// 一周内不显示
                InkWell(
                  onTap: () {
                    setState(() {
                      isChecked = !isChecked;
                    });
                  },
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 40.h),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 25.h,
                          width: 25.w,
                          child: Checkbox(
                            activeColor: TextConfig.primary,
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                            value: isChecked,
                            onChanged: (bool? value) {
                              if (value != null) {
                                setState(() {
                                  isChecked = value;
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "本周内不显示",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
