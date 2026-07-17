import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class HostRouteLoadingBody extends StatelessWidget {
  const HostRouteLoadingBody({super.key, this.showTabRail = false});

  final bool showTabRail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: CatchLayout.maxContentWidth,
        ),
        child: CatchSectionStack(
          padding: CatchInsets.pageBodyUnderHeader,
          gap: CatchSpacing.micro18,
          children: [
            if (showTabRail) const HostTabRailSkeleton(),
            const HostSummarySkeleton(),
            const CatchSkeletonRows(
              leading: CatchSkeletonRowLeading.mediaTile,
              divided: true,
            ),
          ],
        ),
      ),
    );
  }
}

class HostSummarySkeleton extends StatelessWidget {
  const HostSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Row(
        children: [
          CatchSkeleton.circle(),
          gapW14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchSkeleton.text(
                  width: CatchLayout.skeletonTextCardTitleWidth,
                ),
                gapH8,
                CatchSkeleton.text(
                  width: CatchLayout.skeletonTextTertiaryWidth,
                ),
              ],
            ),
          ),
          gapW12,
          CatchSkeleton.box(
            width: CatchLayout.skeletonTextActionWidth,
            height: CatchLayout.badgeActionHeight,
            radius: CatchRadius.pill,
          ),
        ],
      ),
    );
  }
}

class HostTabRailSkeleton extends StatelessWidget {
  const HostTabRailSkeleton({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          Expanded(
            child: CatchSkeleton.box(
              height: CatchLayout.controlCompactMinHeight,
              radius: CatchRadius.sm,
            ),
          ),
          if (i < count - 1) gapW8,
        ],
      ],
    );
  }
}

class HostAnalyticsReportSkeleton extends StatelessWidget {
  const HostAnalyticsReportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatchSectionStack(
      padding: EdgeInsets.zero,
      children: [
        CatchSection.divided(
          first: true,
          child: HostAnalyticsMetricGridSkeleton(),
        ),
        CatchSection.divided(child: HostChartSkeleton()),
        CatchSection.divided(
          child: CatchSkeletonRows(
            leading: CatchSkeletonRowLeading.mediaTile,
            divided: true,
          ),
        ),
        CatchSection.divided(
          child: CatchSkeletonRows(
            leading: CatchSkeletonRowLeading.icon,
            divided: true,
          ),
        ),
      ],
    );
  }
}

class HostChartSkeleton extends StatelessWidget {
  const HostChartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextInlineTitleWidth),
          gapH16,
          CatchSkeleton.box(
            height: CatchLayout.hostChartSkeletonHeight,
            radius: CatchRadius.sm,
          ),
        ],
      ),
    );
  }
}

class HostInlineSkeletonIcon extends StatelessWidget {
  const HostInlineSkeletonIcon({super.key, this.size = CatchIcon.md});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CatchSkeleton.box(width: size, height: size, radius: CatchRadius.sm);
  }
}

class HostAnalyticsMetricGridSkeleton extends StatelessWidget {
  const HostAnalyticsMetricGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 2; i++) ...[
          Expanded(
            child: CatchSkeleton.card(
              height: CatchLayout.skeletonCardCompactHeight,
            ),
          ),
          if (i == 0) gapW12,
        ],
      ],
    );
  }
}
