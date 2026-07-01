import 'dart:ui';

import 'package:bazzone_driver/generated/codegen_loader.g.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

final class AppLocalization extends EasyLocalization {
  AppLocalization({
    super.key,
    required super.child,
    required Locale startLocale,
  }) : super(
         path: localePath,
         fallbackLocale: Locales.ru.locale,
         startLocale: startLocale,
         saveLocale: true,
         useOnlyLangCode: true,
         supportedLocales: Locales.values.map((e) => e.locale).toList(),
         assetLoader: const CodegenLoader(),
       );

  static const String localePath = 'assets/translations';
}

enum Locales {
  ru(Locale('ru'), LocaleKeys.general_ru),
  ky(Locale('ky'), LocaleKeys.general_ky);

  final Locale locale;
  final String displayName;
  const Locales(this.locale, this.displayName);
}
