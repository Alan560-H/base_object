import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ClaimAdDialog extends StatelessWidget {
  final RxInt data;

  /// 回调
  final void Function(dynamic callBackData)? onClick;

  /// 领取存钱罐
  const ClaimAdDialog({super.key, required this.onClick, required this.data});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        // 设置圆角半径
        borderRadius: BorderRadius.circular(5.sp),
      ),
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              decoration: BoxDecoration(
                  image: DecorationImage(image: CachedNetworkImageProvider(ImageConfig.redBagBg))
              ),
            height: 350.h,
            width:300.w,
            child: Stack(
              children: [
                Container(
                  width: Get.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 100.h,),
                      Obx(()=>Text(data.value.toString(),style: TextStyle(fontSize: TextConfig.textSize_36,color: Colors.white),)),
                      SizedBox(height: 30.h,),
                      CuButton(text: "立即领取",width: 120.w,height: 40.h,radius: 10.r,bgColor: TextConfig.primary, onPressed: ()async{
                        if(Get.isRegistered<Api>()){
                          BackModel backModel = await Api.to.getAdAmount();
                          if(backModel.code == CuErrorConfig.success){
                            CuToast.success(msg: "领取成功");
                            if(Get.isRegistered<CuCircularProgressController>()){
                              CuCircularProgressController.to.setProgress(0);
                              Get.back();
                            }
                          }
                        }


                      })
                    ],
                  ),
                ),
                Positioned(
                    top: 0.h,
                    right: 0.w,
                  child: CuButton(text: "",icons: Icons.close,fontSize: TextConfig.textSize_24, onPressed: ()=>Get.back()),
                    )
              ],
            ),
          )
        ],
      ),
    );
  }
}
