import 'package:flutter/material.dart';

class CatchTabBarItem<T> {
  const CatchTabBarItem({
    required this.id,
    required this.icon,
    required this.label,
    this.activeIcon,
    this.iconWidget,
    this.activeIconWidget,
    this.badgeCount = 0,
    this.onLongPress,
    this.semanticValue,
    this.semanticHint,
  });

  final T id;
  final IconData icon;
  final IconData? activeIcon;
  final Widget? iconWidget;
  final Widget? activeIconWidget;
  final String label;
  final int badgeCount;
  final VoidCallback? onLongPress;
  final String? semanticValue;
  final String? semanticHint;
}
