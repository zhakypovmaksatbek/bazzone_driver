import 'package:flutter/material.dart';

class ProfileNewsItem {
  const ProfileNewsItem({
    required this.id,
    required this.title,
    required this.backgroundColor,
    this.imageAsset,
  });

  final String id;
  final String title;
  final Color backgroundColor;
  final String? imageAsset;
}
