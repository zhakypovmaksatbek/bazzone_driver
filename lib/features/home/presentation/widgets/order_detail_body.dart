import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:bazzone_driver/shared/widgets/image/user_avatar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OrderDetailBody extends StatelessWidget {
  const OrderDetailBody({
    super.key,
    required this.order,
    this.showComments = true,
  });

  final Order order;
  final bool showComments;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OrderRouteRow(
            pickup: order.pickupAddress,
            destination: order.destinationAddress,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            order.price,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: ColorConst.black,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            order.description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: ColorConst.grey.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OrderInfoCards(order: order),
        ),
        if (showComments && order.commentTags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OrderCommentTags(tags: order.commentTags),
          ),
        ],
      ],
    );
  }
}

class OrderRouteRow extends StatelessWidget {
  const OrderRouteRow({
    super.key,
    required this.pickup,
    required this.destination,
  });

  final String pickup;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            pickup,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorConst.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ColorConst.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.swap_vert, size: 20, color: ColorConst.black),
          ),
        ),
        Expanded(
          child: Text(
            destination,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorConst.black,
            ),
          ),
        ),
      ],
    );
  }
}

class OrderInfoCards extends StatelessWidget {
  const OrderInfoCards({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OrderInfoCard(
            title: LocaleKeys.home_page_distance_to_client.tr(),
            value: LocaleKeys.home_page_km.tr(
              args: [order.distanceToClientKm.toString()],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OrderInfoCard(
            title: LocaleKeys.home_page_distance_to_point.tr(),
            value: LocaleKeys.home_page_km.tr(
              args: [order.distanceToPointKm.toString()],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OrderInfoCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UserAvatarWidget(
                  userName: order.customerName,
                  imageUrl: order.customerAvatarUrl,
                  size: UserAvatarSize.small,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                    const SizedBox(width: 4),
                    Text(
                      order.customerRating.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ColorConst.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class OrderInfoCard extends StatelessWidget {
  const OrderInfoCard({super.key, this.title, this.value, this.child})
      : assert(
          (title != null && value != null) || child != null,
          'Provide title/value or child',
        );

  final String? title;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: ColorConst.lightGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child ??
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: ColorConst.grey.withValues(alpha: 0.9),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.black,
                ),
              ),
            ],
          ),
    );
  }
}

class OrderCommentTags extends StatelessWidget {
  const OrderCommentTags({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: ColorConst.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.chat_bubble_outline,
            size: 18,
            color: ColorConst.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ColorConst.lightGrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ColorConst.grey.withValues(alpha: 0.95),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
