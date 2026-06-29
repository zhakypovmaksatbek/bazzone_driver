import 'dart:async';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_order_collapsed_panel.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:bazzone_driver/shared/widgets/buttons/swipe_action_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomeActiveOrderPanel extends StatefulWidget {
  const HomeActiveOrderPanel({
    super.key,
    required this.order,
    required this.isExpanded,
    required this.isLoading,
    this.onArrived,
    this.onComplete,
    this.onExpandTap,
    this.onWaitingStateChanged,
  });

  final Order order;
  final bool isExpanded;
  final bool isLoading;
  final VoidCallback? onArrived;
  final VoidCallback? onComplete;
  final VoidCallback? onExpandTap;
  final ValueChanged<bool>? onWaitingStateChanged;

  @override
  State<HomeActiveOrderPanel> createState() => _HomeActiveOrderPanelState();
}

class _HomeActiveOrderPanelState extends State<HomeActiveOrderPanel> {
  Timer? _timer;
  int _freeSecondsLeft = 10; // 10 seconds for mock demo (normally 180)
  int _paidSecondsElapsed = 0;
  bool _isPaidWaiting = false;
  int _selectedRating = 4; // Default rating for review screen

  @override
  void initState() {
    super.initState();
    _checkTimer();
  }

  @override
  void didUpdateWidget(HomeActiveOrderPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.activePhase != widget.order.activePhase) {
      _checkTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkTimer() {
    _timer?.cancel();
    if (widget.order.activePhase == ActiveOrderPhase.waitingForClient) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (!_isPaidWaiting) {
          if (_freeSecondsLeft > 0) {
            setState(() {
              _freeSecondsLeft--;
            });
          } else {
            setState(() {
              _isPaidWaiting = true;
            });
            widget.onWaitingStateChanged?.call(true);
          }
        } else {
          setState(() {
            _paidSecondsElapsed++;
          });
        }
      });
    } else {
      _isPaidWaiting = false;
      _freeSecondsLeft = 10;
      _paidSecondsElapsed = 0;
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _statusLabel => switch (widget.order.activePhase) {
        ActiveOrderPhase.headingToClient => LocaleKeys.home_page_en_route_to_client.tr(),
        ActiveOrderPhase.waitingForClient => LocaleKeys.home_page_arrived_at_client.tr(),
        ActiveOrderPhase.headingToDestination => LocaleKeys.home_page_en_route_to_destination.tr(),
        ActiveOrderPhase.completed => 'Отзыв о поездке',
      };

  String get _swipeLabel => switch (widget.order.activePhase) {
        ActiveOrderPhase.headingToClient => LocaleKeys.home_page_arrived.tr(),
        ActiveOrderPhase.waitingForClient => LocaleKeys.home_page_depart.tr(),
        ActiveOrderPhase.headingToDestination => '',
        ActiveOrderPhase.completed => '',
      };

  Color get _statusColor => switch (widget.order.activePhase) {
        ActiveOrderPhase.headingToClient => ColorConst.primary,
        ActiveOrderPhase.waitingForClient => ColorConst.info,
        ActiveOrderPhase.headingToDestination => ColorConst.success,
        ActiveOrderPhase.completed => ColorConst.primary,
      };

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    // Collapsed State Router
    if (!widget.isExpanded) {
      if (order.activePhase == ActiveOrderPhase.headingToDestination) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _RouteSummaryCard(
                pickup: order.pickupAddress,
                destination: order.destinationAddress,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _TimelineProgressBarCard(),
            ),
            const SizedBox(height: 12),
          ],
        );
      }

      return HomeOrderCollapsedPanel(
        order: order,
        statusLabel: _statusLabel,
        statusColor: _statusColor,
        onTap: widget.onExpandTap,
      );
    }

    // Expanded State views per phase
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: switch (order.activePhase) {
        // Phase 1: Heading to client (point A)
        ActiveOrderPhase.headingToClient => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ActiveStatusHeader(
                label: _statusLabel,
                color: _statusColor,
                price: order.price,
                isExpanded: true,
              ),
              const SizedBox(height: 16),
              _RouteSummaryCard(
                pickup: order.pickupAddress,
                destination: order.destinationAddress,
              ),
              const SizedBox(height: 16),
              _PassengerCard(
                name: order.customerName,
                rating: order.customerRating,
                avatarUrl: order.customerAvatarUrl,
              ),
              const SizedBox(height: 20),
              SwipeActionButton(
                key: ValueKey(order.activePhase),
                label: _swipeLabel,
                isLoading: widget.isLoading,
                color: ColorConst.primary,
                onConfirmed: widget.onArrived ?? () {},
              ),
            ],
          ),

        // Phase 2: Arrived, waiting for client
        ActiveOrderPhase.waitingForClient => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WaitingTimerCard(
                isPaidWaiting: _isPaidWaiting,
                timerText: _isPaidWaiting
                    ? _formatTime(_paidSecondsElapsed)
                    : _formatTime(_freeSecondsLeft),
              ),
              const SizedBox(height: 16),
              _PickupLabelCard(pickup: '${order.pickupAddress}, TechnoPark'),
              const SizedBox(height: 16),
              _PassengerCard(
                name: order.customerName,
                rating: order.customerRating,
                avatarUrl: order.customerAvatarUrl,
              ),
              const SizedBox(height: 20),
              SwipeActionButton(
                key: ValueKey(order.activePhase),
                label: _swipeLabel,
                isLoading: widget.isLoading,
                color: ColorConst.success,
                onConfirmed: widget.onArrived ?? () {},
              ),
            ],
          ),

        // Phase 3: Heading to destination (point B)
        ActiveOrderPhase.headingToDestination => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _RouteSummaryCard(
                pickup: order.pickupAddress,
                destination: order.destinationAddress,
              ),
              const SizedBox(height: 12),
              const _TimelineProgressBarCard(),
              const SizedBox(height: 16),
              _PassengerCard(
                name: order.customerName,
                rating: order.customerRating,
                avatarUrl: order.customerAvatarUrl,
              ),
              const SizedBox(height: 16),
              _PaymentCard(price: order.price),
              const SizedBox(height: 20),
              Column(
                children: [
                  IconButton(
                    onPressed: widget.isLoading ? null : widget.onArrived,
                    icon: const Icon(Icons.close, color: ColorConst.error, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: ColorConst.error.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: widget.isLoading ? null : widget.onArrived,
                    child: const Text(
                      'Завершить поездку',
                      style: TextStyle(
                        color: ColorConst.error,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

        // Phase 4: Completed, review & tips
        ActiveOrderPhase.completed => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _statusLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ColorConst.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: order.customerAvatarUrl != null
                      ? NetworkImage(order.customerAvatarUrl!)
                      : null,
                  backgroundColor: ColorConst.lightGrey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                order.customerName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ColorConst.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              _StarRatingWidget(
                initialRating: _selectedRating,
                onRatingChanged: (val) {
                  setState(() {
                    _selectedRating = val;
                  });
                },
              ),
              const SizedBox(height: 20),
              const _DetailChipsContainer(),
              const SizedBox(height: 16),
              _RouteSummaryCard(
                pickup: order.pickupAddress,
                destination: order.destinationAddress,
              ),
              const SizedBox(height: 16),
              _PaymentCard(price: order.price, showTips: true),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: widget.isLoading ? null : widget.onComplete,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF3544F1), // The premium deep blue color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: widget.isLoading
                      ? const CircularProgressIndicator(color: ColorConst.white)
                      : const Text(
                          'Готово',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ColorConst.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
      },
    );
  }
}

// ----------------------------------------------------
// UI Helper Components
// ----------------------------------------------------

class _RouteSummaryCard extends StatelessWidget {
  const _RouteSummaryCard({
    required this.pickup,
    required this.destination,
  });

  final String pickup;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ColorConst.lightGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              pickup,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorConst.black,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ColorConst.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.swap_horiz,
              color: ColorConst.grey,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              destination,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorConst.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineProgressBarCard extends StatelessWidget {
  const _TimelineProgressBarCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConst.lightGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimelineItem('Старт', '10:20'),
              _buildTimelineItem('На дороге', '16 мин', isBold: true),
              _buildTimelineItem('Финиш', '10:40'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.65,
              backgroundColor: ColorConst.lightGrey,
              valueColor: AlwaysStoppedAnimation<Color>(ColorConst.success),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String label, String value, {bool isBold = false}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: ColorConst.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: ColorConst.black,
          ),
        ),
      ],
    );
  }
}

class _PassengerCard extends StatelessWidget {
  const _PassengerCard({
    required this.name,
    required this.rating,
    this.avatarUrl,
  });

  final String name;
  final double rating;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConst.lightGrey.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            backgroundColor: ColorConst.lightGrey,
            child: avatarUrl == null
                ? const Icon(Icons.person, color: ColorConst.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorConst.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorConst.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone_in_talk, color: ColorConst.black, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: ColorConst.lightGrey.withValues(alpha: 0.4),
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble, color: ColorConst.black, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: ColorConst.lightGrey.withValues(alpha: 0.4),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.price,
    this.showTips = false,
  });

  final String price;
  final bool showTips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ColorConst.lightGrey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, color: ColorConst.black, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  showTips ? 'Оплачено картой' : 'Оплата картой',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: ColorConst.grey,
                  ),
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ColorConst.black,
                ),
              ),
              if (showTips) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorConst.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '+50',
                    style: TextStyle(
                      color: ColorConst.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (showTips) ...[
            const SizedBox(height: 8),
            const Text(
              'Оставили чаевые',
              style: TextStyle(
                color: ColorConst.success,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ],
      ),
    );
  }
}

class _WaitingTimerCard extends StatelessWidget {
  const _WaitingTimerCard({
    required this.isPaidWaiting,
    required this.timerText,
  });

  final bool isPaidWaiting;
  final String timerText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isPaidWaiting
                ? ColorConst.lightGrey.withValues(alpha: 0.15)
                : ColorConst.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Бесплатное ожидание',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isPaidWaiting ? ColorConst.grey.withValues(alpha: 0.5) : ColorConst.primary,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: isPaidWaiting ? ColorConst.grey.withValues(alpha: 0.5) : ColorConst.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPaidWaiting ? '03:00' : timerText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isPaidWaiting ? ColorConst.grey.withValues(alpha: 0.5) : ColorConst.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isPaidWaiting) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ColorConst.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Платное ожидание',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ColorConst.white,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.pause,
                      color: ColorConst.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timerText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ColorConst.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PickupLabelCard extends StatelessWidget {
  const _PickupLabelCard({required this.pickup});

  final String pickup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConst.lightGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Подача',
            style: TextStyle(fontSize: 12, color: ColorConst.grey),
          ),
          const SizedBox(height: 6),
          Text(
            pickup,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: ColorConst.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChipsContainer extends StatelessWidget {
  const _DetailChipsContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConst.lightGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem('Дорога', '4 км'),
          Container(width: 1, height: 36, color: ColorConst.grey.withValues(alpha: 0.3)),
          _buildItem('На дороге', '20 мин'),
          Container(width: 1, height: 36, color: ColorConst.grey.withValues(alpha: 0.3)),
          _buildItem('Прибытие', '10:40'),
        ],
      ),
    );
  }

  Widget _buildItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: ColorConst.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: ColorConst.black,
          ),
        ),
      ],
    );
  }
}

class _StarRatingWidget extends StatefulWidget {
  const _StarRatingWidget({
    required this.initialRating,
    required this.onRatingChanged,
  });

  final int initialRating;
  final ValueChanged<int> onRatingChanged;

  @override
  State<_StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<_StarRatingWidget> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= _rating;
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = starIndex;
            });
            widget.onRatingChanged(starIndex);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              Icons.star,
              color: isFilled ? const Color(0xFFFFCC00) : Colors.grey[300],
              size: 40,
            ),
          ),
        );
      }),
    );
  }
}

class _ActiveStatusHeader extends StatelessWidget {
  const _ActiveStatusHeader({
    required this.label,
    required this.color,
    required this.price,
    required this.isExpanded,
  });

  final String label;
  final Color color;
  final String price;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
