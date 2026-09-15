import 'package:catch_dating_app/event_success/presentation/event_success_host_screen_state.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_skeletons.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class EventSuccessHostSectionSkeleton extends StatelessWidget {
  const EventSuccessHostSectionSkeleton({
    super.key,
    this.initialTab = EventSuccessHostTab.setup,
    this.showTabs = true,
  });

  final EventSuccessHostTab initialTab;
  final bool showTabs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTabs) ...[
          const CatchSkeleton.boxes(
            count: 3,
            height: CatchLayout.controlCompactMinHeight,
            radius: CatchRadius.sm,
            gap: CatchSpacing.s2,
          ),
          gapH16,
        ],
        switch (initialTab) {
          EventSuccessHostTab.setup => const EventSuccessSetupTabSkeleton(),
          EventSuccessHostTab.live => const EventSuccessLiveTabSkeleton(),
          EventSuccessHostTab.report => const EventSuccessReportTabSkeleton(),
        },
      ],
    );
  }
}

class EventSuccessSetupTabSkeleton extends StatelessWidget {
  const EventSuccessSetupTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatchSectionList.inset(
      emptyStateOmitted: true,
      padding: EdgeInsets.zero,
      gap: CatchSpacing.s3,
      children: [
        EventSuccessSkeletonSurface(
          titleWidth: CatchLayout.skeletonTextActionLabelWidth,
          textLines: 3,
          trailingCount: 3,
        ),
        EventSuccessSetupControlsSkeleton(),
        EventSuccessSkeletonSurface(
          titleWidth: CatchLayout.skeletonTextWideWidth,
          textLines: 2,
          trailingCount: 2,
        ),
      ],
    );
  }
}

class EventSuccessLiveTabSkeleton extends StatelessWidget {
  const EventSuccessLiveTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatchSectionList.inset(
      emptyStateOmitted: true,
      padding: EdgeInsets.zero,
      gap: CatchSpacing.s3,
      children: [
        EventSuccessSkeletonSurface(
          titleWidth: CatchLayout.skeletonTextInlineTitleWidth,
          textLines: 2,
          trailingCount: 2,
        ),
        CatchSkeleton.rows(titleWidth: CatchLayout.skeletonTextTitleWidth),
        EventSuccessSkeletonSurface(
          titleWidth: CatchLayout.skeletonTextLongWidth,
          textLines: 3,
          trailingCount: 0,
        ),
      ],
    );
  }
}

class EventSuccessReportTabSkeleton extends StatelessWidget {
  const EventSuccessReportTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatchSectionList.inset(
      emptyStateOmitted: true,
      padding: EdgeInsets.zero,
      gap: CatchSpacing.s3,
      children: [
        EventSuccessReportMetricsSkeleton(),
        EventSuccessSkeletonSurface(
          titleWidth: CatchLayout.skeletonTextCardTitleWidth,
          textLines: 3,
          trailingCount: 2,
        ),
        EventSuccessSkeletonSurface(
          titleWidth: CatchLayout.skeletonTextBodyWideWidth,
          textLines: 2,
          trailingCount: 0,
        ),
      ],
    );
  }
}

class EventSuccessSetupControlsSkeleton extends StatelessWidget {
  const EventSuccessSetupControlsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        children: [
          for (var i = 0; i < 4; i++) ...[
            Row(
              children: [
                CatchSkeleton.box(
                  width: CatchLayout.toggleTrackWidth,
                  height: CatchLayout.toggleTrackHeight,
                  radius: CatchRadius.pill,
                ),
                gapW12,
                Expanded(child: CatchSkeleton.text()),
              ],
            ),
            if (i < 3) gapH14,
          ],
        ],
      ),
    );
  }
}

class EventSuccessReportMetricsSkeleton extends StatelessWidget {
  const EventSuccessReportMetricsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextSectionWideWidth),
          gapH14,
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CatchSkeleton.text(
                        width: CatchLayout.skeletonTextValueWidth,
                      ),
                      gapH8,
                      CatchSkeleton.text(
                        width: CatchLayout.skeletonTextStatusWidth,
                      ),
                    ],
                  ),
                ),
                if (i < 2) gapW12,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
