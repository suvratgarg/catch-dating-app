import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_form_field_label.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

/// Exact natural-height title and supporting-copy lane used by
/// `CatchField.content`.
class CatchFieldContentRow extends StatelessWidget {
  const CatchFieldContentRow({
    super.key,
    required this.title,
    required this.body,
    required this.labelCopy,
    this.titleMaxLines = 2,
    this.bodyMaxLines = 3,
    this.isOptional = false,
    this.titleColor,
    this.bodyColor,
  });

  final String title;
  final String body;
  final CatchFormFieldLabelCopy labelCopy;
  final int titleMaxLines;
  final int bodyMaxLines;
  final bool isOptional;
  final Color? titleColor;
  final Color? bodyColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final normalizedBody = body.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CatchFormFieldLabel.inline(
          copy: labelCopy,
          label: title.trim(),
          style: CatchTextStyles.fieldRowValue(
            context,
            color: titleColor ?? t.ink,
            fontWeight: FontWeight.w600,
          ),
          maxLines: titleMaxLines,
          isOptional: isOptional,
        ),
        if (normalizedBody.isNotEmpty) ...[
          const SizedBox(height: CatchFieldTokens.contentBodyTopGap),
          Text(
            normalizedBody,
            key: const ValueKey('catch-field-content-body'),
            maxLines: bodyMaxLines,
            overflow: TextOverflow.ellipsis,
            style:
                CatchTextStyles.supporting(
                  context,
                  color: bodyColor ?? t.ink2,
                ).copyWith(
                  fontSize: CatchFieldTokens.contentBodyFontSize,
                  fontWeight: FontWeight.w400,
                  height: CatchFieldTokens.contentBodyLineHeight,
                ),
          ),
        ],
      ],
    );
  }
}
