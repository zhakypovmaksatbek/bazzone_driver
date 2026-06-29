import 'package:bazzone_driver/shared/widgets/image/caсhed_image.dart';
import 'package:flutter/material.dart';

class UserAvatarWidget extends StatelessWidget {
  const UserAvatarWidget({
    super.key,
    this.imageUrl,
    required this.userName,
    this.size = UserAvatarSize.large,
  });
  final String? imageUrl;
  final String userName;
  final UserAvatarSize size;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipOval(
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: size.size,
        height: size.size,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
        ),
        child: _buildAvatarImage(theme),
      ),
    );
  }

  Widget _buildAvatarImage(ThemeData theme) {
    if (imageUrl?.isNotEmpty ?? false) {
      return CachedImage(
        imageUrl: imageUrl!,
        errorWidget: _buildPlaceholder(theme),
        fit: BoxFit.cover,
      );
    } else {
      return _buildPlaceholder(theme);
    }
  }

  Widget _buildPlaceholder(ThemeData theme) {
    final firstLetter = (userName.isNotEmpty) ? userName[0].toUpperCase() : "";
    return Center(
      child: Text(
        firstLetter,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: size.fontSize,
          fontWeight: FontWeight.w900,
          color: theme.disabledColor,
        ),
      ),
    );
  }
}

/// User avatar size enum
/// small avatar size 28 font size 16
/// medium avatar size 48 font size 24
/// medium large avatar size 64 font size 28.8
/// large avatar size 120 font size 54

enum UserAvatarSize {
  /// small avatar size 28 font size 16
  small(28, 16),

  /// medium avatar size 48 font size 24
  medium(48, 24),

  /// medium large avatar size 64 font size 28.8
  mediumLarge(64, 28.8),

  /// large avatar size 120 font size 54
  large(120, 54);

  final double size;
  final double fontSize;

  const UserAvatarSize(this.size, this.fontSize);
}
