import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_section_header_variant.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_kicker_text.dart';
import 'package:flutter/material.dart';

/// Section heading, count and trailing-action layouts, selected by recipe.
class CatchSectionHeader extends StatelessWidget {
  const CatchSectionHeader({
    super.key,
    required String this.title,
    this.subtitle,
    this.trailing,
    this.uppercase = false,
    this.heavy = false,
    this.padding = const EdgeInsets.only(bottom: CatchSpacing.s2),
    this.titleStyle,
  }) : variant = CatchSectionHeaderVariant.standard,
       count = null,
       color = null,
       textVariant = CatchKickerTextVariant.md;

  /// Count-bearing kicker with a separate trailing lane at large text scales.
  const CatchSectionHeader.kicker({
    super.key,
    required this.title,
    required Color this.color,
    this.count,
    this.trailing,
    this.textVariant = CatchKickerTextVariant.md,
  }) : variant = CatchSectionHeaderVariant.kicker,
       subtitle = null,
       uppercase = false,
       heavy = false,
       padding = EdgeInsets.zero,
       titleStyle = null;

  final CatchSectionHeaderVariant variant;
  final String? title;
  final Object? count;
  final Color? color;
  final CatchKickerTextVariant textVariant;

  /// Optional supporting line under the title.
  final String? subtitle;

  final Widget? trailing;
  final bool uppercase;
  final bool heavy;
  final EdgeInsets padding;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    if (variant == CatchSectionHeaderVariant.kicker) {
      final trailing = this.trailing;
      final t = CatchTokens.of(context);
      final displayText = title?.trim();
      final hasText = displayText != null && displayText.isNotEmpty;
      final displayCount = count?.toString().trim();
      final hasCount = displayCount != null && displayCount.isNotEmpty;
      if (hasText && !hasCount && trailing == null) {
        return Semantics(
          header: true,
          child: CatchKickerText(
            label: displayText,
            color: color,
            variant: textVariant,
          ),
        );
      }
      final header = Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (hasText)
            Expanded(
              child: CatchKickerText(
                label: displayText,
                color: color,
                variant: textVariant,
              ),
            )
          else
            const Spacer(),
          if (hasCount) ...[
            if (hasText)
              const SizedBox(width: CatchFieldTokens.sectionHeaderGap),
            Text(
              displayCount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: CatchTextStyles.sectionCount(context, color: t.ink3),
            ),
          ],
          if (trailing != null) ...[
            if (hasText || hasCount)
              const SizedBox(width: CatchFieldTokens.sectionHeaderGap),
            DefaultTextStyle.merge(
              style: CatchTextStyles.sectionCount(context, color: t.ink3),
              child: trailing,
            ),
          ],
        ],
      );
      final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.6;
      final responsiveHeader = largeText && trailing != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    if (hasText)
                      Expanded(
                        child: CatchKickerText(
                          label: displayText,
                          color: color,
                          variant: textVariant,
                        ),
                      )
                    else
                      const Spacer(),
                    if (hasCount) ...[
                      if (hasText)
                        const SizedBox(
                          width: CatchFieldTokens.sectionHeaderGap,
                        ),
                      Flexible(
                        child: Text(
                          displayCount,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: CatchTextStyles.sectionCount(
                            context,
                            color: t.ink3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: CatchSpacing.s2),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: DefaultTextStyle.merge(
                    style: CatchTextStyles.sectionCount(context, color: t.ink3),
                    child: trailing,
                  ),
                ),
              ],
            )
          : header;
      return hasText
          ? Semantics(header: true, child: responsiveHeader)
          : responsiveHeader;
    }
    final standardTitle = title!;
    final t = CatchTokens.of(context);
    final text = uppercase ? standardTitle.toUpperCase() : standardTitle;
    final style =
        titleStyle ??
        (heavy
            ? CatchTextStyles.titleL(context, color: t.ink)
            : CatchTextStyles.sectionTitle(context, color: t.ink));
    Widget content = Row(
      children: [
        Expanded(child: Text(text, style: style)),
        ?trailing,
      ],
    );
    if (subtitle != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          content,
          gapH4,
          Text(
            subtitle!,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      );
    }
    return Padding(padding: padding, child: content);
  }
}
