import 'package:base_object/data/models/backModel/userModel/UserModel.dart';
import 'package:base_object/services/storage/local_storage.dart';
import 'package:base_object/shared/config/app_keys.dart';

class UserRepository {
  Future<UserModel?> loadUser() {
    return LocalStorage.getObject<UserModel>(
      AppKeys.userKey,
      (v) => UserModel.fromJson(v),
    );
  }

  Future<void> saveUser(UserModel model) {
    return LocalStorage.setString(AppKeys.userKey, model);
  }
}
