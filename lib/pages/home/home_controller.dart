import 'dart:async';
import 'package:base_object/core/components/Avatar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_controller.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/core/components/dialogs/NoticeDialog.dart';
import 'package:base_object/core/components/dialogs/WeiHuDialog.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/interstitial_tool.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/models/localModels/AdInfo.dart';
import 'package:base_object/models/localModels/ChatMessage.dart';
import 'package:base_object/models/localModels/LocationData.dart';
import 'package:base_object/pages/home/home_group_chat.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/LocationUtil.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_pangrowth/flutter_pangrowth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'home_utils.dart';

class HomeController extends GetxController {
  final ScrollController scrollController = ScrollController();
  // 2. 封装“滚动到最底部”的方法（关键：等列表构建完成后再滚动）
  void scrollToBottom() {
    // 延迟到当前帧构建完成后执行，避免获取不到最新滚动位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 确保控制器已绑定到 ListView，且有可滚动空间
      if (scrollController.hasClients) {
        // 平滑滚动到最底部（也可用 controller.jumpTo 实现瞬时滚动）
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), // 滚动动画时长
          curve: Curves.easeInOut, // 滚动曲线
        );
      }
    });
  }

  // 构建聊天列表（支持滚动）
  Widget buildChatList() {
    Utils.logError("构建聊天列表");
    return Column(
      spacing: 10.h,
      children: [
        Expanded(
          child: Container(
            width: Get.width,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: Store.instance.getAdInfos.length,
              itemBuilder: (context, i) {
                AdInfo currentItem = Store.instance.getAdInfos[i];
                Utils.logError("当前条目${Store.instance.getAdInfos.length}");
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.h,
                    vertical: 5.w,
                  ),
                  margin: EdgeInsets.only(bottom: 10.h),
                  width: 100.w,
                  color: Colors.white70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("广告位id：${currentItem.placementID}"),
                      Text(
                        "预估收益：${currentItem.publisherRevenue}",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: TextConfig.textSize_30,
                        ),
                      ),
                      Text("请求id：${currentItem.reqId}"),
                      Text("广告平台来源id：${currentItem.networkfirmId}"),
                      Text("广告源id：${currentItem.adsourceId}"),
                      Text("生成时间：${currentItem.createdTime}"),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CuButton(
              bgColor: TextConfig.primary,
              text: "清空统计数据",
              width: 150.w,
              height: 40.h,
              onPressed: () {
                Store.instance.setAdInfos([]);
              },
            ),
            CuButton(
              bgColor: TextConfig.primary,
              text: "观看激励视频",
              width: 150.w,
              height: 40.h,
              onPressed: () {
                RewarderTool.to.showRewardedVideoFlutter();
              },
            ),
          ],
        ),
      ],
    );
    // return Center(
    //   child: CuButton(
    //     bgColor: TextConfig.primary,
    //     text: "观看激励视频",
    //     width: 150.w,
    //     height: 40.h,
    //     onPressed: () {
    //       RewarderTool.to.showRewardedVideoFlutter();
    //     },
    //   ),
    // );
    // return Obx(
    //   () => ListView.builder(
    //     controller: scrollController, // 绑定新控制器
    //     padding: EdgeInsets.all(10.sp),
    //     itemCount: HomeGroupChat.to.messages.length,
    //     reverse: false, // 最新消息在底部（需向下滚动查看）
    //     itemBuilder: (context, index) {
    //       final message = HomeGroupChat.to.messages[index];
    //       return _buildMessageItem(message);
    //     },
    //   ),
    // );
  }

  // 构建单条消息项（优先级：广告 > 红包 > 普通消息）
  Widget _buildMessageItem(ChatMessage message) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      margin: EdgeInsets.only(bottom: 8.r), // 消息间距
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 用户头像
          Avatar(
            headImage: message.user.avatarUrl,
            size: 20.h,
            isCircle: false,
          ),
          SizedBox(width: 10.w), // 头像与内容间距
          // 2. 消息内容区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2.1 用户名
                Text(
                  message.user.name,
                  style: TextStyle(
                    fontSize: TextConfig.textSize_14,
                    color: Utils.fromHex("#888888"),
                  ),
                ),
                SizedBox(height: 5.h), // 用户名与内容间距
                message.content,
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  // ------------------- 生命周期 -------------------
  void allInit() async {
    Store.instance.initAdInfos();

    /// 上传地址
    // if (UserInfo.instance.isLoginIn) {
    //   await LocationUtil().getCurrentLocation((Map result) async {
    //     Utils.logError("定位结果：$result");
    //     if (result["errorCode"] != null || result["address"] == null) {
    //       CuToast.error(msg: "定位失败，请打开定位");
    //       await Future.delayed(const Duration(seconds: 2));
    //       SystemNavigator.pop();
    //       return;
    //     }
    //     LocationData locationData = LocationData(
    //       address: result["address"],
    //       latitude: result["latitude"],
    //       longitude: result["longitude"],
    //     );
    //     Store.instance.setLocationData(locationData);
    //   });
    //
    //   await Store.instance.getVer(
    //     type: 3,
    //     msg:
    //         "地理位置${Store.instance.locationData?.address}，经度${Store.instance.locationData?.longitude}，纬度${Store.instance.locationData?.latitude}",
    //   );
    // }

    /// 获取风控配置
    // await Store.instance.getFkConfigFn();

    /// 获取今日领取了多少个红包
    // await Store.instance.initCurrentCount();
    // await getAppUpdata();
    // 初始化用户信息
    // UserInfo.instance.initialize();
    RewarderTool.to.loadRewardedVideoFlutter(
      userID: "${UserInfo.instance.userModel.id}",
      extra: "userid_${UserInfo.instance.userModel.id}_type_1_amount_0_time_0",
    );
    RewarderTool.to.rewardedAdListen();

    /// 是否显示新人邀请
    // isShowNewUser();

    /// 是否显示公告框
    // isShow();

    /// 检查低保任务
    // await Store.instance.postMinAdPrizeList();

    /// 如果任务状态是接取的，那么就跳转到任务大厅
    // if (Store.instance.isTaskStatus == 1) {
    //   CuNavBarController.to.onTabChange(1);
    // }
    // 初始化app升级信息
  }

  @override
  void onInit() {
    Utils.logError("首页页面onInit");

    // 开启广告监听器
    // InterstitialTool.to.interstitialListen();
    // NativeTool.to.nativeLisListen();

    // InterstitialTool.to.loadInterstitialAd();

    // NativeTool.to.loadNativeWith();
    // HomeGroupChat.to.homeGroupChatInit();
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
    // 打开维护弹窗
    // Get.dialog(barrierDismissible: false, WeiHuDialog());
    super.onReady();
  }

  // ------------------- 响应式状态 -------------------
  final RxString appbarTitle = "首页".obs; // 导航栏标题
}
