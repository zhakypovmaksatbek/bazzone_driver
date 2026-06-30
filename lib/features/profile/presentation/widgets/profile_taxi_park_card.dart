import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/profile/domain/entities/taxi_park_details.dart';
import 'package:bazzone_driver/features/profile/presentation/utils/profile_formatters.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ProfileTaxiParkCard extends StatelessWidget {
  const ProfileTaxiParkCard({
    super.key,
    required this.details,
    this.onMoreTap,
    this.onWithdrawalTermsTap,
  });

  final TaxiParkDetails details;
  final VoidCallback? onMoreTap;
  final VoidCallback? onWithdrawalTermsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorConst.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ColorConst.black,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: '${LocaleKeys.profile_page_taxi_park.tr()}\n',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: ColorConst.grey.withValues(alpha: 0.9),
                        ),
                      ),
                      TextSpan(text: details.name),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorConst.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  LocaleKeys.profile_taxi_park_page_commission.tr(
                    args: [ProfileFormatters.formatCommission(details.commissionPercent)],
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColorConst.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailBlock(
            title: LocaleKeys.profile_taxi_park_page_schedule.tr(),
            lines: [
              '${LocaleKeys.profile_taxi_park_page_weekdays.tr()} ${details.weekdaySchedule}',
              '${LocaleKeys.profile_taxi_park_page_weekends.tr()} ${details.weekendSchedule}',
            ],
          ),
          const SizedBox(height: 16),
          _DetailBlock(
            title: LocaleKeys.profile_taxi_park_page_address.tr(),
            lines: [details.address],
          ),
          const SizedBox(height: 16),
          _DetailBlock(
            title: LocaleKeys.profile_taxi_park_page_contacts.tr(),
            lines: [details.phone],
          ),
          const SizedBox(height: 20),
          _ActionTile(
            title: LocaleKeys.profile_taxi_park_page_more_about.tr(),
            onTap: onMoreTap,
          ),
          Divider(height: 1, color: ColorConst.lightGrey),
          _ActionTile(
            title: LocaleKeys.profile_taxi_park_page_withdrawal_terms.tr(),
            onTap: onWithdrawalTermsTap,
          ),
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.title,
    required this.lines,
  });

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: ColorConst.grey.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 6),
        ...lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ColorConst.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    this.onTap,
  });

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: ColorConst.black,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: ColorConst.grey.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
