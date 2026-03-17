import 'package:base_object/core/components/Avatar.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_controller.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/app_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/pages/user/user_controller.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class UserView extends GetView<UserController> {
  const UserView({super.key});

  /// 组件
  Widget getCom({String value = "", String title = ""}) {
    return Column(
      spacing: 10.h,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: TextConfig.textSize_20,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: TextConfig.textSize_14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.userInfo.getUserInfoFn();
    });
    return Scaffold(
      body: Obx(
        () => Container(
          padding: EdgeInsets.only(
            left: 10.w,
            right: 10.w,
            top: Get.mediaQuery.padding.top + 10.h,
          ),
          color: TextConfig.commonYellowPageColor,
          child: Column(
            spacing: 10.h,
            children: [
              // 头像，以及会员id以及邀请码
              Row(
                spacing: 20.w,
                children: [
                  Avatar(
                    headImage: controller.userInfo.userModel.headImage,
                    size: 30.r,
                  ),
                  Column(
                    spacing: 10.h,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 10.w,
                        children: [
                          Text(
                            controller.userInfo.userModel.id > 0
                                ? controller.userInfo.userModel.username
                                : "游客",
                            style: TextStyle(
                              fontSize: TextConfig.textSize_20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                // 亮黄→橙红→红金：活泼又有层次感
                                colors: [
                                  Color(0xFFFF6600), // 鲜艳橙红（增加活力感）
                                  Color(0xFFFFC107), // 明亮浅黄（更活泼）
                                  // Color(0xFF993300), // 深红木金（对比强烈）
                                ],
                                stops: [0.0, 1], // 让橙红的过渡更靠前，更醒目
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              UserInfo.instance.getUserLevel,
                              style: TextStyle(
                                fontSize: TextConfig.textSize_14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        controller.userInfo.userModel.id > 0
                            ? "会员ID:${controller.userInfo.userModel.id}"
                            : "游客",
                        style: TextStyle(
                          fontSize: TextConfig.textSize_14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              /// 本地统计展示（无后端提现）
              Container(
                width: Get.width,
                constraints: BoxConstraints(minHeight: 100.h, maxHeight: 130.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    alignment: Alignment.center,
                    fit: BoxFit.fill,
                    image: CachedNetworkImageProvider(
                      ImageConfig.userMenoyCardBg,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: getCom(
                        value: "广告数：${Store.instance.getAdInfos.length}",
                        title: "累计观看",
                      ),
                    ),
                    Expanded(
                      child: getCom(
                        value: Store.instance.getAdInfosTotal.toString(),
                        title: "总收益(展示)",
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: controller.menuList.length,
                  itemBuilder: (context, i) {
                    final menu = controller.menuList[i];
                    return Container(
                      key: menu.menuKey ?? GlobalKey(),
                      margin: EdgeInsets.only(top: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(10), // 设置圆角半径
                      ),
                      child: ListTile(
                        dense: true,
                        // visualDensity: VisualDensity.compact,
                        minVerticalPadding: 0,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 10.w,
                        ),
                        leading: Icon(menu.icon, color: TextConfig.black333),
                        title: Text(
                          menu.menuName,
                          style: TextStyle(
                            color: TextConfig.black333,
                            fontSize: TextConfig.textSize_16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        trailing: Icon(
                          color: TextConfig.black333,
                          Icons.arrow_forward_ios,
                          size: TextConfig.textSize_14,
                        ),
                        onTap: () async {
                          // 如果跳转二级页面，则优先跳转二级页面
                          if (menu.path != null) {
                            Get.toNamed(menu.path!);
                          } else {
                            if (menu.id == 4) {
                              Utils.openUrl(AppConfig.instance.protocolUri);
                            }
                            if (menu.id == 5) {
                              Utils.openUrl(AppConfig.instance.policyUri);
                            }
                            if (menu.id == 7) {
                              EasyLoading.show(status: "正在努力清除中...");
                              await Future.delayed(const Duration(seconds: 3));
                              CuToast.success(msg: "清除成功");
                              EasyLoading.dismiss();
                              CuNavBarController.to.onTabChange(0);
                              return;
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CuNavBarView(),
    );
  }
}
