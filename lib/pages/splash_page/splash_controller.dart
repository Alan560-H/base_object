import 'dart:developer';

import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/manager/Init_tool.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/manager/interstitial_tool.dart';
import 'package:base_object/manager/listener_tool.dart'; // 导入 ListenerTool
import 'package:base_object/manager/native_tool.dart';
import 'package:base_object/manager/rewarder_tool.dart';
import 'package:base_object/manager/splash_tool.dart';
import 'package:base_object/models/FormModel/checkDeviceForm/CheckDeviceForm.dart';
import 'package:base_object/models/backModel/BackModel.dart';
import 'package:base_object/models/backModel/fKModelConfig/FKConfigVo.dart';
import 'package:base_object/store/di.dart';
import 'package:base_object/store/store.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  /// 初始化广告
  Future<void> initAd() async {
    InitTool.to.setCustomDataDic({
      "user_id": 0,
      "extra": "userid_0_type_1_amount_0_time_0",
    });
    // 初始化广告
    bool isInitAd = await InitTool.to.initTopon();
    Utils.logError("广告初始化完成 $isInitAd ");
  }

  @override
  void onInit() {
    Store.instance.getVer().then((value) async {
      Utils.logError("返回的数值：$value");
      // 如果被封了，就去错误页面
      if (value) {
        Get.offAllNamed(AppRoutes.userError);
      } else {
        /// 获取风控配置
        Store.instance.getFkConfigFn();

        /// 获取今日领取了多少个红包
        Store.instance.initCurrentCount();

        /// 初始化广告
        await initAd();
      }
    });
    super.onInit();
  }
}
