
// 自定义本地化代理
import 'package:flutter/material.dart';

class ChineseLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const ChineseLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return const _ChineseMaterialLocalizations();
  }

  @override
  bool shouldReload(ChineseLocalizationsDelegate old) => false;
}

// 自定义 MaterialLocalizations
class _ChineseMaterialLocalizations extends DefaultMaterialLocalizations {
  const _ChineseMaterialLocalizations();

  @override
  String get copyButtonLabel => '复制';

  @override
  String get pasteButtonLabel => '粘贴';

  @override
  String get cutButtonLabel => '剪切';
  @override
  String get shareButtonLabel => '分享';
  @override
  String get selectAllButtonLabel => '全选';
}