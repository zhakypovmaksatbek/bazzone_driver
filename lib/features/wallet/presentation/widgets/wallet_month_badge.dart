import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:flutter/material.dart';

class WalletMonthBadge extends StatelessWidget {
  const WalletMonthBadge({
    super.key,
    required this.label,
    this.onTap,
    this.usePrimaryText = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool usePrimaryText;

  @override
  Widget build(BuildContext context) {
    final textColor = usePrimaryText ? ColorConst.primary : ColorConst.black;

    return Material(
      color: ColorConst.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: ColorConst.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
