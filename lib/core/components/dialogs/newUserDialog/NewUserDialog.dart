import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/pages/home/home_controller.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NewUserDialog extends StatefulWidget {
  /// 新人红包领取
  const NewUserDialog({super.key});
  @override
  State<NewUserDialog> createState() => _NewUserDialogState();
}

class _NewUserDialogState extends State<NewUserDialog> {
  @override
  void initState() {
    if (!Get.isRegistered<Api>()) {
      Get.put(Api());
    }
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
      child: Stack(
        children: [
          Container(
            width: 300.w,
            height: Get.height * 0.5,
            padding: EdgeInsets.symmetric(vertical: 30.h),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(ImageConfig.hongbaoCover),
              ),
            ),
            child: Column(
              children: [
                Text(
                  UserInfo.instance.newUserModel.value.name,
                  style: TextStyle(
                    fontSize: TextConfig.textSize_30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 50.h),
                Text(
                  UserInfo.instance.newUserModel.value.remark,
                  style: TextStyle(
                    fontSize: TextConfig.textSize_24,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Utils.debounce(() async {
                        try {
                          EasyLoading.show(status: "正在领取中......");
                          if (Get.isRegistered<Api>()) {
                            BackModel backModel = await Api.to.getNewcomer();
                            if (backModel.code == CuErrorConfig.success) {
                              HomeController homeController =
                                  Get.find<HomeController>();
                              await homeController.isShowNewUser();
                              await UserInfo.instance.getUserInfoFn();
                              CuToast.success(msg: backModel.data);
                              Get.back();
                            }
                          }
                        } catch (e) {
                          Utils.logError("领取新人福利失败：$e");
                        } finally {
                          EasyLoading.dismiss();
                        }
                      });
                    },
                    child: Container(),
                  ),
                ),
                Text(
                  "仅限新用户领取一次",
                  style: TextStyle(
                    fontSize: TextConfig.textSize_24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20.h,
            right: 15.h,
            child: InkWell(
              onTap: closeDialog, // 使用统一的关闭方法
              child: Icon(Icons.close, size: 30.w, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
