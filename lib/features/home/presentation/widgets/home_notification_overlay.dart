import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:flutter/material.dart';

class HomeNotificationOverlay extends StatelessWidget {
  const HomeNotificationOverlay({
    super.key,
    required this.balance,
    required this.onTopUpPressed,
    this.threshold = 100.0,
  });

  final double balance;
  final VoidCallback onTopUpPressed;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    if (balance >= threshold) {
      return const SizedBox.shrink();
    }

    final topPadding = MediaQuery.paddingOf(context).top;

    return GestureDetector(
      onTap: onTopUpPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: topPadding + 4,
          bottom: 12,
          left: 16,
          right: 16,
        ),
        color: const Color(0xFFE53935), // Bright red background
        child: SizedBox(
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                'Балансты толуктаңыз',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ColorConst.white,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              Positioned(
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: ColorConst.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFE53935),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
