import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_skeleton.dart';
import 'package:flutter/widgets.dart';

/// Row of equal expanded skeleton boxes for compact controls and action rows.
class CatchSkeletonBoxRow extends StatelessWidget {
  const CatchSkeletonBoxRow({
    super.key,
    this.count = 2,
    required this.height,
    this.radius = CatchRadius.md,
    this.gap = CatchSpacing.s3,
  });

  final int count;
  final double height;
  final double radius;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          Expanded(
            child: CatchSkeleton.box(height: height, radius: radius),
          ),
          if (i < count - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}
