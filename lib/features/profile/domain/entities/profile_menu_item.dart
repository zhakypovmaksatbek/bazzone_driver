import 'package:flutter/material.dart';

enum ProfileMenuType {
  tripHistory,
  cars,
  taxiPark,
  carDiagnostics,
  photoDiagnostics,
  tariffs,
}

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.type,
    required this.title,
    this.subtitle,
    required this.icon,
  });

  final ProfileMenuType type;
  final String title;
  final String? subtitle;
  final IconData icon;
}
