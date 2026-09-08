import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_form_field_optional_badge.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

/// Already-localized optional-field copy supplied by the caller.
class CatchFormFieldLabelCopy {
  const CatchFormFieldLabelCopy({
    required this.optionalLabel,
    required this.optionalSuffix,
    required this.optionalSemantics,
  });

  final String optionalLabel;
  final String optionalSuffix;
  final String Function(String label) optionalSemantics;
}

class CatchFormFieldLabel extends StatelessWidget {
  const CatchFormFieldLabel({
    super.key,
    required this.label,
    required this.copy,
    this.isOptional = false,
    this.hasError = false,
    this.large = false,
  }) : inlineOptional = false,
       style = null,
       maxLines = 1;

  const CatchFormFieldLabel.inline({
    super.key,
    required this.label,
    required this.copy,
    required this.style,
    this.isOptional = false,
    this.hasError = false,
    this.maxLines = 1,
  }) : inlineOptional = true,
       large = false;

  final String label;
  final CatchFormFieldLabelCopy copy;
  final bool isOptional;
  final bool hasError;
  final bool large;
  final bool inlineOptional;
  final TextStyle? style;
  final int maxLines;

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

    if (inlineOptional) {
      final effectiveStyle = style ?? labelStyle;
      final labelText = Text(
        label,
        style: effectiveStyle,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
      if (!isOptional) return labelText;

      // Keep the visible label as its own text node so clients can target the
      // field name without folding the optional qualifier into that name.
      final text = Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(child: labelText),
          Text(
            copy.optionalSuffix,
            style: effectiveStyle.copyWith(
              color: hasError ? t.danger : t.ink3,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
          ),
        ],
      );
      return Semantics(
        label: copy.optionalSemantics(label),
        excludeSemantics: true,
        child: text,
      );
    }

    return Semantics(
      label: isOptional ? copy.optionalSemantics(label) : label,
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
            CatchFormFieldOptionalBadge(
              label: copy.optionalLabel,
              hasError: hasError,
            ),
          ],
        ],
      ),
    );
  }
}
