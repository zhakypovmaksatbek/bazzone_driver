import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/profile/domain/entities/driver_car.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ProfileCarCard extends StatelessWidget {
  const ProfileCarCard({
    super.key,
    required this.car,
  });

  final DriverCar car;

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
            car.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ColorConst.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            car.subtitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: ColorConst.grey.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: car.imageUrl != null
                  ? Image.network(car.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: ColorConst.lightGrey,
                      child: Icon(
                        Icons.directions_car_filled_rounded,
                        size: 64,
                        color: ColorConst.grey.withValues(alpha: 0.35),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(label: car.colorLabel),
              const SizedBox(width: 8),
              _InfoChip(label: car.plateNumber),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: LocaleKeys.profile_cars_page_registration_certificate.tr(),
            value: car.registrationCertificate,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: LocaleKeys.profile_cars_page_vin_or_state_number.tr(),
            value: car.vinOrStateNumber,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ColorConst.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ColorConst.black,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: ColorConst.grey.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ColorConst.black,
          ),
        ),
      ],
    );
  }
}
