// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [CustomCameraPage]
class CustomCameraRoute extends PageRouteInfo<CustomCameraRouteArgs> {
  CustomCameraRoute({
    Key? key,
    required String title,
    required StencilType stencilType,
    List<PageRouteInfo>? children,
  }) : super(
         CustomCameraRoute.name,
         args: CustomCameraRouteArgs(
           key: key,
           title: title,
           stencilType: stencilType,
         ),
         initialChildren: children,
       );

  static const String name = 'CustomCameraRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CustomCameraRouteArgs>();
      return CustomCameraPage(
        key: args.key,
        title: args.title,
        stencilType: args.stencilType,
      );
    },
  );
}

class CustomCameraRouteArgs {
  const CustomCameraRouteArgs({
    this.key,
    required this.title,
    required this.stencilType,
  });

  final Key? key;

  final String title;

  final StencilType stencilType;

  @override
  String toString() {
    return 'CustomCameraRouteArgs{key: $key, title: $title, stencilType: $stencilType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomCameraRouteArgs) return false;
    return key == other.key &&
        title == other.title &&
        stencilType == other.stencilType;
  }

  @override
  int get hashCode => key.hashCode ^ title.hashCode ^ stencilType.hashCode;
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [MainPage]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainPage();
    },
  );
}

/// generated route for
/// [OrdersPage]
class OrdersRoute extends PageRouteInfo<void> {
  const OrdersRoute({List<PageRouteInfo>? children})
    : super(OrdersRoute.name, initialChildren: children);

  static const String name = 'OrdersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OrdersPage();
    },
  );
}

/// generated route for
/// [OtpPage]
class OtpRoute extends PageRouteInfo<void> {
  const OtpRoute({List<PageRouteInfo>? children})
    : super(OtpRoute.name, initialChildren: children);

  static const String name = 'OtpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OtpPage();
    },
  );
}

/// generated route for
/// [ProfileCarDiagnosticsPage]
class ProfileCarDiagnosticsRoute extends PageRouteInfo<void> {
  const ProfileCarDiagnosticsRoute({List<PageRouteInfo>? children})
    : super(ProfileCarDiagnosticsRoute.name, initialChildren: children);

  static const String name = 'ProfileCarDiagnosticsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileCarDiagnosticsPage();
    },
  );
}

/// generated route for
/// [ProfileCarsPage]
class ProfileCarsRoute extends PageRouteInfo<void> {
  const ProfileCarsRoute({List<PageRouteInfo>? children})
    : super(ProfileCarsRoute.name, initialChildren: children);

  static const String name = 'ProfileCarsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileCarsPage();
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
}

/// generated route for
/// [ProfileSettingsPage]
class ProfileSettingsRoute extends PageRouteInfo<void> {
  const ProfileSettingsRoute({List<PageRouteInfo>? children})
    : super(ProfileSettingsRoute.name, initialChildren: children);

  static const String name = 'ProfileSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileSettingsPage();
    },
  );
}

/// generated route for
/// [ProfileTariffsAdditionPage]
class ProfileTariffsAdditionRoute extends PageRouteInfo<void> {
  const ProfileTariffsAdditionRoute({List<PageRouteInfo>? children})
    : super(ProfileTariffsAdditionRoute.name, initialChildren: children);

  static const String name = 'ProfileTariffsAdditionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileTariffsAdditionPage();
    },
  );
}

/// generated route for
/// [ProfileTariffsPage]
class ProfileTariffsRoute extends PageRouteInfo<void> {
  const ProfileTariffsRoute({List<PageRouteInfo>? children})
    : super(ProfileTariffsRoute.name, initialChildren: children);

  static const String name = 'ProfileTariffsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileTariffsPage();
    },
  );
}

/// generated route for
/// [ProfileTaxiParkPage]
class ProfileTaxiParkRoute extends PageRouteInfo<void> {
  const ProfileTaxiParkRoute({List<PageRouteInfo>? children})
    : super(ProfileTaxiParkRoute.name, initialChildren: children);

  static const String name = 'ProfileTaxiParkRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileTaxiParkPage();
    },
  );
}

/// generated route for
/// [ProfileTripHistoryPage]
class ProfileTripHistoryRoute extends PageRouteInfo<void> {
  const ProfileTripHistoryRoute({List<PageRouteInfo>? children})
    : super(ProfileTripHistoryRoute.name, initialChildren: children);

  static const String name = 'ProfileTripHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileTripHistoryPage();
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPage();
    },
  );
}

/// generated route for
/// [SupportChatPage]
class SupportChatRoute extends PageRouteInfo<SupportChatRouteArgs> {
  SupportChatRoute({
    Key? key,
    required String chatId,
    required String title,
    List<PageRouteInfo>? children,
  }) : super(
         SupportChatRoute.name,
         args: SupportChatRouteArgs(key: key, chatId: chatId, title: title),
         initialChildren: children,
       );

  static const String name = 'SupportChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SupportChatRouteArgs>();
      return SupportChatPage(
        key: args.key,
        chatId: args.chatId,
        title: args.title,
      );
    },
  );
}

class SupportChatRouteArgs {
  const SupportChatRouteArgs({
    this.key,
    required this.chatId,
    required this.title,
  });

  final Key? key;

  final String chatId;

  final String title;

  @override
  String toString() {
    return 'SupportChatRouteArgs{key: $key, chatId: $chatId, title: $title}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SupportChatRouteArgs) return false;
    return key == other.key && chatId == other.chatId && title == other.title;
  }

  @override
  int get hashCode => key.hashCode ^ chatId.hashCode ^ title.hashCode;
}

/// generated route for
/// [SupportPage]
class SupportRoute extends PageRouteInfo<void> {
  const SupportRoute({List<PageRouteInfo>? children})
    : super(SupportRoute.name, initialChildren: children);

  static const String name = 'SupportRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SupportPage();
    },
  );
}

/// generated route for
/// [VerifyPage]
class VerifyRoute extends PageRouteInfo<VerifyRouteArgs> {
  VerifyRoute({
    Key? key,
    required String phoneNumber,
    List<PageRouteInfo>? children,
  }) : super(
         VerifyRoute.name,
         args: VerifyRouteArgs(key: key, phoneNumber: phoneNumber),
         initialChildren: children,
       );

  static const String name = 'VerifyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VerifyRouteArgs>();
      return VerifyPage(key: args.key, phoneNumber: args.phoneNumber);
    },
  );
}

class VerifyRouteArgs {
  const VerifyRouteArgs({this.key, required this.phoneNumber});

  final Key? key;

  final String phoneNumber;

  @override
  String toString() {
    return 'VerifyRouteArgs{key: $key, phoneNumber: $phoneNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VerifyRouteArgs) return false;
    return key == other.key && phoneNumber == other.phoneNumber;
  }

  @override
  int get hashCode => key.hashCode ^ phoneNumber.hashCode;
}

/// generated route for
/// [WalletEarnedPage]
class WalletEarnedRoute extends PageRouteInfo<WalletEarnedRouteArgs> {
  WalletEarnedRoute({
    Key? key,
    DateTime? initialMonth,
    List<PageRouteInfo>? children,
  }) : super(
         WalletEarnedRoute.name,
         args: WalletEarnedRouteArgs(key: key, initialMonth: initialMonth),
         initialChildren: children,
       );

  static const String name = 'WalletEarnedRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WalletEarnedRouteArgs>(
        orElse: () => const WalletEarnedRouteArgs(),
      );
      return WalletEarnedPage(key: args.key, initialMonth: args.initialMonth);
    },
  );
}

class WalletEarnedRouteArgs {
  const WalletEarnedRouteArgs({this.key, this.initialMonth});

  final Key? key;

  final DateTime? initialMonth;

  @override
  String toString() {
    return 'WalletEarnedRouteArgs{key: $key, initialMonth: $initialMonth}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WalletEarnedRouteArgs) return false;
    return key == other.key && initialMonth == other.initialMonth;
  }

  @override
  int get hashCode => key.hashCode ^ initialMonth.hashCode;
}

/// generated route for
/// [WalletPage]
class WalletRoute extends PageRouteInfo<void> {
  const WalletRoute({List<PageRouteInfo>? children})
    : super(WalletRoute.name, initialChildren: children);

  static const String name = 'WalletRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WalletPage();
    },
  );
}
