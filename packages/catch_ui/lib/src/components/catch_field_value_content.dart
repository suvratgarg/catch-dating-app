import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_badge.dart';
import 'package:catch_ui/src/components/catch_field_emphasis.dart';
import 'package:catch_ui/src/components/catch_field_support_row.dart';
import 'package:catch_ui/src/components/catch_field_support_tone.dart';
import 'package:catch_ui/src/components/catch_field_tone.dart';
import 'package:catch_ui/src/components/catch_field_value_content_mode.dart';
import 'package:catch_ui/src/components/catch_field_value_content_status.dart';
import 'package:catch_ui/src/components/catch_form_field_label.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

/// Field-owned caption, value, badge, and supporting-copy lanes.
///
/// The enclosing field supplies interaction state and the trailing reservation;
/// this member owns text styling, minimum line extents, and supporting geometry.
class CatchFieldValueContent extends StatelessWidget {
  const CatchFieldValueContent({
    super.key,
    required this.labelCopy,
    this.label,
    this.value,
    this.valueWidget,
    this.supportText,
    this.counterText,
    this.status = CatchFieldValueContentStatus.idle,
    this.emphasis = CatchFieldEmphasis.body,
    this.mode = CatchFieldValueContentMode.value,
    this.valueMaxLines = 1,
    this.titleMaxLines = 1,
    this.labelStyle,
    this.valueStyle,
    this.tone = CatchFieldTone.normal,
    this.helperTone = CatchFieldSupportTone.neutral,
    this.headerTrailingReserve = 0,
    this.isOptional = false,
    this.badgeLabel,
    this.badgeTone,
  });

  final CatchFormFieldLabelCopy labelCopy;
  final String? label;
  final String? value;
  final Widget? valueWidget;
  final String? supportText;
  final String? counterText;
  final CatchFieldValueContentStatus status;
  final CatchFieldEmphasis emphasis;
  final CatchFieldValueContentMode mode;
  final int valueMaxLines;
  final int titleMaxLines;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final CatchFieldTone tone;
  final CatchFieldSupportTone helperTone;
  final double headerTrailingReserve;
  final bool isOptional;
  final String? badgeLabel;
  final CatchBadgeTone? badgeTone;

  /// Caption geometry shared with the field's text-entry and select shells.
  static TextStyle captionStyle(BuildContext context, {required Color color}) =>
      CatchTextStyles.fieldLabel(context, color: color).copyWith(
        fontSize: CatchFieldTokens.captionFontSize,
        fontWeight: FontWeight.w500,
        height: CatchFieldTokens.supportLineHeight,
      );

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasError = status == CatchFieldValueContentStatus.error;
    final active = status == CatchFieldValueContentStatus.active;
    final labelEmphasized = emphasis == CatchFieldEmphasis.title;
    final valueIsPlaceholder = mode == CatchFieldValueContentMode.placeholder;
    final toneColor = switch (tone) {
      CatchFieldTone.primary => t.primary,
      CatchFieldTone.danger => t.danger,
      CatchFieldTone.normal => t.ink,
    };
    final supportColor = switch (helperTone) {
      CatchFieldSupportTone.neutral => t.ink2,
      CatchFieldSupportTone.brand => t.primary,
      CatchFieldSupportTone.success => t.success,
    };
    final labelText = label?.trim();
    final valueText = value?.trim();
    final hasLabel = labelText != null && labelText.isNotEmpty;
    final hasValue =
        valueWidget != null || (valueText != null && valueText.isNotEmpty);
    final support = supportText?.trim();
    final counter = counterText?.trim();
    final hasCounter = counter != null && counter.isNotEmpty;
    final hasSupport = (support != null && support.isNotEmpty) || hasCounter;

    if (!hasLabel && !hasValue && !hasSupport) {
      return const SizedBox.shrink();
    }

    final baseLabelStyle =
        labelStyle ??
        (labelEmphasized
            ? CatchTextStyles.fieldRowValue(
                context,
                color: hasError ? t.danger : toneColor,
              )
            : captionStyle(context, color: hasError ? t.danger : t.ink2));
    final effectiveLabelStyle = baseLabelStyle.copyWith(
      color: hasError
          ? t.danger
          : active
          ? t.ink
          : baseLabelStyle.color ?? t.ink2,
    );
    final effectiveValueStyle =
        valueStyle ??
        (labelEmphasized
            ? captionStyle(context, color: t.ink2)
            : CatchTextStyles.fieldRowValue(
                context,
                color: valueIsPlaceholder ? t.ink2 : toneColor,
              ));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasLabel)
          Padding(
            key: const ValueKey<String>('catch-field-label-content'),
            padding: EdgeInsetsDirectional.only(end: headerTrailingReserve),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: labelEmphasized
                    ? CatchFieldTokens.valueLineExtent
                    : CatchFieldTokens.captionExtent,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: badgeLabel?.trim().isNotEmpty == true
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: CatchFormFieldLabel.inline(
                              copy: labelCopy,
                              label: labelText,
                              style: effectiveLabelStyle,
                              maxLines: titleMaxLines,
                              isOptional: isOptional,
                            ),
                          ),
                          const SizedBox(width: CatchSpacing.s2),
                          CatchBadge(
                            label: badgeLabel!.trim(),
                            tone: badgeTone ?? CatchBadgeTone.neutral,
                          ),
                        ],
                      )
                    : CatchFormFieldLabel.inline(
                        copy: labelCopy,
                        label: labelText,
                        style: effectiveLabelStyle,
                        maxLines: titleMaxLines,
                        isOptional: isOptional,
                      ),
              ),
            ),
          ),
        if (hasValue) ...[
          Padding(
            key: const ValueKey<String>('catch-field-value-content'),
            padding: EdgeInsetsDirectional.only(end: headerTrailingReserve),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: CatchFieldTokens.valueLineExtent,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child:
                    valueWidget ??
                    Text(
                      valueText!,
                      maxLines: valueMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: effectiveValueStyle,
                    ),
              ),
            ),
          ),
        ],
        if (hasSupport) ...[
          if (hasLabel || hasValue)
            const SizedBox(height: CatchFieldTokens.supportingTopGap),
          CatchFieldSupportRow(
            text: support,
            counter: hasCounter ? counter : null,
            color: hasError ? t.danger : supportColor,
            showErrorIcon: hasError,
          ),
        ],
      ],
    );
  }
}
