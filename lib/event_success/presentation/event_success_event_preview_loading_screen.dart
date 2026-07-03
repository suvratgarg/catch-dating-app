import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_skeletons.dart';
import 'package:flutter/material.dart';

class EventSuccessEventPreviewLoadingScreen extends StatelessWidget {
  const EventSuccessEventPreviewLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Event success preview', border: true),
      body: const SafeArea(child: EventSuccessEventPreviewLoadingBody()),
    );
  }
}

class EventSuccessEventPreviewLoadingBody extends StatelessWidget {
  const EventSuccessEventPreviewLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: const Padding(
                padding: CatchInsets.pageBodyRelaxed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EventPreviewHeroSkeleton(),
                    gapH16,
                    EventPreviewNotesSkeleton(),
                    gapH16,
                    EventPreviewSetupSkeleton(),
                    gapH16,
                    EventPreviewLiveSkeleton(),
                    gapH16,
                    EventPreviewCompanionSkeleton(),
                    gapH16,
                    EventPreviewReportSkeleton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EventPreviewHeroSkeleton extends StatelessWidget {
  const EventPreviewHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [t.accent, t.ink],
      ),
      borderColor: t.surface.withValues(alpha: CatchOpacity.none),
      padding: CatchInsets.contentRelaxed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchSkeleton.box(
                width: CatchLayout.skeletonTextCompactWidth,
                height: CatchLayout.badgeActionHeight,
                radius: CatchRadius.pill,
              ),
              CatchSkeleton.box(
                width: CatchLayout.skeletonTextLabelWidth,
                height: CatchLayout.badgeActionHeight,
                radius: CatchRadius.pill,
              ),
            ],
          ),
          gapH20,
          CatchSkeleton.text(width: CatchLayout.skeletonTextHeroWideWidth),
          gapH10,
          CatchSkeleton.text(width: CatchLayout.skeletonTextLongWidth),
          gapH20,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (var i = 0; i < 4; i++)
                CatchSkeleton.box(
                  width: i == 0
                      ? CatchLayout.skeletonTextLabelWidth
                      : CatchLayout.skeletonTextMetaLabelWidth,
                  height: CatchLayout.badgeActionHeight,
                  radius: CatchRadius.pill,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class EventPreviewNotesSkeleton extends StatelessWidget {
  const EventPreviewNotesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const EventSuccessSkeletonSurface(
      titleWidth: CatchLayout.skeletonTextFeatureWidth,
      textLines: 3,
      trailingCount: 0,
    );
  }
}

class EventPreviewSetupSkeleton extends StatelessWidget {
  const EventPreviewSetupSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const EventSuccessSkeletonSurface(
      titleWidth: CatchLayout.skeletonTextWideWidth,
      textLines: 3,
      trailingCount: 3,
    );
  }
}

class EventPreviewLiveSkeleton extends StatelessWidget {
  const EventPreviewLiveSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const EventSuccessSkeletonSurface(
      titleWidth: CatchLayout.skeletonTextTitleWidth,
      textLines: 2,
      trailingCount: 2,
    );
  }
}

class EventPreviewCompanionSkeleton extends StatelessWidget {
  const EventPreviewCompanionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const EventSuccessSkeletonSurface(
      titleWidth: CatchLayout.skeletonTextActionLabelWidth,
      textLines: 3,
      trailingCount: 1,
    );
  }
}

class EventPreviewReportSkeleton extends StatelessWidget {
  const EventPreviewReportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const EventSuccessSkeletonSurface(
      titleWidth: CatchLayout.skeletonTextBodyLongWidth,
      textLines: 2,
      trailingCount: 3,
    );
  }
}
