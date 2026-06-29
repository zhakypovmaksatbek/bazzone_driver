import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_primary_action_button.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/order_detail_body.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomeOrderOfferPanel extends StatelessWidget {
  const HomeOrderOfferPanel({
    super.key,
    required this.order,
    required this.isLoading,
    this.onAccept,
    this.onDecline,
  });

  final Order order;
  final bool isLoading;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrderDetailBody(order: order),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: HomePrimaryActionButton(
            label: LocaleKeys.home_page_accept.tr(),
            isLoading: isLoading,
            onPressed: onAccept,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextButton(
            onPressed: isLoading ? null : onDecline,
            style: TextButton.styleFrom(
              foregroundColor: ColorConst.error,
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Text(
              LocaleKeys.home_page_decline.tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
