import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/design_fixtures/host_operations_fixtures.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_invite_link.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/events/shared/attendance_sheet_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_attendance_panel.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_roster_drawer.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'manage_fixture.dart';
import 'preview.dart';

Widget _hostEventManageExactCatalog(BuildContext context, String focus) {
  return WidgetbookHostCatalog(
    title: focus,
    contractId:
        'component.host.event_manage.${widgetbookHostComponentSlug(focus)}',
    children: [
      WidgetbookHostStateCard(
        label: 'exact component',
        child: _HostManageComponentFrame(
          child: _hostEventManagePreviewFor(context, focus),
        ),
      ),
    ],
  );
}

Widget _hostEventManagePreviewFor(BuildContext context, String focus) {
  final event = HostOperationsFixtures.privateEvent;
  final club = HostOperationsFixtures.primaryClub;
  final roster = EventParticipationRoster.fromParticipations(
    HostOperationsFixtures.participations,
  );
  final viewModel = _hostAttendanceViewModel();
  final profiles = _hostAttendeeProfiles();
  final inviteCode = HostOperationsFixtures.privateAccess.inviteCode;
  final inviteLink = AppDeepLinks.event(
    clubId: club.id,
    eventId: event.id,
    inviteCode: inviteCode,
  ).toString();
  final filters = const [
    HostRosterFilterSpec(
      filter: HostRosterFilter.all,
      label: 'All',
      value: 3,
      tone: CatchBadgeTone.neutral,
    ),
    HostRosterFilterSpec(
      filter: HostRosterFilter.booked,
      label: 'Booked',
      value: 2,
      tone: CatchBadgeTone.success,
    ),
    HostRosterFilterSpec(
      filter: HostRosterFilter.waitlist,
      label: 'Waitlist',
      value: 1,
      tone: CatchBadgeTone.warning,
    ),
  ];
  return switch (focus) {
    'HostActionRow' => HostActionRow(
      label: 'Edit event details',
      detail: 'Schedule / location',
      onTap: () {},
    ),
    'HostEventActionsSection' => HostEventActionsSection(
      club: club,
      event: event,
      actionState: HostEventActionDisplayState.resolve(
        event: event,
        roster: roster,
        l10n: context.l10n,
        cancelEventPending: false,
        deleteEventPending: false,
      ),
      actionError: null,
      privateLinkActionState: HostPrivateLinkActionState.resolve(
        l10n: context.l10n,
        accessState: CatchAsyncState<EventPrivateAccess?>.data(
          HostOperationsFixtures.privateAccess,
        ),
        inviteLinksState: CatchAsyncState<List<EventInviteLink>>.data(
          HostOperationsFixtures.inviteLinks,
        ),
        inviteLink: inviteLink,
        sharePending: false,
      ),
      onEditEvent: () {},
      onCancelEvent: () async {},
      onDeleteEvent: () async {},
      onSharePrivateLink: (_) {},
    ),
    'HostEventAttendancePanel' => HostEventAttendancePanel(eventId: event.id),
    'HostEventParticipantsList' => HostEventParticipantsList(
      viewModel: viewModel,
      mode: HostEventParticipantsMode.live,
      scrollable: false,
      showSummaryHeader: true,
      initialSearchQuery: '',
      profileLookupState: HostParticipantProfilesLookupState(
        status: HostParticipantProfilesLookupStatus.ready,
        profileIds: viewModel.profileIds,
        profiles: profiles,
      ),
      mutationState: HostParticipantsMutationDisplayState.resolve(
        markAttendancePendingIds: const {},
        approveJoinRequestPendingIds: const {},
        declineJoinRequestPendingIds: const {},
        createWaitlistOfferPendingIds: const {},
        bulkWaitlistOfferPending: false,
        opsReportPending: false,
        revenueReportPending: false,
      ),
      actions: HostParticipantLifecycleActions(
        openProfile: (_) {},
        approveJoinRequest: (_) {},
        declineJoinRequest: (_) {},
        toggleAttendance: (_) {},
        createWaitlistOffers: (_) {},
        shareOpsReport: () async {},
        shareRevenueReport: () async {},
      ),
      onRetryProfiles: () {},
    ),
    'HostEventParticipantsPanel' => HostEventParticipantsPanel(
      eventId: event.id,
      mode: HostEventParticipantsMode.setup,
    ),
    'HostEventCheckInQrPanel' => HostEventCheckInQrPanel(event: event),
    'HostEventRosterHandle' => Center(
      child: SizedBox(
        width: CatchLayout.hostRosterDrawerHandleWidth,
        height: CatchLayout.hostRosterDrawerHandleHeight,
        child: HostEventRosterHandle(
          open: false,
          bookedCount: roster.bookedCount,
          onTap: () {},
          onHorizontalDragEnd: (_) {},
        ),
      ),
    ),
    'HostEventRosterPanel' => SizedBox(
      width: 360,
      height: 520,
      child: HostEventRosterPanel(
        bookedCount: roster.bookedCount,
        onClose: () {},
        child: const Center(child: Text('Guest roster content')),
      ),
    ),
    'HostEventRosterDrawer' => SizedBox(
      height: 620,
      child: HostEventRosterDrawer(
        open: true,
        bookedCount: roster.bookedCount,
        onOpenChanged: (_) {},
        body: const Center(child: Text('Live operations stay mounted')),
        roster: const Center(child: Text('Guest roster content')),
      ),
    ),
    'HostEventSummaryCard' => HostEventSummaryCard(club: club, event: event),
    'HostEventSummaryRow' => HostEventSummaryRow(
      icon: CatchIcons.locationOnOutlined,
      label: 'Meet',
      value: 'Carter Road Jetty',
    ),
    'HostFullCapacityApron' => HostFullCapacityApron(
      event: event,
      roster: roster,
    ),
    'HostFullCapacityBanner' => const HostFullCapacityBanner(),
    'HostInviteLinkRow' => HostInviteLinkRow(
      event: event,
      inviteCode: inviteCode,
      link: HostOperationsFixtures.inviteLinks.first,
      actionsDisabled: false,
      onCopyInviteLink: (_) {},
      onDisableInviteLink: (_) {},
    ),
    'HostInviteLinksList' => HostInviteLinksList(
      event: event,
      inviteCode: inviteCode,
      linksAsync: AsyncData<List<EventInviteLink>>(
        HostOperationsFixtures.inviteLinks,
      ),
      state: HostInviteLinksListDisplayState.resolve(
        createPending: false,
        copyPending: false,
        disablePending: false,
      ),
      mutationError: null,
      onRetry: () {},
      onCreateInviteLink: (_) async {},
      onCopyInviteLink: (_) {},
      onDisableInviteLink: (_) {},
    ),
    'HostParticipationLifecycleBoard' => HostParticipationLifecycleBoard(
      viewModel: viewModel,
      mode: HostEventParticipantsMode.live,
      profiles: profiles,
      scrollable: false,
      showHeader: true,
      usesRequestApproval: false,
      mutationState: HostParticipantsMutationDisplayState.resolve(
        markAttendancePendingIds: const {},
        approveJoinRequestPendingIds: const {},
        declineJoinRequestPendingIds: const {},
        createWaitlistOfferPendingIds: const {},
        bulkWaitlistOfferPending: false,
        opsReportPending: false,
        revenueReportPending: false,
      ),
      actions: HostParticipantLifecycleActions(
        openProfile: (_) {},
        approveJoinRequest: (_) {},
        declineJoinRequest: (_) {},
        toggleAttendance: (_) {},
        createWaitlistOffers: (_) {},
        shareOpsReport: () async {},
        shareRevenueReport: () async {},
      ),
      searchQuery: '',
      selectedFilter: HostRosterFilter.all,
      onSearchChanged: (_) {},
      onFilterChanged: (_) {},
    ),
    'HostPrivateAccessBody' => Consumer(
      builder: (context, ref, _) {
        final shareMutation = ref.watch(
          HostEventManageController.sharePrivateLinkMutation,
        );
        return HostPrivateAccessBody(
          event: event,
          state: HostPrivateAccessDisplayState.resolve(
            l10n: context.l10n,
            access: HostOperationsFixtures.privateAccess,
            inviteLinksState: CatchAsyncState<List<EventInviteLink>>.data(
              HostOperationsFixtures.inviteLinks,
            ),
            inviteLink: inviteLink,
            sharePending: shareMutation.isPending,
          ),
          inviteLinksAsync: AsyncData<List<EventInviteLink>>(
            HostOperationsFixtures.inviteLinks,
          ),
          shareMutation: shareMutation,
          inviteLinksListState: HostInviteLinksListDisplayState.resolve(
            createPending: false,
            copyPending: false,
            disablePending: false,
          ),
          inviteLinksMutationError: null,
          onRetryInviteLinks: () {},
          onSharePrivateLink: (_) {},
          onCreateInviteLink: (_) async {},
          onCopyInviteLink: (_) {},
          onDisableInviteLink: (_) {},
        );
      },
    ),
    'HostPrivateAccessCard' => Consumer(
      builder: (context, ref, _) => HostPrivateAccessCard(
        club: club,
        event: event,
        accessAsync: AsyncData<EventPrivateAccess?>(
          HostOperationsFixtures.privateAccess,
        ),
        inviteLinksAsync: AsyncData<List<EventInviteLink>>(
          HostOperationsFixtures.inviteLinks,
        ),
        shareMutation: ref.watch(
          HostEventManageController.sharePrivateLinkMutation,
        ),
        inviteLinksListState: HostInviteLinksListDisplayState.resolve(
          createPending: false,
          copyPending: false,
          disablePending: false,
        ),
        inviteLinksMutationError: null,
        onRetryPrivateAccess: () {},
        onRetryInviteLinks: () {},
        onSharePrivateLink: (_) {},
        onCreateInviteLink: (_) async {},
        onCopyInviteLink: (_) {},
        onDisableInviteLink: (_) {},
      ),
    ),
    'HostPrivateAccessShell' => const HostPrivateAccessShell(
      child: Text('Private access preview shell'),
    ),
    'HostRosterFilterHeader' => HostRosterFilterHeader(
      title: 'Participation',
      subtitle: 'Review booking status before launch.',
      filters: filters,
      selectedFilter: HostRosterFilter.all,
      onFilterChanged: (_) {},
    ),
    'HostRosterSearchBar' => HostRosterSearchBar(
      value: '',
      label: 'Search roster',
      onChanged: (_) {},
    ),
    'HostWaitlistBulkOfferAction' => HostWaitlistBulkOfferAction(
      count: 1,
      candidateCount: 3,
      isPending: false,
      onOffer: () {},
    ),
    _ => Text('No exact preview registered for $focus.'),
  };
}

AttendanceSheetViewModel _hostAttendanceViewModel() {
  final value = buildAttendanceSheetViewModel(
    eventAsync: AsyncData<Event?>(HostOperationsFixtures.privateEvent),
    participationsAsync: AsyncData<List<EventParticipation>>(
      HostOperationsFixtures.participations,
    ),
  );
  return value.asData!.value!;
}

Map<String, (String, String?)> _hostAttendeeProfiles() {
  return const {
    HostOperationsFixtures.guestUid: ('Aarav Mehta', null),
    HostOperationsFixtures.secondGuestUid: ('Rhea Kapoor', null),
    HostOperationsFixtures.waitlistUid: ('Kabir Jain', null),
  };
}

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostActionRow,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostActionRowCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostActionRow');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventRosterDrawer,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventRosterDrawerCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostEventRosterDrawer');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventRosterHandle,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventRosterHandleCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostEventRosterHandle');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventRosterPanel,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventRosterPanelCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostEventRosterPanel');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventActionsSection,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventActionsSectionCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostEventActionsSection');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventAttendancePanel,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventAttendancePanelCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostEventAttendancePanel');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventManageRouteScreen,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventManageRouteScreenCatalogStates(
  BuildContext context,
) => _hostEventManageExactCatalog(context, 'HostEventManageRouteScreen');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventParticipantsList,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventParticipantsListCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostEventParticipantsList');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventParticipantsPanel,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventParticipantsPanelCatalogStates(
  BuildContext context,
) => _hostEventManageExactCatalog(context, 'HostEventParticipantsPanel');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventSummaryCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventSummaryCardCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostEventSummaryCard');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventSummaryRow,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventSummaryRowCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostEventSummaryRow');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventCheckInQrPanel,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventCheckInQrPanelCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostEventCheckInQrPanel');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostFullCapacityApron,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostFullCapacityApronCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostFullCapacityApron');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostFullCapacityBanner,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostFullCapacityBannerCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostFullCapacityBanner');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostInviteLinkRow,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostInviteLinkRowCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostInviteLinkRow');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostInviteLinksList,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostInviteLinksListCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostInviteLinksList');

class _HostManageComponentFrame extends StatelessWidget {
  const _HostManageComponentFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WidgetbookHostDeviceFrame(
      child: WidgetbookHostManageRouteScope(
        child: WidgetbookHostComponentScaffold(child: child),
      ),
    );
  }
}
