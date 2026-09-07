import 'package:flutter/material.dart';

enum CatchMenuItemRole { action, choice }

class CatchMenuItem<T> {
  const CatchMenuItem({
    required this.value,
    required this.label,
    this.sublabel,
    this.icon,
    this.selected = false,
    this.danger = false,
    this.enabled = true,
    this.role = CatchMenuItemRole.action,
    this.startsSection = false,
    this.onSelected,
  }) : assert(
         !selected || role == CatchMenuItemRole.choice,
         'Only choice rows can be selected.',
       );

  final T value;
  final String label;
  final String? sublabel;
  final IconData? icon;
  final bool selected;
  final bool danger;
  final bool enabled;
  final CatchMenuItemRole role;
  final bool startsSection;
  final ValueChanged<T>? onSelected;
}
