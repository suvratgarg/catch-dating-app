import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

class CatchFormFieldOptionalBadge extends StatelessWidget {
  const CatchFormFieldOptionalBadge({
    super.key,
    required this.label,
    this.hasError = false,
  });

  final String label;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = hasError ? t.danger : t.ink3;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.micro6,
        vertical: CatchSpacing.micro2,
      ),
      decoration: BoxDecoration(
        color: hasError
            ? t.danger.withValues(alpha: CatchOpacity.controlOverlayPressed)
            : t.raised,
        borderRadius: BorderRadius.circular(CatchRadius.sm),
      ),
      child: Text(
        label,
        style: CatchTextStyles.supporting(
          context,
          color: color,
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
