import 'package:flutter/material.dart';

enum DriverWorkStatus {
  offline,
  online,
  restricted;

  Color get markerColor {
    return switch (this) {
      DriverWorkStatus.offline => const Color(0xFF8E8E93), // Grey
      DriverWorkStatus.online => const Color(0xFFFFCC00),  // Yellow
      DriverWorkStatus.restricted => const Color(0xFFFF3B30), // Red
    };
  }
}
