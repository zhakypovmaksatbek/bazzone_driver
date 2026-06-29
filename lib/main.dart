import 'package:bazzone_driver/app/app.dart';
import 'package:bazzone_driver/app/localization/app_localization.dart';
import 'package:bazzone_driver/core/di/injection.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(AppLocalization(startLocale: Locales.ru.locale, child: const App()));
}
