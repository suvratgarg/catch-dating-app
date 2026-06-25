import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
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
            const HostEventRowsSkeleton(count: 3),
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

class HostSettingsRowsSkeleton extends StatelessWidget {
  const HostSettingsRowsSkeleton({super.key, this.rowCount = 3});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        children: [
          for (var i = 0; i < rowCount; i++) ...[
            Row(
              children: [
                CatchSkeleton.box(
                  width: CatchIcon.md,
                  height: CatchIcon.md,
                  radius: CatchRadius.sm,
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CatchSkeleton.text(width: i == 0 ? 112 : 136),
                      gapH6,
                      CatchSkeleton.text(width: i == 1 ? 176 : 148),
                    ],
                  ),
                ),
              ],
            ),
            if (i < rowCount - 1) ...[
              gapH14,
              Divider(color: t.line, height: 1, thickness: 1),
              gapH14,
            ],
          ],
        ],
      ),
    );
  }
}

class HostEventRowsSkeleton extends StatelessWidget {
  const HostEventRowsSkeleton({super.key, this.count = 2});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            Row(
              children: [
                CatchSkeleton.box(
                  width: CatchLayout.skeletonMediaTileExtent,
                  height: CatchLayout.skeletonMediaTileExtent,
                  radius: CatchRadius.sm,
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CatchSkeleton.text(
                        width: i == 0
                            ? CatchLayout.skeletonTextBodyLongWidth
                            : CatchLayout.skeletonTextDetailWidth,
                      ),
                      gapH8,
                      CatchSkeleton.text(width: i == 1 ? 128 : 166),
                    ],
                  ),
                ),
              ],
            ),
            if (i < count - 1) ...[
              gapH14,
              Divider(color: t.line, height: 1, thickness: 1),
              gapH14,
            ],
          ],
        ],
      ),
    );
  }
}

class HostAnalyticsReportSkeleton extends StatelessWidget {
  const HostAnalyticsReportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatchSectionStack(
      padding: EdgeInsets.zero,
      gap: CatchSpacing.s4,
      children: [
        _HostAnalyticsMetricGridSkeleton(),
        HostChartSkeleton(),
        HostEventRowsSkeleton(count: 3),
        HostSettingsRowsSkeleton(),
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

class HostRosterSkeleton extends StatelessWidget {
  const HostRosterSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextSectionWidth),
          gapH14,
          for (var i = 0; i < count; i++) ...[
            Row(
              children: [
                CatchSkeleton.circle(
                  size: CatchLayout.skeletonAvatarCompactExtent,
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CatchSkeleton.text(
                        width: i.isEven
                            ? CatchLayout.skeletonTextSecondaryWidth
                            : CatchLayout.skeletonTextDetailWideWidth,
                      ),
                      gapH6,
                      CatchSkeleton.text(
                        width: i == count - 1
                            ? CatchLayout.skeletonTextBodyWidth
                            : CatchLayout.skeletonTextBodyLongWidth,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (i < count - 1) gapH16,
          ],
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

class _HostAnalyticsMetricGridSkeleton extends StatelessWidget {
  const _HostAnalyticsMetricGridSkeleton();

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
