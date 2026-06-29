import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Professional user avatar widget for comments
/// Supports network images with fallback to initials
class CommentUserAvatar extends StatelessWidget {
  /// User's avatar image URL (can be null)
  final String? imageUrl;

  /// User's display name for fallback initials
  final String userName;

  /// Avatar radius size
  final double radius;

  /// Background color for fallback avatar
  final Color? backgroundColor;

  /// Text color for initials
  final Color? textColor;

  /// Font size for initials text
  final double? fontSize;

  const CommentUserAvatar({
    super.key,
    this.imageUrl,
    required this.userName,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  /// Factory constructor for small avatars (replies)
  factory CommentUserAvatar.small({
    Key? key,
    String? imageUrl,
    required String userName,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return CommentUserAvatar(
      key: key,
      imageUrl: imageUrl,
      userName: userName,
      radius: 16,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 12,
    );
  }

  /// Factory constructor for medium avatars (main comments)
  factory CommentUserAvatar.medium({
    Key? key,
    String? imageUrl,
    required String userName,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return CommentUserAvatar(
      key: key,
      imageUrl: imageUrl,
      userName: userName,
      radius: 20,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 14,
    );
  }

  /// Factory constructor for large avatars
  factory CommentUserAvatar.large({
    Key? key,
    String? imageUrl,
    required String userName,
    Color? backgroundColor,
    Color? textColor,
    double? radius,
    double? fontSize,
  }) {
    return CommentUserAvatar(
      key: key,
      imageUrl: imageUrl,
      userName: userName,
      radius: radius ?? 24,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize ?? 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? ColorConst.lightGrey,
      child: _buildAvatarContent(theme),
    );
  }

  /// Build avatar content (image or initials)
  Widget _buildAvatarContent(ThemeData theme) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildNetworkImage(theme);
    } else {
      return _buildInitialsText(theme);
    }
  }

  /// Build network image with caching and error handling
  Widget _buildNetworkImage(ThemeData theme) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingIndicator(),
        errorWidget: (context, url, error) => _buildErrorFallback(theme),
      ),
    );
  }

  /// Build loading indicator for image loading state
  Widget _buildLoadingIndicator() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: ColorConst.lightGrey.withValues(alpha: 0.2),
      child: Center(
        child: SizedBox(
          width: radius * 0.6,
          height: radius * 0.6,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              ColorConst.primary.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }

  /// Build error fallback (shows initials)
  Widget _buildErrorFallback(ThemeData theme) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? theme.inputDecorationTheme.fillColor,
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: radius * 0.8,
          color: textColor ?? theme.disabledColor.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  /// Build initials text when no image is available
  Widget _buildInitialsText(ThemeData theme) {
    final initials = _getInitials(userName);

    return Text(
      initials,
      style:
          theme.textTheme.bodyLarge?.copyWith(
            fontSize: fontSize ?? _getDefaultFontSize(),
            fontWeight: FontWeight.w900,
            color: textColor ?? theme.disabledColor,
          ) ??
          TextStyle(
            fontSize: fontSize ?? _getDefaultFontSize(),
            fontWeight: FontWeight.w900,
            color: textColor ?? theme.disabledColor,
          ),
    );
  }

  /// Extract initials from user name
  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'
          .toUpperCase();
    }
  }

  /// Get default font size based on radius
  double _getDefaultFontSize() {
    if (radius <= 16) return 11;
    if (radius <= 20) return 13;
    if (radius <= 24) return 15;
    return 17;
  }
}
