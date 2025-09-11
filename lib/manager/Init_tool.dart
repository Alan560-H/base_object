import 'package:anythink_sdk/at_index.dart';
import 'package:base_object/core/config/app_ad_config.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class InitTool extends GetxController {
  // GetX单例获取方式
  static InitTool get to =>
      Get.isRegistered<InitTool>() ? Get.find<InitTool>() : Get.put(InitTool());

  Future<bool> setLogEnabled() async {
    return await ATInitManger.setLogEnabled(logEnabled: true);
  }

  setChannelStr() async {
    await ATInitManger.setChannelStr(channelStr: "test_setChannel").then((
      value,
    ) {
      Utils.logError('渠道设置结果：$value'); // 原"Set up channels"→"渠道设置结果"
    });
  }

  setSubchannelStr() async {
    await ATInitManger.setSubChannelStr(
      subchannelStr: "test_setSubchannelStr",
    ).then((value) {
      Utils.logError('子渠道设置完成'); // 原"Set up sub-channels"→"子渠道设置完成"
    });
  }

  setCustomDataDic(Map<String, Object> customDataMap) async {
    Utils.logError("整个收到的map$customDataMap");
    await ATInitManger.setCustomDataMap(customDataMap: customDataMap).then((
      value,
    ) {
      Utils.logError(
        '自定义数据设置完成',
      ); // 原"Set up custom rules"→"自定义数据设置完成"（结合方法功能修正，原"rules"表述不准确）
    });
  }

  setExludeBundleIDArray() async {
    await ATInitManger.setExludeBundleIDArray(
      exludeBundleIDList: ['test_setExludeBundleIDArray'],
    ).then((value) {
      Utils.logError(
        '跨推广排除列表设置完成',
      ); // 原"Set up exclusion of cross-promotion"→"跨推广排除列表设置完成"
    });
  }

  setPlacementCustomData() async {
    await ATInitManger.setPlacementCustomData(
      placementIDStr: 'b5b72b21184aa8',
      placementCustomDataMap: {
        'setPlacementCustomData': 'test_setPlacementCustomData',
      },
    ).then((value) {
      Utils.logError(
        '广告位自定义规则设置完成',
      ); // 原"Set pl rules"→"广告位自定义规则设置完成"（"pl"补充为"广告位"）
    });
  }

  getUserLocation() async {
    await ATInitManger.getUserLocation().then((value) {
      Utils.logError(
        'flutter：获取用户位置信息 -- ${value.toString()}',
      ); // 原"Get user location"→"获取用户位置信息"
    });
  }

  getGDPRLevel() async {
    await ATInitManger.getGDPRLevel().then((value) {
      Utils.logError(
        'flutter：获取GDPR授权级别 --${value.toString()}',
      ); // 原"Get GDPR"→"获取GDPR授权级别"（补充"授权级别"使含义更明确）
    });
  }

  setDataConsentSet() async {
    await ATInitManger.setDataConsentSet(
      gdprLevel: ATInitManger.dataConsentSetPersonalized(),
    ).then((value) {
      Utils.logError(
        'flutter：GDPR授权级别设置完成 ${value.toString()}',
      ); // 原"Set up GDPR"→"GDPR授权级别设置完成"
    });
  }

  deniedUploadDeviceInfo() async {
    await ATInitManger.deniedUploadDeviceInfo(
      deniedUploadDeviceInfoList: [ATInitManger.aOAID()],
    ).then((value) {
      Utils.logError('flutter：初始化流程结束'); // 原"End of initialization"→"初始化流程结束"
    });
  }

  Future<bool> initTopon() async {
    // await setLogEnabled();
    try {
      await ATInitManger.initAnyThinkSDK(
        appidStr: AppAdConfig.appidStr,
        appidkeyStr: AppAdConfig.appidkeyStr,
      );
      return true;
    } catch (e) {
      Utils.logError(
        'flutter：初始化Topon失败 $e',
      ); // 原"End of initialization"→"初始化Topon失败"
      return false;
    }
  }

  showGDPRAuth() async {
    await ATInitManger.showGDPRAuth();
  }

  initListen() {
    ATListenerManager.initEventHandler.listen((value) {
      if (value.userLocation != null) {
        switch (value.userLocation) {
          case InitUserLocation.initUserLocationInEU:
            Utils.logError(
              "flutter：监听初始用户位置 - 位于欧盟地区",
            ); // 原"Monitor initial user location in the EU"→"监听初始用户位置 - 位于欧盟地区"
            ATInitManger.getGDPRLevel().then((value) {
              if (value == ATInitManger.dataConsentSetUnknown()) {
                showGDPRAuth();
              }
            });
            break;
          case InitUserLocation.initUserLocationOutOfEU:
            Utils.logError(
              "flutter：监听初始用户位置 - 不在欧盟地区",
            ); // 原"The location of the listening initial user is not in the EU"→"监听初始用户位置 - 不在欧盟地区"
            break;
          case InitUserLocation.initUserLocationUnknown:
            Utils.logError(
              "flutter：监听初始用户位置 - 位置未知",
            ); // 原"The location of the initial listening user is unknown"→"监听初始用户位置 - 位置未知"
            break;
        }
      }

      if (value.consentSet != null) {
        switch (value.consentSet) {
          case InitConsentSet.initConsentSetPersonalized:
            Utils.logError(
              "flutter：GDPR授权状态 - 个性化授权",
            ); // 原"initConsentSetPersonalized"→"GDPR授权状态 - 个性化授权"
            break;
          case InitConsentSet.initConsentSetNonpersonalized:
            Utils.logError(
              "flutter：GDPR授权状态 - 非个性化授权",
            ); // 原"initConsentSetNonpersonalized"→"GDPR授权状态 - 非个性化授权"
            break;
          case InitConsentSet.initConsentSetUnknown:
            Utils.logError(
              "flutter：GDPR授权状态 - 授权状态未知",
            ); // 原"initConsentSetUnknown"→"GDPR授权状态 - 授权状态未知"
            break;
        }
      }
    });
  }
}
