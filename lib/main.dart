import 'package:bazzone_driver/app/app.dart';
import 'package:bazzone_driver/core/di/injection.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const App());
}
