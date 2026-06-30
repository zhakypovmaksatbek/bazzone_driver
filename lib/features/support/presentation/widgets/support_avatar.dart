import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:flutter/material.dart';

class SupportAvatar extends StatelessWidget {
  const SupportAvatar({
    super.key,
    this.size = 44,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: ColorConst.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.support_agent_rounded,
        size: size * 0.5,
        color: ColorConst.white,
      ),
    );
  }
}
