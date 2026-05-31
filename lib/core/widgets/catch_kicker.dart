import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Caps-tracked label primitive used for time-line kickers on event cards
/// (`TONIGHT · 8:50 PM`), section sashes (`TONIGHT'S PICK`), and
/// editorial labels.
///
/// Always renders the text fully upper-cased — pass natural casing in, the
/// primitive handles the visual treatment.
class CatchKicker extends StatelessWidget {
  const CatchKicker({
    super.key,
    required this.label,
    this.trailing,
    this.color,
    this.size = CatchKickerSize.sm,
    this.textAlign,
    this.maxLines = 1,
  });

  /// The kicker text. Will be upper-cased internally.
  final String label;

  /// Optional trailing text (typically a countdown like `IN 4H 56M`),
  /// rendered with a leading separator and a slightly muted tone.
  final String? trailing;

  /// Override the kicker tint. Defaults to the brand primary so the kicker
  /// always reads as a brand moment.
  final Color? color;

  final CatchKickerSize size;
  final TextAlign? textAlign;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final base = switch (size) {
      CatchKickerSize.sm => CatchTextStyles.kicker(context, color: color),
      CatchKickerSize.md => CatchTextStyles.kickerLg(context, color: color),
    };
    final trailingText = trailing;
    if (trailingText == null) {
      return Text(
        label.toUpperCase(),
        style: base,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
      );
    }
    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign ?? TextAlign.start,
      text: TextSpan(
        style: base,
        children: [
          TextSpan(text: label.toUpperCase()),
          TextSpan(
            text: '  ${trailingText.toUpperCase()}',
            style: base.copyWith(color: t.ink2),
          ),
        ],
      ),
    );
  }
}

enum CatchKickerSize { sm, md }
