import 'package:bazzone_driver/core/constants/asset_const.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/shared/widgets/image/custom_asset_image.dart';
import 'package:flutter/material.dart';

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: ColorConst.white,
      indicatorColor: ColorConst.primary.withValues(alpha: 0.12),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      destinations: const [
        NavigationDestination(
          icon: CustomAssetImage(path: AssetConst.home),
          selectedIcon: CustomAssetImage(
            path: AssetConst.home,
            color: ColorConst.primary,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: CustomAssetImage(path: AssetConst.wallet),
          selectedIcon: CustomAssetImage(
            path: AssetConst.wallet,
            color: ColorConst.primary,
          ),
          label: 'Wallet',
        ),
        NavigationDestination(
          icon: CustomAssetImage(path: AssetConst.support),
          selectedIcon: CustomAssetImage(
            path: AssetConst.support,
            color: ColorConst.primary,
          ),
          label: 'Support',
        ),
        NavigationDestination(
          icon: CustomAssetImage(path: AssetConst.profile),
          selectedIcon: CustomAssetImage(
            path: AssetConst.profile,
            color: ColorConst.primary,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
