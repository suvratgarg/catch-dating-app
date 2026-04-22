import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Uppercase tiny pill used to describe a run's vibe or club character.
///
/// Renders with [CatchTokens.primarySoft] background and [CatchTokens.primary]
/// text, 11 px Inter semibold, 0.5 letter spacing.
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

  /// When true (default) uses primarySoft/primary colours.
  /// When false uses raised/ink3 — for inactive filter chips.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? t.primarySoft : t.raised,
        borderRadius: BorderRadius.circular(CatchRadius.button),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: active ? t.primary : t.ink3,
          height: 1.2,
        ),
      ),
    );
  }
}
