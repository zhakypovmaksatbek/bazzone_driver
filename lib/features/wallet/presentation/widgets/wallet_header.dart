import 'package:bazzone_driver/core/constants/asset_const.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/wallet/presentation/utils/wallet_formatters.dart';
import 'package:bazzone_driver/features/wallet/presentation/widgets/wallet_currency_text.dart';
import 'package:bazzone_driver/features/wallet/presentation/widgets/wallet_month_badge.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:bazzone_driver/shared/widgets/image/custom_asset_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WalletHeader extends StatelessWidget {
  const WalletHeader({
    super.key,
    required this.selectedMonth,
    required this.monthlyEarned,
    this.onMonthTap,
    this.onEarnedTap,
  });

  final DateTime selectedMonth;
  final double monthlyEarned;
  final VoidCallback? onMonthTap;
  final VoidCallback? onEarnedTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        WalletMonthBadge(
          label: WalletFormatters.formatMonth(selectedMonth),
          onTap: onMonthTap,
        ),
        const Spacer(),
        _EarnedCard(
          amount: WalletFormatters.formatEarned(monthlyEarned),
          onTap: onEarnedTap,
        ),
      ],
    );
  }
}

class _EarnedCard extends StatelessWidget {
  const _EarnedCard({required this.amount, this.onTap});

  final String amount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorConst.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      shadowColor: ColorConst.black.withValues(alpha: 0.04),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ColorConst.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomAssetImage(path: AssetConst.sendArrow),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.wallet_page_earned.tr(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ColorConst.grey.withValues(alpha: 0.9),
                    ),
                  ),
                  WalletCurrencyText(
                    amount: amount,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
