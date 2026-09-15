import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class ExploreFeedSkeleton extends StatelessWidget {
  const ExploreFeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CatchSkeleton.card(height: CatchLayout.exploreEventsSkeletonHeight),
        gapH16,
        CatchSkeleton.card(height: CatchLayout.skeletonCardCompactHeight),
        gapH12,
        CatchSkeleton.card(height: CatchLayout.skeletonCardCompactHeight),
      ],
    );
  }
}
