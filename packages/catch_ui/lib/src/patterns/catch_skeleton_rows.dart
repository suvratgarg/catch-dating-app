import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_skeleton.dart';
import 'package:catch_ui/src/patterns/catch_skeleton_row_leading.dart';
import 'package:catch_ui/src/primitives/catch_divider.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/widgets.dart';

/// Surface with repeated skeleton rows and an optional title line.
class CatchSkeletonRows extends StatelessWidget {
  const CatchSkeletonRows({
    super.key,
    this.leading = CatchSkeletonRowLeading.avatar,
    this.count = 3,
    this.titleWidth,
    this.divided = false,
  });

  final CatchSkeletonRowLeading leading;
  final int count;
  final double? titleWidth;
  final bool divided;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titleWidth case final width?) ...[
            CatchSkeleton.text(width: width),
            gapH14,
          ],
          for (var i = 0; i < count; i++) ...[
            Row(
              children: [
                switch (leading) {
                  CatchSkeletonRowLeading.mediaTile => CatchSkeleton.box(
                    width: CatchLayout.skeletonMediaTileExtent,
                    height: CatchLayout.skeletonMediaTileExtent,
                    radius: CatchRadius.sm,
                  ),
                  CatchSkeletonRowLeading.avatar => CatchSkeleton.circle(
                    size: CatchLayout.skeletonAvatarCompactExtent,
                  ),
                  CatchSkeletonRowLeading.icon => CatchSkeleton.box(
                    width: CatchIcon.md,
                    height: CatchIcon.md,
                    radius: CatchRadius.sm,
                  ),
                },
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CatchSkeleton.text(
                        width: i.isEven
                            ? CatchLayout.skeletonTextBodyLongWidth
                            : CatchLayout.skeletonTextSecondaryWidth,
                      ),
                      gapH6,
                      CatchSkeleton.text(
                        width: CatchLayout.skeletonTextDetailWidth,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (i < count - 1)
              if (divided) ...[
                gapH14,
                const SizedBox(width: double.infinity, child: CatchDivider()),
                gapH14,
              ] else
                gapH14,
          ],
        ],
      ),
    );
  }
}
