import 'package:catch_dating_app/swipes/shared/profile_surface/catch_profile_view.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_surface.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_view.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Section dispatch states',
  type: ProfileSectionView,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSectionViewStates(BuildContext context) {
  final section = widgetbookCatchesProfileSection<ProfileCompatibilitySection>(
    context,
  );
  return WidgetbookPageCatalogFrame(
    title: 'ProfileSectionView',
    contractId: 'screen.catches.profile.section_view',
    children: [
      WidgetbookPageStateCard(
        label: 'passive section',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.stateViewportHeight,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileSectionView(section: section),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'reactable section',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.routeViewportHeight,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileSectionView(
              section: section,
              onReact: widgetbookCatchesNoopReaction,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Section kicker states',
  type: ProfileSectionKicker,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSectionKickerStates(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'ProfileSectionKicker',
    contractId: 'screen.catches.profile.section_kicker',
    children: [
      WidgetbookPageStateCard(
        label: 'mono label',
        child: ProfileSectionKicker('Running rhythm'),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Compatibility states',
  type: ProfileCompatibility,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileCompatibilityStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProfileCompatibility',
    contractId: 'screen.catches.profile.compatibility',
    children: [
      WidgetbookPageStateCard(
        label: 'reasons and signals',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.routeViewportHeight,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileCompatibility(
              section:
                  widgetbookCatchesProfileSection<ProfileCompatibilitySection>(
                    context,
                  ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Prompt states',
  type: ProfilePrompt,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profilePromptStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProfilePrompt',
    contractId: 'screen.catches.profile.prompt',
    children: [
      WidgetbookPageStateCard(
        label: 'prompt answer',
        child: ProfilePrompt(
          section: widgetbookCatchesProfileSection<ProfilePromptSectionData>(
            context,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Running states',
  type: ProfileRunning,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileRunningStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProfileRunning',
    contractId: 'screen.catches.profile.running',
    children: [
      WidgetbookPageStateCard(
        label: 'running rhythm',
        child: Center(
          child: WidgetbookContentFrame(
            child: Padding(
              padding: CatchInsets.content,
              child: ProfileRunning(
                section: widgetbookCatchesProfileSection<ProfileRunningSection>(
                  context,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Running stat states',
  type: CatchMetricTile,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget runningStatStates(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'CatchMetricTile',
    contractId: 'screen.catches.profile.running_stat',
    children: [
      WidgetbookPageStateCard(
        label: 'pace',
        child: CatchMetricTile(label: 'Pace', value: '5:30/km'),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Facts states',
  type: ProfileFacts,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileFactsStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProfileFacts',
    contractId: 'screen.catches.profile.facts',
    children: [
      WidgetbookPageStateCard(
        label: 'details',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.routeViewportHeight,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileFacts(
              section: widgetbookCatchesProfileSection<ProfileFactsSection>(
                context,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Rule states',
  type: ProfileRule,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileRuleStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return WidgetbookPageCatalogFrame(
    title: 'ProfileRule',
    contractId: 'screen.catches.profile.rule',
    children: [
      WidgetbookPageStateCard(
        label: 'hairline',
        child: ProfileRule(color: t.line),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile surface rule states',
  type: ProfileSurfaceRule,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSurfaceRuleStates(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'ProfileSurfaceRule',
    contractId: 'screen.catches.profile.surface_rule',
    children: [
      WidgetbookPageStateCard(
        label: 'section divider',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.skeletonListItemHeight,
          child: ProfileSurfaceRule(),
        ),
      ),
    ],
  );
}
