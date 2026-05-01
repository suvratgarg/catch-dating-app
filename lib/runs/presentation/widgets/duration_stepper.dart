import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class DurationStepper extends StatelessWidget {
  const DurationStepper({
    super.key,
    required this.minutes,
    required this.onDecrease,
    required this.onIncrease,
    required this.formatDuration,
  });

  final int minutes;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final String Function(int) formatDuration;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      tone: CatchSurfaceTone.raised,
      radius: CatchRadius.md,
      borderColor: t.line,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.remove_rounded, color: t.ink),
            onPressed: onDecrease,
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Center(
              child: Text(
                formatDuration(minutes),
                style: CatchTextStyles.mono(context),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_rounded, color: t.ink),
            onPressed: onIncrease,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
