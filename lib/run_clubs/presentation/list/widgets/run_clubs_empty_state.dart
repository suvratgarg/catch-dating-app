import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class RunClubsEmptyState extends StatelessWidget {
  const RunClubsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 60,
        horizontal: CatchSpacing.screenH,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_outlined, size: 64, color: t.ink3),
          const SizedBox(height: 16),
          Text(
            'No run clubs in this city yet',
            style: CatchTextStyles.displaySm(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to create one!',
            style: CatchTextStyles.bodySm(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
