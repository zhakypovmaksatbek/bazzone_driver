import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:bazzone_driver/shared/widgets/image/user_avatar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomeDriverPanel extends StatelessWidget {
  const HomeDriverPanel({
    super.key,
    required this.driverName,
    required this.dateLabel,
    required this.earnings,
    required this.ordersCount,
    required this.isOnline,
    this.isLoading = false,
    this.avatarUrl,
    this.onProfileTap,
    this.onStartWork,
    this.onFinishWork,
  });

  final String driverName;
  final String dateLabel;
  final String earnings;
  final int ordersCount;
  final bool isOnline;
  final bool isLoading;
  final String? avatarUrl;
  final VoidCallback? onProfileTap;
  final VoidCallback? onStartWork;
  final VoidCallback? onFinishWork;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  UserAvatarWidget(
                    userName: driverName,
                    imageUrl: avatarUrl,
                    size: UserAvatarSize.medium,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: ColorConst.grey.withValues(alpha: 0.9),
                          ),
                        ),
                        Text(
                          driverName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ColorConst.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: ColorConst.lightGrey),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        earnings,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ColorConst.black,
                        ),
                      ),
                      Text(
                        LocaleKeys.home_page_orders_count.tr(
                          args: [ordersCount.toString()],
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: ColorConst.grey.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: ColorConst.grey.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: isOnline
              ? _FinishWorkButton(isLoading: isLoading, onPressed: onFinishWork)
              : _StartWorkButton(isLoading: isLoading, onPressed: onStartWork),
        ),
      ],
    );
  }
}

class _StartWorkButton extends StatelessWidget {
  const _StartWorkButton({this.isLoading = false, this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: ColorConst.primary,
          foregroundColor: ColorConst.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      LocaleKeys.home_page_start_work.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_double_arrow_right, size: 22),
                ],
              ),
      ),
    );
  }
}

class _FinishWorkButton extends StatelessWidget {
  const _FinishWorkButton({this.isLoading = false, this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: ColorConst.lightGrey,
          foregroundColor: ColorConst.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      LocaleKeys.home_page_finish_work.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.close,
                    size: 20,
                    color: ColorConst.grey.withValues(alpha: 0.8),
                  ),
                ],
              ),
      ),
    );
  }
}
