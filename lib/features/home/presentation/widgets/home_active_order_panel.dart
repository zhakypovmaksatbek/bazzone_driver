import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_primary_action_button.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/order_detail_body.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:bazzone_driver/shared/widgets/buttons/swipe_action_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Kabul edilmiş aktif siparişin UI'ı.
///
/// Aşama ([Order.activePhase]) değiştikçe içerik tamamen değişir:
/// - [ActiveOrderPhase.accepted]: tam sipariş detayı + "Yola çık" butonu.
/// - [ActiveOrderPhase.headingToClient]: kompakt seyir kartı + "Vardım"
///   kaydırma butonu.
/// - [ActiveOrderPhase.headingToDestination]: kompakt seyir kartı +
///   "Siparişi bitir" kaydırma butonu.
class HomeActiveOrderPanel extends StatelessWidget {
  const HomeActiveOrderPanel({
    super.key,
    required this.order,
    required this.isLoading,
    this.onPrimaryAction,
  });

  final Order order;
  final bool isLoading;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return switch (order.activePhase) {
      ActiveOrderPhase.accepted => _AcceptedOrderView(
          order: order,
          isLoading: isLoading,
          onDepart: onPrimaryAction,
        ),
      ActiveOrderPhase.headingToClient => _NavigatingOrderView(
          order: order,
          isLoading: isLoading,
          statusLabel: LocaleKeys.home_page_en_route_to_client.tr(),
          swipeLabel: LocaleKeys.home_page_arrived_at_client.tr(),
          onConfirmed: onPrimaryAction,
        ),
      ActiveOrderPhase.headingToDestination => _NavigatingOrderView(
          order: order,
          isLoading: isLoading,
          statusLabel: LocaleKeys.home_page_en_route_to_destination.tr(),
          swipeLabel: LocaleKeys.home_page_complete_order.tr(),
          onConfirmed: onPrimaryAction,
        ),
    };
  }
}

class _AcceptedOrderView extends StatelessWidget {
  const _AcceptedOrderView({
    required this.order,
    required this.isLoading,
    this.onDepart,
  });

  final Order order;
  final bool isLoading;
  final VoidCallback? onDepart;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: ColorConst.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              LocaleKeys.home_page_order_accepted.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorConst.primary,
              ),
            ),
          ),
        ),
        OrderDetailBody(order: order),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: HomePrimaryActionButton(
            label: LocaleKeys.home_page_depart.tr(),
            isLoading: isLoading,
            onPressed: onDepart,
          ),
        ),
      ],
    );
  }
}

class _NavigatingOrderView extends StatelessWidget {
  const _NavigatingOrderView({
    required this.order,
    required this.isLoading,
    required this.statusLabel,
    required this.swipeLabel,
    this.onConfirmed,
  });

  final Order order;
  final bool isLoading;
  final String statusLabel;
  final String swipeLabel;
  final VoidCallback? onConfirmed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: ColorConst.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorConst.primary,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OrderRouteRow(
            pickup: order.pickupAddress,
            destination: order.destinationAddress,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  order.price,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ColorConst.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: ColorConst.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  LocaleKeys.home_page_km.tr(
                    args: [order.distanceToPointKm.toString()],
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColorConst.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SwipeActionButton(
            label: swipeLabel,
            isLoading: isLoading,
            onConfirmed: onConfirmed ?? () {},
          ),
        ),
      ],
    );
  }
}
