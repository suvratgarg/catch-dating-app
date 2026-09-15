import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class EventSuccessCompanionLoadingPageBody extends StatelessWidget {
  const EventSuccessCompanionLoadingPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: CatchInsets.pageBodyRelaxed,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.maxContentWidth,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EventSuccessCompanionStageSkeleton(),
              gapH16,
              EventSuccessCompanionPrimaryActionSkeleton(),
              gapH16,
              CatchSkeleton.rows(
                titleWidth: CatchLayout.skeletonTextSectionWideWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventSuccessCompanionStageSkeleton extends StatelessWidget {
  const EventSuccessCompanionStageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.contentRelaxed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.box(
            width: CatchLayout.skeletonTextPillWidth,
            height: CatchLayout.badgeActionHeight,
            radius: CatchRadius.pill,
          ),
          gapH16,
          CatchSkeleton.text(width: CatchLayout.skeletonTextFeatureWidth),
          gapH10,
          CatchSkeleton.textBlock(),
          gapH18,
          Row(
            children: [
              Expanded(
                child: CatchSkeleton.box(
                  height: CatchLayout.controlMdMinHeight,
                  radius: CatchRadius.sm,
                ),
              ),
              gapW10,
              CatchSkeleton.box(
                width: CatchLayout.controlMdMinHeight,
                height: CatchLayout.controlMdMinHeight,
                radius: CatchRadius.sm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EventSuccessCompanionPrimaryActionSkeleton extends StatelessWidget {
  const EventSuccessCompanionPrimaryActionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextActionLabelWidth),
          gapH12,
          CatchSkeleton.textBlock(lines: 2),
          gapH16,
          CatchSkeleton.box(
            height: CatchLayout.controlMdMinHeight,
            radius: CatchRadius.sm,
          ),
        ],
      ),
    );
  }
}
