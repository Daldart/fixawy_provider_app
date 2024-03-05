import 'package:flutter/material.dart';
import 'package:fixawy_provider/locale/base_language.dart';
import 'package:fixawy_provider/locale/language_ar.dart';
import 'package:fixawy_provider/locale/language_en.dart';
import 'package:nb_utils/nb_utils.dart';

class AppLocalizations extends LocalizationsDelegate<Languages> {
  const AppLocalizations();

  @override
  Future<Languages> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'ar':
        return LanguageAr();
      default:
        return LanguageAr();
    }
  }

  @override
  bool isSupported(Locale locale) =>
      LanguageDataModel.languages().contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<Languages> old) => false;
}
