import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_skeleton.dart';
import 'package:flutter/widgets.dart';

/// Jittered pill skeletons for loading chip or tag rows.
class CatchSkeletonChips extends StatelessWidget {
  const CatchSkeletonChips({super.key, this.height = CatchSpacing.s9});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        CatchSkeleton.box(
          width: CatchLayout.skeletonChipMediumWidth,
          height: height,
          radius: CatchRadius.pill,
        ),
        CatchSkeleton.box(
          width: CatchLayout.skeletonChipWideWidth,
          height: height,
          radius: CatchRadius.pill,
        ),
        CatchSkeleton.box(
          width: CatchLayout.skeletonChipNarrowWidth,
          height: height,
          radius: CatchRadius.pill,
        ),
      ],
    );
  }
}
