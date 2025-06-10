import 'package:get/get.dart';
import 'package:gtads/gtads.dart';
import 'package:gtads_csj/gtads_csj.dart';

class AppAdConfig extends GetxController{
  static AppAdConfig get instance => Get.find();
  static String cSJ = "csj";
  // 广告注入
  static List<GTAdsProvider> providers = [
    GTAdsCsjProvider(
      cSJ,
      '5710771',
      '',
      appName: "疯狂小广告",
      useMediation: true,
      androidPrivacy: AndroidPrivacy(),
    ),
    // GTAdsYlhProvider(yLH, "1210679133", ""),
    // GTAdsKSProvider(kS, '2476700002', ''),
  ];
  //开屏广告位
  static List<GTAdsCode> splashCodes = [
    GTAdsCode(alias: cSJ, probability: 1, androidId: "103518438", iosId: ""),
    GTAdsCode(alias: cSJ, probability: 1, androidId: "891767960", iosId: ""),
    GTAdsCode(alias: cSJ, probability: 1, androidId: "891767961", iosId: ""),
    GTAdsCode(alias: cSJ, probability: 1, androidId: "891767962", iosId: ""),

  ];
}