import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/events/domain/event_invite_link.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/events/presentation/attendance_sheet_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/widgets/who_is_going.dart';
import 'package:catch_dating_app/hosts/data/host_analytics_repository.dart';
import 'package:catch_dating_app/hosts/data/host_profile_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_screen.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_create_club_screen.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_club_edit_controller.dart';
import 'package:catch_dating_app/hosts/presentation/edit_hosted_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_success_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_settings_state.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_team_management_controller.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_team_management_section.dart';
import 'package:catch_dating_app/labs/design_fixtures/host_operations_fixtures.dart';
import 'package:catch_dating_app/payments/data/host_payment_account_repository.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

final _hostUid = HostOperationsFixtures.hostUid;
final _club = HostOperationsFixtures.primaryClub;
final _privateEvent = HostOperationsFixtures.privateEvent;
final _editableEvent = HostOperationsFixtures.event(
  id: 'design-host-editable-event',
  club: _club,
  start: DateTime(2030, 7, 2, 18, 30),
  bookedCount: 0,
);
final _validationEvent = _editableEvent.copyWith(
  id: 'design-host-validation-event',
  meetingPoint: '',
  meetingLocation: const EventMeetingLocation(
    name: '',
    address: 'Carter Road, Bandra West',
    placeId: 'design-carter-road-empty-label',
    latitude: 19.0706,
    longitude: 72.8223,
    notes: 'Meet by the sea-facing steps',
  ),
  distanceKm: 0,
);
final _selectedLocationEvent = _editableEvent.copyWith(
  id: 'design-host-selected-location-event',
  meetingPoint: 'Carter Road Amphitheatre',
  meetingLocation: const EventMeetingLocation(
    name: 'Carter Road Amphitheatre',
    address: 'Carter Road, Bandra West',
    placeId: 'design-carter-road',
    latitude: 19.0706,
    longitude: 72.8223,
    notes: 'Meet by the sea-facing steps',
  ),
  startingPointLat: 19.0706,
  startingPointLng: 72.8223,
  locationDetails: 'Meet by the sea-facing steps',
);
final _customActivityEventDraft = HostOperationsFixtures.eventDraft.copyWith(
  id: 'design-host-event-custom-activity-draft',
  activityKind: 'openActivity',
  customActivityLabel: 'Salsa mixer',
  interactionModel: 'hostLedProgram',
  distance: null,
  paceName: null,
);
const _createClubSteps = <int, String>{
  0: 'basics step',
  1: 'details step',
  2: 'host defaults step',
  3: 'event success defaults step',
};

List<PickedClubPhoto> _createClubPickedPhotos() {
  return [
    _createClubPickedPhoto('club-cover-1'),
    _createClubPickedPhoto('club-cover-2'),
  ];
}

PickedClubPhoto _createClubPickedPhoto(String name) {
  final bytes = _createClubPngBytes();
  return PickedClubPhoto(
    image: XFile.fromData(bytes, name: '$name.png', mimeType: 'image/png'),
    bytes: bytes,
  );
}

PickedClubProfileImage _createClubProfileImage() {
  final bytes = _createClubPngBytes();
  return PickedClubProfileImage(
    image: XFile.fromData(
      bytes,
      name: 'club-profile.png',
      mimeType: 'image/png',
    ),
    bytes: bytes,
  );
}

List<PickedEventPhoto> _createEventPickedPhotos() {
  return [
    _createEventPickedPhoto('event-cover-1'),
    _createEventPickedPhoto('event-cover-2'),
  ];
}

PickedEventPhoto _createEventPickedPhoto(String name) {
  final bytes = _createClubPngBytes();
  return PickedEventPhoto(
    image: XFile.fromData(bytes, name: '$name.png', mimeType: 'image/png'),
    bytes: bytes,
  );
}

Uint8List _createClubPngBytes() {
  return base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAAFkl'
    'EQVR42mO4Y+DwnxTMMKphVAN2DAApmUpA0AfJaAAAAABJRU5ErkJggg==',
  );
}

HostProfile _hostProfileVariant(HostProfileStatus status) {
  final suffix = switch (status) {
    HostProfileStatus.active => 'Active',
    HostProfileStatus.pending => 'Pending',
    HostProfileStatus.suspended => 'Suspended',
  };
  return HostProfile(
    uid: _hostUid,
    displayName: 'Mira Shah',
    roleTitle: '$suffix host profile',
    bio:
        'Runs hosted event formats with clear arrival cues, structured prompts, and visible safety follow-through.',
    status: status,
    verified: status == HostProfileStatus.active,
    linkedClubIds: [HostOperationsFixtures.primaryClub.id],
    createdAt: HostOperationsFixtures.now.subtract(const Duration(days: 400)),
    updatedAt: HostOperationsFixtures.now.subtract(const Duration(days: 2)),
  );
}

@widgetbook.UseCase(
  name: 'Route states',
  type: HostOperationsHomeScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget hostHomeRouteStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostOperationsHomeScreen',
    contractId: 'screen.host.home',
    children: [
      _StateCard(
        label: 'auth required',
        child: const _DeviceFrame(
          child: _HostShellScope(uid: null, child: HostOperationsHomeScreen()),
        ),
      ),
      _StateCard(
        label: 'clubs loading',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostedClubsStream:
                HostOperationsFixtures.loadingStream<List<Club>>(),
            child: const HostOperationsHomeScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'clubs error',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostedClubsStream: HostOperationsFixtures.errorStream<List<Club>>(
              'Hosted clubs failed',
            ),
            child: const HostOperationsHomeScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'clubs offline',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostedClubsStream: Stream<List<Club>>.error(
              obviousOfflineException(),
              StackTrace.empty,
            ),
            child: const HostOperationsHomeScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'events offline',
        child: _DeviceFrame(
          child: _HostShellScope(
            clubEventStreams: {
              HostOperationsFixtures.dinnerClub.id: Stream<List<Event>>.error(
                obviousOfflineException(),
                StackTrace.empty,
              ),
            },
            child: HostOperationsHomeScreen(
              initialClubId: HostOperationsFixtures.dinnerClub.id,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'empty host account',
        child: const _DeviceFrame(
          child: _HostShellScope(
            hostedClubs: [],
            ownedClubs: [],
            child: HostOperationsHomeScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'populated host dashboard',
        child: const _DeviceFrame(
          child: _HostShellScope(child: HostOperationsHomeScreen()),
        ),
      ),
      _StateCard(
        label: 'co-host empty events',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostedClubs: [HostOperationsFixtures.coHostedClub],
            ownedClubs: const [],
            child: const HostOperationsHomeScreen(
              initialClubId: 'design-host-cohost-club',
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: const _DeviceFrame(
          child: _MediaOverride(
            textScaler: TextScaler.linear(2),
            child: _HostShellScope(child: HostOperationsHomeScreen()),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: const _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _HostShellScope(child: HostOperationsHomeScreen()),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: const _DeviceFrame(
          child: _HostShellScope(
            themeMode: ThemeMode.dark,
            child: HostOperationsHomeScreen(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Top bar states',
  type: HostOperationsTopBar,
  path: '[P1 product surfaces]/Host operations/Sections',
)
Widget hostOperationsTopBarStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostOperationsTopBar',
    contractId: 'section.host.home_top_bar',
    children: [
      _StateCard(
        label: 'title with kicker',
        child: const _HostHomeScaffoldFrame(
          child: Scaffold(
            appBar: HostOperationsTopBar(
              kicker: 'OPERATIONS',
              title: 'Sea Face Social',
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'club switcher action',
        child: _HostHomeScaffoldFrame(
          child: Scaffold(
            appBar: HostOperationsTopBar(
              kicker: 'OPERATIONS',
              title: 'Sea Face Social',
              actions: [
                CatchTopBarMenuAction<int>(
                  tooltip: 'Switch club',
                  items: const [
                    CatchActionMenuItem(value: 0, label: 'Sea Face Social'),
                    CatchActionMenuItem(value: 1, label: 'Long Table Club'),
                  ],
                  onSelected: (_) {},
                ),
              ],
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'compact large text',
        child: const _HostHomeScaffoldFrame(
          textScaler: TextScaler.linear(2),
          child: Scaffold(
            appBar: HostOperationsTopBar(
              kicker: 'OPERATIONS',
              title: 'Sea Face Social',
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Meta row states',
  type: HostMetaRow,
  path: '[P1 product surfaces]/Host operations/Sections',
)
Widget hostHomeMetaRowStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostMetaRow',
    contractId: 'section.host.home_meta_row',
    children: [
      _StateCard(
        label: 'owner club metadata',
        child: _HostHomeSectionFrame(
          child: HostMetaRow(club: _club, roleLabel: 'Owner', owner: true),
        ),
      ),
      _StateCard(
        label: 'host team metadata',
        child: _HostHomeSectionFrame(
          child: HostMetaRow(
            club: HostOperationsFixtures.coHostedClub,
            roleLabel: 'Host team',
            owner: false,
          ),
        ),
      ),
      _StateCard(
        label: 'missing area fallback',
        child: _HostHomeSectionFrame(
          child: HostMetaRow(
            club: _club.copyWith(area: '', location: ''),
            roleLabel: 'Owner',
            owner: true,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Event row states',
  type: HostEventRow,
  path: '[P1 product surfaces]/Host operations/Sections',
)
Widget hostHomeEventRowStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostEventRow',
    contractId: 'section.host.home_event_row',
    children: [
      _StateCard(
        label: 'first upcoming event',
        child: _HostHomeSectionFrame(
          child: HostEventRow(
            row: HostHomeEventRowData(
              event: HostOperationsFixtures.upcomingEvent,
              divider: false,
            ),
            onTap: () {},
          ),
        ),
      ),
      _StateCard(
        label: 'divided private event',
        child: _HostHomeSectionFrame(
          child: HostEventRow(
            row: HostHomeEventRowData(
              event: HostOperationsFixtures.privateEvent,
              divider: true,
            ),
            onTap: () {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Event section states',
  type: HostEventsClubCard,
  path: '[P1 product surfaces]/Host operations/Sections',
)
Widget hostHomeEventSectionStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostEventsClubCard',
    contractId: 'section.host.home_events',
    children: [
      _StateCard(
        label: 'owned club with upcoming rows',
        child: _HostHomeSectionFrame(
          child: HostEventsClubCard(
            club: _club,
            currentUid: _hostUid,
            onCreateEvent: (_) {},
            onManageEvent: (_, _) {},
          ),
        ),
      ),
      _StateCard(
        label: 'events loading',
        child: _HostHomeSectionFrame(
          clubEventStreams: {
            _club.id: HostOperationsFixtures.loadingStream<List<Event>>(),
          },
          child: HostEventsClubCard(
            club: _club,
            currentUid: _hostUid,
            onCreateEvent: (_) {},
            onManageEvent: (_, _) {},
          ),
        ),
      ),
      _StateCard(
        label: 'events error',
        child: _HostHomeSectionFrame(
          clubEventStreams: {
            _club.id: HostOperationsFixtures.errorStream<List<Event>>(
              'Upcoming events failed',
            ),
          },
          child: HostEventsClubCard(
            club: _club,
            currentUid: _hostUid,
            onCreateEvent: (_) {},
            onManageEvent: (_, _) {},
          ),
        ),
      ),
      _StateCard(
        label: 'events offline',
        child: _HostHomeSectionFrame(
          clubEventStreams: {
            _club.id: Stream<List<Event>>.error(
              obviousOfflineException(),
              StackTrace.empty,
            ),
          },
          child: HostEventsClubCard(
            club: _club,
            currentUid: _hostUid,
            onCreateEvent: (_) {},
            onManageEvent: (_, _) {},
          ),
        ),
      ),
      _StateCard(
        label: 'empty events',
        child: _HostHomeSectionFrame(
          clubEventStreams: {_club.id: Stream<List<Event>>.value(const [])},
          child: HostEventsClubCard(
            club: _club,
            currentUid: _hostUid,
            onCreateEvent: (_) {},
            onManageEvent: (_, _) {},
          ),
        ),
      ),
      _StateCard(
        label: 'cancelled events hidden',
        child: _HostHomeSectionFrame(
          clubEventStreams: {
            _club.id: Stream<List<Event>>.value([
              HostOperationsFixtures.cancelledEvent,
            ]),
          },
          child: HostEventsClubCard(
            club: _club,
            currentUid: _hostUid,
            onCreateEvent: (_) {},
            onManageEvent: (_, _) {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Route states',
  type: HostClubsScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget hostClubsRouteStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostClubsScreen',
    contractId: 'screen.host.clubs',
    children: [
      _StateCard(
        label: 'auth required',
        child: const _DeviceFrame(
          child: _HostShellScope(uid: null, child: HostClubsScreen()),
        ),
      ),
      _StateCard(
        label: 'clubs loading',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostedClubsStream:
                HostOperationsFixtures.loadingStream<List<Club>>(),
            child: const HostClubsScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'clubs error',
        child: _DeviceFrame(
          child: _HostShellScope(
            ownedClubsStream: HostOperationsFixtures.errorStream<List<Club>>(
              'Owned clubs failed',
            ),
            child: const HostClubsScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'clubs offline',
        child: _DeviceFrame(
          child: _HostShellScope(
            ownedClubsStream: Stream<List<Club>>.error(
              obviousOfflineException(),
              StackTrace.empty,
            ),
            child: const HostClubsScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'empty clubs',
        child: const _DeviceFrame(
          child: _HostShellScope(
            hostedClubs: [],
            ownedClubs: [],
            child: HostClubsScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'owner and co-host clubs',
        child: const _DeviceFrame(
          child: _HostShellScope(child: HostClubsScreen()),
        ),
      ),
      _StateCard(
        label: 'co-host limited edit',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostedClubs: [HostOperationsFixtures.coHostedClub],
            ownedClubs: const [],
            child: HostClubsScreen(
              initialClubId: HostOperationsFixtures.coHostedClub.id,
              initialTab: HostClubTab.edit,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'inline edit pending',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.inlinePending,
            child: _HostShellScope(
              child: HostClubsScreen(initialExpandedEditField: 'name'),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'inline edit error',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.inlineError,
            child: _HostShellScope(
              child: HostClubsScreen(initialExpandedEditField: 'name'),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'inline edit offline',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.inlineOffline,
            child: _HostShellScope(
              child: HostClubsScreen(initialExpandedEditField: 'name'),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'insights report',
        child: const _DeviceFrame(
          child: _HostShellScope(
            child: HostClubsScreen(initialTab: HostClubTab.insights),
          ),
        ),
      ),
      _StateCard(
        label: 'insights loading',
        child: const _DeviceFrame(
          child: _HostShellScope(
            analyticsRepository: _HostLoadingAnalyticsRepository(),
            child: HostClubsScreen(initialTab: HostClubTab.insights),
          ),
        ),
      ),
      _StateCard(
        label: 'insights error',
        child: _DeviceFrame(
          child: _HostShellScope(
            analyticsRepository: HostFixtureAnalyticsRepository(
              error: StateError('Widgetbook host analytics failed'),
            ),
            child: const HostClubsScreen(initialTab: HostClubTab.insights),
          ),
        ),
      ),
      _StateCard(
        label: 'insights offline',
        child: _DeviceFrame(
          child: _HostShellScope(
            analyticsRepository: HostFixtureAnalyticsRepository(
              error: obviousOfflineException(),
            ),
            child: const HostClubsScreen(initialTab: HostClubTab.insights),
          ),
        ),
      ),
      _StateCard(
        label: 'preview tab',
        child: const _DeviceFrame(
          child: _HostShellScope(
            child: HostClubsScreen(initialTab: HostClubTab.preview),
          ),
        ),
      ),
      _StateCard(
        label: 'payout loading',
        child: const _DeviceFrame(
          child: _HostShellScope(
            paymentAccountValue: AsyncLoading<HostPaymentAccount?>(),
            child: HostClubsScreen(initialTab: HostClubTab.edit),
          ),
        ),
      ),
      _StateCard(
        label: 'payout ready',
        child: const _DeviceFrame(
          child: _HostShellScope(
            paymentAccountValue: AsyncData<HostPaymentAccount?>(
              HostOperationsFixtures.readyPaymentAccount,
            ),
            child: HostClubsScreen(initialTab: HostClubTab.edit),
          ),
        ),
      ),
      _StateCard(
        label: 'payout restricted',
        child: const _DeviceFrame(
          child: _HostShellScope(
            paymentAccountValue: AsyncData<HostPaymentAccount?>(
              HostOperationsFixtures.restrictedPaymentAccount,
            ),
            child: HostClubsScreen(initialTab: HostClubTab.edit),
          ),
        ),
      ),
      _StateCard(
        label: 'payout error',
        child: _DeviceFrame(
          child: _HostShellScope(
            paymentAccountValue: AsyncError<HostPaymentAccount?>(
              StateError('Widgetbook payout status failed'),
              StackTrace.empty,
            ),
            child: const HostClubsScreen(initialTab: HostClubTab.edit),
          ),
        ),
      ),
      _StateCard(
        label: 'payout offline',
        child: _DeviceFrame(
          child: _HostShellScope(
            paymentAccountValue: AsyncError<HostPaymentAccount?>(
              obviousOfflineException(),
              StackTrace.empty,
            ),
            child: const HostClubsScreen(initialTab: HostClubTab.edit),
          ),
        ),
      ),
      _StateCard(
        label: 'payout setup pending',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.payoutSetupPending,
            child: _HostShellScope(
              child: HostClubsScreen(initialTab: HostClubTab.edit),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'payout setup error',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.payoutSetupError,
            child: _HostShellScope(
              child: HostClubsScreen(initialTab: HostClubTab.edit),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'payout setup offline',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.payoutSetupOffline,
            child: _HostShellScope(
              child: HostClubsScreen(initialTab: HostClubTab.edit),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'payout refresh pending',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.payoutRefreshPending,
            child: _HostShellScope(
              paymentAccountValue: AsyncData<HostPaymentAccount?>(
                HostOperationsFixtures.readyPaymentAccount,
              ),
              child: HostClubsScreen(initialTab: HostClubTab.edit),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'payout refresh error',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.payoutRefreshError,
            child: _HostShellScope(
              paymentAccountValue: AsyncData<HostPaymentAccount?>(
                HostOperationsFixtures.readyPaymentAccount,
              ),
              child: HostClubsScreen(initialTab: HostClubTab.edit),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'payout refresh offline',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.payoutRefreshOffline,
            child: _HostShellScope(
              paymentAccountValue: AsyncData<HostPaymentAccount?>(
                HostOperationsFixtures.readyPaymentAccount,
              ),
              child: HostClubsScreen(initialTab: HostClubTab.edit),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'host team pending',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.teamPending,
            child: _HostShellScope(child: _HostTeamSectionPreview()),
          ),
        ),
      ),
      _StateCard(
        label: 'host team error',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.teamError,
            child: _HostShellScope(child: _HostTeamSectionPreview()),
          ),
        ),
      ),
      _StateCard(
        label: 'host team offline',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.teamOffline,
            child: _HostShellScope(child: _HostTeamSectionPreview()),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: const _DeviceFrame(
          child: _MediaOverride(
            textScaler: TextScaler.linear(2),
            child: _HostShellScope(child: HostClubsScreen()),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: const _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _HostShellScope(child: HostClubsScreen()),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: const _DeviceFrame(
          child: _HostShellScope(
            themeMode: ThemeMode.dark,
            child: HostClubsScreen(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Add host sheet states',
  type: HostTeamAddHostSheet,
  path: '[P1 product surfaces]/Host operations/Sections',
)
Widget hostTeamAddHostSheetStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostTeamAddHostSheet',
    contractId: 'section.host.clubs_host_team',
    children: [
      _StateCard(
        label: 'ready',
        child: const _DeviceFrame(
          child: _HostShellScope(child: _HostTeamAddHostSheetPreview()),
        ),
      ),
      _StateCard(
        label: 'add pending',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.teamAddPending,
            child: _HostShellScope(child: _HostTeamAddHostSheetPreview()),
          ),
        ),
      ),
      _StateCard(
        label: 'add error',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.teamAddError,
            child: _HostShellScope(child: _HostTeamAddHostSheetPreview()),
          ),
        ),
      ),
      _StateCard(
        label: 'add offline',
        child: const _DeviceFrame(
          child: _HostClubsMutationPreview(
            mode: _HostClubsMutationPreviewMode.teamAddOffline,
            child: _HostShellScope(child: _HostTeamAddHostSheetPreview()),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Host action confirmation dialogs',
  type: HostTeamHostActionDialog,
  path: '[P1 product surfaces]/Host operations/Sections',
)
Widget hostTeamHostActionDialogStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostTeamHostActionDialog',
    contractId: 'section.host.clubs_host_team',
    children: const [
      _StateCard(
        label: 'remove host',
        child: _DeviceFrame(
          child: _HostShellScope(
            child: _HostTeamHostActionDialogPreview(
              action: HostTeamHostAction.remove,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'transfer ownership',
        child: _DeviceFrame(
          child: _HostShellScope(
            child: _HostTeamHostActionDialogPreview(
              action: HostTeamHostAction.transferOwnership,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Route states',
  type: HostAccountScreen,
  path: '[P2 host surfaces]/Host settings',
)
Widget hostSettingsRouteStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostAccountScreen',
    contractId: 'screen.host.settings',
    children: [
      _StateCard(
        label: 'auth required',
        child: const _DeviceFrame(
          child: _HostShellScope(uid: null, child: HostAccountScreen()),
        ),
      ),
      _StateCard(
        label: 'profile loading',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostedClubs: const [],
            ownedClubs: const [],
            hostProfileStream:
                HostOperationsFixtures.loadingStream<HostProfile?>(),
            child: const HostAccountScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'profile error',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostedClubs: const [],
            ownedClubs: const [],
            hostProfileStream: HostOperationsFixtures.errorStream<HostProfile?>(
              'Host profile failed',
            ),
            child: const HostAccountScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'no profile',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostedClubs: const [],
            ownedClubs: const [],
            hostProfileStream: Stream<HostProfile?>.value(null),
            child: const HostAccountScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'fallback profile from club',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostProfileStream:
                HostOperationsFixtures.loadingStream<HostProfile?>(),
            child: const HostAccountScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'active profile and clubs',
        child: const _DeviceFrame(
          child: _HostShellScope(child: HostAccountScreen()),
        ),
      ),
      _StateCard(
        label: 'clubs loading',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostedClubsStream:
                HostOperationsFixtures.loadingStream<List<Club>>(),
            child: const HostAccountScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'clubs error',
        child: _DeviceFrame(
          child: _HostShellScope(
            ownedClubsStream: HostOperationsFixtures.errorStream<List<Club>>(
              'Hosted clubs failed',
            ),
            child: const HostAccountScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: const _DeviceFrame(
          child: _MediaOverride(
            textScaler: TextScaler.linear(2),
            child: _HostShellScope(child: HostAccountScreen()),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: const _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _HostShellScope(child: HostAccountScreen()),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: const _DeviceFrame(
          child: _HostShellScope(
            themeMode: ThemeMode.dark,
            child: HostAccountScreen(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile summary states',
  type: HostSettingsProfileSection,
  path: '[P2 host surfaces]/Host settings',
)
Widget hostSettingsProfileSummaryStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostSettingsProfileSection',
    contractId: 'section.host.settings.profile_summary',
    children: [
      _StateCard(
        label: 'profile loading',
        child: const _DeviceFrame(
          child: _HostSettingsProfileFrame(state: HostSettingsProfileLoading()),
        ),
      ),
      _StateCard(
        label: 'profile error',
        child: _DeviceFrame(
          child: _HostSettingsProfileFrame(
            state: HostSettingsProfileError(
              error: StateError('Host profile failed'),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'no profile',
        child: const _DeviceFrame(
          child: _HostSettingsProfileFrame(state: HostSettingsProfileMissing()),
        ),
      ),
      _StateCard(
        label: 'create pending',
        child: const _DeviceFrame(
          child: _HostSettingsProfileFrame(
            state: HostSettingsProfileMissing(),
            creatingProfile: true,
          ),
        ),
      ),
      _StateCard(
        label: 'club fallback profile',
        child: _DeviceFrame(
          child: _HostSettingsProfileFrame(
            state: HostSettingsProfileContent(
              profile: _hostProfileVariant(HostProfileStatus.active),
              isFallback: true,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'active edit rows',
        child: _DeviceFrame(
          child: _HostSettingsProfileFrame(
            profile: _hostProfileVariant(HostProfileStatus.active),
          ),
        ),
      ),
      _StateCard(
        label: 'active preview rows',
        child: _DeviceFrame(
          child: _HostSettingsProfileFrame(
            profile: _hostProfileVariant(HostProfileStatus.active),
            editMode: false,
          ),
        ),
      ),
      _StateCard(
        label: 'pending status',
        child: _DeviceFrame(
          child: _HostSettingsProfileFrame(
            profile: _hostProfileVariant(HostProfileStatus.pending),
          ),
        ),
      ),
      _StateCard(
        label: 'suspended status',
        child: _DeviceFrame(
          child: _HostSettingsProfileFrame(
            profile: _hostProfileVariant(HostProfileStatus.suspended),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScaler: const TextScaler.linear(2),
            child: _HostSettingsProfileFrame(
              profile: _hostProfileVariant(HostProfileStatus.active),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Clubs states',
  type: HostSettingsClubsSection,
  path: '[P2 host surfaces]/Host settings',
)
Widget hostSettingsClubsStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostSettingsClubsSection',
    contractId: 'section.host.settings.clubs',
    children: [
      _StateCard(
        label: 'clubs loading',
        child: const _DeviceFrame(
          child: _HostSettingsClubsFrame(loading: true),
        ),
      ),
      _StateCard(
        label: 'clubs error',
        child: _DeviceFrame(
          child: _HostSettingsClubsFrame(
            error: StateError('Hosted clubs failed'),
          ),
        ),
      ),
      _StateCard(
        label: 'empty clubs',
        child: const _DeviceFrame(child: _HostSettingsClubsFrame(clubs: [])),
      ),
      _StateCard(
        label: 'owner and host-team rows',
        child: const _DeviceFrame(child: _HostSettingsClubsFrame()),
      ),
      _StateCard(
        label: 'preview mode rows',
        child: const _DeviceFrame(
          child: _HostSettingsClubsFrame(editMode: false),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: const _DeviceFrame(
          child: _MediaOverride(
            textScaler: TextScaler.linear(2),
            child: _HostSettingsClubsFrame(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Tab states',
  type: HostSettingsTabRail,
  path: '[P2 host surfaces]/Host settings',
)
Widget hostSettingsTabStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostSettingsTabRail',
    contractId: 'section.host.settings.top_bar_tabs',
    children: [
      _StateCard(
        label: 'edit selected',
        child: const _DeviceFrame(
          child: _HostSettingsTabFrame(selected: HostSettingsMode.edit),
        ),
      ),
      _StateCard(
        label: 'preview selected',
        child: const _DeviceFrame(
          child: _HostSettingsTabFrame(selected: HostSettingsMode.preview),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: const _DeviceFrame(
          child: _MediaOverride(
            textScaler: TextScaler.linear(2),
            child: _HostSettingsTabFrame(selected: HostSettingsMode.edit),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Route states',
  type: HostProfileScreen,
  path: '[P2 host surfaces]/Host profile',
)
Widget hostProfileRouteStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostProfileScreen',
    contractId: 'screen.host.profile',
    children: [
      _StateCard(
        label: 'auth required',
        child: const _DeviceFrame(
          child: _HostShellScope(uid: null, child: HostProfileScreen()),
        ),
      ),
      _StateCard(
        label: 'profile loading',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostProfileStream:
                HostOperationsFixtures.loadingStream<HostProfile?>(),
            child: const HostProfileScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'profile error',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostProfileStream: HostOperationsFixtures.errorStream<HostProfile?>(
              'Host profile failed',
            ),
            child: const HostProfileScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'missing profile',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostProfileStream: Stream<HostProfile?>.value(null),
            child: const HostProfileScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'populated active profile',
        child: const _DeviceFrame(
          child: _HostShellScope(child: HostProfileScreen()),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: const _DeviceFrame(
          child: _MediaOverride(
            textScaler: TextScaler.linear(2),
            child: _HostShellScope(child: HostProfileScreen()),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: const _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _HostShellScope(child: HostProfileScreen()),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: const _DeviceFrame(
          child: _HostShellScope(
            themeMode: ThemeMode.dark,
            child: HostProfileScreen(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Form states',
  type: HostProfileForm,
  path: '[P2 host surfaces]/Host profile',
)
Widget hostProfileFormStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostProfileForm',
    contractId: 'section.host.profile.form',
    children: [
      _StateCard(
        label: 'active profile',
        child: _DeviceFrame(
          child: _HostProfileFormFrame(
            profile: _hostProfileVariant(HostProfileStatus.active),
          ),
        ),
      ),
      _StateCard(
        label: 'pending review',
        child: _DeviceFrame(
          child: _HostProfileFormFrame(
            profile: _hostProfileVariant(HostProfileStatus.pending),
          ),
        ),
      ),
      _StateCard(
        label: 'suspended profile',
        child: _DeviceFrame(
          child: _HostProfileFormFrame(
            profile: _hostProfileVariant(HostProfileStatus.suspended),
          ),
        ),
      ),
      _StateCard(
        label: 'validation error',
        child: _DeviceFrame(
          child: _HostProfileFormFrame(
            profile: _hostProfileVariant(HostProfileStatus.active),
            displayNameOverride: '',
            validateOnBuild: true,
          ),
        ),
      ),
      _StateCard(
        label: 'save pending',
        child: _DeviceFrame(
          child: _HostProfileFormFrame(
            profile: _hostProfileVariant(HostProfileStatus.active),
            saving: true,
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScaler: const TextScaler.linear(2),
            child: _HostProfileFormFrame(
              profile: _hostProfileVariant(HostProfileStatus.active),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _HostProfileFormFrame(
              profile: _hostProfileVariant(HostProfileStatus.active),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: _DeviceFrame(
          child: _HostProfileFormFrame(
            profile: _hostProfileVariant(HostProfileStatus.active),
            themeMode: ThemeMode.dark,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Field states',
  type: HostProfileFields,
  path: '[P2 host surfaces]/Host profile',
)
Widget hostProfileFieldStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostProfileFields',
    contractId: 'section.host.profile.form.fields',
    children: [
      for (final status in HostProfileStatus.values)
        _StateCard(
          label: hostProfileStatusLabel(status),
          child: _DeviceFrame(
            child: _HostProfileFieldsFrame(
              profile: _hostProfileVariant(status),
            ),
          ),
        ),
      _StateCard(
        label: 'editor sheet without status',
        child: _DeviceFrame(
          child: _HostProfileFieldsFrame(
            profile: _hostProfileVariant(HostProfileStatus.active),
            showStatus: false,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Missing states',
  type: HostProfileMissingState,
  path: '[P2 host surfaces]/Host profile',
)
Widget hostProfileMissingStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostProfileMissingState',
    contractId: 'section.host.profile.missing_state',
    children: [
      _StateCard(
        label: 'ready to create',
        child: const _DeviceFrame(child: _HostProfileMissingFrame()),
      ),
      _StateCard(
        label: 'create pending',
        child: const _DeviceFrame(
          child: _HostProfileMissingFrame(creating: true),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: const _DeviceFrame(
          child: _MediaOverride(
            textScaler: TextScaler.linear(2),
            child: _HostProfileMissingFrame(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Public preview states',
  type: ClubDetailScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget hostClubDetailPublicPreviewStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostClubDetailScreen',
    contractId: 'screen.host.club.detail',
    children: [
      _StateCard(
        label: 'host public preview',
        child: const _DeviceFrame(child: _HostClubDetailScope()),
      ),
      _StateCard(
        label: 'initial club loading fallback',
        child: const _DeviceFrame(
          child: _HostClubDetailScope(viewModel: AsyncLoading()),
        ),
      ),
      _StateCard(
        label: 'load error',
        child: _DeviceFrame(
          child: _HostClubDetailScope(
            viewModel: AsyncError<ClubDetailViewModel?>(
              StateError('Club detail failed'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'offline',
        child: _DeviceFrame(
          child: _HostClubDetailScope(
            viewModel: AsyncError<ClubDetailViewModel?>(
              obviousOfflineException(),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'not found',
        child: const _DeviceFrame(
          child: _HostClubDetailScope(
            useInitialClub: false,
            viewModel: AsyncData<ClubDetailViewModel?>(null),
          ),
        ),
      ),
      _StateCard(
        label: 'signed out preview',
        child: _DeviceFrame(
          child: _HostClubDetailScope(
            uid: null,
            viewModel: AsyncData<ClubDetailViewModel?>(
              _clubDetailViewModel(isHost: false, uid: null),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'signed-in non-host preview',
        child: _DeviceFrame(
          child: _HostClubDetailScope(
            uid: 'design-host-non-team',
            viewModel: AsyncData<ClubDetailViewModel?>(
              _clubDetailViewModel(isHost: false, uid: 'design-host-non-team'),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'empty schedule',
        child: _DeviceFrame(
          child: _HostClubDetailScope(
            viewModel: AsyncData<ClubDetailViewModel?>(
              _clubDetailViewModel(upcomingEvents: const <Event>[]),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: const _DeviceFrame(
          child: _MediaOverride(
            textScaler: TextScaler.linear(2),
            child: _HostClubDetailScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: const _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _HostClubDetailScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: const _DeviceFrame(
          child: _HostClubDetailScope(themeMode: ThemeMode.dark),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Route and wizard states',
  type: HostCreateClubScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget hostCreateClubRouteAndWizardStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostCreateClubScreen',
    contractId: 'screen.host.club.create',
    children: [
      _StateCard(
        label: 'route entry',
        child: const _DeviceFrame(
          child: _HostCreateClubScope(
            child: CreateClubScreen(restoreSavedDraft: false),
          ),
        ),
      ),
      _StateCard(
        label: 'basics validation',
        child: const _DeviceFrame(
          child: _HostCreateClubScope(
            child: CreateClubScreen(
              restoreSavedDraft: false,
              formAutovalidateMode: AutovalidateMode.always,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'picked media',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: CreateClubScreen(
              initialDraft: HostOperationsFixtures.clubDraft,
              restoreSavedDraft: false,
              initialPickedClubPhotos: _createClubPickedPhotos(),
              initialProfileImage: _createClubProfileImage(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'restored draft',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: CreateClubScreen(
              initialDraft: HostOperationsFixtures.clubDraft,
              restoreSavedDraft: false,
            ),
          ),
        ),
      ),
      for (final step in _createClubSteps.entries)
        _StateCard(
          label: step.value,
          child: _DeviceFrame(
            child: _HostCreateClubScope(
              child: CreateClubScreen(
                initialDraft: HostOperationsFixtures.clubDraft,
                initialStep: step.key,
                restoreSavedDraft: false,
              ),
            ),
          ),
        ),
      _StateCard(
        label: 'save draft pending',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: _HostCreateClubMutationPreview(
              mode: _HostCreateClubMutationPreviewMode.saveDraftPending,
              child: CreateClubScreen(
                initialDraft: HostOperationsFixtures.clubDraft,
                restoreSavedDraft: false,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'save draft error',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: _HostCreateClubMutationPreview(
              mode: _HostCreateClubMutationPreviewMode.saveDraftError,
              child: CreateClubScreen(
                initialDraft: HostOperationsFixtures.clubDraft,
                restoreSavedDraft: false,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'submit pending',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: _HostCreateClubMutationPreview(
              mode: _HostCreateClubMutationPreviewMode.submitPending,
              child: CreateClubScreen(
                initialDraft: HostOperationsFixtures.clubDraft,
                initialStep: 3,
                restoreSavedDraft: false,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'submit error',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: _HostCreateClubMutationPreview(
              mode: _HostCreateClubMutationPreviewMode.submitError,
              child: CreateClubScreen(
                initialDraft: HostOperationsFixtures.clubDraft,
                initialStep: 3,
                restoreSavedDraft: false,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'submit offline',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: _HostCreateClubMutationPreview(
              mode: _HostCreateClubMutationPreviewMode.submitOffline,
              child: CreateClubScreen(
                initialDraft: HostOperationsFixtures.clubDraft,
                initialStep: 3,
                restoreSavedDraft: false,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScaler: const TextScaler.linear(2),
            child: _HostCreateClubScope(
              child: CreateClubScreen(
                initialDraft: HostOperationsFixtures.clubDraft,
                initialStep: 1,
                restoreSavedDraft: false,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _HostCreateClubScope(
              child: CreateClubScreen(
                initialDraft: HostOperationsFixtures.clubDraft,
                initialStep: 2,
                restoreSavedDraft: false,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            themeMode: ThemeMode.dark,
            child: CreateClubScreen(
              initialDraft: HostOperationsFixtures.clubDraft,
              initialStep: 3,
              restoreSavedDraft: false,
            ),
          ),
        ),
      ),
    ],
  );
}

enum _HostCreateClubMutationPreviewMode {
  saveDraftPending,
  saveDraftError,
  submitPending,
  submitError,
  submitOffline,
}

class _HostCreateClubMutationPreview extends ConsumerStatefulWidget {
  const _HostCreateClubMutationPreview({
    required this.mode,
    required this.child,
  });

  final _HostCreateClubMutationPreviewMode mode;
  final Widget child;

  @override
  ConsumerState<_HostCreateClubMutationPreview> createState() =>
      _HostCreateClubMutationPreviewState();
}

class _HostCreateClubMutationPreviewState
    extends ConsumerState<_HostCreateClubMutationPreview> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) return;
      _started = true;
      CreateClubController.submitMutation.reset(ref);
      CreateClubDraftController.saveDraftMutation.reset(ref);
      switch (widget.mode) {
        case _HostCreateClubMutationPreviewMode.saveDraftPending:
          _runPending(CreateClubDraftController.saveDraftMutation);
          break;
        case _HostCreateClubMutationPreviewMode.saveDraftError:
          _runError(
            CreateClubDraftController.saveDraftMutation,
            StateError('Widgetbook club draft save failed'),
          );
          break;
        case _HostCreateClubMutationPreviewMode.submitPending:
          _runPending(CreateClubController.submitMutation);
          break;
        case _HostCreateClubMutationPreviewMode.submitError:
          _runError(
            CreateClubController.submitMutation,
            StateError('Widgetbook club submit failed'),
          );
          break;
        case _HostCreateClubMutationPreviewMode.submitOffline:
          _runError(
            CreateClubController.submitMutation,
            obviousOfflineException(),
          );
          break;
      }
    });
  }

  void _runPending<T>(Mutation<T> mutation) {
    final completer = Completer<T>();
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError<T>(Mutation<T> mutation, Object error) {
    unawaited(
      mutation
          .run(ref, (_) async => throw error)
          .then<void>((_) {}, onError: (_) {}),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

@widgetbook.UseCase(
  name: 'Route and mode states',
  type: HostEditClubRouteScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget hostEditClubRouteAndModeStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostEditClubRouteScreen',
    contractId: 'screen.host.club.edit',
    children: [
      _StateCard(
        label: 'route loading',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            clubValue: const AsyncLoading<Club?>(),
            child: HostEditClubRouteScreen(clubId: _club.id),
          ),
        ),
      ),
      _StateCard(
        label: 'route error',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            clubValue: AsyncError<Club?>(
              StateError('Club fetch failed'),
              StackTrace.empty,
            ),
            child: HostEditClubRouteScreen(clubId: _club.id),
          ),
        ),
      ),
      _StateCard(
        label: 'route offline',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            clubValue: AsyncError<Club?>(
              obviousOfflineException(),
              StackTrace.empty,
            ),
            child: HostEditClubRouteScreen(clubId: _club.id),
          ),
        ),
      ),
      _StateCard(
        label: 'missing club',
        child: const _DeviceFrame(
          child: _HostCreateClubScope(
            clubValue: AsyncData<Club?>(null),
            child: HostEditClubRouteScreen(clubId: 'design-host-sea-face'),
          ),
        ),
      ),
      _StateCard(
        label: 'owner full edit',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: CreateClubScreen(
              initialClub: _club,
              restoreSavedDraft: false,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'owner validation',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: CreateClubScreen(
              initialClub: _club.copyWith(
                name: '',
                area: '',
                description: '',
                location: '',
              ),
              restoreSavedDraft: false,
              formAutovalidateMode: AutovalidateMode.always,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'media replacement',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: CreateClubScreen(
              initialClub: _club,
              restoreSavedDraft: false,
              initialPickedClubPhotos: _createClubPickedPhotos(),
              initialProfileImage: _createClubProfileImage(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'submit pending',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: _HostCreateClubMutationPreview(
              mode: _HostCreateClubMutationPreviewMode.submitPending,
              child: CreateClubScreen(
                initialClub: _club,
                restoreSavedDraft: false,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'submit error',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: _HostCreateClubMutationPreview(
              mode: _HostCreateClubMutationPreviewMode.submitError,
              child: CreateClubScreen(
                initialClub: _club,
                restoreSavedDraft: false,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'co-host media-only edit',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: CreateClubScreen(
              initialClub: HostOperationsFixtures.coHostedClub,
              restoreSavedDraft: false,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'forbidden identity',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            uid: HostOperationsFixtures.guestUid,
            child: HostEditClubRouteScreen(
              clubId: _club.id,
              initialClub: _club,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScaler: const TextScaler.linear(2),
            child: _HostCreateClubScope(
              child: CreateClubScreen(
                initialClub: _club,
                restoreSavedDraft: false,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _HostCreateClubScope(
              child: CreateClubScreen(
                initialClub: HostOperationsFixtures.coHostedClub,
                restoreSavedDraft: false,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            themeMode: ThemeMode.dark,
            child: CreateClubScreen(
              initialClub: _club,
              restoreSavedDraft: false,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Route and wizard states',
  type: HostCreateEventRouteScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget hostCreateEventRouteAndWizardStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostCreateEventRouteScreen',
    contractId: 'screen.host.event.create',
    children: [
      _StateCard(
        label: 'route loading',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            clubValue: const AsyncLoading<Club?>(),
            child: HostCreateEventRouteScreen(clubId: _club.id),
          ),
        ),
      ),
      _StateCard(
        label: 'route error',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            clubValue: AsyncError<Club?>(
              StateError('Club fetch failed'),
              StackTrace.empty,
            ),
            child: HostCreateEventRouteScreen(clubId: _club.id),
          ),
        ),
      ),
      _StateCard(
        label: 'route offline',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            clubValue: AsyncError<Club?>(
              obviousOfflineException(),
              StackTrace.empty,
            ),
            child: HostCreateEventRouteScreen(clubId: _club.id),
          ),
        ),
      ),
      _StateCard(
        label: 'missing club',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            clubValue: const AsyncData<Club?>(null),
            child: HostCreateEventRouteScreen(clubId: _club.id),
          ),
        ),
      ),
      _StateCard(
        label: 'basics validation',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            child: CreateEventScreen(
              club: _club,
              formAutovalidateMode: AutovalidateMode.always,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'custom activity',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            child: CreateEventScreen(
              club: _club,
              initialDraft: _customActivityEventDraft,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'picked event photos',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            child: CreateEventScreen(
              club: _club,
              initialDraft: HostOperationsFixtures.eventDraft,
              initialPickedEventPhotos: _createEventPickedPhotos(),
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'location selected',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            child: CreateEventScreen(
              club: _club,
              initialDraft: HostOperationsFixtures.eventDraft,
              initialStep: 1,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'draft picker',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            drafts: [HostOperationsFixtures.eventDraft],
            child: CreateEventScreen(
              club: _club,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'draft restored',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            child: CreateEventScreen(
              club: _club,
              initialDraft: HostOperationsFixtures.eventDraft,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'save draft pending',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            child: _HostCreateEventMutationPreview(
              mode: _HostCreateEventMutationPreviewMode.saveDraftPending,
              child: CreateEventScreen(
                club: _club,
                initialDraft: HostOperationsFixtures.eventDraft,
                loadMapTiles: false,
                now: () => HostOperationsFixtures.now,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'save draft error',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            child: _HostCreateEventMutationPreview(
              mode: _HostCreateEventMutationPreviewMode.saveDraftError,
              child: CreateEventScreen(
                club: _club,
                initialDraft: HostOperationsFixtures.eventDraft,
                loadMapTiles: false,
                now: () => HostOperationsFixtures.now,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'submit pending',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            child: _HostCreateEventMutationPreview(
              mode: _HostCreateEventMutationPreviewMode.submitPending,
              child: CreateEventScreen(
                club: _club,
                initialDraft: HostOperationsFixtures.eventDraft,
                initialStep: 4,
                loadMapTiles: false,
                now: () => HostOperationsFixtures.now,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'submit error',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            child: _HostCreateEventMutationPreview(
              mode: _HostCreateEventMutationPreviewMode.submitError,
              child: CreateEventScreen(
                club: _club,
                initialDraft: HostOperationsFixtures.eventDraft,
                initialStep: 4,
                loadMapTiles: false,
                now: () => HostOperationsFixtures.now,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'submit offline',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            child: _HostCreateEventMutationPreview(
              mode: _HostCreateEventMutationPreviewMode.submitOffline,
              child: CreateEventScreen(
                club: _club,
                initialDraft: HostOperationsFixtures.eventDraft,
                initialStep: 4,
                loadMapTiles: false,
                now: () => HostOperationsFixtures.now,
              ),
            ),
          ),
        ),
      ),
      for (final step in _createEventSteps.entries)
        _StateCard(
          label: step.value,
          child: _DeviceFrame(
            child: _HostCreateEventScope(
              child: CreateEventScreen(
                club: _club,
                initialDraft: HostOperationsFixtures.eventDraft,
                initialStep: step.key,
                loadMapTiles: false,
                now: () => HostOperationsFixtures.now,
              ),
            ),
          ),
        ),
      _StateCard(
        label: 'text scale 2.0',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScaler: const TextScaler.linear(2),
            child: _HostCreateEventScope(
              child: CreateEventScreen(
                club: _club,
                initialDraft: HostOperationsFixtures.eventDraft,
                loadMapTiles: false,
                now: () => HostOperationsFixtures.now,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _HostCreateEventScope(
              child: CreateEventScreen(
                club: _club,
                initialDraft: HostOperationsFixtures.eventDraft,
                initialStep: 2,
                loadMapTiles: false,
                now: () => HostOperationsFixtures.now,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            themeMode: ThemeMode.dark,
            child: CreateEventScreen(
              club: _club,
              initialDraft: HostOperationsFixtures.eventDraft,
              initialStep: 4,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'created success',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            child: CreateEventSuccessScreen(
              club: _club,
              event: _privateEvent,
              inviteCode: 'SEAFACE',
              onManageEvent: () {},
              onDone: () {},
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Route and section states',
  type: EditHostedEventRouteScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget hostEditEventRouteAndFormStates(BuildContext context) {
  return _HostCatalog(
    title: 'EditHostedEventRouteScreen',
    contractId: 'screen.host.event.edit',
    children: [
      _StateCard(
        label: 'route loading',
        child: _DeviceFrame(
          child: _HostEditEventScope(
            clubValue: const AsyncLoading<Club?>(),
            eventValue: const AsyncLoading<Event?>(),
            child: EditHostedEventRouteScreen(
              clubId: _club.id,
              eventId: _editableEvent.id,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'route error',
        child: _DeviceFrame(
          child: _HostEditEventScope(
            clubValue: AsyncError<Club?>(
              StateError('Club fetch failed'),
              StackTrace.empty,
            ),
            child: EditHostedEventRouteScreen(
              clubId: _club.id,
              eventId: _editableEvent.id,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'route offline',
        child: _DeviceFrame(
          child: _HostEditEventScope(
            clubValue: AsyncError<Club?>(
              obviousOfflineException(),
              StackTrace.empty,
            ),
            child: EditHostedEventRouteScreen(
              clubId: _club.id,
              eventId: _editableEvent.id,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'event not found',
        child: _DeviceFrame(
          child: _HostEditEventScope(
            eventValue: const AsyncData<Event?>(null),
            child: EditHostedEventRouteScreen(
              clubId: _club.id,
              eventId: _editableEvent.id,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'unauthorized host',
        child: _DeviceFrame(
          child: _HostEditEventScope(
            uid: HostOperationsFixtures.guestUid,
            child: EditHostedEventRouteScreen(
              clubId: _club.id,
              eventId: _editableEvent.id,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'editable prefilled form',
        child: _DeviceFrame(
          child: _HostEditEventScope(
            child: EditHostedEventScreen(
              club: _club,
              event: _editableEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'schedule locked form',
        child: _DeviceFrame(
          child: _HostEditEventScope(
            child: EditHostedEventScreen(
              club: _club,
              event: _privateEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'cancelled disabled form',
        child: _DeviceFrame(
          child: _HostEditEventScope(
            child: EditHostedEventScreen(
              club: _club,
              event: HostOperationsFixtures.cancelledEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'private access loading',
        child: _DeviceFrame(
          child: _HostEditEventScope(
            privateAccessValue: const AsyncLoading<EventPrivateAccess?>(),
            child: EditHostedEventScreen(
              club: _club,
              event: _privateEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'validation errors',
        child: _DeviceFrame(
          child: _HostEditEventScope(
            child: EditHostedEventScreen(
              club: _club,
              event: _validationEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
              formAutovalidateMode: AutovalidateMode.always,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'selected location',
        child: _DeviceFrame(
          child: _HostEditEventScope(
            child: EditHostedEventScreen(
              club: _club,
              event: _selectedLocationEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScaler: const TextScaler.linear(2),
            child: _HostEditEventScope(
              child: EditHostedEventScreen(
                club: _club,
                event: _editableEvent,
                loadMapTiles: false,
                now: () => HostOperationsFixtures.now,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _HostEditEventScope(
              child: EditHostedEventScreen(
                club: _club,
                event: _editableEvent,
                loadMapTiles: false,
                now: () => HostOperationsFixtures.now,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: _DeviceFrame(
          child: _HostEditEventScope(
            themeMode: ThemeMode.dark,
            child: EditHostedEventScreen(
              club: _club,
              event: _editableEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Route and section states',
  type: HostEventManageRouteScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget hostEventManageRouteAndSectionStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostEventManageRouteScreen',
    contractId: 'screen.host.event.manage',
    children: [
      _StateCard(
        label: 'route loading',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            clubValue: const AsyncLoading<Club?>(),
            eventValue: const AsyncLoading<Event?>(),
          ),
        ),
      ),
      _StateCard(
        label: 'initial event fallback',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(eventValue: AsyncLoading<Event?>()),
        ),
      ),
      _StateCard(
        label: 'route error',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            clubValue: AsyncError<Club?>(
              StateError('Club fetch failed'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'route offline',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            clubValue: AsyncError<Club?>(
              obviousOfflineException(),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'event not found',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(eventValue: AsyncData<Event?>(null)),
        ),
      ),
      _StateCard(
        label: 'unauthorized user',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(uid: 'design-host-not-on-team'),
        ),
      ),
      _StateCard(
        label: 'setup / private access',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.setup,
          ),
        ),
      ),
      _StateCard(
        label: 'full / waitlist apron',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            club: HostOperationsFixtures.dinnerClub,
            event: HostOperationsFixtures.fullEvent,
          ),
        ),
      ),
      _StateCard(
        label: 'live console',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.live,
          ),
        ),
      ),
      _StateCard(
        label: 'attendance mutation pending',
        child: const _DeviceFrame(
          child: _HostManageAttendanceMutationRoutePreview(
            mode: _HostManageAttendanceMutationPreviewMode.pending,
          ),
        ),
      ),
      _StateCard(
        label: 'attendance mutation error',
        child: const _DeviceFrame(
          child: _HostManageAttendanceMutationRoutePreview(
            mode: _HostManageAttendanceMutationPreviewMode.error,
          ),
        ),
      ),
      _StateCard(
        label: 'live unavailable',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.live,
            planValue: AsyncData<EventSuccessPlan?>(null),
          ),
        ),
      ),
      _StateCard(
        label: 'report workspace',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.report,
          ),
        ),
      ),
      _StateCard(
        label: 'report export pending',
        child: const _DeviceFrame(
          child: _HostManageReportExportMutationPreview(
            mode: _HostManageReportExportMutationPreviewMode.pending,
            child: _HostManageRouteScope(
              initialSection: HostEventManageSection.report,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'report export error',
        child: const _DeviceFrame(
          child: _HostManageReportExportMutationPreview(
            mode: _HostManageReportExportMutationPreviewMode.error,
            child: _HostManageRouteScope(
              initialSection: HostEventManageSection.report,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'attendance loading',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(
            attendanceValue: AsyncLoading<AttendanceSheetViewModel?>(),
          ),
        ),
      ),
      _StateCard(
        label: 'attendance error',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            attendanceValue: AsyncError<AttendanceSheetViewModel?>(
              StateError('Attendance failed'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'attendance empty',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(
            attendanceValue: AsyncData<AttendanceSheetViewModel?>(null),
          ),
        ),
      ),
      _StateCard(
        label: 'attendee profiles loading',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(
            attendeeProfilesValue:
                AsyncLoading<Map<String, (String, String?)>>(),
          ),
        ),
      ),
      _StateCard(
        label: 'attendee profiles error',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            attendeeProfilesValue: AsyncError<Map<String, (String, String?)>>(
              StateError('Profile lookup failed'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'filtered roster empty',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(
            initialParticipantSearchQuery: 'no matching guest',
          ),
        ),
      ),
      _StateCard(
        label: 'private access loading',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(
            privateAccessValue: AsyncLoading<EventPrivateAccess?>(),
          ),
        ),
      ),
      _StateCard(
        label: 'private access error',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            privateAccessValue: AsyncError<EventPrivateAccess?>(
              StateError('Private access failed'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'invite links loading',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(
            inviteLinksValue: AsyncLoading<List<EventInviteLink>>(),
          ),
        ),
      ),
      _StateCard(
        label: 'invite links error',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            inviteLinksValue: AsyncError<List<EventInviteLink>>(
              StateError('Invite links failed'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'invite links empty',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(
            inviteLinksValue: AsyncData<List<EventInviteLink>>(
              <EventInviteLink>[],
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'invite link action pending',
        child: const _DeviceFrame(
          child: _HostManageInviteLinkMutationPreview(
            mode: _HostManageInviteLinkMutationPreviewMode.pending,
            child: _HostManageRouteScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'invite link action error',
        child: const _DeviceFrame(
          child: _HostManageInviteLinkMutationPreview(
            mode: _HostManageInviteLinkMutationPreviewMode.error,
            child: _HostManageRouteScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'private link share pending',
        child: const _DeviceFrame(
          child: _HostManagePrivateLinkShareMutationPreview(
            mode: _HostManagePrivateLinkShareMutationPreviewMode.pending,
            child: _HostManageRouteScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'private link share error',
        child: const _DeviceFrame(
          child: _HostManagePrivateLinkShareMutationPreview(
            mode: _HostManagePrivateLinkShareMutationPreviewMode.error,
            child: _HostManageRouteScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'host actions / edit event',
        child: const _DeviceFrame(child: _HostManageRouteScope()),
      ),
      _StateCard(
        label: 'cancel action pending',
        child: const _DeviceFrame(
          child: _HostManageActionMutationPreview(
            mode: _HostManageActionMutationPreviewMode.cancelPending,
            child: _HostManageRouteScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'cancel action error',
        child: const _DeviceFrame(
          child: _HostManageActionMutationPreview(
            mode: _HostManageActionMutationPreviewMode.cancelError,
            child: _HostManageRouteScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'delete action pending',
        child: _DeviceFrame(
          child: _HostManageActionMutationPreview(
            mode: _HostManageActionMutationPreviewMode.deletePending,
            child: _HostManageRouteScope(
              event: HostOperationsFixtures.unusedEvent,
              participations: <EventParticipation>[],
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'delete action error',
        child: _DeviceFrame(
          child: _HostManageActionMutationPreview(
            mode: _HostManageActionMutationPreviewMode.deleteError,
            child: _HostManageRouteScope(
              event: HostOperationsFixtures.unusedEvent,
              participations: <EventParticipation>[],
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: const _DeviceFrame(
          child: _MediaOverride(
            textScaler: TextScaler.linear(2),
            child: _HostManageRouteScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: const _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _HostManageRouteScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(themeMode: ThemeMode.dark),
        ),
      ),
    ],
  );
}

const _createEventSteps = <int, String>{
  0: 'wizard basics step',
  1: 'wizard location step',
  2: 'wizard schedule step',
  3: 'wizard policy step',
  4: 'wizard Event Success step',
};

enum _HostCreateEventMutationPreviewMode {
  saveDraftPending,
  saveDraftError,
  submitPending,
  submitError,
  submitOffline,
}

class _HostCreateEventMutationPreview extends ConsumerStatefulWidget {
  const _HostCreateEventMutationPreview({
    required this.mode,
    required this.child,
  });

  final _HostCreateEventMutationPreviewMode mode;
  final Widget child;

  @override
  ConsumerState<_HostCreateEventMutationPreview> createState() =>
      _HostCreateEventMutationPreviewState();
}

class _HostCreateEventMutationPreviewState
    extends ConsumerState<_HostCreateEventMutationPreview> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) return;
      _started = true;
      CreateEventController.submitMutation.reset(ref);
      CreateEventDraftController.saveDraftMutation.reset(ref);
      switch (widget.mode) {
        case _HostCreateEventMutationPreviewMode.saveDraftPending:
          _runPending(CreateEventDraftController.saveDraftMutation);
          break;
        case _HostCreateEventMutationPreviewMode.saveDraftError:
          _runError(
            CreateEventDraftController.saveDraftMutation,
            StateError('Widgetbook event draft save failed'),
          );
          break;
        case _HostCreateEventMutationPreviewMode.submitPending:
          _runPending(CreateEventController.submitMutation);
          break;
        case _HostCreateEventMutationPreviewMode.submitError:
          _runError(
            CreateEventController.submitMutation,
            StateError('Widgetbook event submit failed'),
          );
          break;
        case _HostCreateEventMutationPreviewMode.submitOffline:
          _runError(
            CreateEventController.submitMutation,
            obviousOfflineException(),
          );
          break;
      }
    });
  }

  void _runPending<T>(Mutation<T> mutation) {
    final completer = Completer<T>();
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError<T>(Mutation<T> mutation, Object error) {
    unawaited(
      mutation
          .run(ref, (_) async => throw error)
          .then<void>((_) {}, onError: (_) {}),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _HostSettingsProfileFrame extends StatelessWidget {
  const _HostSettingsProfileFrame({
    this.profile,
    this.state,
    this.editMode = true,
    this.creatingProfile = false,
  });

  final HostProfile? profile;
  final HostSettingsProfileState? state;
  final bool editMode;
  final bool creatingProfile;

  @override
  Widget build(BuildContext context) {
    return _ThemedHostPreview(
      themeMode: ThemeMode.light,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: ListView(
              padding: CatchInsets.pageBodyUnderHeader,
              children: [
                HostSettingsProfileSection(
                  state: state ?? HostSettingsProfileContent(profile: profile!),
                  editMode: editMode,
                  creatingProfile: creatingProfile,
                  onRetry: () {},
                  onCreateProfile: () {},
                  onEditProfile: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HostSettingsClubsFrame extends StatelessWidget {
  const _HostSettingsClubsFrame({
    this.clubs,
    this.loading = false,
    this.error,
    this.editMode = true,
  });

  final List<Club>? clubs;
  final bool loading;
  final Object? error;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    return _ThemedHostPreview(
      themeMode: ThemeMode.light,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: ListView(
              padding: CatchInsets.pageBodyUnderHeader,
              children: [
                HostSettingsClubsSection(
                  uid: _hostUid,
                  state: error != null
                      ? HostSettingsClubsError(error: error!)
                      : loading
                      ? const HostSettingsClubsLoading()
                      : HostSettingsClubsState.fromAsync(
                          AsyncData<List<Club>>(
                            clubs ?? HostOperationsFixtures.clubs,
                          ),
                        ),
                  onRetry: error == null ? null : () {},
                  editMode: editMode,
                  onOpenClub: (_) {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HostHomeSectionFrame extends StatelessWidget {
  const _HostHomeSectionFrame({
    required this.child,
    this.clubEventStreams = const {},
  });

  final Widget child;
  final Map<String, Stream<List<Event>>> clubEventStreams;

  @override
  Widget build(BuildContext context) {
    final framedChild = Builder(
      builder: (context) {
        final t = CatchTokens.of(context);
        return Scaffold(
          backgroundColor: t.bg,
          body: ListView(
            padding: CatchInsets.pageBodyUnderHeader,
            children: [child],
          ),
        );
      },
    );

    return _DeviceFrame(
      child: _HostShellScope(
        clubEventStreams: clubEventStreams,
        child: framedChild,
      ),
    );
  }
}

class _HostHomeScaffoldFrame extends StatelessWidget {
  const _HostHomeScaffoldFrame({required this.child, this.textScaler});

  final Widget child;
  final TextScaler? textScaler;

  @override
  Widget build(BuildContext context) {
    Widget framedChild = child;
    final scaler = textScaler;
    if (scaler != null) {
      framedChild = _MediaOverride(textScaler: scaler, child: framedChild);
    }

    return _DeviceFrame(child: _HostShellScope(child: framedChild));
  }
}

class _HostSettingsTabFrame extends StatelessWidget {
  const _HostSettingsTabFrame({required this.selected});

  final HostSettingsMode selected;

  @override
  Widget build(BuildContext context) {
    return _ThemedHostPreview(
      themeMode: ThemeMode.light,
      child: Scaffold(
        appBar: CatchTopBar(
          title: 'Host profile',
          showBackButton: false,
          border: true,
          bottom: HostSettingsTabRail(selected: selected, onChanged: (_) {}),
        ),
      ),
    );
  }
}

class _HostProfileFormFrame extends StatefulWidget {
  const _HostProfileFormFrame({
    required this.profile,
    this.displayNameOverride,
    this.saving = false,
    this.validateOnBuild = false,
    this.themeMode = ThemeMode.light,
  });

  final HostProfile profile;
  final String? displayNameOverride;
  final bool saving;
  final bool validateOnBuild;
  final ThemeMode themeMode;

  @override
  State<_HostProfileFormFrame> createState() => _HostProfileFormFrameState();
}

class _HostProfileFormFrameState extends State<_HostProfileFormFrame> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _roleTitleController;
  late final TextEditingController _bioController;
  var _validated = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.displayNameOverride ?? widget.profile.displayName,
    );
    _roleTitleController = TextEditingController(
      text: widget.profile.roleTitle ?? '',
    );
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
  }

  @override
  void didUpdateWidget(covariant _HostProfileFormFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile ||
        oldWidget.displayNameOverride != widget.displayNameOverride) {
      _displayNameController.text =
          widget.displayNameOverride ?? widget.profile.displayName;
      _roleTitleController.text = widget.profile.roleTitle ?? '';
      _bioController.text = widget.profile.bio ?? '';
      _validated = false;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _roleTitleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.validateOnBuild && !_validated) {
      _validated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _formKey.currentState?.validate();
      });
    }

    return _ThemedHostPreview(
      themeMode: widget.themeMode,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: Form(
              key: _formKey,
              child: HostProfileForm(
                profile: widget.profile,
                displayNameController: _displayNameController,
                roleTitleController: _roleTitleController,
                bioController: _bioController,
                saving: widget.saving,
                onSave: () => _formKey.currentState?.validate(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HostProfileFieldsFrame extends StatefulWidget {
  const _HostProfileFieldsFrame({
    required this.profile,
    this.showStatus = true,
  });

  final HostProfile profile;
  final bool showStatus;

  @override
  State<_HostProfileFieldsFrame> createState() =>
      _HostProfileFieldsFrameState();
}

class _HostProfileFieldsFrameState extends State<_HostProfileFieldsFrame> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _roleTitleController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.profile.displayName,
    );
    _roleTitleController = TextEditingController(
      text: widget.profile.roleTitle ?? '',
    );
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
  }

  @override
  void didUpdateWidget(covariant _HostProfileFieldsFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _displayNameController.text = widget.profile.displayName;
      _roleTitleController.text = widget.profile.roleTitle ?? '';
      _bioController.text = widget.profile.bio ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _roleTitleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ThemedHostPreview(
      themeMode: ThemeMode.light,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: ListView(
              padding: CatchInsets.pageBodyUnderHeader,
              children: [
                HostProfileFields(
                  status: widget.profile.status,
                  showStatus: widget.showStatus,
                  displayNameController: _displayNameController,
                  roleTitleController: _roleTitleController,
                  bioController: _bioController,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HostProfileMissingFrame extends StatelessWidget {
  const _HostProfileMissingFrame({this.creating = false});

  final bool creating;

  @override
  Widget build(BuildContext context) {
    return _ThemedHostPreview(
      themeMode: ThemeMode.light,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: HostProfileMissingState(
              creating: creating,
              onCreateProfile: () {},
            ),
          );
        },
      ),
    );
  }
}

class _HostShellScope extends StatelessWidget {
  const _HostShellScope({
    required this.child,
    this.uid = 'design-host-owner',
    this.hostedClubs,
    this.ownedClubs,
    this.hostProfileStream,
    this.hostedClubsStream,
    this.ownedClubsStream,
    this.clubEventStreams = const {},
    this.paymentAccountValue,
    this.analyticsRepository = const HostFixtureAnalyticsRepository(),
    this.themeMode = ThemeMode.light,
  });

  final Widget child;
  final String? uid;
  final List<Club>? hostedClubs;
  final List<Club>? ownedClubs;
  final Stream<HostProfile?>? hostProfileStream;
  final Stream<List<Club>>? hostedClubsStream;
  final Stream<List<Club>>? ownedClubsStream;
  final Map<String, Stream<List<Event>>> clubEventStreams;
  final AsyncValue<HostPaymentAccount?>? paymentAccountValue;
  final HostAnalyticsRepository analyticsRepository;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final effectiveHostedClubs = hostedClubs ?? HostOperationsFixtures.clubs;
    final effectiveOwnedClubs =
        ownedClubs ??
        [HostOperationsFixtures.primaryClub, HostOperationsFixtures.dinnerClub];
    final effectiveUid = uid ?? _hostUid;
    final overrides = [
      uidProvider.overrideWithValue(AsyncData<String?>(uid)),
      watchHostProfileProvider(effectiveUid).overrideWith(
        (ref) =>
            hostProfileStream ??
            Stream<HostProfile?>.value(HostOperationsFixtures.hostProfile),
      ),
      watchClubsHostedByProvider(effectiveUid).overrideWith(
        (ref) =>
            hostedClubsStream ?? Stream<List<Club>>.value(effectiveHostedClubs),
      ),
      watchClubsOwnedByProvider(effectiveUid).overrideWith(
        (ref) =>
            ownedClubsStream ?? Stream<List<Club>>.value(effectiveOwnedClubs),
      ),
      watchHostPaymentAccountProvider(effectiveUid).overrideWithValue(
        paymentAccountValue ?? const AsyncData<HostPaymentAccount?>(null),
      ),
      hostClubEditControllerProvider.overrideWithValue(
        const _NoopHostClubEditActions(),
      ),
      hostPaymentAccountControllerProvider.overrideWithValue(
        const _NoopHostPaymentAccountActions(),
      ),
      hostAnalyticsRepositoryProvider.overrideWithValue(analyticsRepository),
    ];
    for (final club in HostOperationsFixtures.clubs) {
      overrides.add(
        watchEventsForClubProvider(club.id).overrideWith(
          (ref) =>
              clubEventStreams[club.id] ??
              Stream<List<Event>>.value(
                HostOperationsFixtures.eventsByClub[club.id] ?? const [],
              ),
        ),
      );
    }

    return _AppRoleBoundary(
      role: AppRole.host,
      child: ProviderScope(
        overrides: overrides,
        child: _ThemedHostPreview(themeMode: themeMode, child: child),
      ),
    );
  }
}

enum _HostClubsMutationPreviewMode {
  inlinePending,
  inlineError,
  inlineOffline,
  payoutSetupPending,
  payoutSetupError,
  payoutSetupOffline,
  payoutRefreshPending,
  payoutRefreshError,
  payoutRefreshOffline,
  teamAddPending,
  teamAddError,
  teamAddOffline,
  teamPending,
  teamError,
  teamOffline,
}

class _HostClubsMutationPreview extends ConsumerStatefulWidget {
  const _HostClubsMutationPreview({required this.mode, required this.child});

  final _HostClubsMutationPreviewMode mode;
  final Widget child;

  @override
  ConsumerState<_HostClubsMutationPreview> createState() =>
      _HostClubsMutationPreviewState();
}

class _HostClubsMutationPreviewState
    extends ConsumerState<_HostClubsMutationPreview> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) return;
      _started = true;
      _resetMutations();
      _seed();
    });
  }

  @override
  void didUpdateWidget(_HostClubsMutationPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _started = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _started) return;
        _started = true;
        _resetMutations();
        _seed();
      });
    }
  }

  void _resetMutations() {
    HostClubEditController.updateClubMutation.reset(ref);
    HostPaymentAccountController.startOnboardingMutation.reset(ref);
    HostPaymentAccountController.refreshStatusMutation.reset(ref);
    HostTeamManagementController.addHostMutation.reset(ref);
    HostTeamManagementController.removeHostMutation.reset(ref);
    HostTeamManagementController.transferOwnershipMutation.reset(ref);
  }

  void _seed() {
    switch (widget.mode) {
      case _HostClubsMutationPreviewMode.inlinePending:
        _runPending(HostClubEditController.updateClubMutation);
        break;
      case _HostClubsMutationPreviewMode.inlineError:
        _runError(
          HostClubEditController.updateClubMutation,
          StateError('Widgetbook club update failed'),
        );
        break;
      case _HostClubsMutationPreviewMode.inlineOffline:
        _runError(
          HostClubEditController.updateClubMutation,
          obviousOfflineException(),
        );
        break;
      case _HostClubsMutationPreviewMode.payoutSetupPending:
        _runPending(HostPaymentAccountController.startOnboardingMutation);
        break;
      case _HostClubsMutationPreviewMode.payoutSetupError:
        _runError(
          HostPaymentAccountController.startOnboardingMutation,
          StateError('Widgetbook payout setup failed'),
        );
        break;
      case _HostClubsMutationPreviewMode.payoutSetupOffline:
        _runError(
          HostPaymentAccountController.startOnboardingMutation,
          obviousOfflineException(),
        );
        break;
      case _HostClubsMutationPreviewMode.payoutRefreshPending:
        _runPending(HostPaymentAccountController.refreshStatusMutation);
        break;
      case _HostClubsMutationPreviewMode.payoutRefreshError:
        _runError(
          HostPaymentAccountController.refreshStatusMutation,
          StateError('Widgetbook payout refresh failed'),
        );
        break;
      case _HostClubsMutationPreviewMode.payoutRefreshOffline:
        _runError(
          HostPaymentAccountController.refreshStatusMutation,
          obviousOfflineException(),
        );
        break;
      case _HostClubsMutationPreviewMode.teamAddPending:
        _runPending(HostTeamManagementController.addHostMutation);
        break;
      case _HostClubsMutationPreviewMode.teamAddError:
        _runError(
          HostTeamManagementController.addHostMutation,
          StateError('Widgetbook add host failed'),
        );
        break;
      case _HostClubsMutationPreviewMode.teamAddOffline:
        _runError(
          HostTeamManagementController.addHostMutation,
          obviousOfflineException(),
        );
        break;
      case _HostClubsMutationPreviewMode.teamPending:
        _runPending(HostTeamManagementController.removeHostMutation);
        break;
      case _HostClubsMutationPreviewMode.teamError:
        _runError(
          HostTeamManagementController.removeHostMutation,
          StateError('Widgetbook host team update failed'),
        );
        break;
      case _HostClubsMutationPreviewMode.teamOffline:
        _runError(
          HostTeamManagementController.removeHostMutation,
          obviousOfflineException(),
        );
        break;
    }
  }

  void _runPending(Mutation<void> mutation) {
    final completer = Completer<void>();
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError(Mutation<void> mutation, Object error) {
    unawaited(
      mutation
          .run(ref, (_) async => throw error)
          .then<void>((_) {}, onError: (_) {}),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _HostTeamSectionPreview extends StatelessWidget {
  const _HostTeamSectionPreview();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: CatchInsets.pageBody,
      child: HostTeamManagementSection(
        club: HostOperationsFixtures.primaryClub,
        currentUid: HostOperationsFixtures.hostUid,
      ),
    );
  }
}

class _HostTeamAddHostSheetPreview extends StatelessWidget {
  const _HostTeamAddHostSheetPreview();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: HostTeamAddHostSheet(clubId: 'design-host-sea-face'),
      ),
    );
  }
}

class _HostTeamHostActionDialogPreview extends StatelessWidget {
  const _HostTeamHostActionDialogPreview({required this.action});

  final HostTeamHostAction action;

  @override
  Widget build(BuildContext context) {
    final host = HostOperationsFixtures.primaryClub.hostProfiles[1];

    return Scaffold(
      body: Center(
        child: HostTeamHostActionDialog(
          confirmation: HostTeamHostActionConfirmation(
            action: action,
            host: host,
          ),
        ),
      ),
    );
  }
}

final class _NoopHostClubEditActions implements HostClubEditActions {
  const _NoopHostClubEditActions();

  @override
  Future<void> updateClub({
    required String clubId,
    required UpdateClubPatch patch,
  }) async {}
}

final class _NoopHostPaymentAccountActions
    implements HostPaymentAccountActions {
  const _NoopHostPaymentAccountActions();

  @override
  Future<void> refreshStatus() async {}

  @override
  Future<void> startOnboarding({
    required String country,
    required String defaultCurrency,
  }) async {}
}

final class _HostLoadingAnalyticsRepository implements HostAnalyticsRepository {
  const _HostLoadingAnalyticsRepository();

  @override
  Future<HostAnalyticsReport> getHostAnalytics(HostAnalyticsQuery query) {
    return Completer<HostAnalyticsReport>().future;
  }
}

class _HostClubDetailScope extends StatelessWidget {
  const _HostClubDetailScope({
    this.uid = 'design-host-owner',
    this.viewModel,
    this.useInitialClub = true,
    this.themeMode,
  });

  final String? uid;
  final AsyncValue<ClubDetailViewModel?>? viewModel;
  final bool useInitialClub;
  final ThemeMode? themeMode;

  @override
  Widget build(BuildContext context) {
    final effectiveUid = uid ?? _hostUid;
    return _AppRoleBoundary(
      role: AppRole.host,
      child: ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(AsyncData<String?>(uid)),
          watchUserProfileProvider.overrideWith(
            (ref) =>
                Stream.value(uid == null ? null : HostOperationsFixtures.owner),
          ),
          watchClubMembershipProvider(
            _club.id,
            effectiveUid,
          ).overrideWith((ref) => Stream<ClubMembership?>.value(null)),
          clubDetailViewModelProvider(_club.id).overrideWith(
            (ref) =>
                viewModel ??
                AsyncData<ClubDetailViewModel?>(
                  _clubDetailViewModel(uid: effectiveUid),
                ),
          ),
        ],
        child: _ThemedHostPreview(
          themeMode: themeMode ?? ThemeMode.light,
          child: ClubDetailScreen(
            clubId: _club.id,
            initialClub: useInitialClub ? _club : null,
          ),
        ),
      ),
    );
  }
}

class _HostCreateClubScope extends StatelessWidget {
  const _HostCreateClubScope({
    required this.child,
    this.uid,
    this.clubValue,
    this.themeMode = ThemeMode.light,
  });

  final Widget child;
  final String? uid;
  final AsyncValue<Club?>? clubValue;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final effectiveUid = uid ?? _hostUid;
    final overrides = [
      uidProvider.overrideWithValue(AsyncData<String?>(effectiveUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(HostOperationsFixtures.owner),
      ),
      if (clubValue != null)
        fetchClubProvider(_club.id).overrideWithValue(clubValue!),
    ];

    return _AppRoleBoundary(
      role: AppRole.host,
      child: ProviderScope(
        overrides: overrides,
        child: _ThemedHostPreview(themeMode: themeMode, child: child),
      ),
    );
  }
}

class _HostCreateEventScope extends StatelessWidget {
  const _HostCreateEventScope({
    required this.child,
    this.clubValue,
    this.drafts = const <EventDraft>[],
    this.themeMode = ThemeMode.light,
  });

  final Widget child;
  final AsyncValue<Club?>? clubValue;
  final List<EventDraft> drafts;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return _AppRoleBoundary(
      role: AppRole.host,
      child: ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(AsyncData<String?>(_hostUid)),
          eventDraftRepositoryProvider.overrideWithValue(
            HostFixtureEventDraftRepository(drafts: drafts),
          ),
          fetchClubProvider(_club.id).overrideWith(
            (ref) => switch (clubValue) {
              AsyncData(:final value) => value,
              AsyncError(:final error, :final stackTrace) =>
                Future<Club?>.error(error, stackTrace),
              AsyncLoading() => Future<Club?>.delayed(const Duration(days: 1)),
              null => _club,
            },
          ),
        ],
        child: _ThemedHostPreview(themeMode: themeMode, child: child),
      ),
    );
  }
}

class _HostEditEventScope extends StatelessWidget {
  const _HostEditEventScope({
    required this.child,
    this.uid,
    this.clubValue,
    this.eventValue,
    this.privateAccessValue,
    this.themeMode = ThemeMode.light,
  });

  final Widget child;
  final String? uid;
  final AsyncValue<Club?>? clubValue;
  final AsyncValue<Event?>? eventValue;
  final AsyncValue<EventPrivateAccess?>? privateAccessValue;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final effectiveUid = uid ?? _hostUid;
    return _AppRoleBoundary(
      role: AppRole.host,
      child: ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(AsyncData<String?>(effectiveUid)),
          fetchClubProvider(
            _club.id,
          ).overrideWithValue(clubValue ?? AsyncData<Club?>(_club)),
          watchEventProvider(
            _editableEvent.id,
          ).overrideWithValue(eventValue ?? AsyncData<Event?>(_editableEvent)),
          watchEventProvider(
            _privateEvent.id,
          ).overrideWithValue(AsyncData<Event?>(_privateEvent)),
          watchEventPrivateAccessProvider(_privateEvent.id).overrideWithValue(
            privateAccessValue ??
                AsyncData<EventPrivateAccess?>(
                  HostOperationsFixtures.privateAccess,
                ),
          ),
        ],
        child: _ThemedHostPreview(themeMode: themeMode, child: child),
      ),
    );
  }
}

enum _HostManageAttendanceMutationPreviewMode { pending, error }

class _HostManageAttendanceMutationRoutePreview extends StatelessWidget {
  const _HostManageAttendanceMutationRoutePreview({required this.mode});

  final _HostManageAttendanceMutationPreviewMode mode;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final event = _privateEvent.copyWith(
      startTime: now.subtract(const Duration(minutes: 45)),
      endTime: now.add(const Duration(minutes: 45)),
    );
    final plan = EventSuccessPlan.defaultForEvent(event, now: now).copyWith(
      activeStepIndex: 1,
      status: EventSuccessPlanStatus.live,
      frozenAt: now,
    );
    return _HostManageAttendanceMutationPreview(
      mode: mode,
      child: _HostManageRouteScope(
        event: event,
        initialSection: HostEventManageSection.live,
        planValue: AsyncData<EventSuccessPlan?>(plan),
      ),
    );
  }
}

class _HostManageAttendanceMutationPreview extends ConsumerStatefulWidget {
  const _HostManageAttendanceMutationPreview({
    required this.mode,
    required this.child,
  });

  final _HostManageAttendanceMutationPreviewMode mode;
  final Widget child;

  @override
  ConsumerState<_HostManageAttendanceMutationPreview> createState() =>
      _HostManageAttendanceMutationPreviewState();
}

class _HostManageAttendanceMutationPreviewState
    extends ConsumerState<_HostManageAttendanceMutationPreview> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      Future<void>(() {
        if (mounted) _start();
      }),
    );
  }

  void _start() {
    if (_started) return;
    _started = true;
    _resetMutations();
    switch (widget.mode) {
      case _HostManageAttendanceMutationPreviewMode.pending:
        _runPending(EventBookingController.createWaitlistOfferMutation);
        break;
      case _HostManageAttendanceMutationPreviewMode.error:
        _runError(
          EventBookingController.markAttendanceMutation,
          StateError('Widgetbook attendance mutation failed'),
        );
        break;
    }
  }

  void _resetMutations() {
    EventBookingController.markAttendanceMutation.reset(ref);
    EventBookingController.approveJoinRequestMutation.reset(ref);
    EventBookingController.declineJoinRequestMutation.reset(ref);
    EventBookingController.createWaitlistOfferMutation.reset(ref);
  }

  void _runPending<T>(Mutation<T> mutation) {
    final completer = Completer<T>();
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError<T>(Mutation<T> mutation, Object error) {
    unawaited(
      mutation
          .run(ref, (_) async => throw error)
          .then<void>((_) {}, onError: (_) {}),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

enum _HostManageInviteLinkMutationPreviewMode { pending, error }

class _HostManageInviteLinkMutationPreview extends ConsumerStatefulWidget {
  const _HostManageInviteLinkMutationPreview({
    required this.mode,
    required this.child,
  });

  final _HostManageInviteLinkMutationPreviewMode mode;
  final Widget child;

  @override
  ConsumerState<_HostManageInviteLinkMutationPreview> createState() =>
      _HostManageInviteLinkMutationPreviewState();
}

class _HostManageInviteLinkMutationPreviewState
    extends ConsumerState<_HostManageInviteLinkMutationPreview> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      Future<void>(() {
        if (mounted) _start();
      }),
    );
  }

  void _start() {
    if (_started) return;
    _started = true;
    _resetMutations();
    switch (widget.mode) {
      case _HostManageInviteLinkMutationPreviewMode.pending:
        _runPending(HostEventManageController.createInviteLinkMutation);
        break;
      case _HostManageInviteLinkMutationPreviewMode.error:
        _runError(
          HostEventManageController.disableInviteLinkMutation,
          StateError('Widgetbook invite link mutation failed'),
        );
        break;
    }
  }

  void _resetMutations() {
    HostEventManageController.createInviteLinkMutation.reset(ref);
    HostEventManageController.copyInviteLinkMutation.reset(ref);
    HostEventManageController.disableInviteLinkMutation.reset(ref);
    HostEventManageController.sharePrivateLinkMutation.reset(ref);
  }

  void _runPending<T>(Mutation<T> mutation) {
    final completer = Completer<T>();
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError<T>(Mutation<T> mutation, Object error) {
    unawaited(
      mutation
          .run(ref, (_) async => throw error)
          .then<void>((_) {}, onError: (_) {}),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

enum _HostManagePrivateLinkShareMutationPreviewMode { pending, error }

class _HostManagePrivateLinkShareMutationPreview
    extends ConsumerStatefulWidget {
  const _HostManagePrivateLinkShareMutationPreview({
    required this.mode,
    required this.child,
  });

  final _HostManagePrivateLinkShareMutationPreviewMode mode;
  final Widget child;

  @override
  ConsumerState<_HostManagePrivateLinkShareMutationPreview> createState() =>
      _HostManagePrivateLinkShareMutationPreviewState();
}

class _HostManagePrivateLinkShareMutationPreviewState
    extends ConsumerState<_HostManagePrivateLinkShareMutationPreview> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      Future<void>(() {
        if (mounted) _start();
      }),
    );
  }

  void _start() {
    if (_started) return;
    _started = true;
    HostEventManageController.sharePrivateLinkMutation.reset(ref);
    switch (widget.mode) {
      case _HostManagePrivateLinkShareMutationPreviewMode.pending:
        _runPending(HostEventManageController.sharePrivateLinkMutation);
        break;
      case _HostManagePrivateLinkShareMutationPreviewMode.error:
        _runError(
          HostEventManageController.sharePrivateLinkMutation,
          StateError('Widgetbook private link share failed'),
        );
        break;
    }
  }

  void _runPending<T>(Mutation<T> mutation) {
    final completer = Completer<T>();
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError<T>(Mutation<T> mutation, Object error) {
    unawaited(
      mutation
          .run(ref, (_) async => throw error)
          .then<void>((_) {}, onError: (_) {}),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

enum _HostManageReportExportMutationPreviewMode { pending, error }

class _HostManageReportExportMutationPreview extends ConsumerStatefulWidget {
  const _HostManageReportExportMutationPreview({
    required this.mode,
    required this.child,
  });

  final _HostManageReportExportMutationPreviewMode mode;
  final Widget child;

  @override
  ConsumerState<_HostManageReportExportMutationPreview> createState() =>
      _HostManageReportExportMutationPreviewState();
}

class _HostManageReportExportMutationPreviewState
    extends ConsumerState<_HostManageReportExportMutationPreview> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      Future<void>(() {
        if (mounted) _start();
      }),
    );
  }

  void _start() {
    if (_started) return;
    _started = true;
    HostEventManageController.shareOpsReportMutation.reset(ref);
    HostEventManageController.shareRevenueReportMutation.reset(ref);
    switch (widget.mode) {
      case _HostManageReportExportMutationPreviewMode.pending:
        _runPending(HostEventManageController.shareRevenueReportMutation);
        break;
      case _HostManageReportExportMutationPreviewMode.error:
        _runError(
          HostEventManageController.shareOpsReportMutation,
          StateError('Widgetbook report export failed'),
        );
        break;
    }
  }

  void _runPending<T>(Mutation<T> mutation) {
    final completer = Completer<T>();
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError<T>(Mutation<T> mutation, Object error) {
    unawaited(
      mutation
          .run(ref, (_) async => throw error)
          .then<void>((_) {}, onError: (_) {}),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

enum _HostManageActionMutationPreviewMode {
  cancelPending,
  cancelError,
  deletePending,
  deleteError,
}

class _HostManageActionMutationPreview extends ConsumerStatefulWidget {
  const _HostManageActionMutationPreview({
    required this.mode,
    required this.child,
  });

  final _HostManageActionMutationPreviewMode mode;
  final Widget child;

  @override
  ConsumerState<_HostManageActionMutationPreview> createState() =>
      _HostManageActionMutationPreviewState();
}

class _HostManageActionMutationPreviewState
    extends ConsumerState<_HostManageActionMutationPreview> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      Future<void>(() {
        if (mounted) _start();
      }),
    );
  }

  void _start() {
    if (_started) return;
    _started = true;
    _resetMutations();
    switch (widget.mode) {
      case _HostManageActionMutationPreviewMode.cancelPending:
        _runPending(EventBookingController.hostCancelEventMutation);
        break;
      case _HostManageActionMutationPreviewMode.cancelError:
        _runError(
          EventBookingController.hostCancelEventMutation,
          StateError('Widgetbook cancel event failed'),
        );
        break;
      case _HostManageActionMutationPreviewMode.deletePending:
        _runPending(EventBookingController.deleteEventMutation);
        break;
      case _HostManageActionMutationPreviewMode.deleteError:
        _runError(
          EventBookingController.deleteEventMutation,
          StateError('Widgetbook delete event failed'),
        );
        break;
    }
  }

  void _resetMutations() {
    EventBookingController.hostCancelEventMutation.reset(ref);
    EventBookingController.deleteEventMutation.reset(ref);
  }

  void _runPending<T>(Mutation<T> mutation) {
    final completer = Completer<T>();
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError<T>(Mutation<T> mutation, Object error) {
    unawaited(
      mutation
          .run(ref, (_) async => throw error)
          .then<void>((_) {}, onError: (_) {}),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _HostManageRouteScope extends StatelessWidget {
  const _HostManageRouteScope({
    this.uid = 'design-host-owner',
    this.club,
    this.event,
    this.clubValue,
    this.eventValue,
    this.attendanceValue,
    this.attendeeProfilesValue,
    this.privateAccessValue,
    this.inviteLinksValue,
    this.planValue,
    this.participations,
    this.initialSection = HostEventManageSection.setup,
    this.initialParticipantSearchQuery = '',
    this.themeMode = ThemeMode.light,
  });

  final String? uid;
  final Club? club;
  final Event? event;
  final AsyncValue<Club?>? clubValue;
  final AsyncValue<Event?>? eventValue;
  final AsyncValue<AttendanceSheetViewModel?>? attendanceValue;
  final AsyncValue<Map<String, (String, String?)>>? attendeeProfilesValue;
  final AsyncValue<EventPrivateAccess?>? privateAccessValue;
  final AsyncValue<List<EventInviteLink>>? inviteLinksValue;
  final AsyncValue<EventSuccessPlan?>? planValue;
  final List<EventParticipation>? participations;
  final HostEventManageSection initialSection;
  final String initialParticipantSearchQuery;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final effectiveClub = club ?? _club;
    final effectiveEvent = event ?? _privateEvent;
    final effectiveParticipations =
        participations ?? HostOperationsFixtures.participations;
    final roster = EventParticipationRoster.fromParticipations(
      effectiveParticipations,
    );
    final effectiveAttendanceValue =
        attendanceValue ??
        buildAttendanceSheetViewModel(
          eventAsync: AsyncData<Event?>(effectiveEvent),
          participationsAsync: AsyncData<List<EventParticipation>>(
            effectiveParticipations,
          ),
        );
    final profileIds = switch (effectiveAttendanceValue) {
      AsyncData(:final value) => value?.profileIds ?? const <String>[],
      _ => const <String>[],
    };
    const defaultProfiles = <String, (String, String?)>{
      HostOperationsFixtures.guestUid: ('Aarav Mehta', null),
      HostOperationsFixtures.secondGuestUid: ('Rhea Kapoor', null),
      HostOperationsFixtures.waitlistUid: ('Kabir Jain', null),
    };
    final profiles = <String, (String, String?)>{
      for (final profileId in profileIds)
        if (defaultProfiles.containsKey(profileId))
          profileId: defaultProfiles[profileId]!,
    };
    return _AppRoleBoundary(
      role: AppRole.host,
      child: ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(AsyncData<String?>(uid)),
          fetchClubProvider(
            effectiveClub.id,
          ).overrideWith((ref) => _futureOrValue(clubValue, effectiveClub)),
          watchEventProvider(
            effectiveEvent.id,
          ).overrideWith((ref) => _streamValue(eventValue, effectiveEvent)),
          watchEventParticipationRosterProvider(effectiveEvent.id).overrideWith(
            (ref) => Stream<EventParticipationRoster>.value(roster),
          ),
          watchEventParticipationsForEventProvider(
            effectiveEvent.id,
          ).overrideWith(
            (ref) =>
                Stream<List<EventParticipation>>.value(effectiveParticipations),
          ),
          attendanceSheetViewModelProvider(
            effectiveEvent.id,
          ).overrideWith((ref) => effectiveAttendanceValue),
          attendeeProfilesProvider(profileIds).overrideWithValue(
            attendeeProfilesValue ??
                AsyncData<Map<String, (String, String?)>>(profiles),
          ),
          watchEventPrivateAccessProvider(effectiveEvent.id).overrideWith(
            (ref) => _streamValue(
              privateAccessValue,
              HostOperationsFixtures.privateAccess,
            ),
          ),
          watchEventInviteLinksProvider(effectiveEvent.id).overrideWith(
            (ref) => _streamValue(
              inviteLinksValue,
              HostOperationsFixtures.inviteLinks,
            ),
          ),
          watchEventSuccessPlanProvider(
            effectiveEvent.id,
          ).overrideWith((ref) => _streamValue(planValue, null)),
        ],
        child: _ThemedHostPreview(
          themeMode: themeMode,
          child: HostEventManageRouteScreen(
            clubId: effectiveClub.id,
            eventId: effectiveEvent.id,
            initialEvent: _initialManageEvent(eventValue, effectiveEvent),
            initialSection: initialSection,
            initialParticipantSearchQuery: initialParticipantSearchQuery,
          ),
        ),
      ),
    );
  }
}

class _ThemedHostPreview extends StatelessWidget {
  const _ThemedHostPreview({required this.child, required this.themeMode});

  final Widget child;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeMode == ThemeMode.dark ? AppTheme.dark : AppTheme.light,
      child: child,
    );
  }
}

class _AppRoleBoundary extends StatefulWidget {
  const _AppRoleBoundary({required this.role, required this.child});

  final AppRole role;
  final Widget child;

  @override
  State<_AppRoleBoundary> createState() => _AppRoleBoundaryState();
}

class _AppRoleBoundaryState extends State<_AppRoleBoundary> {
  @override
  void initState() {
    super.initState();
    AppConfig.configureEntrypointRole(widget.role);
  }

  @override
  void didUpdateWidget(covariant _AppRoleBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      AppConfig.configureEntrypointRole(widget.role);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppConfig.configureEntrypointRole(widget.role);
    return widget.child;
  }
}

class _HostCatalog extends StatelessWidget {
  const _HostCatalog({
    required this.title,
    required this.contractId,
    required this.children,
  });

  final String title;
  final String contractId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.content,
          children: [
            Text(title, style: CatchTextStyles.titleL(context)),
            gapH4,
            Text(
              contractId,
              style: CatchTextStyles.monoLabel(context, color: t.ink2),
            ),
            gapH24,
            for (final child in children) ...[child, gapH20],
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: Padding(
        padding: CatchInsets.content,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: CatchTextStyles.sectionTitle(context)),
            gapH12,
            child,
          ],
        ),
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(height: 720, child: child),
          ),
        ),
      ),
    );
  }
}

class _MediaOverride extends StatelessWidget {
  const _MediaOverride({
    required this.child,
    this.textScaler,
    this.disableAnimations = false,
  });

  final Widget child;
  final TextScaler? textScaler;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final base = MediaQuery.of(context);
    return MediaQuery(
      data: base.copyWith(
        textScaler: textScaler ?? base.textScaler,
        disableAnimations: disableAnimations || base.disableAnimations,
      ),
      child: child,
    );
  }
}

ClubDetailViewModel _clubDetailViewModel({
  bool isHost = true,
  String? uid = 'design-host-owner',
  List<Event>? upcomingEvents,
}) {
  return ClubDetailViewModel(
    club: _club,
    isHost: isHost,
    isMember: false,
    upcomingEvents:
        upcomingEvents ??
        HostOperationsFixtures.eventsByClub[_club.id] ??
        const [],
    reviews: const [],
    userProfile: uid == null ? null : HostOperationsFixtures.owner,
    uid: uid,
    isAuthenticated: uid != null,
  );
}

Future<Club?> _futureOrValue(AsyncValue<Club?>? value, Club fallback) {
  return switch (value) {
    AsyncData(:final value) => Future.value(value),
    AsyncError(:final error, :final stackTrace) => Future<Club?>.error(
      error,
      stackTrace,
    ),
    AsyncLoading() => Future<Club?>.delayed(const Duration(days: 1)),
    null => Future.value(fallback),
  };
}

Event? _initialManageEvent(AsyncValue<Event?>? value, Event fallback) {
  return switch (value) {
    AsyncData(:final value) => value,
    _ => fallback,
  };
}

Stream<T> _streamValue<T>(AsyncValue<T>? value, T fallback) {
  return switch (value) {
    AsyncData(:final value) => Stream<T>.value(value),
    AsyncError(:final error, :final stackTrace) => Stream<T>.error(
      error,
      stackTrace,
    ),
    AsyncLoading() => Stream<T>.empty(),
    null => Stream<T>.value(fallback),
  };
}
