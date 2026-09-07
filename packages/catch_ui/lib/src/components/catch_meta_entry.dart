import 'package:flutter/material.dart';

class CatchMetaEntry {
  const CatchMetaEntry({
    required this.label,
    this.icon,
    this.iconColor,
    this.color,
  });

  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Color? color;
}
