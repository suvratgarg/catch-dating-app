import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.kickerLg(context, color: t.primary),
            ),
          ),
          if (count != null) _AnimatedCount(count: count!, color: t.ink2),
        ],
      ),
    );

    if (!sticky) return content;
    return ColoredBox(color: t.bg, child: content);
  }
}

/// Ticker that slides + fades the count when it changes (e.g. when the
/// filter row narrows or widens the day's matches). The outgoing number
/// rises out of view as the incoming one rises into view from below.
class _AnimatedCount extends StatelessWidget {
  const _AnimatedCount({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: CatchMotion.base,
      switchInCurve: CatchMotion.springCurve,
      switchOutCurve: CatchMotion.standardCurve,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.4),
          end: Offset.zero,
        ).animate(animation);
        return ClipRect(
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.centerRight,
          children: [...previousChildren, ?currentChild],
        );
      },
      child: Text(
        count.toString(),
        key: ValueKey<int>(count),
        style: CatchTextStyles.numericMeta(
          context,
          color: color,
        ).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Sliver persistent-header delegate that pins a [CatchDaySectionHeader].
class CatchDaySectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  const CatchDaySectionHeaderDelegate({
    required this.label,
    this.count,
    this.height = 44,
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
