import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class ProfilePromptCard extends StatelessWidget {
  const ProfilePromptCard({
    super.key,
    required this.eyebrow,
    required this.text,
    this.isPrompt = false,
    this.onTap,
  });

  final String eyebrow;
  final String text;
  final bool isPrompt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final content = Padding(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow, style: CatchTextStyles.bodyS(context, color: t.ink2)),
          gapH4,
          Text(
            text,
            style: CatchTextStyles.bodyL(
              context,
              color: isPrompt ? t.ink3 : null,
            ),
          ),
        ],
      ),
    );

    return CatchSurface(
      borderColor: t.line,
      child: onTap == null
          ? content
          : Semantics(
              button: true,
              label: eyebrow,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(CatchRadius.lg),
                child: content,
              ),
            ),
    );
  }
}
