import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/support/domain/entities/support_notification.dart';
import 'package:bazzone_driver/features/support/presentation/utils/support_formatters.dart';
import 'package:flutter/material.dart';

class SupportNotificationCard extends StatelessWidget {
  const SupportNotificationCard({
    super.key,
    required this.notification,
  });

  final SupportNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorConst.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ColorConst.black,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            notification.body,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: ColorConst.grey.withValues(alpha: 0.95),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              SupportFormatters.formatShortDate(notification.date),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: ColorConst.grey.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
