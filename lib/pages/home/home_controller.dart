import 'dart:async';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/core/components/dialogs/NoticeDialog.dart';
import 'package:base_object/core/components/dialogs/interAdDialog/interAdDialog.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/localModels/ChatMessage.dart';
import 'package:base_object/pages/home/home_group_chat.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pangrowth/flutter_pangrowth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'home_utils.dart';

class HomeController extends GetxController {
  // 获取App升级信息
  Future<void> getAppUpdata({bool isReturn = false}) async {
    await HomeUtils.getAppUpdata(isReturn: isReturn);
  }

  RxBool isShowNew = false.obs;

  /// 是否显示新人奖励
  isShowNewUser() async {
    Utils.logError("登录？？${UserInfo.instance.isLoginIn}");
    if (!UserInfo.instance.isLoginIn) return false;
    isShowNew.value = await UserInfo.instance.isNewUser();
  }

  /// 显示公告框
  isShow() async {
    if (await NoticeDialog.shouldShow()) {
      Dialogs.noticeDialog();
    }
  }

  Future _pangrowthInit() async {
    // 这里的appid  和logappid 填写穿山甲的sdkjson文件李的值
    await PangrowthVideo.registerVideo(
      appName: "",
      andoridAppId: "5670418",
      appLogAppId: "751081",
      iosAppId: "",
      debug: true,
    );
  }

  // ------------------- 生命周期 -------------------
  void allInit() async {
    await getAppUpdata();
    // 初始化用户信息
    UserInfo.instance.initialize();
    RewarderTool.to.loadRewardedVideo(
      userID: "${UserInfo.instance.userModel.id}",
      extra: "userid_${UserInfo.instance.userModel.id}_type_1_amount_0_time_0",
    );

    /// 是否显示新人邀请
    isShowNewUser();

    /// 是否显示公告框
    isShow();
    // 初始化app升级信息
    await getAppUpdata(isReturn: true);

    ///同意隐私政策之后调用
    await _pangrowthInit();
  }

  @override
  void onInit() {
    Utils.logError("首页页面onInit");
    InterAdDialog.to.restartTimer();
    NativeTool.to.nativeLisListen();
    NativeTool.to.loadNativeWith();
    HomeGroupChat.to.homeGroupChatInit();
    allInit();
    super.onInit();
  }

  @override
  void onClose() {
    Utils.logError("首页页面关闭");
    super.onClose();
  }

  @override
  void onReady() {
    Utils.logError("首页页面onReady");
    // TODO: implement onReady
    super.onReady();
  }

  // ------------------- 响应式状态 -------------------
  final RxString appbarTitle = "红包群".obs; // 导航栏标题
}
