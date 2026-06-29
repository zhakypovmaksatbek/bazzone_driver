import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: ColorConst.primary),
    scaffoldBackgroundColor: ColorConst.white,
    appBarTheme: AppBarTheme(backgroundColor: ColorConst.white),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  );
}
