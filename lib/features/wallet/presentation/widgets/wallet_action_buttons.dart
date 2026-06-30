import 'package:bazzone_driver/core/constants/asset_const.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:bazzone_driver/shared/widgets/image/custom_asset_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WalletActionButtons extends StatelessWidget {
  const WalletActionButtons({
    super.key,
    this.onTopUpTap,
    this.onCardsTap,
    this.onMoreTap,
  });

  final VoidCallback? onTopUpTap;
  final VoidCallback? onCardsTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _WalletActionButton(
            label: LocaleKeys.wallet_page_top_up.tr(),
            icon: AssetConst.cardReceived,
            isPrimary: true,
            onTap: onTopUpTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _WalletActionButton(
            label: LocaleKeys.wallet_page_my_cards.tr(),
            icon: AssetConst.wallet2,
            onTap: onCardsTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _WalletActionButton(
            label: LocaleKeys.wallet_page_more.tr(),
            icon: AssetConst.moreCircle,
            onTap: onMoreTap,
          ),
        ),
      ],
    );
  }
}

class _WalletActionButton extends StatelessWidget {
  const _WalletActionButton({
    required this.label,
    required this.icon,
    this.isPrimary = false,
    this.onTap,
  });

  final String label;
  final String icon;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPrimary ? ColorConst.primary : ColorConst.white;
    final labelColor = isPrimary ? ColorConst.primary : ColorConst.black;

    return Column(
      children: [
        Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          elevation: isPrimary ? 0 : 0,
          shadowColor: ColorConst.black.withValues(alpha: 0.06),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 56,
              padding: EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: isPrimary
                    ? null
                    : [
                        BoxShadow(
                          color: ColorConst.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: CustomAssetImage(path: icon),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
      ],
    );
  }
}
