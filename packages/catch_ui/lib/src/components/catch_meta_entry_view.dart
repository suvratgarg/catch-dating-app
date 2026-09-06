import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_meta_entry.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/material.dart';

class CatchMetaEntryView extends StatelessWidget {
  const CatchMetaEntryView({
    super.key,
    required this.entry,
    this.color,
    this.iconSize = CatchIcon.sm,
    this.maxLines = 1,
    this.isStrong = false,
  });

  final CatchMetaEntry entry;
  final Color? color;
  final double iconSize;
  final int maxLines;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    final inkColor = color ?? CatchTokens.of(context).ink2;
    final iconColor = entry.iconColor ?? inkColor;
    final textColor = entry.color ?? inkColor;
    final style = isStrong
        ? CatchTextStyles.numericMeta(
            context,
            color: textColor,
          ).copyWith(fontWeight: FontWeight.w700)
        : CatchTextStyles.numericMeta(context, color: textColor);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (entry.icon != null) ...[
          Icon(entry.icon, size: iconSize, color: iconColor),
          gapW4,
        ],
        Flexible(
          child: Text(
            entry.label,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}
