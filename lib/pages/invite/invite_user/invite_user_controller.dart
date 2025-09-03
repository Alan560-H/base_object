import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/manager/banner_tool.dart';
import 'package:base_object/models/localModels/BannerVo.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/components/cu_toast.dart';

class InviteUserController extends GetxController {
  RxString appbarTitle = "邀请好友页面标题".obs;
  final UserInfo userInfo = Get.find<UserInfo>();
  BannerTool bannerTool = Get.find<BannerTool>();
  final RxList<BannerVo> swipers = [
    BannerVo(imageUrl: ImageConfig.inviteBanner1, id: 0),
    BannerVo(imageUrl: ImageConfig.inviteBanner3, id: 1),
  ].obs;
  // 海报id相当于
  final RxList<GlobalKey> bannerKeys = <GlobalKey>[].obs;
  // 当前轮播索引
  final RxInt currentSwiperIndex = 0.obs;
  onPageChanged(int index, CarouselPageChangedReason reason){
    Utils.logError("当前页面：$index, 原因：$reason");
    currentSwiperIndex.value = index;
  }
  Future<Uint8List?> _captureWidget(GlobalKey key)async{
    try{
      RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      /// 转换为图片
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      /// 转换为字节数据
      ByteData? bytedata = await image.toByteData(format: ui.ImageByteFormat.png);
      return bytedata?.buffer.asUint8List();
    }catch(e){
      CuToast.error(msg: "捕获图片失败");
      return null;
    }
  }
  saveImage()async{
    try{
      EasyLoading.show(status: "正在保存中...");
      Uint8List? imageData = await _captureWidget(bannerKeys[currentSwiperIndex.value]);
      if(imageData !=null){
        final result = await ImageGallerySaverPlus.saveImage(imageData,quality:100,name:"邀请好友${DateTime.now().millisecondsSinceEpoch}");
        if(result['isSuccess'] == true){
          EasyLoading.showSuccess("保存成功");
        }else{
          EasyLoading.showError("保存失败");

        }
        EasyLoading.dismiss();
      }
    }catch(e){
      Utils.logError("保存图片失败");
      EasyLoading.dismiss();
    }
  }
  @override
  void onInit() {
    // TODO: implement onInit
    bannerTool.hideBannerAd();
    for(int i = 0; i < swipers.length; i++){
      bannerKeys.add(GlobalKey());
    }
    super.onInit();
  }
  @override
  void onClose() {
    Utils.logError("关闭页面");
    bannerTool.afreshShowBannerAd();
    // TODO: implement onClose
    super.onClose();
  }

}
