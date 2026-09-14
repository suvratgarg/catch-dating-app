import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field_support_row_tone.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

/// Field helper/error and optional counter row.
class CatchFieldSupportRow extends StatelessWidget {
  const CatchFieldSupportRow({
    super.key,
    this.text,
    this.counter,
    required this.color,
    this.showErrorIcon = false,
    this.padding = EdgeInsets.zero,
  });

  final String? text;
  final String? counter;
  final Color color;
  final bool showErrorIcon;
  final EdgeInsetsGeometry padding;

  /// Semantic support palette shared with native text and content-row renderers.
  static Color resolveColor(
    BuildContext context,
    CatchFieldSupportRowTone tone,
  ) {
    final tokens = CatchTokens.of(context);
    return switch (tone) {
      CatchFieldSupportRowTone.neutral => tokens.ink2,
      CatchFieldSupportRowTone.brand => tokens.primary,
      CatchFieldSupportRowTone.success => tokens.success,
    };
  }

  @override
  Widget build(BuildContext context) {
    final normalizedText = text?.trim();
    final normalizedCounter = counter?.trim();
    final hasText = normalizedText?.isNotEmpty == true;
    final hasCounter = normalizedCounter?.isNotEmpty == true;
    if (!hasText && !hasCounter) return const SizedBox.shrink();

    final label = Text(
      normalizedText ?? '',
      // Helpers and errors explain the consequence of a setting or how to
      // recover. They must remain readable at narrow widths and large text.
      style: CatchTextStyles.supporting(context, color: color).copyWith(
        fontSize: CatchFieldTokens.captionFontSize,
        fontWeight: FontWeight.w500,
        height: CatchFieldTokens.supportLineHeight,
      ),
    );
    final support = showErrorIcon
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(
                  CatchIcons.fieldWarning,
                  size: CatchFieldTokens.errorGlyphExtent,
                  color: color,
                ),
              ),
              const SizedBox(width: CatchFieldTokens.errorGlyphGap),
              Flexible(child: label),
            ],
          )
        : label;

    final content = Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (hasText) Expanded(child: support) else const Spacer(),
          if (hasCounter) ...[
            if (hasText)
              const SizedBox(width: CatchFieldTokens.supportingCounterGap),
            Text(
              normalizedCounter!,
              style: CatchTextStyles.monoLabel(
                context,
                color: CatchTokens.of(context).ink3,
              ).copyWith(fontSize: CatchFieldTokens.counterFontSize),
            ),
          ],
        ],
      ),
    );
    if (!showErrorIcon || !hasText) return content;
    return Semantics(
      label: normalizedText,
      liveRegion: true,
      child: ExcludeSemantics(child: content),
    );
  }
}
