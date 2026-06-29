import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/core/constants/asset_const.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/shared/widgets/image/custom_asset_image.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'SplashRoute')
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.primary,
      body: Center(child: CustomAssetImage(path: AssetConst.logo, height: 153)),
    );
  }
}
