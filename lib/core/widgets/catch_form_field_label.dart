import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class CatchFormFieldLabel extends StatelessWidget {
  const CatchFormFieldLabel({
    super.key,
    required this.label,
    this.isOptional = false,
    this.hasError = false,
    this.large = false,
  });

  final String label;
  final bool isOptional;
  final bool hasError;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final showOptionalBadge =
        isOptional && MediaQuery.textScalerOf(context).scale(1) < 1.5;
    final labelStyle = large
        ? CatchTextStyles.labelL(context, color: hasError ? t.danger : t.ink2)
        // `.t-field-label` — 11.5 / w500 / ink3 (sentence case, not mono).
        : CatchTextStyles.fieldLabel(
            context,
            color: hasError ? t.danger : null,
          );

    return Semantics(
      label: isOptional
          ? context.l10n.coreCatchFormFieldLabelLabelLabelOptional(label: label)
          : label,
      excludeSemantics: true,
      child: Row(
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
          ),
          if (showOptionalBadge) ...[
            const SizedBox(width: CatchSpacing.s2),
            CatchFormFieldOptionalBadge(hasError: hasError),
          ],
        ],
      ),
    );
  }
}

class CatchFormFieldOptionalBadge extends StatelessWidget {
  const CatchFormFieldOptionalBadge({super.key, this.hasError = false});

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
        context.l10n.coreCatchFormFieldLabelTextOptional,
        style: CatchTextStyles.supporting(
          context,
          color: color,
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
