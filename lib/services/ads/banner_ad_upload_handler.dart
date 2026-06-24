import 'package:base_object/app/providers.dart';
import 'package:base_object/data/models/FormModel/upADForm/UpDataADForm.dart';
import 'package:base_object/data/models/localModels/UpADModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:jiffy/jiffy.dart';

/// 横幅自动刷新后的风控上报（原 CuNavBarController.upDataADFn）。
void handleBannerAdUpload(dynamic event) {
  try {
    Utils.logError(
      '${Jiffy.now().format(pattern: 'yyyy-MM-dd HH:mm:ss')}横幅广告 handleBannerAdUpload${event.extraMap}',
    );
    final UpDataADForm upDataADForm = UpDataADForm();

    final dynamic publisherRevenueCny = event.extraMap?['publisher_revenue_cny'];
    final double? amount = double.tryParse(publisherRevenueCny?.toString() ?? '0');
    final String reqId = event.extraMap?['req_id'];
    final String adsourceId = event.extraMap?['adsource_id'];

    final userState = globalContainer.read(userProvider);
    final adStats = globalContainer.read(adStatsProvider.notifier);
    final fkConfig = globalContainer.read(adStatsProvider).fkConfig;
    final String userId = userState.userModel.id.toString();

    upDataADForm.extra =
        'userid_${userId}_type_2_amount_${publisherRevenueCny ?? 0}_time_0';
    upDataADForm.transId = event.extraMap?['id'];
    upDataADForm.amount = amount;
    upDataADForm.adsourceId = adsourceId;
    upDataADForm.reqId = reqId;
    upDataADForm.sign = Utils.generateEncryptedString(
      userId: userId,
      reqId: reqId,
      adsourceId: adsourceId,
    );
    Utils.logError('横幅广告凑成的字符串${upDataADForm.toJson()}');
    Utils.logError('横幅广告金额$amount，限制金额${fkConfig.wactchMaxAmountV1}');

    if (!userState.isLoggedIn) return;
    if (amount == null) return;

    final double amount1 = amount * 10000;
    final UpADModel upADModel = UpADModel(
      adsourceId: adsourceId,
      reqId: reqId,
      adType: '横幅广告',
      adAmount: amount1,
    );

    if (amount1 > fkConfig.wactchMaxAmountV1) {
      adStats.addWatchMaxAdList(upADModel);
    }
    if (amount1 < fkConfig.wactchMinAmountV1) {
      adStats.addWatchMinAdList(upADModel);
    }
  } catch (e) {
    Utils.logError('上报副广失败：$e');
  }
}
