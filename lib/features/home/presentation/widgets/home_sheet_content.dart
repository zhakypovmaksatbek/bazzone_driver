import 'package:bazzone_driver/features/home/domain/entities/driver_session.dart';
import 'package:bazzone_driver/features/home/domain/entities/home_sheet_phase.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';
import 'package:bazzone_driver/features/home/presentation/bloc/home_bloc.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_active_order_panel.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_driver_panel.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_order_collapsed_panel.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_order_offer_panel.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSheetContent extends StatelessWidget {
  const HomeSheetContent({
    super.key,
    required this.session,
    required this.isBusy,
    required this.action,
    required this.isCollapsed,
    this.onExpandSheet,
    this.onProfileTap,
  });

  final DriverSession session;
  final bool isBusy;
  final HomeAction action;
  final bool isCollapsed;
  final VoidCallback? onExpandSheet;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return switch (session.sheetPhase) {
      HomeSheetPhase.driverSummary => HomeDriverPanel(
          driverName: session.profile.name,
          dateLabel: session.shiftSummary.dateLabel,
          earnings: session.shiftSummary.earnings,
          ordersCount: session.shiftSummary.ordersCount,
          isOnline: session.isOnline,
          isLoading: isBusy,
          avatarUrl: session.profile.avatarUrl,
          onProfileTap: onProfileTap,
          onStartWork: () =>
              context.read<HomeBloc>().add(const HomeStartWorkRequested()),
          onFinishWork: () =>
              context.read<HomeBloc>().add(const HomeFinishWorkRequested()),
        ),
      HomeSheetPhase.orderOffer => _buildOrderOffer(context),
      HomeSheetPhase.activeOrder => _buildActiveOrder(context),
    };
  }

  Widget _buildOrderOffer(BuildContext context) {
    final order = session.offeredOrder!;

    if (isCollapsed) {
      return HomeOrderCollapsedPanel(
        order: order,
        onTap: onExpandSheet,
      );
    }

    return HomeOrderOfferPanel(
      order: order,
      isLoading: action == HomeAction.acceptingOrder,
      onAccept: () =>
          context.read<HomeBloc>().add(const HomeAcceptOrderRequested()),
      onDecline: () =>
          context.read<HomeBloc>().add(const HomeDeclineOrderRequested()),
    );
  }

  Widget _buildActiveOrder(BuildContext context) {
    final order = session.activeOrder!;

    if (isCollapsed) {
      return HomeOrderCollapsedPanel(
        order: order,
        statusLabel: _activeStatusLabel(order),
        onTap: onExpandSheet,
      );
    }

    return HomeActiveOrderPanel(
      order: order,
      isLoading: action == HomeAction.advancingOrder ||
          action == HomeAction.completingOrder,
      onPrimaryAction: () {
        final bloc = context.read<HomeBloc>();
        if (order.activePhase == ActiveOrderPhase.headingToDestination) {
          bloc.add(const HomeCompleteOrderRequested());
        } else {
          bloc.add(const HomeAdvanceOrderRequested());
        }
      },
    );
  }

  String? _activeStatusLabel(Order order) => switch (order.activePhase) {
        ActiveOrderPhase.accepted => null,
        ActiveOrderPhase.headingToClient =>
          LocaleKeys.home_page_en_route_to_client.tr(),
        ActiveOrderPhase.headingToDestination =>
          LocaleKeys.home_page_en_route_to_destination.tr(),
      };
}
