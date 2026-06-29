import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/order_detail_body.dart';
import 'package:flutter/material.dart';

/// Collapsed sheet — status + route through point B, no action buttons.
class HomeOrderCompactPanel extends StatelessWidget {
  const HomeOrderCompactPanel({
    super.key,
    required this.order,
    required this.statusLabel,
    required this.statusColor,
    this.onTap,
  });

  final Order order;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        statusLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    Text(
                      order.price,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ColorConst.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: ColorConst.grey.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OrderRouteColumn(
                  pickup: order.pickupAddress,
                  destination: order.destinationAddress,
                  pickupDistanceKm: order.distanceToClientKm,
                  destinationDistanceKm: order.distanceToPointKm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
