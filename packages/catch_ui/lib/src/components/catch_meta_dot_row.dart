import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_meta_entry.dart';
import 'package:catch_ui/src/components/catch_meta_entry_flow.dart';
import 'package:catch_ui/src/components/catch_meta_entry_view.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/material.dart';

/// A single dot-separated meta row for event/club cards.
///
/// Renders entries as `icon? text  ·  icon? text  ·  …` with a trailing slot
/// that is right-aligned (typically distance-from-user, e.g. `2.3 km`).
///
/// Use this instead of stacking `CatchBadge` chips for inline metadata — the
/// chips compete for attention and look "bolted-on" in modern card hierarchies.
class CatchMetaDotRow extends StatelessWidget {
  const CatchMetaDotRow({
    super.key,
    required this.entries,
    this.trailing,
    this.color,
    this.iconSize = CatchIcon.sm,
    this.maxLines = 1,
  });

  final List<CatchMetaEntry> entries;
  final CatchMetaEntry? trailing;
  final Color? color;
  final double iconSize;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final inkColor = color ?? t.ink2;

    return Row(
      children: [
        Expanded(
          child: ClipRect(
            child: CatchMetaEntryFlow(
              entries: entries,
              color: inkColor,
              iconSize: iconSize,
              maxLines: maxLines,
            ),
          ),
        ),
        if (trailing != null) ...[
          gapW8,
          CatchMetaEntryView(
            entry: trailing!,
            color: inkColor,
            iconSize: iconSize,
            maxLines: maxLines,
            isStrong: true,
          ),
        ],
      ],
    );
  }
}
