import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_order_collapsed_panel.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/order_detail_body.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:bazzone_driver/shared/widgets/buttons/swipe_action_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomeOrderOfferPanel extends StatefulWidget {
  const HomeOrderOfferPanel({
    super.key,
    required this.order,
    required this.isExpanded,
    required this.isLoading,
    this.onAccept,
    this.onDecline,
    this.onExpandTap,
  });

  final Order order;
  final bool isExpanded;
  final bool isLoading;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onExpandTap;

  @override
  State<HomeOrderOfferPanel> createState() => _HomeOrderOfferPanelState();
}

class _HomeOrderOfferPanelState extends State<HomeOrderOfferPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _countdownController;
  bool _declined = false;

  @override
  void initState() {
    super.initState();
    _countdownController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.order.offerTimeoutSeconds),
    )..addStatusListener(_onCountdownStatus);

    if (!widget.isLoading) {
      _countdownController.forward();
    }
  }

  @override
  void didUpdateWidget(HomeOrderOfferPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && _countdownController.isAnimating) {
      _countdownController.stop();
    }
  }

  void _onCountdownStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_declined && mounted) {
      _declined = true;
      widget.onDecline?.call();
    }
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  int get _remainingSeconds {
    final remaining = (1 - _countdownController.value) *
        widget.order.offerTimeoutSeconds;
    return remaining.ceil().clamp(0, widget.order.offerTimeoutSeconds);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isExpanded) {
      return HomeOrderCollapsedPanel(
        order: widget.order,
        statusLabel: LocaleKeys.home_page_new_order.tr(),
        statusColor: ColorConst.error,
        onTap: widget.onExpandTap,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OfferStatusHeader(
          price: widget.order.price,
          remainingSeconds: _remainingSeconds,
          countdownController: _countdownController,
          isExpanded: widget.isExpanded,
          onExpandTap: widget.onExpandTap,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OrderRouteColumn(
            pickup: widget.order.pickupAddress,
            destination: widget.order.destinationAddress,
            pickupDistanceKm: widget.order.distanceToClientKm,
            destinationDistanceKm: widget.order.distanceToPointKm,
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: widget.isExpanded
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: OrderCustomerRow(
                        customerName: widget.order.customerName,
                        rating: widget.order.customerRating,
                        tags: widget.order.commentTags,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: SwipeActionButton(
                        label: LocaleKeys.home_page_accept_order.tr(),
                        isLoading: widget.isLoading,
                        onConfirmed: widget.onAccept ?? () {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextButton(
                        onPressed: widget.isLoading ? null : widget.onDecline,
                        style: TextButton.styleFrom(
                          foregroundColor: ColorConst.error,
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: Text(
                          LocaleKeys.home_page_decline.tr(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }
}

class _OfferStatusHeader extends StatelessWidget {
  const _OfferStatusHeader({
    required this.price,
    required this.remainingSeconds,
    required this.countdownController,
    required this.isExpanded,
    this.onExpandTap,
  });

  final String price;
  final int remainingSeconds;
  final AnimationController countdownController;
  final bool isExpanded;
  final VoidCallback? onExpandTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: ColorConst.error.withValues(alpha: 0.9),
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              LocaleKeys.home_page_new_order.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorConst.black,
              ),
            ),
          ),
          if (isExpanded)
            _OfferCountdownRing(
              controller: countdownController,
              remainingSeconds: remainingSeconds,
            )
          else ...[
            Text(
              price,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ColorConst.black,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_up,
              color: ColorConst.grey.withValues(alpha: 0.6),
            ),
          ],
        ],
      ),
    );

    if (isExpanded) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onExpandTap,
        borderRadius: BorderRadius.circular(14),
        child: content,
      ),
    );
  }
}

class _OfferCountdownRing extends StatelessWidget {
  const _OfferCountdownRing({
    required this.controller,
    required this.remainingSeconds,
  });

  final AnimationController controller;
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _CountdownRingPainter(progress: 1 - controller.value),
            child: Center(
              child: Text(
                LocaleKeys.home_page_seconds_short.tr(
                  args: [remainingSeconds.toString()],
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  const _CountdownRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const strokeWidth = 3.0;

    final trackPaint = Paint()
      ..color = ColorConst.lightGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = ColorConst.error
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2,
      2 * 3.141592653589793 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CountdownRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
