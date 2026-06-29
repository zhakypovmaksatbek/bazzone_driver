import 'package:bazzone_driver/features/home/domain/entities/driver_session.dart';
import 'package:bazzone_driver/features/home/domain/entities/home_sheet_phase.dart';
import 'package:bazzone_driver/features/home/presentation/bloc/home_bloc.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_active_order_panel.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_driver_panel.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_order_offer_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSheetContent extends StatelessWidget {
  const HomeSheetContent({
    super.key,
    required this.session,
    required this.isBusy,
    required this.action,
    required this.isExpanded,
    this.onExpandSheet,
    this.onProfileTap,
    this.onWaitingStateChanged,
  });

  final DriverSession session;
  final bool isBusy;
  final HomeAction action;
  final bool isExpanded;
  final VoidCallback? onExpandSheet;
  final VoidCallback? onProfileTap;
  final ValueChanged<bool>? onWaitingStateChanged;

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
      HomeSheetPhase.orderOffer => HomeOrderOfferPanel(
          order: session.offeredOrder!,
          isExpanded: isExpanded,
          isLoading: action == HomeAction.acceptingOrder,
          onExpandTap: onExpandSheet,
          onAccept: () =>
              context.read<HomeBloc>().add(const HomeAcceptOrderRequested()),
          onDecline: () =>
              context.read<HomeBloc>().add(const HomeDeclineOrderRequested()),
        ),
      HomeSheetPhase.activeOrder => HomeActiveOrderPanel(
          order: session.activeOrder!,
          isExpanded: isExpanded,
          isLoading: action == HomeAction.advancingOrder ||
              action == HomeAction.completingOrder,
          onExpandTap: onExpandSheet,
          onArrived: () =>
              context.read<HomeBloc>().add(const HomeAdvanceOrderRequested()),
          onComplete: () =>
              context.read<HomeBloc>().add(const HomeCompleteOrderRequested()),
          onWaitingStateChanged: onWaitingStateChanged,
        ),
    };
  }
}
