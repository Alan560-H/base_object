import 'package:base_object/data/models/backModel/userModel/UserModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:base_object/services/storage/local_storage.dart';
import 'package:base_object/shared/config/app_keys.dart';
import 'package:get/get.dart';

class UserInfo extends GetxController {
  static UserInfo get instance => Get.find<UserInfo>();
  final Rx<UserModel> _userModel = UserModel().obs;

  bool get isLoginIn => userModel.id > 0;

  String get getUserLevel {
    Utils.logError("用户等级是${userModel.type}");
    switch (userModel.type) {
      case 1:
        return "会员";
      case 2:
        return "高级团长";
      case 3:
        return "代理";
      case 4:
        return "总代理";
      default:
        return "会员";
    }
  }

  UserModel get userModel {
    try {
      return _userModel.value;
    } catch (e) {
      return UserModel();
    }
  }

  Future<void> getUserInfoFn() async {
    try {
      final UserModel? model = await LocalStorage.getObject<UserModel>(
        AppKeys.userKey,
        (v) => UserModel.fromJson(v),
      );
      if (model != null && model.id > 0) {
        updateUserModel(model);
      }
    } catch (e) {
      Utils.logError("读取本地用户信息失败$e");
    }
  }

  void updateUserModel(UserModel newModel) {
    try {
      _userModel.value = newModel;
      LocalStorage.setString(AppKeys.userKey, newModel);
    } catch (e) {
      Utils.logError(e);
    }
  }
}
