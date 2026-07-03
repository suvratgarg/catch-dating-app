import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

enum CatchSkeletonRowLeading { mediaTile, avatar, icon }

/// Surface with repeated skeleton rows and an optional title line.
class CatchSkeletonRows extends StatelessWidget {
  const CatchSkeletonRows({
    super.key,
    this.leading = CatchSkeletonRowLeading.avatar,
    this.count = 3,
    this.titleWidth,
  });

  final CatchSkeletonRowLeading leading;
  final int count;
  final double? titleWidth;

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
                _catchSkeletonRowLeadingShape(leading),
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
            if (i < count - 1) gapH14,
          ],
        ],
      ),
    );
  }
}

Widget _catchSkeletonRowLeadingShape(CatchSkeletonRowLeading leading) {
  return switch (leading) {
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
  };
}

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
          width: CatchSpacing.s16 + CatchSpacing.s6,
          height: height,
          radius: CatchRadius.pill,
        ),
        CatchSkeleton.box(
          width: CatchSpacing.s16 + CatchSpacing.s10,
          height: height,
          radius: CatchRadius.pill,
        ),
        CatchSkeleton.box(
          width: CatchSpacing.s16 + CatchSpacing.s4,
          height: height,
          radius: CatchRadius.pill,
        ),
      ],
    );
  }
}
