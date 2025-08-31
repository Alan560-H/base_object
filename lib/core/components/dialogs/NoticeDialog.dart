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
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
      shape: RoundedRectangleBorder(
        // 设置圆角半径
        borderRadius: BorderRadius.circular(5.sp),
      ),
      backgroundColor: Colors.transparent,
      child:
          _loadding
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

                                        // decoration: BoxDecoration(
                                        //   image:index==i? DecorationImage(image: CachedNetworkImageProvider(ImageConfig.noticeActive)):null,
                                        // ),
                                        child: Text(noticeList[i].name),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  LocalStorage.setString(
                                    "noteDialogDisable",
                                    true,
                                  );
                                  Get.back();
                                },
                                child: Icon(Icons.close,size: 30.w,),
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

                        /// 一周内不显示
                        InkWell(
                          onTap: () {
                            setState(() {
                              isChecked = !isChecked;
                              if (isChecked) {
                                LocalStorage.setString(
                                  AppKeys.noteLastTimeKey,
                                  DateTime.now().millisecondsSinceEpoch,
                                );
                              }
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
                                    onChanged: (bool? value) {},
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
                    // child: Column(
                    //   children: [
                    //     SizedBox(
                    //       width: 80.w,
                    //       child:Column(
                    //         children: [
                    //           Expanded(child:  ListView.builder(
                    //             itemCount: noticeList.length,
                    //             itemBuilder: (BuildContext _, int i) {
                    //               return InkWell(onTap: (){
                    //                 setState(() {
                    //                   index = i;
                    //                 });
                    //               },child: Container(
                    //                 margin: EdgeInsets.symmetric(vertical: 5.h),
                    //                 alignment: Alignment.center,
                    //                 color:Colors.red,
                    //                 // decoration: BoxDecoration(
                    //                 //   image:index==i? DecorationImage(image: CachedNetworkImageProvider(ImageConfig.noticeActive)):null,
                    //                 // ),
                    //                 child: Text(noticeList[i].name),
                    //               ),);
                    //             },
                    //           )),
                    //           /// 一周内不显示
                    //           InkWell(
                    //             onTap: (){
                    //               setState(() {
                    //                 isChecked = !isChecked;
                    //                 if(isChecked){
                    //                   LocalStorage.setString(AppKeys.noteLastTimeKey, DateTime.now().millisecondsSinceEpoch);
                    //                 }
                    //               });
                    //             },
                    //             child: Container(
                    //               constraints: BoxConstraints(maxHeight: 40.h),
                    //               child:Row(
                    //                 children: [
                    //                   SizedBox(height: 25.h,width: 25.w,child: Checkbox(
                    //                     activeColor: TextConfig.primary,
                    //                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    //                     value: isChecked,
                    //                     onChanged: (bool? value) {
                    //
                    //                     },
                    //                   ),),
                    //                   Expanded(child: Text("本周内不显示", overflow: TextOverflow.ellipsis,
                    //                     maxLines: 1,),)
                    //                 ],
                    //               ),
                    //             ),
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //     /// 公告内容
                    //     Expanded(
                    //       child: noticeList.isNotEmpty
                    //           ? SingleChildScrollView(
                    //         child: Html(
                    //           data: md.markdownToHtml(noticeList[index].content),
                    //         ),
                    //       )
                    //           : Container(),
                    //     ),
                    //   ],
                    // ),
                  ),
                ],
              ),
    );
  }
}
