import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class EventSuccessSkeletonSurface extends StatelessWidget {
  const EventSuccessSkeletonSurface({
    super.key,
    required this.titleWidth,
    required this.textLines,
    required this.trailingCount,
  });

  final double titleWidth;
  final int textLines;
  final int trailingCount;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: titleWidth),
          gapH12,
          CatchSkeleton.textBlock(lines: textLines),
          if (trailingCount > 0) ...[
            gapH16,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                for (var i = 0; i < trailingCount; i++)
                  CatchSkeleton.box(
                    width: i == 0 ? 104 : 86,
                    height: CatchLayout.badgeActionHeight,
                    radius: CatchRadius.pill,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
