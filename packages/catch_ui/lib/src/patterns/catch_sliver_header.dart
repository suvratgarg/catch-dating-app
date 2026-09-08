import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

/// A sliver header with a collapsible title and an optional pinned bottom.
///
/// The title uses a [SliverToBoxAdapter] and scrolls away completely.
/// An optional [SliverPersistentHeader] keeps the bottom pinned.
class CatchSliverHeader {
  const CatchSliverHeader({
    required this.title,
    this.bottom,
    this.bottomHeight = 52,
  });

  static const double compactSearchBottomHeight =
      CatchLayout.topBarCompactSearchBottomHeight;
  static const double searchControlTopPadding = CatchSpacing.s2;
  static const double contentAfterSearchGap = CatchSpacing.s3;

  final Widget title;
  final Widget? bottom;
  final double bottomHeight;

  List<Widget> buildSlivers(BuildContext context) {
    return [
      SliverToBoxAdapter(child: title),
      if (bottom != null)
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedHeaderDelegate(child: bottom!, height: bottomHeight),
        ),
    ];
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedHeaderDelegate({required this.child, required this.height});

  final Widget child;
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
  ) => ColoredBox(
    color: CatchTokens.of(context).bg,
    child: SizedBox.expand(child: child),
  );

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate old) =>
      child != old.child || height != old.height;
}
