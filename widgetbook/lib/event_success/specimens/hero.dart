import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_hero_surface.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_progress_status.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'preview.dart';

@widgetbook.UseCase(
  name: "EventSuccessHeroSurface",
  type: EventSuccessHeroSurface,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Feature block folded states",
)
Widget eventSuccessStrictEventSuccessHeroSurface(BuildContext context) {
  final t = CatchTokens.of(context);
  return StrictCoverageScaffold(
    componentName: "EventSuccessHeroSurface",
    child: EventSuccessHeroSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Event success hero shell",
            style: CatchTextStyles.headline(context, color: t.accentInk),
          ),
          gapH8,
          Text(
            "Shared accent-to-ink surface for preview, lab, and manual QA heroes.",
            style: CatchTextStyles.bodyL(
              context,
              color: t.accentInk.withValues(
                alpha: CatchOpacity.eventSuccessPreviewMeta,
              ),
            ),
          ),
          gapH16,
          const Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge.onDark(label: "Preview"),
              CatchBadge.onDark(label: "Lab"),
              CatchBadge.onDark(label: "Manual QA"),
            ],
          ),
        ],
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: "EventSuccessMetricPill",
  type: EventSuccessMetricPill,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Feature block folded states",
)
Widget eventSuccessStrictEventSuccessMetricPill(BuildContext context) {
  return const StrictCoverageScaffold(
    componentName: "EventSuccessMetricPill",
    child: Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        EventSuccessMetricPill(label: "Pacing", value: 0.78),
        EventSuccessMetricPill(label: "Responses", value: 1),
        EventSuccessMetricPill(label: "Coverage", value: 0),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: "LiveStepRow",
  type: LiveStepRow,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Feature block folded states",
)
Widget eventSuccessStrictLiveStepRow(BuildContext context) {
  final steps = EventSuccessPlaybookLibrary.socialRun.runOfShow
      .take(3)
      .toList();
  return StrictCoverageScaffold(
    componentName: "LiveStepRow",
    child: Column(
      children: [
        for (final entry in steps.indexed)
          LiveStepRow(
            step: entry.$2,
            state: EventSuccessProgressStatus.fromPosition(
              index: entry.$1,
              currentIndex: 1,
            ),
          ),
      ],
    ),
  );
}
