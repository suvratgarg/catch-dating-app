import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_meta_entry.dart';
import 'package:catch_ui/src/components/catch_meta_entry_view.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

class CatchMetaEntryFlow extends StatelessWidget {
  const CatchMetaEntryFlow({
    super.key,
    required this.entries,
    this.color,
    this.iconSize = CatchIcon.sm,
    this.maxLines = 1,
  });

  final List<CatchMetaEntry> entries;
  final Color? color;
  final double iconSize;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final inkColor = color ?? CatchTokens.of(context).ink2;
    final children = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      if (i > 0) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CatchSpacing.micro6,
            ),
            child: Text(
              '·',
              style: CatchTextStyles.numericMeta(context, color: inkColor),
            ),
          ),
        );
      }
      children.add(
        Flexible(
          child: CatchMetaEntryView(
            entry: entries[i],
            color: inkColor,
            iconSize: iconSize,
            maxLines: maxLines,
          ),
        ),
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
