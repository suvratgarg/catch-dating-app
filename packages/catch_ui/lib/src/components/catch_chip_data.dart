import 'package:flutter/material.dart';

/// Caller-resolved content and pigments for the chip's soft and solid recipes.
/// The shared rendering contract does not interpret an activity or feature model.
@immutable
class CatchChipData {
  const CatchChipData({
    required this.label,
    required this.icon,
    required this.accent,
    required this.deep,
    required this.soft,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final Color deep;
  final Color soft;
}
