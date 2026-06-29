import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/shared/widgets/image/custom_asset_image.dart';
import 'package:flutter/material.dart';

class MapOverlayButton extends StatelessWidget {
  const MapOverlayButton({
    super.key,
    required this.path,
    this.onPressed,
    this.size = 48,
  });

  final String path;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ColorConst.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ColorConst.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomAssetImage(path: path),
        ),
      ),
    );
  }
}
