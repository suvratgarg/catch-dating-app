import 'package:catch_dating_app/clubs/shared/club_transition_tags.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

/// Skeleton loading body for the club detail screen.
class ClubDetailLoadingBody extends StatelessWidget {
  const ClubDetailLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ColoredBox(
      color: t.surface,
      child: const CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: ClubHeroLoadingSkeleton()),
          CatchDetailSliverSectionList(
            gap: CatchSpacing.screenPt,
            sections: [
              ClubStatsLoadingSkeleton(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CatchSection.divided(
                    title: 'About',
                    first: true,
                    child: ClubTextLoadingSkeleton(lines: 3),
                  ),
                  CatchSection.divided(
                    title: 'What we do',
                    child: CatchSkeletonChips(height: CatchSpacing.s8),
                  ),
                  CatchSection.divided(
                    title: 'Your hosts',
                    child: ClubHostLoadingSkeleton(),
                  ),
                  CatchSection.divided(
                    title: 'Schedule',
                    child: ClubScheduleLoadingSkeleton(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ClubHeroLoadingSkeleton extends StatelessWidget {
  const ClubHeroLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ColoredBox(
      color: t.surface,
      child: Padding(
        padding: clubInteractionMediaPadding,
        child: CatchSurface(
          height:
              CatchLayout.clubDetailHeroNoCoverPhoneHeight +
              CatchLayout.clubDetailHeroCaptionExtent,
          borderColor: t.line,
          radius: CatchLayout.clubPolaroidRadius,
          elevation: CatchSurfaceElevation.card,
          backgroundColor: t.surface,
          padding: CatchInsets.contentDense,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CatchSkeleton.box(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.circular(
                    CatchLayout.clubPolaroidMediaRadius,
                  ),
                ),
              ),
              gapH10,
              CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
              gapH4,
              CatchSkeleton.text(width: CatchSpacing.s16 * 3),
            ],
          ),
        ),
      ),
    );
  }
}

class ClubStatsLoadingSkeleton extends StatelessWidget {
  const ClubStatsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.tileContentCompact,
      child: const Row(
        children: [
          Expanded(child: ClubStatLoadingSkeleton()),
          ClubStatsDividerSkeleton(),
          Expanded(child: ClubStatLoadingSkeleton()),
          ClubStatsDividerSkeleton(),
          Expanded(child: ClubStatLoadingSkeleton()),
          ClubStatsDividerSkeleton(),
          Expanded(child: ClubStatLoadingSkeleton()),
        ],
      ),
    );
  }
}

class ClubStatLoadingSkeleton extends StatelessWidget {
  const ClubStatLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
        gapH8,
        CatchSkeleton.text(width: CatchSpacing.s10),
      ],
    );
  }
}

class ClubStatsDividerSkeleton extends StatelessWidget {
  const ClubStatsDividerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s3),
      child: SizedBox(
        width: CatchStroke.hairline,
        height: CatchSpacing.s11,
        child: ColoredBox(color: CatchTokens.of(context).line),
      ),
    );
  }
}

class ClubHostLoadingSkeleton extends StatelessWidget {
  const ClubHostLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.tileContentCompact,
      child: Row(
        children: [
          CatchSkeleton.circle(size: CatchSpacing.s10),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
                gapH6,
                CatchSkeleton.text(width: CatchSpacing.s16 * 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ClubTextLoadingSkeleton extends StatelessWidget {
  const ClubTextLoadingSkeleton({super.key, required this.lines});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return CatchSkeleton.textBlock(lines: lines);
  }
}

class ClubScheduleLoadingSkeleton extends StatelessWidget {
  const ClubScheduleLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CatchSkeleton.card(height: CatchLayout.skeletonCardCompactHeight),
        gapH10,
        CatchSkeleton.card(height: CatchLayout.skeletonCardCompactHeight),
      ],
    );
  }
}
