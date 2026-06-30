import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/wallet/presentation/utils/wallet_formatters.dart';
import 'package:bazzone_driver/features/wallet/presentation/widgets/wallet_currency_text.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WalletBalanceSection extends StatelessWidget {
  const WalletBalanceSection({
    super.key,
    required this.balance,
  });

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          LocaleKeys.wallet_page_balance.tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorConst.grey.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 8),
        WalletCurrencyText(
          amount: WalletFormatters.formatBalance(balance),
        ),
      ],
    );
  }
}
