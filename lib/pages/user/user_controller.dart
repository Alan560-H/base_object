import 'package:base_object/models/backModel/userModel/UserModel.dart';
import 'package:base_object/store/user_info.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  var count = 0.obs;
  void increment() => count++;
  void changeSteamName(){
    UserModel newUserModel = UserModel();
    newUserModel.username = "哈哈哈哈";
    UserInfo.instance.updateUserModel(newUserModel);
    Utils.logError(UserInfo.instance.userModel.toJson());
  }
}