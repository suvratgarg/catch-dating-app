import 'package:flutter/material.dart';

@immutable
class CatchBannerAction {
  const CatchBannerAction({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  /// Visible copy for a text action; accessible tooltip for an icon action.
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
}
