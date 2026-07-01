import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomeFloatingTrafficProgressCard extends StatelessWidget {
  const HomeFloatingTrafficProgressCard({
    super.key,
    required this.order,
  });

  final Order order;

  @override
  Widget build(BuildContext context) {
    final arrivalTime = DateTime.now().add(
      Duration(minutes: (order.distanceToPointKm * 3).round()),
    );
    final arrivalStr =
        "${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}";

    final durationMin = (order.distanceToPointKm * 3).round();
    final durationStr = LocaleKeys.home_page_minutes_short.tr(
      args: [durationMin.toString()],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.home_page_km.tr(
                  args: [order.distanceToPointKm.toString()],
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.black,
                ),
              ),
              Text(
                arrivalStr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.black,
                ),
              ),
              Text(
                durationStr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.play_arrow, color: ColorConst.black, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 6,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Container(color: ColorConst.success),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(color: Colors.yellow),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(color: ColorConst.error),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(color: ColorConst.success),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(color: Colors.yellow),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(color: ColorConst.success),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ColorConst.black, width: 2),
                  color: ColorConst.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
