import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_screen_body.dart';
import 'package:catch_ui/src/patterns/catch_skeleton_list.dart';
import 'package:flutter/widgets.dart';

class CatchAsyncScreenLoading extends StatelessWidget {
  const CatchAsyncScreenLoading({
    super.key,
    this.count = 3,
    this.itemHeight,
    this.scrollable = true,
  });

  final int count;
  final double? itemHeight;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return CatchScreenBody(
      scrollable: scrollable,
      child: CatchSkeletonList(
        count: count,
        height: itemHeight ?? CatchLayout.skeletonCardHeight,
      ),
    );
  }
}
