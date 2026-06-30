import 'dart:math' as math;

import 'package:bazzone_driver/shared/widgets/image/custom_asset_image.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final String icon;

  static const badgeSize = 28.0;
  static const radius = 20.0;
  static const gap = 4.0;
  static const fillet = 10.0;

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFFF3F4F8);

    return SizedBox(
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: _ProfileCardClipper(
              radius: radius,
              badgeSize: badgeSize,
              gap: gap,
              fillet: fillet,
            ),
            child: Container(
              width: double.infinity,
              color: cardColor,
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF8B8E99),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 16 / 13,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF141518),
                      height: 25 / 20,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: cardColor,
              ),
              child: Center(
                child: SizedBox(
                  width: badgeSize * 0.55,
                  height: badgeSize * 0.55,
                  child: CustomAssetImage(path: icon),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCardClipper extends CustomClipper<Path> {
  const _ProfileCardClipper({
    required this.radius,
    required this.badgeSize,
    required this.gap,
    required this.fillet,
  });

  final double radius;
  final double badgeSize;
  final double gap;
  final double fillet;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final rb = badgeSize / 2;
    final rcut = rb + gap;
    final rf = fillet;

    // Distances
    final distSq = (rf + rcut) * (rf + rcut) - (rcut - rf) * (rcut - rf);
    double dist = math.sqrt(math.max(0.0, distSq));

    // Safety checks to prevent the cutout from overlapping corners
    if (rb + dist > h - radius) {
      dist = math.max(0.0, h - radius - rb);
    }
    if (w - rb - dist < radius) {
      dist = math.max(0.0, w - rb - radius);
    }

    // Centers
    final cg = Offset(w - rb, rb);
    final cf1 = Offset(w - rb - dist, rf);
    final cf2 = Offset(w - rf, rb + dist);

    // Contact points
    final p1 = cf1 + (cg - cf1) * (rf / (rf + rcut));
    final p2 = cf2 + (cg - cf2) * (rf / (rf + rcut));

    final path = Path();

    // Top Left
    path.moveTo(0, radius);
    path.arcToPoint(
      Offset(radius, 0),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Top edge to first fillet
    path.lineTo(cf1.dx, 0);

    // Top fillet
    path.arcToPoint(p1, radius: Radius.circular(rf), clockwise: true);

    // Cutout
    path.arcToPoint(p2, radius: Radius.circular(rcut), clockwise: false);

    // Right fillet
    path.arcToPoint(
      Offset(w, cf2.dy),
      radius: Radius.circular(rf),
      clockwise: true,
    );

    // Right edge to bottom
    path.lineTo(w, h - radius);

    // Bottom Right
    path.arcToPoint(
      Offset(w - radius, h),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Bottom edge
    path.lineTo(radius, h);

    // Bottom Left
    path.arcToPoint(
      Offset(0, h - radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _ProfileCardClipper oldClipper) {
    return radius != oldClipper.radius ||
        badgeSize != oldClipper.badgeSize ||
        gap != oldClipper.gap ||
        fillet != oldClipper.fillet;
  }
}
