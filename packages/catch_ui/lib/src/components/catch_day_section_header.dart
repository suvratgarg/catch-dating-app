import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_day_section_header_count.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

/// Sticky day-section header for chronologically grouped feeds.
///
/// Renders a tight caps-tracked kicker (`TODAY · WED 27 MAY`) with an
/// optional right-aligned count (`3`). Designed to sit inside a
/// [SliverPersistentHeader] via [CatchDaySectionHeaderDelegate], or as a
/// regular widget at the top of a `Column`.
class CatchDaySectionHeader extends StatelessWidget {
  const CatchDaySectionHeader({
    super.key,
    required this.label,
    this.count,
    this.padding = const EdgeInsets.fromLTRB(
      CatchSpacing.s5,
      CatchSpacing.s4,
      CatchSpacing.s5,
      CatchSpacing.s2,
    ),
    this.sticky = false,
  });

  final String label;
  final int? count;
  final EdgeInsets padding;

  /// When true, the header paints a full-width background so it can sit
  /// inside a sliver persistent header without revealing the scroll content
  /// underneath while sticky.
  final bool sticky;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final content = Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.kickerLg(context, color: t.primary),
            ),
          ),
          if (count != null)
            CatchDaySectionHeaderCount(count: count!, color: t.ink2),
        ],
      ),
    );

    if (!sticky) return content;
    return ColoredBox(color: t.bg, child: content);
  }
}

/// Sliver persistent-header delegate that pins a [CatchDaySectionHeader].
class CatchDaySectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  const CatchDaySectionHeaderDelegate({
    required this.label,
    this.count,
    this.height = CatchSpacing.s11,
  });

  final String label;
  final int? count;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: height,
      child: CatchDaySectionHeader(label: label, count: count, sticky: true),
    );
  }

  @override
  bool shouldRebuild(covariant CatchDaySectionHeaderDelegate oldDelegate) {
    return oldDelegate.label != label ||
        oldDelegate.count != count ||
        oldDelegate.height != height;
  }
}
