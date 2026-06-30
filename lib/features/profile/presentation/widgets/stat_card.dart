import 'dart:math' as math;

import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = ColorConst.black,
    this.iconWidget,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Widget? iconWidget;

  static const badgeSize = 38.0;
  static const cardRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    final notchRadius = badgeSize / 2;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topRight,
      children: [
        ClipPath(
          clipper: _NotchedCardClipper(
            radius: cardRadius,
            notchRadius: notchRadius,
          ),
          child: Container(
            width: double.infinity,
            height: 96,
            color: const Color(0xFFF1F1F4),
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ColorConst.grey.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: ColorConst.black,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: _StatBadge(
            child: iconWidget ??
                Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
          ),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: StatCard.badgeSize,
      height: StatCard.badgeSize,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F4),
        shape: BoxShape.circle,
        border: Border.all(
          color: ColorConst.white,
          width: 3,
        ),
      ),
      child: Center(child: child),
    );
  }
}

class SteeringWheelIcon extends StatelessWidget {
  const SteeringWheelIcon({
    super.key,
    this.size = 18,
    this.color = ColorConst.black,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SteeringWheelPainter(color: color),
    );
  }
}

class _SteeringWheelPainter extends CustomPainter {
  _SteeringWheelPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.11
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Outer ring
    canvas.drawCircle(center, radius, stroke);

    // Center hub
    canvas.drawCircle(center, size.width * 0.15, fillPaint);

    // Spokes oriented with one pointing straight down (6 o'clock)
    for (var i = 0; i < 3; i++) {
      final angle = math.pi / 2 + i * 2 * math.pi / 3;
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, end, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _SteeringWheelPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}

class _NotchedCardClipper extends CustomClipper<Path> {
  const _NotchedCardClipper({
    required this.radius,
    required this.notchRadius,
  });

  final double radius;
  final double notchRadius;

  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Move to starting point on the left edge
    path.moveTo(0, radius);

    // Top-left corner
    path.arcToPoint(
      Offset(radius, 0),
      radius: Radius.circular(radius),
    );

    // Top edge to the start of the notch
    path.lineTo(width - notchRadius, 0);

    // Notch (concave quarter-circle curving inwards)
    path.arcToPoint(
      Offset(width, notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: true,
    );

    // Right edge to bottom-right corner
    path.lineTo(width, height - radius);

    // Bottom-right corner
    path.arcToPoint(
      Offset(width - radius, height),
      radius: Radius.circular(radius),
    );

    // Bottom edge to bottom-left corner
    path.lineTo(radius, height);

    // Bottom-left corner
    path.arcToPoint(
      Offset(0, height - radius),
      radius: Radius.circular(radius),
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _NotchedCardClipper oldClipper) {
    return radius != oldClipper.radius || notchRadius != oldClipper.notchRadius;
  }
}
