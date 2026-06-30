import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/wallet/domain/entities/wallet_earned_details.dart';
import 'package:bazzone_driver/features/wallet/presentation/utils/wallet_formatters.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WalletEarnedDetailsCard extends StatelessWidget {
  const WalletEarnedDetailsCard({super.key, required this.details});

  final WalletEarnedDetails details;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorConst.lightGrey,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: ColorConst.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  size: 22,
                  color: ColorConst.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.wallet_earned_page_taxi_park.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: ColorConst.grey.withValues(alpha: 0.9),
                      ),
                    ),
                    Text(
                      details.taxiParkName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: ColorConst.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: LocaleKeys.wallet_earned_page_limit.tr(),
                  value: '${WalletFormatters.formatBalance(details.limit)} с',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: LocaleKeys.wallet_earned_page_commission.tr(),
                  value:
                      '${WalletFormatters.formatBalance(details.commission)} с',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: LocaleKeys.wallet_earned_page_partnership.tr(),
                  value: LocaleKeys.wallet_earned_page_partnership_months.tr(
                    args: [details.partnershipMonths.toString()],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AdaptiveSingleLineText(
            text: label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: ColorConst.grey.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),
          _AdaptiveSingleLineText(
            text: value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ColorConst.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaptiveSingleLineText extends StatelessWidget {
  const _AdaptiveSingleLineText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(text, maxLines: 1, softWrap: false, style: style),
      ),
    );
  }
}
