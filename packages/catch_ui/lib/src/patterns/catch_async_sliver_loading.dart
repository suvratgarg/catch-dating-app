import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_skeleton_list.dart';
import 'package:catch_ui/src/patterns/catch_sliver_page_body.dart';
import 'package:flutter/widgets.dart';

class CatchAsyncSliverLoading extends StatelessWidget {
  const CatchAsyncSliverLoading({
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
        child: CatchSkeletonList(
          count: count,
          height: itemHeight ?? CatchLayout.skeletonCardHeight,
        ),
      ),
    );
  }
}
