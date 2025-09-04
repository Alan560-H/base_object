import 'dart:developer';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/manager/listener_tool.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/rewarderModel/RewarderModel.dart';
import 'package:base_object/pages/home/home_controller.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ClaimAdDialog extends StatelessWidget {
  final RxDouble data;

  /// 回调
  final void Function(dynamic callBackData)? onClick;

  /// 领取存钱罐
  const ClaimAdDialog({super.key, required this.onClick, required this.data});

  // 显示激励广告
  showRewarder() async {
    if (await Store.instance.canLookReward()) {
      await RewarderTool.to.showRewardedVideo();
    } else {
      checkClaim();
    }
  }
  static checkClaim()async{
    if(Get.isRegistered<Api>()){
      BackModel backModel = await Api.to.getAdAmount();
      Utils.logError("领取存钱罐奖励返回数据：${backModel.toJson()}");
      if(backModel.code == CuErrorConfig.success){
        CuToast.success(msg: "存钱罐领取成功");
        UserInfo.instance.getUserInfoFn();
       Store.instance.setIsOpenClaim(false);

        Utils.logError("是否有进度条${Get.isRegistered<CuCircularProgressController>()}");
        if(Get.isRegistered<CuCircularProgressController>()){
          CuCircularProgressController.to.setProgress(0);
          CuCircularProgressController.to.resetProgressTimer();
          NativeTool.to.removeNativeAd();
          NativeTool.to.loadNativeWith();
          Get.back();
        }
      }
    }
  }
  // 激励广告奖励提交方法
  upDataADFn(dynamic event) async {
    debugger();
    try {
      checkClaim();
     if(Get.isRegistered<HomeController>()){
       HomeController().upDataADFn(event);
     }

    } catch (e) {
      Utils.logError("领取激励视频奖励失败：$e");
    }finally{
      checkClaim();
    }
  }

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
          SizedBox(
            height:260.h,
          ),
          Container(
              decoration: BoxDecoration(
                  image: DecorationImage(image: CachedNetworkImageProvider(ImageConfig.redBagBg))
              ),
            height: 350.h,
            width:300.w,
            child: Stack(
              children: [
                SizedBox(
                  width: Get.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 100.h,),
                      Obx(()=>Text(data.value.toString(),style: TextStyle(fontSize: TextConfig.textSize_36,color: Colors.white),)),
                      SizedBox(height: 30.h,),
                      Text("温馨提示：建议累计到2000以上再领取哦",style: TextStyle(fontSize: TextConfig.textSize_12,color: Colors.white),),
                      SizedBox(height: 10.h,),
                      CuButton(text: "立即领取",width: 120.w,height: 40.h,radius: 10.r,bgColor: TextConfig.primary, onPressed: ()async{
                        showRewarder();
                      })
                    ],
                  ),
                ),
                Positioned(
                    top: 0.h,
                    right: 0.w,
                  child: CuButton(text: "",icons: Icons.close,fontSize: TextConfig.textSize_24, onPressed: (){
                    NativeTool.to.removeNativeAd();
                    NativeTool.to.loadNativeWith();
                    Get.back();

                  }),
                    )
              ],
            ),
          )
        ],
      ),
    );
  }
}
