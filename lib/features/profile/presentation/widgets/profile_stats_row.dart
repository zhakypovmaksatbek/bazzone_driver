import 'package:bazzone_driver/features/profile/domain/entities/driver_profile.dart';
import 'package:bazzone_driver/features/profile/presentation/utils/profile_formatters.dart';
import 'package:bazzone_driver/features/profile/presentation/widgets/stat_card.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    required this.profile,
  });

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: StatCard(
            label: LocaleKeys.profile_page_orders.tr(),
            value: ProfileFormatters.formatCount(profile.ordersCount),
            icon: Icons.flag_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            label: LocaleKeys.profile_page_experience.tr(),
            value: ProfileFormatters.formatExperienceYears(
              profile.experienceYears,
            ),
            icon: Icons.circle,
            iconWidget: const SteeringWheelIcon(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            label: LocaleKeys.profile_page_rating.tr(),
            value: ProfileFormatters.formatRating(profile.rating),
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFFC727),
          ),
        ),
      ],
    );
  }
}
