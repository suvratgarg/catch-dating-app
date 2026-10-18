import 'package:catch_dating_app/swipes/shared/profile_surface/profile_body.dart';
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
  type: ProfileSection,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSectionViewStates(BuildContext context) {
  final section =
      widgetbookCatchesProfileSection<ProfileCompatibilitySectionData>(context);
  return WidgetbookPageCatalogFrame(
    title: 'ProfileSection',
    contractId: 'screen.catches.profile.section_view',
    children: [
      WidgetbookPageStateCard(
        label: 'passive section',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.stateViewportHeight,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileSection(section: section),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'reactable section',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.routeViewportHeight,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileSection(
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
  type: ProfileKickerText,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSectionKickerStates(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'ProfileKickerText',
    contractId: 'screen.catches.profile.section_kicker',
    children: [
      WidgetbookPageStateCard(
        label: 'mono label',
        child: ProfileKickerText('Running rhythm'),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Compatibility states',
  type: ProfileCompatibilitySection,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileCompatibilityStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProfileCompatibilitySection',
    contractId: 'screen.catches.profile.compatibility',
    children: [
      WidgetbookPageStateCard(
        label: 'reasons and signals',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.routeViewportHeight,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileCompatibilitySection(
              section:
                  widgetbookCatchesProfileSection<
                    ProfileCompatibilitySectionData
                  >(context),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Prompt states',
  type: ProfilePromptSection,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profilePromptStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProfilePromptSection',
    contractId: 'screen.catches.profile.prompt',
    children: [
      WidgetbookPageStateCard(
        label: 'prompt answer',
        child: ProfilePromptSection(
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
  type: ProfileRunningSection,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileRunningStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProfileRunningSection',
    contractId: 'screen.catches.profile.running',
    children: [
      WidgetbookPageStateCard(
        label: 'running rhythm',
        child: Center(
          child: WidgetbookContentFrame(
            child: Padding(
              padding: CatchInsets.content,
              child: ProfileRunningSection(
                section:
                    widgetbookCatchesProfileSection<ProfileRunningSectionData>(
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
  type: ProfileFactsSection,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileFactsStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProfileFactsSection',
    contractId: 'screen.catches.profile.facts',
    children: [
      WidgetbookPageStateCard(
        label: 'details',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.routeViewportHeight,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileFactsSection(
              section: widgetbookCatchesProfileSection<ProfileFactsSectionData>(
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
  type: ProfileDivider,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileRuleStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return WidgetbookPageCatalogFrame(
    title: 'ProfileDivider',
    contractId: 'screen.catches.profile.rule',
    children: [
      WidgetbookPageStateCard(
        label: 'hairline',
        child: ProfileDivider(color: t.line),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile surface rule states',
  type: ProfileSurfaceDivider,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSurfaceRuleStates(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'ProfileSurfaceDivider',
    contractId: 'screen.catches.profile.surface_rule',
    children: [
      WidgetbookPageStateCard(
        label: 'section divider',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.skeletonListItemHeight,
          child: ProfileSurfaceDivider(),
        ),
      ),
    ],
  );
}
