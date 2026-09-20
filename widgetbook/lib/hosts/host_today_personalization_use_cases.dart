import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_focus_screen.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_personalized_view.dart';
import 'package:catch_dating_app/hosts/today/personalization/domain/host_today_preference.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_focus_body.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_personalization_panel.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_personalization_state.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_state.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Covered by focus choice',
  type: HostTodayFocusScreen,
  path: '[P1 product surfaces]/Host Today',
)
@widgetbook.UseCase(
  name: 'Choose a focus',
  type: HostTodayFocusBody,
  path: '[P1 product surfaces]/Host Today',
)
Widget hostTodayFocusChoices(BuildContext context) => CatchRouteScaffold(
  topBarBuilder: (_, _) => const CatchTopBar(title: 'Your focus'),
  body: CatchRouteBody.standardConstrained(
    child: HostTodayFocusBody(
      selected: HostTodayFocus.audience,
      pending: false,
      onSelect: (_) {},
      onContinue: () {},
      onSkip: () {},
    ),
  ),
);

@widgetbook.UseCase(
  name: 'Covered by quiet roadmap',
  type: HostTodayPersonalizedView,
  path: '[P1 product surfaces]/Host Today',
)
@widgetbook.UseCase(
  name: 'Quiet day roadmap',
  type: HostTodayPersonalizationPanel,
  path: '[P1 product surfaces]/Host Today',
)
Widget hostTodayQuietRoadmap(BuildContext context) =>
    CatchRootScreenScaffold.sections(
      title: const Text('Today'),
      children: [
        SliverToBoxAdapter(
          child: HostTodayPersonalizationPanel(
            state: buildHostTodayPersonalizationState(
              today: const HostTodayState(status: HostTodayStatus.empty),
              preference: const HostTodayPreference.selected(
                HostTodayFocus.audience,
              ),
              evidence: const HostTodayRoadmapEvidence(
                audience: HostTodayMilestoneProgress.complete,
                rehearsal: HostTodayMilestoneProgress.incomplete,
                organizerPage: HostTodayMilestoneProgress.unknown,
                canManagePayouts: true,
              ),
            ),
            onChangeFocus: () {},
            onAction: (_) {},
          ),
        ),
      ],
    );
