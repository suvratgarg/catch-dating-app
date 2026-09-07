import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_meta_dot_row.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/material.dart';

/// A single icon + label metadata row.
///
/// One standard treatment: small tinted icon, one-line label in secondary
/// ink. Pass [color] for a semantic icon tint and [labelColor] only when the
/// label carries the same semantic color. For dot-separated multi-entry rows
/// use [CatchMetaDotRow].
class CatchMetaRow extends StatelessWidget {
  const CatchMetaRow({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.labelColor,
    this.maxLines = 1,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final Color? labelColor;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        Icon(icon, size: CatchIcon.sm, color: color ?? t.primary),
        gapW6,
        Expanded(
          child: Text(
            label,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.labelM(context, color: labelColor ?? t.ink2),
          ),
        ),
      ],
    );
  }
}
