import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:flutter/material.dart';

/// Uppercase tiny badge used to describe a run's vibe or club character.
///
/// Delegates to [CatchBadge] so metadata tags share the same tone scale as
/// status badges.
///
/// Usage:
/// ```dart
/// VibeTag(label: 'Easy Pace')
/// VibeTag(label: 'Social', active: false) // ink2 text variant
/// ```
class VibeTag extends StatelessWidget {
  const VibeTag({super.key, required this.label, this.active = true});

  /// The display text — rendered uppercase automatically.
  final String label;

  /// When true (default) uses the brand badge tone.
  /// When false uses the neutral badge tone.
  final bool active;

  @override
  Widget build(BuildContext context) {
    return CatchBadge(
      label: label,
      tone: active ? CatchBadgeTone.brand : CatchBadgeTone.neutral,
      uppercase: true,
    );
  }
}
