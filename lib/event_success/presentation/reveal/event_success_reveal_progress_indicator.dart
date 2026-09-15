import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

class EventSuccessRevealProgressIndicator extends StatelessWidget {
  const EventSuccessRevealProgressIndicator({
    super.key,
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(CatchRadius.pill),
      child: LinearProgressIndicator(
        minHeight: 7,
        value: progress.clamp(0, 1).toDouble(),
        backgroundColor: t.surface.withValues(alpha: CatchOpacity.warningFill),
        valueColor: AlwaysStoppedAnimation<Color>(t.gold),
      ),
    );
  }
}
