import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
class DeregisterDialog extends StatelessWidget {
  /// 注销帮助说明
   DeregisterDialog({super.key});
  final List<String> helpTexts = [
    "尊敬的用户，若您提交账户注销申请，我们将在 15 个自然日内，依照严格流程，自动且彻底地清除您的账户相关全部信息。此过程不可逆，请您谨慎操作。期间，若有任何疑问，可随时联系我们的客服团队。感谢您一直以来的支持与理解。",
   
  ];
   @override
   Widget build(BuildContext context) {
     return Column(
       spacing: 10.w,
       mainAxisAlignment: MainAxisAlignment.start,
       crossAxisAlignment: CrossAxisAlignment.start,
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
               width: 120.w,
               height:30.h,
               textColor: Colors.white,
               text: "取消",
               onPressed: () => Get.back(),
               bgImage: ImageConfig.currentAmount,
             ),CuButton(
               width: 120.w,
               height:30.h,
               textColor: Colors.white,
               text: "确定",
               onPressed: ()async => await UserInfo.instance.loginOut(),
               bgImage: ImageConfig.currentAmount,
             )
           ],
         ),
       ],
     );
   }
}

