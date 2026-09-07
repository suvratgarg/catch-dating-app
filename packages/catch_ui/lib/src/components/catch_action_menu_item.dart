import 'package:flutter/material.dart';

class CatchActionMenuItem<T> {
  const CatchActionMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.sublabel,
    this.enabled = true,
    this.isDestructive = false,
  });

  final T value;
  final String label;
  final IconData? icon;
  final String? sublabel;
  final bool enabled;
  final bool isDestructive;
}
