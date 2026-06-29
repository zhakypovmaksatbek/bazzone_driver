import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/main/presentation/widgets/main_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'MainRoute')
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      backgroundColor: ColorConst.white,
      bottomNavigationBuilder: (_, tabsRouter) {
        return MainBottomNavBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
        );
      },
    );
  }
}
