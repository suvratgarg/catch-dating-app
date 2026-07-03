import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/create_event_step_header.dart';
import 'package:flutter/material.dart';

class HostCreateEventRouteLoadingScreen extends StatelessWidget {
  const HostCreateEventRouteLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            CreateEventStepHeader(
              title: 'Event basics',
              clubName: 'Loading club',
              currentStep: 0,
              totalSteps: 5,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            gapH4,
            const Expanded(child: CreateEventLoadingBody()),
            const CreateEventLoadingFooter(),
          ],
        ),
      ),
    );
  }
}

class CreateEventLoadingBody extends StatelessWidget {
  const CreateEventLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.s4,
        CatchSpacing.s4,
        CatchSpacing.s6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextInlineTitleWidth),
          gapH12,
          CatchSkeleton.card(
            height: CatchLayout.hostCreateEventRouteFormSkeletonHeight,
          ),
          gapH24,
          CatchSkeleton.text(width: CatchLayout.skeletonTextPageTitleWidth),
          gapH12,
          const LoadingChipRow(widths: [168, 108]),
          gapH10,
          const LoadingChipRow(widths: [212]),
          gapH18,
          CatchSkeleton.text(width: CatchLayout.skeletonTextBodyWidth),
          gapH12,
          CatchSkeleton.textBlock(),
        ],
      ),
    );
  }
}

class LoadingChipRow extends StatelessWidget {
  const LoadingChipRow({super.key, required this.widths});

  final List<double> widths;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        for (final width in widths)
          CatchSkeleton.box(
            width: width,
            height: CatchLayout.controlMdMinHeight,
            radius: CatchRadius.pill,
          ),
      ],
    );
  }
}

class CreateEventLoadingFooter extends StatelessWidget {
  const CreateEventLoadingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: t.bg,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          CatchSpacing.s4,
          CatchSpacing.s3,
          CatchSpacing.s4,
          CatchSpacing.s3 + bottomPadding,
        ),
        child: Row(
          children: [
            CatchSkeleton.box(
              width: CatchLayout.skeletonTextBodyWidth,
              height: CatchLayout.buttonLgHeight,
              radius: CatchRadius.pill,
            ),
            gapW12,
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: CatchSkeleton.box(
                  width: CatchLayout.skeletonTextInlineTitleWidth,
                  height: CatchLayout.buttonLgHeight,
                  radius: CatchRadius.pill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
