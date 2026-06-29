import 'package:bazzone_driver/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bazzone Driver',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const Scaffold(body: Center(child: Text('Bazzone Driver'))),
    );
  }
}
