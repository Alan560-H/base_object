import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_empty.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/NoticeModel/NoticeModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_html/flutter_html.dart';

class PbkyyDialog extends StatefulWidget {
  /// 屏蔽快应用弹窗
  const PbkyyDialog({super.key});

  @override
  State<PbkyyDialog> createState() => _PbkyyDialogState();
}

class _PbkyyDialogState extends State<PbkyyDialog> {
  List<NoticeModel> noticeList = [];
  bool _loadding = true;
  // 当前条目索引
  int index = 0;

  void getNoticeAPP() async {
    noticeList = await Api.to.getNoticeAPP();
    setState(() {
      _loadding = false;
    });
    Utils.logDebug("屏蔽快应用列表：${noticeList.toList()},$_loadding");
  }

  @override
  void initState() {
    if (!Get.isRegistered<Api>()) {
      Get.put(Api());
    }
    getNoticeAPP();
    super.initState();
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
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.sp)),
      backgroundColor: Colors.transparent,
      child:
          _loadding
              ? Center()
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
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5.sp,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              index == i
                                                  ? TextConfig.primary
                                                  : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            5.w,
                                          ),
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
                                onTap: closeDialog, // 使用统一的关闭方法
                                child: Icon(Icons.close, size: 30.w),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child:
                              noticeList.isNotEmpty
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
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
