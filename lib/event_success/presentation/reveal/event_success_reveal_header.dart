import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class EventSuccessRevealHeader extends StatelessWidget {
  const EventSuccessRevealHeader({
    super.key,
    required this.headline,
    required this.body,
  });

  final String headline;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headline,
          style: CatchTextStyles.titleL(context, color: t.surface),
        ),
        gapH6,
        Text(
          body,
          style: CatchTextStyles.supporting(
            context,
            color: t.surface.withValues(
              alpha: CatchOpacity.revealMutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}
