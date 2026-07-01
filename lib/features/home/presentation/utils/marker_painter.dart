import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerPainter {
  static Future<BitmapDescriptor> getNavigationArrow({
    double size = 120.0,
    required Color color,
  }) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    
    // Scale canvas matrix so coordinates are drawn relative to 120x120 reference
    final scale = size / 120.0;
    canvas.scale(scale, scale);

    // Dynamic HSL lightness modifications for 3D crease effect
    final hsl = HSLColor.fromColor(color);
    final leftColor = hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0)).toColor();
    final rightColor = hsl.withLightness((hsl.lightness - 0.08).clamp(0.0, 1.0)).toColor();

    // Outline paint (white border)
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Paint left side (lighter shading)
    final leftPaint = Paint()
      ..color = leftColor
      ..style = PaintingStyle.fill;

    // Paint right side (darker shading)
    final rightPaint = Paint()
      ..color = rightColor
      ..style = PaintingStyle.fill;

    // Outer white path (outline)
    final outlinePath = Path()
      ..moveTo(60, 10)  // Tip
      ..lineTo(20, 105) // Bottom left wing
      ..lineTo(60, 85)  // Inner crease bottom
      ..lineTo(100, 105)// Bottom right wing
      ..close();

    // Left path
    final leftPath = Path()
      ..moveTo(60, 16)  // Tip
      ..lineTo(26, 98)  // Bottom left wing
      ..lineTo(60, 80)  // Inner crease
      ..close();

    // Right path
    final rightPath = Path()
      ..moveTo(60, 16)  // Tip
      ..lineTo(94, 98)  // Bottom right wing
      ..lineTo(60, 80)  // Inner crease
      ..close();

    // Draw outline border
    canvas.drawPath(outlinePath, outlinePaint);
    // Draw left and right shaded halves
    canvas.drawPath(leftPath, leftPaint);
    canvas.drawPath(rightPath, rightPaint);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes);
  }
}
