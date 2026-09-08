import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_skeleton.dart';
import 'package:flutter/widgets.dart';

/// A list of skeleton cards with a [count] and optional spacing.
///
/// Convenience widget for swipe hubs, dashboards, and club lists.
class CatchSkeletonList extends StatelessWidget {
  const CatchSkeletonList({
    super.key,
    this.count = 3,
    this.height = CatchLayout.skeletonCardHeight,
    this.spacing = CatchSpacing.s3,
  });

  final int count;
  final double height;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          CatchSkeleton.card(height: height),
          if (i < count - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}
