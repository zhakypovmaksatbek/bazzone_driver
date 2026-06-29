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
                  Container(
                    width: 1,
                    height: 40,
                    color: ColorConst.lightGrey,
                  ),
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
        if (isOnline) const _SearchingIndicator(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: isOnline
              ? _FinishWorkButton(
                  isLoading: isLoading,
                  onPressed: onFinishWork,
                )
              : _StartWorkButton(
                  isLoading: isLoading,
                  onPressed: onStartWork,
                ),
        ),
      ],
    );
  }
}

/// Sürücü çevrimiçiyken ve elinde sipariş yokken gösterilen "aranıyor"
/// göstergesi. Nabız animasyonu, sürücüye sistemin aktif olarak sipariş
/// aradığını hissettirir.
class _SearchingIndicator extends StatefulWidget {
  const _SearchingIndicator();

  @override
  State<_SearchingIndicator> createState() => _SearchingIndicatorState();
}

class _SearchingIndicatorState extends State<_SearchingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: ColorConst.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _PulseRing(progress: _controller.value),
                    const _PulseDot(),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.home_page_searching_orders.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ColorConst.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  LocaleKeys.home_page_searching_orders_hint.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: ColorConst.grey.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final scale = 0.4 + progress * 0.6;
    final opacity = (1 - progress).clamp(0, 1).toDouble();
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: ColorConst.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(
        color: ColorConst.primary,
        shape: BoxShape.circle,
      ),
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
