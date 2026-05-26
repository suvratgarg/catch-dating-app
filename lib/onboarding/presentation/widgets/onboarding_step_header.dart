import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class OnboardingStepHeader extends StatelessWidget {
  const OnboardingStepHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: CatchTextStyles.formQuestion(context, color: t.ink)),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          gapH8,
          Text(
            subtitle!,
            style: CatchTextStyles.bodyLead(context, color: t.ink2),
          ),
        ],
      ],
    );
  }
}
