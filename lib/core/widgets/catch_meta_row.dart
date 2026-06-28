import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
            child: _buildMetaEntryFlow(
              context,
              entries: entries,
              color: inkColor,
              iconSize: iconSize,
              maxLines: maxLines,
            ),
          ),
        ),
        if (trailing != null) ...[
          gapW8,
          _buildEntry(
            context,
            trailing!,
            inkColor,
            iconSize: iconSize,
            maxLines: maxLines,
            isStrong: true,
          ),
        ],
      ],
    );
  }
}

Widget _buildMetaEntryFlow(
  BuildContext context, {
  required List<CatchMetaEntry> entries,
  required Color color,
  required double iconSize,
  required int maxLines,
}) {
  final children = <Widget>[];
  for (var i = 0; i < entries.length; i++) {
    if (i > 0) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.micro6),
          child: Text(
            '·',
            style: CatchTextStyles.numericMeta(context, color: color),
          ),
        ),
      );
    }
    children.add(
      Flexible(
        child: _buildEntry(
          context,
          entries[i],
          color,
          iconSize: iconSize,
          maxLines: maxLines,
        ),
      ),
    );
  }
  return Row(mainAxisSize: MainAxisSize.min, children: children);
}

Widget _buildEntry(
  BuildContext context,
  CatchMetaEntry entry,
  Color inkColor, {
  required double iconSize,
  required int maxLines,
  bool isStrong = false,
}) {
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

class CatchMetaEntry {
  const CatchMetaEntry({
    required this.label,
    this.icon,
    this.iconColor,
    this.color,
  });

  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Color? color;
}
