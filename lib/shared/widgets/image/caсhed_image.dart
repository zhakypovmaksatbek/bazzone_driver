import 'package:bazzone_driver/core/constants/asset_const.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/core/utils/app_debug_log.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CachedImage extends StatelessWidget {
  static const _placeholderPalette = <Color>[
    ColorConst.primary,
    ColorConst.grey,
  ];

  static Color _placeholderColorFor(String url) {
    final index = url.hashCode.abs() % _placeholderPalette.length;
    return _placeholderPalette[index].withValues(alpha: 0.3);
  }

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.localImage,
    this.width,
    this.height,
    this.fit,
    this.imageRadius,
    this.borderRadius,
    this.isUser = false,
    this.errorWidget,
  });
  final String imageUrl;
  final String? localImage;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final double? imageRadius;
  final BorderRadiusGeometry? borderRadius;
  final bool isUser;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveFit = fit ?? BoxFit.cover;
    final isSvg = imageUrl.toLowerCase().endsWith('.svg');
    const errorAssetSize = 43.5;

    Widget buildFallback() {
      if (!isUser) {
        return ColoredBox(color: _placeholderColorFor(imageUrl));
      }

      return Container(
        decoration: BoxDecoration(
          color: ColorConst.primary.withValues(alpha: 0.3),
        ),
        child: Center(
          child: SizedBox(
            width: errorAssetSize,
            height: errorAssetSize,
            child: Image.asset(
              localImage ?? AssetConst.logo,
              width: errorAssetSize,
              height: errorAssetSize,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
        ),
      );
    }

    Widget buildPlaceholder() {
      return SizedBox(
        width: width,
        height: height,
        child: Center(
          child: LoadingAnimationWidget.flickr(
            size: 40,
            leftDotColor: ColorConst.grey,
            rightDotColor: ColorConst.primary,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(imageRadius ?? 0),
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              fit: effectiveFit,
              imageUrl: imageUrl,
              height: height,
              alignment: Alignment.center,
              width: width,
              placeholder: (context, url) => buildPlaceholder(),
              errorListener: (value) {
                appDebugLog('Error loading image: $value');
              },
              filterQuality: FilterQuality.low,
              fadeOutDuration: const Duration(milliseconds: 300),
              fadeInDuration: const Duration(milliseconds: 300),
              errorWidget: (context, url, error) =>
                  errorWidget ?? buildFallback(),
            )
          : buildFallback(),
    );
  }
}

class CustomSvgImage extends StatelessWidget {
  const CustomSvgImage({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      imageUrl,
      placeholderBuilder: (context) => LoadingAnimationWidget.flickr(
        size: 20,
        leftDotColor: ColorConst.grey,
        rightDotColor: ColorConst.primary,
      ),
      errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
    );
  }
}
