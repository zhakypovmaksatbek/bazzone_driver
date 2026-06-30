import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/wallet/domain/entities/wallet_earned_details.dart';
import 'package:bazzone_driver/features/wallet/presentation/utils/wallet_formatters.dart';
import 'package:bazzone_driver/features/wallet/presentation/widgets/wallet_currency_text.dart';
import 'package:bazzone_driver/features/wallet/presentation/widgets/wallet_month_badge.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WalletEarnedBalanceCard extends StatelessWidget {
  const WalletEarnedBalanceCard({
    super.key,
    required this.details,
    this.onMonthTap,
    this.onPaymentCardTap,
  });

  final WalletEarnedDetails details;
  final VoidCallback? onMonthTap;
  final VoidCallback? onPaymentCardTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: ColorConst.lightGrey,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          WalletMonthBadge(
            label: WalletFormatters.formatMonth(details.selectedMonth),
            usePrimaryText: true,
            onTap: onMonthTap,
          ),
          const SizedBox(height: 24),
          WalletCurrencyText(
            amount: WalletFormatters.formatEarned(details.earnedAmount),
            fontSize: 40,
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.wallet_page_earned.tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: ColorConst.grey.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 24),
          Material(
            color: ColorConst.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onPaymentCardTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.credit_card_rounded,
                      size: 22,
                      color: ColorConst.grey.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        details.selectedPaymentCard.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: ColorConst.black,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 24,
                      color: ColorConst.grey.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
