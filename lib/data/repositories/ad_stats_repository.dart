import 'package:base_object/data/models/backModel/fKModelConfig/FKConfigVo.dart';
import 'package:base_object/data/models/localModels/AdInfo.dart';
import 'package:base_object/services/storage/local_storage.dart';
import 'package:base_object/shared/config/app_keys.dart';

class AdStatsRepository {
  Future<List<AdInfo>?> loadAdInfos() {
    return LocalStorage.getObjectList(AppKeys.adInfosKey, AdInfo.fromJson);
  }

  Future<void> saveAdInfos(List<AdInfo> adInfos) {
    return LocalStorage.setString(AppKeys.adInfosKey, adInfos);
  }

  Future<void> saveFkConfig(FKConfigVo config) {
    return LocalStorage.setString(AppKeys.fkConfig, config.toJson());
  }
}
