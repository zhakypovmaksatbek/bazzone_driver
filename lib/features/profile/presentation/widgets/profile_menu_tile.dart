import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/profile/domain/entities/profile_menu_item.dart';
import 'package:flutter/material.dart';

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.item,
    this.onTap,
    this.showDivider = true,
  });

  final ProfileMenuItem item;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final isTripHistory = item.type == ProfileMenuType.tripHistory;
    final isCarOrPark = item.type == ProfileMenuType.cars || item.type == ProfileMenuType.taxiPark;

    Widget content;

    if (isTripHistory) {
      // Variant 1: Left icon + bold title (inside Card 1)
      content = Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 22,
                    color: ColorConst.black,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ColorConst.black,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: ColorConst.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (isCarOrPark) {
      // Variant 2: Top label, bottom bold value, no left icon (inside Card 2)
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: ColorConst.grey.withValues(alpha: 0.9),
                        ),
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ColorConst.black,
                          ),
                        ),
                      ],
                    ],
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
    } else {
      // Variant 3: Single line title, no left icon (inside Card 3)
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
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

    if (isTripHistory) {
      return content;
    }

    return Column(
      children: [
        content,
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFFF1F1F4),
          ),
      ],
    );
  }
}
