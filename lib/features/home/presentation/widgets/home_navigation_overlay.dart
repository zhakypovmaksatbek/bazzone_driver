import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:flutter/material.dart';

class HomeNavigationOverlay extends StatelessWidget {
  const HomeNavigationOverlay({
    super.key,
    required this.isVisible,
    required this.streetName,
    required this.distanceToTurn,
    required this.turnIcon,
    required this.onOpenNavigator,
  });

  final bool isVisible;
  final String streetName;
  final String distanceToTurn;
  final IconData turnIcon;
  final VoidCallback onOpenNavigator;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // Dark modern container
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Maneuver Turn Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorConst.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ColorConst.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              turnIcon,
              color: ColorConst.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          // Maneuver Info Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  distanceToTurn,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorConst.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  streetName,
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorConst.white.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // External Navigation Trigger Button
          ElevatedButton.icon(
            onPressed: onOpenNavigator,
            icon: const Icon(Icons.navigation, size: 14),
            label: const Text('Навигатор'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConst.primary,
              foregroundColor: ColorConst.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
