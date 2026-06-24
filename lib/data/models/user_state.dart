import 'package:base_object/data/models/backModel/userModel/UserModel.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserState {
  UserState({UserModel? userModel})
    : userModel = userModel ?? UserModel();

  final UserModel userModel;

  bool get isLoggedIn => userModel.id > 0;

  String get userLevel {
    switch (userModel.type) {
      case 1:
        return '会员';
      case 2:
        return '高级团长';
      case 3:
        return '代理';
      case 4:
        return '总代理';
      default:
        return '会员';
    }
  }

  UserState copyWith({UserModel? userModel}) {
    return UserState(userModel: userModel ?? this.userModel);
  }
}
