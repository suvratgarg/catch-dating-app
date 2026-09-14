import 'package:catch_dating_app/design_fixtures/host_operations_fixtures.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_card.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_controller_card.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_team_management_section.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'fixtures.dart';
import 'preview.dart';
import 'shell_fixture.dart';

Widget _hostClubExactCatalog(BuildContext context, String focus) {
  return WidgetbookHostCatalog(
    title: focus,
    contractId: 'component.host.club.${widgetbookHostComponentSlug(focus)}',
    children: [
      WidgetbookHostStateCard(
        label: 'exact component',
        child: WidgetbookHostComponentFrame(child: _hostClubPreviewFor(focus)),
      ),
    ],
  );
}

Widget _hostClubPreviewFor(String focus) {
  final club = HostOperationsFixtures.primaryClub;
  final events =
      HostOperationsFixtures.eventsByClub[club.id] ?? const <Event>[];
  final metricItems = [
    const HostOrganizerMetricItem(value: '188', label: 'Members'),
    const HostOrganizerMetricItem(value: '4.6', label: 'Rating'),
  ];
  final team = club.displayHostProfiles;
  final payment = HostOperationsFixtures.readyPaymentAccount;
  return switch (focus) {
    'HostClubInsightsPane' => HostClubInsightsPane(club: club),
    'HostClubOrganizerOverview' => HostClubOrganizerOverview(
      club: club,
      eventsLoaded: true,
      eventCount: events.length,
      activeEventCount: events.where((event) => !event.isCancelled).length,
    ),
    'HostClubOrganizerOverviewController' =>
      HostClubOrganizerOverviewController(club: club),
    'HostClubEditTab' => HostClubEditTab(
      club: club,
      currentUid: widgetbookHostUid,
      isOwner: true,
    ),
    'HostEventsClubCard' => HostEventsClubCard(
      club: club,
      onEventEntrySelected: (_, _, _) {},
      onManageEvent: (_, _) {},
      now: HostOperationsFixtures.now,
      sessionBoundary: HostOperationsFixtures.now,
    ),
    'HostOrganizerMetricGrid' => HostOrganizerMetricGrid(
      club: club,
      eventsLoaded: true,
      eventCount: events.length,
      activeEventCount: events.where((event) => !event.isCancelled).length,
    ),
    'HostOrganizerMetricRow' => HostOrganizerMetricRow(items: metricItems),
    'HostPaymentAccountCard' => HostPaymentAccountCard(
      club: club,
      account: payment,
    ),
    'HostPaymentAccountControllerCard' => HostPaymentAccountControllerCard(
      club: club,
    ),
    'HostPaymentAccountContentCard' => HostPaymentAccountContentCard(
      accounts: [payment],
      recommendedProvider: HostPaymentProvider.razorpay,
      actionErrorMessage: null,
      onboardingPending: false,
      refreshPending: false,
      onShowPayoutsHandoff: (_, _, _) async {},
      onRefresh: (_) async {},
    ),
    'HostPaymentAccountErrorCard' => HostPaymentAccountErrorCard(
      error: StateError('Widgetbook payout status failed'),
      onRetry: () {},
    ),
    'HostPaymentAccountLoadingCard' => const HostPaymentAccountLoadingCard(),
    'HostTeamManagementSection' => HostTeamManagementSection(
      club: club,
      currentUid: widgetbookHostUid,
      canManage: true,
    ),
    'HostTeamOwnerHostRow' => HostTeamOwnerHostRow(
      host: team.first,
      canManage: true,
      onTransfer: () {},
      onRemove: () {},
    ),
    _ => Text('No exact preview registered for $focus.'),
  };
}

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostClubInsightsPane,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostClubInsightsPaneCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostClubInsightsPane');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostClubOrganizerOverview,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostClubOrganizerOverviewCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostClubOrganizerOverview');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostClubOrganizerOverviewController,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostClubOrganizerOverviewControllerCatalogStates(
  BuildContext context,
) => _hostClubExactCatalog(context, 'HostClubOrganizerOverviewController');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostClubEditTab,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostClubEditTabCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostClubEditTab');

@widgetbook.UseCase(
  name: 'Owner loaded',
  type: HostClubEventDefaultsScreen,
  path: '[P1 product surfaces]/Host operations/Club settings spokes',
)
Widget hostClubEventDefaultsScreenLoaded(BuildContext context) =>
    WidgetbookHostShellScope(
      child: HostClubEventDefaultsScreen(
        clubId: HostOperationsFixtures.primaryClub.id,
      ),
    );

@widgetbook.UseCase(
  name: 'Owner loaded',
  type: HostClubLiveGuideScreen,
  path: '[P1 product surfaces]/Host operations/Club settings spokes',
)
Widget hostClubLiveGuideScreenLoaded(BuildContext context) =>
    WidgetbookHostShellScope(
      child: HostClubLiveGuideScreen(
        clubId: HostOperationsFixtures.primaryClub.id,
      ),
    );

@widgetbook.UseCase(
  name: 'Owner loaded',
  type: HostClubTeamScreen,
  path: '[P1 product surfaces]/Host operations/Club settings spokes',
)
Widget hostClubTeamScreenLoaded(BuildContext context) =>
    WidgetbookHostShellScope(
      child: HostClubTeamScreen(clubId: HostOperationsFixtures.primaryClub.id),
    );

@widgetbook.UseCase(
  name: 'Owner loaded',
  type: HostClubPaymentsScreen,
  path: '[P1 product surfaces]/Host operations/Club settings spokes',
)
Widget hostClubPaymentsScreenLoaded(BuildContext context) =>
    WidgetbookHostShellScope(
      child: HostClubPaymentsScreen(
        clubId: HostOperationsFixtures.primaryClub.id,
      ),
    );

@widgetbook.UseCase(
  name: 'Resolver states',
  type: HostClubSpokeResolver,
  path: '[P1 product surfaces]/Host operations/Club settings spokes',
)
Widget hostClubSpokeResolverStates(BuildContext context) =>
    hostClubEventDefaultsScreenLoaded(context);

@widgetbook.UseCase(
  name: 'Canonical scaffold',
  type: HostClubSpokeScaffold,
  path: '[P1 product surfaces]/Host operations/Club settings spokes',
)
Widget hostClubSpokeScaffoldStates(BuildContext context) =>
    hostClubEventDefaultsScreenLoaded(context);

@widgetbook.UseCase(
  name: 'Optimistic editor',
  type: HostClubDefaultsEditor,
  path: '[P1 product surfaces]/Host operations/Club settings spokes',
)
Widget hostClubDefaultsEditorStates(BuildContext context) =>
    hostClubEventDefaultsScreenLoaded(context);

@widgetbook.UseCase(
  name: 'Co-host read only',
  type: HostClubReadOnlyEventDefaults,
  path: '[P1 product surfaces]/Host operations/Club settings spokes',
)
Widget hostClubReadOnlyEventDefaultsStates(BuildContext context) =>
    hostClubEventDefaultsScreenLoaded(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventsClubCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventsClubCardCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostEventsClubCard');
