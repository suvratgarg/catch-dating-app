import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_badge.dart';
import 'package:catch_ui/src/components/catch_field_content_row_mode.dart';
import 'package:catch_ui/src/components/catch_field_content_row_status.dart';
import 'package:catch_ui/src/components/catch_field_emphasis.dart';
import 'package:catch_ui/src/components/catch_field_label_text.dart';
import 'package:catch_ui/src/components/catch_field_support_row.dart';
import 'package:catch_ui/src/components/catch_field_support_row_tone.dart';
import 'package:catch_ui/src/components/catch_field_tone.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

/// Field content with two explicit hierarchies: title/description and caption/value.
/// The enclosing field owns interaction; this member owns text lanes and support.
class CatchFieldContentRow extends StatelessWidget {
  const CatchFieldContentRow({
    super.key,
    required String title,
    required String body,
    required this.labelCopy,
    int titleMaxLines = 2,
    int bodyMaxLines = 3,
    this.isOptional = false,
    Color? titleColor,
    Color? bodyColor,
  }) : _value = null,
       _content = (
         title: title,
         body: body,
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         titleColor: titleColor,
         bodyColor: bodyColor,
       );

  const CatchFieldContentRow.value({
    super.key,
    required this.labelCopy,
    String? label,
    String? value,
    Widget? body,
    String? supportText,
    String? counterText,
    CatchFieldContentRowStatus status = CatchFieldContentRowStatus.idle,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldContentRowMode mode = CatchFieldContentRowMode.value,
    int valueMaxLines = 1,
    int titleMaxLines = 1,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    CatchFieldTone tone = CatchFieldTone.normal,
    CatchFieldSupportRowTone helperTone = CatchFieldSupportRowTone.neutral,
    double headerTrailingReserve = 0,
    this.isOptional = false,
    String? badgeLabel,
    CatchBadgeTone? badgeTone,
  }) : _content = null,
       _value = (
         label: label,
         value: value,
         body: body,
         supportText: supportText,
         counterText: counterText,
         status: status,
         emphasis: emphasis,
         mode: mode,
         valueMaxLines: valueMaxLines,
         titleMaxLines: titleMaxLines,
         labelStyle: labelStyle,
         valueStyle: valueStyle,
         tone: tone,
         helperTone: helperTone,
         headerTrailingReserve: headerTrailingReserve,
         badgeLabel: badgeLabel,
         badgeTone: badgeTone,
       );

  final CatchFieldLabelTextCopy labelCopy;
  final bool isOptional;
  final _FieldDescriptionContent? _content;
  final _FieldValueContent? _value;

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
    final description = _content;
    if (description != null) {
      final title = description.title;
      final body = description.body;
      final titleMaxLines = description.titleMaxLines;
      final bodyMaxLines = description.bodyMaxLines;
      final titleColor = description.titleColor;
      final bodyColor = description.bodyColor;
      final normalizedBody = body.trim();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CatchFieldLabelText.inline(
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
    final content = _value!;
    final label = content.label;
    final value = content.value;
    final body = content.body;
    final supportText = content.supportText;
    final counterText = content.counterText;
    final status = content.status;
    final emphasis = content.emphasis;
    final mode = content.mode;
    final valueMaxLines = content.valueMaxLines;
    final titleMaxLines = content.titleMaxLines;
    final labelStyle = content.labelStyle;
    final valueStyle = content.valueStyle;
    final tone = content.tone;
    final helperTone = content.helperTone;
    final headerTrailingReserve = content.headerTrailingReserve;
    final badgeLabel = content.badgeLabel;
    final badgeTone = content.badgeTone;
    final hasError = status == CatchFieldContentRowStatus.error;
    final active = status == CatchFieldContentRowStatus.active;
    final labelEmphasized = emphasis == CatchFieldEmphasis.title;
    final valueIsPlaceholder = mode == CatchFieldContentRowMode.placeholder;
    final toneColor = switch (tone) {
      CatchFieldTone.primary => t.primary,
      CatchFieldTone.danger => t.danger,
      CatchFieldTone.normal => t.ink,
    };
    final supportColor = CatchFieldSupportRow.resolveColor(context, helperTone);
    final labelText = label?.trim();
    final valueText = value?.trim();
    final hasLabel = labelText != null && labelText.isNotEmpty;
    final hasValue =
        body != null || (valueText != null && valueText.isNotEmpty);
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
                            child: CatchFieldLabelText.inline(
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
                    : CatchFieldLabelText.inline(
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
                    body ??
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

typedef _FieldDescriptionContent = ({
  String title,
  String body,
  int titleMaxLines,
  int bodyMaxLines,
  Color? titleColor,
  Color? bodyColor,
});

typedef _FieldValueContent = ({
  String? label,
  String? value,
  Widget? body,
  String? supportText,
  String? counterText,
  CatchFieldContentRowStatus status,
  CatchFieldEmphasis emphasis,
  CatchFieldContentRowMode mode,
  int valueMaxLines,
  int titleMaxLines,
  TextStyle? labelStyle,
  TextStyle? valueStyle,
  CatchFieldTone tone,
  CatchFieldSupportRowTone helperTone,
  double headerTrailingReserve,
  String? badgeLabel,
  CatchBadgeTone? badgeTone,
});
