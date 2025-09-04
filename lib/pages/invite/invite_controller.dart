import 'package:base_object/core/api/api.dart';
import 'package:base_object/core/routes/app_routes.dart';
import 'package:base_object/models/backModel/userModel/UserInviteInfoModel.dart';
import 'package:base_object/models/localModels/MenuModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class InviteController extends GetxController {
  static InviteController get to => Get.find<InviteController>();
  UserInfo userInfo = Get.find<UserInfo>();
  RxString appbarTitle = "邀请好友/领取现金".obs;
  //  我的推广信息
  Rx<UserInviteInfoModel> userInviteInfoModel = UserInviteInfoModel().obs;
  List<MenuModel> menuList = [
    MenuModel(
      id: 0,
      menuName: "我的钱包",
      path: AppRoutes.userWallet,
      icon: Icons.shopping_bag,
    ),
    MenuModel(
      id: 1,
      path: AppRoutes.userEarnings,
      menuName: "我的收益",
      icon: Icons.share,
    ),
    MenuModel(
      id: 2,
      menuName: "我的徒弟",
      path: AppRoutes.userSon,
      icon: Icons.supervisor_account,
    ),
    MenuModel(
      id: 3,
      path: AppRoutes.userEditInfo,
      menuName: "我的资料",
      icon: Icons.info,
    ),
  ];
  void getMyInviteInfo()async {
    try{
      if(userInfo.isLoginIn){
        EasyLoading.show();
        userInviteInfoModel.value = await Api().getMyInviteInfo();
        Utils.logError("我的邀请数据 ${userInviteInfoModel.toJson()}");
      }
    }catch(e){
      Utils.logError("getMyInviteInfo 邀请界面报错：$e");
    }finally{
      EasyLoading.dismiss();
    }
  }

}
