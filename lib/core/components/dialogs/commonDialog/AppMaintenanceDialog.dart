import 'package:base_object/core/config/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class AppMaintenanceDialog extends StatelessWidget {
  /// 维护中弹窗
   AppMaintenanceDialog({super.key});
  final List<String> helpTexts = [
    "服务器优化升级中，预计12小时内完成，给您造成的不便，万分歉意。",
  ];
   @override
   Widget build(BuildContext context) {
     return Container(
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
     );
   }
}

