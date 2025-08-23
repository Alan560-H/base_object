
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
class ConfirmDialog extends StatelessWidget {
  final List<String> data;
  /// 回调
  final void Function(dynamic callBackData)? onClick;
  /// 通用确认框
  const ConfirmDialog({super.key, required this.onClick,required this.data});
  // 修改为 getter 方法
  List<String> get helpTexts => data;

   @override
   Widget build(BuildContext context) {
     return Container(
       constraints: BoxConstraints(minHeight: 130.h),
       child: Column(

         spacing: 10.w,
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         crossAxisAlignment: CrossAxisAlignment.center,
         mainAxisSize: MainAxisSize.min,
         children: [
           Container(
               constraints: BoxConstraints(
                   minHeight: 150.h,
                   maxHeight: 300.h
               ),
               child: SingleChildScrollView(
                 child: Column(
                   spacing: 3.h,
                   children: [
                     ...helpTexts.map(
                           (e) => Text(e, style: TextStyle(fontSize: TextConfig.textSize_16)),
                     ),
                   ],
                 ),
               )
           ),
           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             spacing: 10.w,
             children: [

               CuButton(
                 height: 40.h,
                 width: 130.w,
                 text: "取消",
                 onPressed:()async{
                   Get.back();
                 },
                 bgImage: ImageConfig.inviteDefault,
               ),
               CuButton(
                 height: 40.h,
                 width: 130.w,
                 text: "确定",
                 onPressed:()async{
                   onClick?.call(null);
                 },
                 bgImage: ImageConfig.inviteDefault,
               ),
             ],
           )
         ],
       ),
     );
   }
}

