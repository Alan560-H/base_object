
import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/components/cu_circular_progress/cu_circular_progress_controller.dart';
import 'package:base_object/core/components/cu_toast.dart';
import 'package:base_object/core/config/cu_error_config.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/manager/listener_tool.dart';
import 'package:base_object/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/localModels/MenuModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CuNavBarController extends GetxController {
  var selectedIndex = 0.obs;
  // 创建一个菜单对象
  MenuModel _createMenuModel(
      int id,
      String menuName,
      bool isMock,
      String defaultIcon,
      String activeIcon,
      ) {
    return MenuModel(
      id: id,
      menuName: menuName,
      isMock: isMock,
      defaultIcon: defaultIcon,
      activeIcon: activeIcon,
    );
  }
  /// 一级页面索引
  RxInt currentPageIndex = 0.obs;
  RxDouble height = 60.h.obs;
  void onTabChange(int index) {
    try{
      currentPageIndex.value = index;
      switch(index){
        case 0:
          Get.toNamed(AppRoutes.home);
          break;
        case 1:
          Get.toNamed(AppRoutes.shortVideo);
          break;
        case 2:
          Get.toNamed(AppRoutes.djVideo);
          break;
        case 3:
          Get.toNamed(AppRoutes.invite);
          break;
        case 4:
          Get.toNamed(AppRoutes.user);
          break;
      }
    }catch(e){
      Utils.logError("切换一级页面失败：$e");
      Get.toNamed(AppRoutes.home);
      currentPageIndex.value = 0;
    }
  }
  List<MenuModel> menuModels = [];
  // 定义一个方法来生成 BottomNavigationBarItem 列表
  List<BottomNavigationBarItem> getNavigationItems() {
    menuModels = [
      _createMenuModel(
        0,
        "红包群",
        false,
        ImageConfig.redBagDefatult,
        ImageConfig.redBagActive,

      ),
      _createMenuModel(
        1,
        "短视频",
        true,
        ImageConfig.videoDefault,
        ImageConfig.videoActive,

      ),
      _createMenuModel(
        2,
        "短剧",
        true,
        ImageConfig.shortVideoDefault,
        ImageConfig.shortVideoActive,

      ),
      _createMenuModel(
        3,
        "邀请",
        false,
        ImageConfig.inviteDefault,
        ImageConfig.inviteActive,

      ),
      _createMenuModel(
        4,
        "我的",
        false,
        ImageConfig.myDefatult,
        ImageConfig.myActive,
      ),
    ];
    return menuModels.map((menu) {
      return BottomNavigationBarItem(
        backgroundColor: Colors.transparent,
        icon: CachedNetworkImage(
          width: 24.w,
          imageUrl: menu.defaultIcon!,
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        activeIcon: CachedNetworkImage(
          width: 24.w,
          imageUrl: menu.activeIcon!,
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        label: menu.menuName,
      );
    }).toList();
  }
  upDataADFn(dynamic event)async{
   try{
     UpDataADForm upDataADForm = UpDataADForm();
     DateTime now = DateTime.now();
     int timestampMs  = now.millisecondsSinceEpoch;
     upDataADForm.extra = "userid_${UserInfo.instance.userModel.id}_type_2_amount_${event['extraMap']['adsource_price']}_time_$timestampMs";
     upDataADForm.amount = event['extraMap']['adsource_price'];
     if(upDataADForm.amount!=null){
       double pross = upDataADForm.amount!*100;
       Utils.logError("横幅广告增加进度${pross}");

       CuCircularProgressController.to.incrementProgress(pross);
     }
     Utils.logError("凑成的字符串${ upDataADForm.extra }");
     BackModel backModel = await Api.to.getSelectAdV2(upDataADForm);
     if(backModel.code == CuErrorConfig.success){
       CuToast.success(msg: "上报副广成功");
     }
    }catch(e){
      Utils.logError("上报副广失败：$e");
    }
  }
  // 用于标记是否已处理跳转（避免重复跳转）
  bool _hasShow = false;
  /// 订阅 ListenerTool 的开屏广告事件
  void _bannerEvent() async {
    // ever：持续监听 splashEvent 的变化（广告状态更新时触发）
    ever(ListenerTool.to.bannerEvent, (event) {
      if (event == null || _hasShow) return; // 过滤空事件或重复跳转

      // 获取事件类型（从 event 中解析，与 ListenerTool 中转发的格式对应）
      String eventType = event["eventType"] ?? "";
      String placementID = event["placementID"] ?? "";

      Utils.logError("收到banner广告事件：$eventType，广告位ID：$placementID，事件参数：$event");
      // 根据事件类型执行业务逻辑
      switch (eventType) {
      // banner广告加载失败
        case "BannerStatus.bannerAdFailToLoadAD":
          Utils.logError("banner广告加载失败");
          height.value = 60.h;
          break;
      // banner广告加载完成
        case "BannerStatus.bannerAdDidFinishLoading":
          Utils.logError("banner广告加载完成");
          height.value=110.h;
          BannerTool.to.showAdInPosition();
          break;

      /// 横幅广告自动刷新成功
        case "BannerStatus.bannerAdAutoRefreshSucceed":
          height.value = 110.h;
          Utils.logError("好招术${event['extraMap']}");
          if(Get.isRegistered<UserInfo>()){
            if(UserInfo.instance.isLoginIn){
              upDataADFn(event);

            }
          }

          break;
      /// 横幅广告被点击
        case "BannerStatus.bannerAdDidClick":
          Utils.logError("横幅广告被点击");
          break;
      /// 横幅广告触发深度链接（跳转至指定页面/内容）
        case "BannerStatus.bannerAdDidDeepLink":
          Utils.logError("横幅广告触发深度链接（跳转至指定页面/内容）");
          break;
      /// 点击
        case "BannerStatus.splashDidClick":
          Utils.logError("横幅广告点击");
          break;
      /// 横幅广告展示成功
        case "BannerStatus.bannerAdDidShowSucceed":
          Utils.logError("横幅广告展示成功$event，增加进度");
          break;
      /// 横幅广告点击关闭按钮
        case "BannerStatus.bannerAdTapCloseButton":
          Utils.logError("横幅广告点击关闭按钮");
          height.value = 60.h;
          break;
      /// 横幅广告自动刷新失败
        case "BannerStatus.bannerAdAutoRefreshFail":
          Utils.logError("横幅广告自动刷新失败");
          break;
      /// 横幅广告未知状态
        case "BannerStatus.bannerAdUnknown":
          Utils.logError("横幅广告未知状态");
          break;
      }
    });
  }
  @override
  void onInit() async {
    Utils.logError("onInit");
    // TODO: implement onReady
    super.onInit();
    // 1. 先订阅开屏广告事件（关键：确保事件监听在广告展示前生效）
    _bannerEvent();
    await BannerTool.to.loadBannerWith();
  }
}
