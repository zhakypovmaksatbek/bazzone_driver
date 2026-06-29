import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'OrdersRoute')
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ColorConst.white,
      body: Center(child: Text('Orders')),
    );
  }
}
