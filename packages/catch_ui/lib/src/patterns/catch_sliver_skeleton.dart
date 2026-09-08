import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_skeleton.dart';
import 'package:catch_ui/src/patterns/catch_sliver_page_body.dart';
import 'package:flutter/widgets.dart';

/// Sliver loading placement with caller-owned page padding.
class CatchSliverSkeleton extends StatelessWidget {
  const CatchSliverSkeleton({
    super.key,
    this.count = 3,
    this.itemHeight,
    this.padding = CatchInsets.pageBody,
  });

  final int count;
  final double? itemHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return CatchSliverPageBody(
      padding: padding,
      sliver: SliverToBoxAdapter(
        child: CatchSkeleton.cards(
          count: count,
          height: itemHeight ?? CatchLayout.skeletonCardHeight,
        ),
      ),
    );
  }
}
