import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Thin animated progress bar used in the onboarding flow and Create Run
/// stepper. Mirrors the `Progress` primitive in primitives.jsx.
///
/// [value] is 0.0–1.0.
///
/// Usage:
/// ```dart
/// CatchProgressBar(value: 2 / 7)   // step 2 of 7 onboarding
/// CatchProgressBar(value: 0.5)
/// ```
class CatchProgressBar extends StatelessWidget {
  const CatchProgressBar({super.key, required this.value});

  /// Progress fraction, clamped to [0, 1].
  final double value;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Container(
          height: 4,
          decoration: BoxDecoration(
            color: t.line2,
            borderRadius: BorderRadius.circular(CatchRadius.button),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: (value.clamp(0.0, 1.0) * width).toDouble(),
              height: 4,
              decoration: BoxDecoration(
                color: t.primary,
                borderRadius: BorderRadius.circular(CatchRadius.button),
              ),
            ),
          ),
        );
      },
    );
  }
}
