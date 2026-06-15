import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:flutter/material.dart';

enum CatchKickerSize { md, lg }

/// Handoff `Kicker`: uppercase mono eyebrow for section starts and editorial
/// labels.
class CatchKicker extends StatelessWidget {
  const CatchKicker({
    super.key,
    required this.label,
    this.color,
    this.size = CatchKickerSize.md,
    this.textAlign,
    this.maxLines = 1,
  });

  final String label;
  final Color? color;
  final CatchKickerSize size;
  final TextAlign? textAlign;
  final int maxLines;

  static TextStyle styleOf(
    BuildContext context, {
    Color? color,
    CatchKickerSize size = CatchKickerSize.md,
  }) {
    return switch (size) {
      CatchKickerSize.md => CatchTextStyles.kicker(context, color: color),
      CatchKickerSize.lg => CatchTextStyles.kickerLg(context, color: color),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: styleOf(context, color: color, size: size),
    );
  }
}
