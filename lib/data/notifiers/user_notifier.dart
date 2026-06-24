import 'package:base_object/app/repository_providers.dart';
import 'package:base_object/data/models/backModel/userModel/UserModel.dart';
import 'package:base_object/data/models/user_state.dart';
import 'package:base_object/data/repositories/user_repository.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserNotifier extends Notifier<UserState> {
  late final UserRepository _repository;

  @override
  UserState build() {
    _repository = ref.read(userRepositoryProvider);
    return UserState();
  }

  UserModel get userModel => state.userModel;
  bool get isLoggedIn => state.isLoggedIn;
  String get userLevel => state.userLevel;

  Future<void> loadFromStorage() async {
    try {
      final UserModel? model = await _repository.loadUser();
      if (model != null && model.id > 0) {
        updateUserModel(model);
      }
    } catch (e) {
      Utils.logError('读取本地用户信息失败$e');
    }
  }

  Future<void> getUserInfoFn() => loadFromStorage();

  void updateUserModel(UserModel newModel) {
    try {
      state = state.copyWith(userModel: newModel);
      _repository.saveUser(newModel);
    } catch (e) {
      Utils.logError('$e');
    }
  }
}
