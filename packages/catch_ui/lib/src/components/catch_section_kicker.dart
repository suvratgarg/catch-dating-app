import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_kicker.dart';
import 'package:flutter/material.dart';

/// Section-owned heading with a count and responsive trailing action lane.
///
/// Product surfaces use the named `CatchSection` constructors. This member
/// keeps their heading semantics and large-text layout directly cataloged.
class CatchSectionKicker extends StatelessWidget {
  const CatchSectionKicker({
    super.key,
    required this.text,
    required this.color,
    this.count,
    this.trailing,
    this.size = CatchKickerSize.md,
  });

  final String? text;
  final Color color;
  final Object? count;
  final Widget? trailing;
  final CatchKickerSize size;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    final t = CatchTokens.of(context);
    final displayText = text?.trim();
    final hasText = displayText != null && displayText.isNotEmpty;
    final displayCount = count?.toString().trim();
    final hasCount = displayCount != null && displayCount.isNotEmpty;
    if (hasText && !hasCount && trailing == null) {
      return Semantics(
        header: true,
        child: CatchKicker(label: displayText, color: color, size: size),
      );
    }
    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (hasText)
          Expanded(
            child: CatchKicker(label: displayText, color: color, size: size),
          )
        else
          const Spacer(),
        if (hasCount) ...[
          if (hasText) const SizedBox(width: CatchFieldTokens.sectionHeaderGap),
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
                      child: CatchKicker(
                        label: displayText,
                        color: color,
                        size: size,
                      ),
                    )
                  else
                    const Spacer(),
                  if (hasCount) ...[
                    if (hasText)
                      const SizedBox(width: CatchFieldTokens.sectionHeaderGap),
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
}
