// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_dynamic_calls
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomAssetImage extends StatelessWidget {
  const CustomAssetImage({
    super.key,
    this.fit,
    this.borderRadius,
    this.height,
    this.width,
    required this.path,
    this.color,
  });

  final BoxFit? fit;
  final BorderRadiusGeometry? borderRadius;
  final double? height;
  final double? width;
  final String path;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isSvg = path.endsWith(".svg");

    Widget imageWidget = isSvg
        ? SvgPicture.asset(
            path,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
            fit: fit ?? BoxFit.contain,
            height: height,
            width: width,
            allowDrawingOutsideViewBox: false,
          )
        : Image.asset(
            path,
            fit: fit ?? BoxFit.contain,
            height: height,
            width: width,
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }
}
