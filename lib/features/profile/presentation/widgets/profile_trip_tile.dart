import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/profile/domain/entities/trip_history_item.dart';
import 'package:bazzone_driver/features/profile/presentation/utils/profile_formatters.dart';
import 'package:flutter/material.dart';

class ProfileTripTile extends StatelessWidget {
  const ProfileTripTile({
    super.key,
    required this.trip,
    this.showDivider = true,
  });

  final TripHistoryItem trip;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.flag_rounded,
                  size: 18,
                  color: ColorConst.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ProfileFormatters.formatTripDistance(trip.distanceKm)} / ${trip.time}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ColorConst.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.route,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ColorConst.grey.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ProfileFormatters.formatTripEarned(trip.earnedAmount),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.black,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 46,
            endIndent: 16,
            color: ColorConst.lightGrey,
          ),
      ],
    );
  }
}
