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
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ColorConst.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: ColorConst.white,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CustomAssetImage(path: path),
            ),
          ),
        ),
      ),
    );
  }
}
