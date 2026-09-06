import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchJourneyStepNode extends StatelessWidget {
  const CatchJourneyStepNode({super.key, this.accent});

  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      width: CatchLayout.journeyStepsNodeExtent,
      height: CatchLayout.journeyStepsNodeExtent,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: t.bg,
        border: Border.all(
          color: accent ?? t.primary,
          width: CatchStroke.avatarRing,
        ),
      ),
    );
  }
}
