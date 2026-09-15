import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/design_fixtures/event_success_companion_fixtures.dart';
import 'package:catch_dating_app/event_success/domain/event_success_coach.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen_state.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_workspace_page_body.dart';
import 'package:catch_dating_app/event_success/presentation/host_components/event_success_host_section_skeleton.dart';
import 'package:catch_dating_app/event_success/presentation/host_report/event_success_funnel_section.dart';
import 'package:catch_dating_app/event_success/presentation/host_report/event_success_host_report_page_body.dart';
import 'package:catch_dating_app/event_success/presentation/host_report/event_success_report_empty_state.dart';
import 'package:catch_dating_app/event_success/presentation/host_report/event_success_report_quality_section.dart';
import 'package:catch_dating_app/event_success/presentation/host_setup/event_success_host_setup_page_body.dart';
import 'package:catch_dating_app/event_success/presentation/host_setup/event_success_readiness_field.dart';
import 'package:catch_dating_app/event_success/presentation/host_setup/event_success_setup_notice_banner.dart';
import 'package:catch_dating_app/event_success/presentation/host_setup/event_success_target_attendees_field.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../support/widgetbook_harness.dart';

final _brief = EventSuccessCompanionFixtures.basePlan.buildBriefFromScorecard(
  event: EventSuccessCompanionFixtures.socialEvent,
  scorecard: EventSuccessSampleScorecards.strongSocialRun,
);

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessHostWorkspacePageBody,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget eventSuccessStrictEventSuccessHostPanel(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'EventSuccessHostWorkspacePageBody',
      catalogId: 'Event Success Host workspace',
      children: [
        EventSuccessHostWorkspacePageBody(
          event: EventSuccessCompanionFixtures.socialEvent,
          plan: EventSuccessCompanionFixtures.basePlan,
          planIsPersisted: true,
          roster: EventParticipationRoster.empty(),
          embedded: true,
          showTabs: true,
          referenceNow: EventSuccessCompanionFixtures.now,
        ),
      ],
    );

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessHostSetupPageBody,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget eventSuccessStrictSetupTab(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'EventSuccessHostSetupPageBody',
      catalogId: 'Event Success Host workspace',
      children: [
        EventSuccessHostSetupPageBody(
          event: EventSuccessCompanionFixtures.socialEvent,
          plan: EventSuccessCompanionFixtures.basePlan,
          planIsPersisted: true,
          organizerLayoutsState: const CatchAsyncState.data([]),
          layoutSavePending: false,
          layoutSaveError: null,
          onSaveLayout: null,
          actionState: const EventSuccessSetupActionState(),
          onSaveSetup: (_) async {},
          embedded: true,
          referenceNow: EventSuccessCompanionFixtures.now,
        ),
      ],
    );

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessTargetAttendeesField,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget eventSuccessStrictTargetAttendeeControl(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'EventSuccessTargetAttendeesField',
      catalogId: 'Event Success Host workspace',
      children: [
        EventSuccessTargetAttendeesField(
          value: 18,
          recommendedMin: 12,
          recommendedMax: 30,
          enabled: true,
          onChanged: (_) {},
        ),
      ],
    );

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessReadinessField,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget eventSuccessStrictReadinessIssues(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'EventSuccessReadinessField',
      catalogId: 'Event Success Host workspace',
      children: [
        const EventSuccessReadinessField(
          issues: [
            'Choose the first live prompt.',
            'Confirm the attendee target.',
          ],
        ),
      ],
    );

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessSetupNoticeBanner,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget eventSuccessStrictNoticeCard(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'EventSuccessSetupNoticeBanner',
      catalogId: 'Event Success Host workspace',
      children: [
        EventSuccessSetupNoticeBanner(
          icon: CatchIcons.infoOutlineRounded,
          title: 'Setup notice',
          body: 'Check the guide before the event begins.',
        ),
      ],
    );

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessHostReportPageBody,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget eventSuccessStrictReportTab(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'EventSuccessHostReportPageBody',
      catalogId: 'Event Success Host workspace',
      children: [
        EventSuccessHostReportPageBody(
          event: EventSuccessCompanionFixtures.socialEvent,
          plan: EventSuccessCompanionFixtures.basePlan,
          planIsPersisted: true,
          scorecard: EventSuccessSampleScorecards.strongSocialRun,
          resourceFailures: const [],
          onRetryResource: (_) {},
          embedded: true,
        ),
      ],
    );

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessReportEmptyState,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget previewEventSuccessReportEmptyState(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'EventSuccessReportEmptyState',
      catalogId: 'Event Success Host workspace',
      children: [
        EventSuccessReportEmptyState(
          icon: CatchIcons.insightsOutlined,
          title: 'Waiting for attendee feedback',
          message: 'The report appears when attendee feedback is available.',
        ),
      ],
    );

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessReportQualitySection,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget eventSuccessStrictHostReportSignalGrid(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'EventSuccessReportQualitySection',
      catalogId: 'Event Success Host workspace',
      children: [EventSuccessReportQualitySection(brief: _brief)],
    );

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessFunnelSection,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget eventSuccessStrictHostFunnelSummary(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'EventSuccessFunnelSection',
      catalogId: 'Event Success Host workspace',
      children: [EventSuccessFunnelSection(brief: _brief)],
    );

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessHostSectionSkeleton,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget eventSuccessStrictEventSuccessHostSectionSkeleton(
  BuildContext context,
) => WidgetbookCatalogFrame(
  title: 'EventSuccessHostSectionSkeleton',
  catalogId: 'Event Success Host workspace',
  children: [const EventSuccessHostSectionSkeleton()],
);

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessSetupTabSkeleton,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget eventSuccessStrictEventSuccessSetupTabSkeleton(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'EventSuccessSetupTabSkeleton',
      catalogId: 'Event Success Host workspace',
      children: [const EventSuccessSetupTabSkeleton()],
    );

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessLiveTabSkeleton,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget eventSuccessStrictEventSuccessLiveTabSkeleton(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'EventSuccessLiveTabSkeleton',
      catalogId: 'Event Success Host workspace',
      children: [const EventSuccessLiveTabSkeleton()],
    );

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessReportTabSkeleton,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget eventSuccessStrictEventSuccessReportTabSkeleton(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'EventSuccessReportTabSkeleton',
      catalogId: 'Event Success Host workspace',
      children: [const EventSuccessReportTabSkeleton()],
    );

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessSetupControlsSkeleton,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget eventSuccessStrictEventSuccessSetupControlsSkeleton(
  BuildContext context,
) => WidgetbookCatalogFrame(
  title: 'EventSuccessSetupControlsSkeleton',
  catalogId: 'Event Success Host workspace',
  children: [const EventSuccessSetupControlsSkeleton()],
);

@widgetbook.UseCase(
  name: 'Ready',
  type: EventSuccessReportMetricsSkeleton,
  path: '[P1 product surfaces]/Event Success/Host workspace components',
)
Widget eventSuccessStrictEventSuccessReportMetricsSkeleton(
  BuildContext context,
) => WidgetbookCatalogFrame(
  title: 'EventSuccessReportMetricsSkeleton',
  catalogId: 'Event Success Host workspace',
  children: [const EventSuccessReportMetricsSkeleton()],
);
