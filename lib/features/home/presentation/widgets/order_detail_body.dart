import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
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
          child: OrderRouteColumn(
            pickup: order.pickupAddress,
            destination: order.destinationAddress,
            pickupDistanceKm: order.distanceToClientKm,
            destinationDistanceKm: order.distanceToPointKm,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OrderCustomerRow(
            customerName: order.customerName,
            rating: order.customerRating,
            tags: showComments ? order.commentTags : const [],
          ),
        ),
      ],
    );
  }
}

class OrderRouteColumn extends StatelessWidget {
  const OrderRouteColumn({
    super.key,
    required this.pickup,
    required this.destination,
    required this.pickupDistanceKm,
    required this.destinationDistanceKm,
  });

  final String pickup;
  final String destination;
  final double pickupDistanceKm;
  final double destinationDistanceKm;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              _RouteMarker(label: LocaleKeys.home_page_pickup_point.tr()),
              Expanded(
                child: Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: ColorConst.primary.withValues(alpha: 0.35),
                ),
              ),
              _RouteMarker(label: LocaleKeys.home_page_destination_point.tr()),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RouteStopRow(
                  address: pickup,
                  distanceKm: pickupDistanceKm,
                ),
                const SizedBox(height: 20),
                _RouteStopRow(
                  address: destination,
                  distanceKm: destinationDistanceKm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteMarker extends StatelessWidget {
  const _RouteMarker({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ColorConst.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ColorConst.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteStopRow extends StatelessWidget {
  const _RouteStopRow({
    required this.address,
    required this.distanceKm,
  });

  final String address;
  final double distanceKm;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorConst.black,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _DistanceBadge(km: distanceKm),
      ],
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  const _DistanceBadge({required this.km});

  final double km;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorConst.lightGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        LocaleKeys.home_page_km.tr(args: [km.toString()]),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: ColorConst.grey.withValues(alpha: 0.95),
        ),
      ),
    );
  }
}

class OrderCustomerRow extends StatelessWidget {
  const OrderCustomerRow({
    super.key,
    required this.customerName,
    required this.rating,
    required this.tags,
  });

  final String customerName;
  final double rating;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 16, color: ColorConst.primary),
            const SizedBox(width: 4),
            Text(
              rating.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ColorConst.black,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            customerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorConst.black,
            ),
          ),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: [
                for (final tag in tags.take(2))
                  Chip(
                    label: Text(tag),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ColorConst.grey.withValues(alpha: 0.95),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: ColorConst.lightGrey,
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
