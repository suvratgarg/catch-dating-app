import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_screen_body.dart';
import 'package:catch_ui/src/patterns/catch_skeleton.dart';
import 'package:flutter/widgets.dart';

/// Screen-body loading placement with standard insets and optional scrolling.
class CatchScreenSkeleton extends StatelessWidget {
  const CatchScreenSkeleton({
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
      child: CatchSkeleton.cards(
        count: count,
        height: itemHeight ?? CatchLayout.skeletonCardHeight,
      ),
    );
  }
}
