import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/models/FormModel/checkDeviceForm/CheckDeviceForm.dart';
import 'package:base_object/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/models/localModels/MenuModel.dart';
import 'package:base_object/models/localModels/UpADModel.dart';
import 'package:base_object/pages/login/login_controller.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_android_oaid_plugin/flutter_android_oaid_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

class CuNavBarController extends GetxService {
  // GetX单例获取方式
  static CuNavBarController get to =>
      Get.isRegistered<CuNavBarController>()
          ? Get.find<CuNavBarController>()
          : Get.put(CuNavBarController());

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
  RxDouble height = 110.h.obs;

  /// 设置高度
  void setHeight(double h) {
    height.value = h;
  }

  void onTabChange(int index) async {
    try {
      currentPageIndex.value = index;
      NativeTool.to.removeNativeAd();
      bool isHasAdStr = await NativeTool.to.getNativeValidAds();
      Utils.logError("底部导航判断$isHasAdStr");
      switch (index) {
        case 0:
          Get.offAllNamed(AppRoutes.home);
          break;
        // case 1:
        //   Get.toNamed(AppRoutes.shortVideo);
        //   break;
        // case 2:
        //   Get.offAllNamed(AppRoutes.djVideo);
        //   break;
        case 1:
          Get.offAllNamed(AppRoutes.invite);
          break;
        case 2:
          Get.offAllNamed(AppRoutes.user);
          break;
      }
    } catch (e) {
      Utils.logError("切换一级页面失败：$e");
      Get.offAllNamed(AppRoutes.home);
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
      // _createMenuModel(
      //   1,
      //   "短视频",
      //   true,
      //   ImageConfig.videoDefault,
      //   ImageConfig.videoActive,
      // ),
      // _createMenuModel(
      //   2,
      //   "短剧",
      //   true,
      //   ImageConfig.shortVideoDefault,
      //
      //   ImageConfig.shortVideoActive,
      // ),
      _createMenuModel(
        1,
        "邀请",
        false,
        ImageConfig.inviteDefault,
        ImageConfig.inviteActive,
      ),
      _createMenuModel(
        2,
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

  upDataADFn(dynamic event) async {
    try {
      Utils.logError(
        "${Jiffy.now().format(pattern: "yyyy-MM-dd HH:mm:ss")}横幅广告upDataADFn${event.extraMap}",
      );
      UpDataADForm upDataADForm = UpDataADForm();

      // 1. 安全获取 publisher_revenue_cny + 处理类型转换（核心改这里）
      // 逐层判空+类型兼容，最终转成 double? 赋值给 amount
      dynamic publisherRevenueCny = event.extraMap?['publisher_revenue_cny'];
      // 先转成 String 再解析 double（兼容 int/String 类型，避免直接赋值类型冲突）
      double? amount = double.tryParse(publisherRevenueCny?.toString() ?? "0");
      String reqId = event.extraMap?['req_id'];
      String adsourceId = event.extraMap?['adsource_id'];
      // 2. 拼接 extra 字符串（用原始值的字符串形式，避免类型问题）
      String userId = UserInfo.instance.userModel.id.toString();
      upDataADForm.extra =
          "userid_${userId}_type_2_amount_${publisherRevenueCny ?? 0}_time_0";
      upDataADForm.transId = event.extraMap?['id'];
      upDataADForm.amount = amount;
      upDataADForm.adsourceId = adsourceId;
      upDataADForm.reqId = reqId;

      upDataADForm.sign = Utils.generateEncryptedString(
        userId: userId,
        reqId: reqId,
        adsourceId: adsourceId,
      );
      Utils.logError("横幅广告凑成的字符串${upDataADForm.toJson()}");
      // 4. 原有进度逻辑不变（保留你的业务逻辑）
      Utils.logError(
        "横幅广告金额$amount，限制金额${Store.instance.getFkConfig.wactchMaxAmountV1}",
      );
      if (!UserInfo.instance.isLoginIn) return;
      if (amount == null) return;
      double amount1 = amount * 10000;
      UpADModel upADModel = UpADModel(
        adsourceId: adsourceId,
        reqId: reqId,
        adType: "横幅广告",
        adAmount: amount1,
      );

      /// 如果广告金额大于风控设置的最高金额
      if (amount1 > Store.instance.getFkConfig.wactchMaxAmountV1) {
        Store.instance.addWactchMaxADList(upADModel);
      }

      /// 如果广告金额小于风控设置得最低金额
      if (amount1 < Store.instance.getFkConfig.wactchMinAmountV1) {
        Store.instance.addWactchMinADList(upADModel);
      }
    } catch (e) {
      Utils.logError("上报副广失败：$e");
    }
  }

  @override
  void onInit() async {
    // TODO: implement onReady
    super.onInit();
    // 启动banner监听
    BannerTool.to.bannerListen();

    DateTime now = DateTime.now();
    int timestampMs = now.millisecondsSinceEpoch;
    await BannerTool.to.loadBannerWith({
      Common.getUserIdKey(): UserInfo.instance.userModel.id,
      Common.getExtraKey():
          "userid_${UserInfo.instance.userModel.id}_type_2_amount_0_time_$timestampMs",
      ATCommon.isNativeShow(): true,
      ATCommon.getAdSizeKey(): ATBannerManager.createLoadBannerAdSize(
        Get.width,
        Get.width * (50 / 320),
      ),
      ATBannerManager.getAdaptiveWidthKey(): Get.width,
      ATBannerManager.getAdaptiveOrientationKey():
          ATBannerManager.adaptiveOrientationCurrent(),
    });
  }
}
