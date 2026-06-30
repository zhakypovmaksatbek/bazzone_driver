import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/features/auth/presentation/pages/otp_page.dart';
import 'package:bazzone_driver/features/auth/presentation/pages/verify_page.dart';
import 'package:bazzone_driver/features/home/presentation/pages/home_page.dart';
import 'package:bazzone_driver/features/main/presentation/pages/main_page.dart';
import 'package:bazzone_driver/features/orders/presentation/pages/orders_page.dart';
import 'package:bazzone_driver/features/profile/presentation/pages/profile_cars_page.dart';
import 'package:bazzone_driver/features/profile/presentation/pages/profile_page.dart';
import 'package:bazzone_driver/features/profile/presentation/pages/profile_taxi_park_page.dart';
import 'package:bazzone_driver/features/profile/presentation/pages/profile_trip_history_page.dart';
import 'package:bazzone_driver/features/splash/presentation/pages/splash_page.dart';
import 'package:bazzone_driver/features/support/presentation/pages/support_chat_page.dart';
import 'package:bazzone_driver/features/support/presentation/pages/support_page.dart';
import 'package:bazzone_driver/features/wallet/presentation/pages/wallet_earned_page.dart';
import 'package:bazzone_driver/features/wallet/presentation/pages/wallet_page.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: false),
    AutoRoute(page: OtpRoute.page),
    AutoRoute(page: VerifyRoute.page),
    AutoRoute(page: WalletEarnedRoute.page),
    AutoRoute(page: SupportChatRoute.page),
    AutoRoute(page: ProfileCarsRoute.page),
    AutoRoute(page: ProfileTaxiParkRoute.page),
    AutoRoute(page: ProfileTripHistoryRoute.page),
    AutoRoute(
      page: MainRoute.page,
      initial: true,
      children: [
        AutoRoute(path: 'home', page: HomeRoute.page, initial: true),
        AutoRoute(path: 'wallet', page: WalletRoute.page),
        AutoRoute(path: 'support', page: SupportRoute.page),
        AutoRoute(path: 'profile', page: ProfileRoute.page),
      ],
    ),
  ];
}
