import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks/modules.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_runtime.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen.dart';
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
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/who_is_going.dart';
import 'package:catch_dating_app/hosts/data/host_analytics_repository.dart';
import 'package:catch_dating_app/hosts/data/host_profile_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_attendance_window.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_screen.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_basics_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_details_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_event_success_defaults_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/club_host_defaults_step.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/create_club_contact_fields.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_create_club_screen.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_club_edit_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_team_management_controller.dart';
import 'package:catch_dating_app/hosts/presentation/edit_hosted_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_policy_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_success_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_route_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/create_event_photo_picker.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/create_event_step_header.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/draft_picker_sheet.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/event_details_step.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/event_policy_step.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/event_success_step.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/when_step.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/where_step.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_settings_state.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_controller.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_card.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_controller_card.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/catch_roster_board.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_club_tools.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_attendance_panel.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_tools.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_team_management_section.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/stepper_footer.dart';
import 'package:catch_dating_app/image_uploads/presentation/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/labs/design_fixtures/host_operations_fixtures.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/payments/data/host_payment_account_repository.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
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
final _longNameOwnerClub = HostOperationsFixtures.primaryClub.copyWith(
  id: 'design-host-long-owner-club',
  name: 'Bandra Sea Face Morning Run Club for New Members',
  area: 'Bandra West Promenade',
);
final _longNameCoHostedClub = HostOperationsFixtures.coHostedClub.copyWith(
  id: 'design-host-long-cohost-club',
  name: 'South Mumbai Rooftop Dinner Collective With Guest Hosts',
  area: 'Fort and Kala Ghoda',
);
final _longNameEvent = HostOperationsFixtures.upcomingEvent.copyWith(
  id: 'design-host-long-name-event',
  clubId: _longNameOwnerClub.id,
  meetingPoint: 'Bandra West Promenade amphitheatre',
);
final _customActivityEventDraft = HostOperationsFixtures.eventDraft.copyWith(
  id: 'design-host-event-custom-activity-draft',
  activityKind: 'openActivity',
  customActivityLabel: 'Salsa mixer',
  interactionModel: 'hostLedProgram',
  distance: null,
  paceName: null,
);
final _hostManageDisabledInviteLinks = <EventInviteLink>[
  HostOperationsFixtures.inviteLinks.first.copyWith(
    id: 'design-host-link-disabled-edge',
    label: 'Alumni WhatsApp paused',
    source: 'whatsapp alumni',
    openCount: 88,
    requestCount: 14,
    confirmedCount: 6,
    checkedInCount: 3,
    catcherCount: 2,
    chatStartedCount: 2,
    disabledAt: HostOperationsFixtures.now.subtract(const Duration(hours: 3)),
    updatedAt: HostOperationsFixtures.now.subtract(const Duration(hours: 3)),
  ),
];
final _hostManageLongLabelInviteLinks = <EventInviteLink>[
  HostOperationsFixtures.inviteLinks.first.copyWith(
    id: 'design-host-link-long-label-source',
    label: 'Partner newsletter referral with venue concierge follow-up',
    source: 'partner newsletter / co-working founders circle / June RSVP push',
    openCount: 214,
    requestCount: 43,
    confirmedCount: 18,
    checkedInCount: 9,
    catcherCount: 5,
    chatStartedCount: 7,
    disabledAt: null,
    updatedAt: HostOperationsFixtures.now.subtract(const Duration(minutes: 25)),
  ),
];
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
  name: 'Covered by host home route states',
  type: HostEventsScaffold,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostSectionLabel,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostTodayDashboardCard,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostTodayDashboardSection,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostTodayHeader,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostTodayClubPill,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostTodayLoadingBody,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostTodayEmptyEvents,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostTodayEventHero,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostTodayCountdownPill,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostTodayHeroMetric,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostTodayAvatarStack,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostTodayAvatarDot,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostTodayTaskCard,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostEmptyState,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostAuthRequiredScreen,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host home route states',
  type: HostLoadingScreen,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
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
        label: 'owner and co-host switcher',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostedClubs: HostOperationsFixtures.clubs,
            ownedClubs: [
              HostOperationsFixtures.primaryClub,
              HostOperationsFixtures.dinnerClub,
            ],
            child: const HostOperationsHomeScreen(
              initialClubId: 'design-host-cohost-club',
              initialTab: HostHomeTab.events,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'long club names',
        child: _DeviceFrame(
          child: _HostShellScope(
            hostedClubs: [_longNameOwnerClub, _longNameCoHostedClub],
            ownedClubs: [_longNameOwnerClub],
            clubEventStreams: {
              _longNameOwnerClub.id: Stream<List<Event>>.value([
                _longNameEvent,
              ]),
              _longNameCoHostedClub.id: Stream<List<Event>>.value(const []),
            },
            child: HostOperationsHomeScreen(
              initialClubId: _longNameOwnerClub.id,
              initialTab: HostHomeTab.events,
            ),
          ),
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
  name: 'Covered by host event section states',
  type: HostEventsClubSection,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event section states',
  type: HostEventRows,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
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
  name: 'Skeleton states',
  type: HostRouteLoadingBody,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Skeleton states',
  type: HostSummarySkeleton,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Skeleton states',
  type: HostTabRailSkeleton,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Skeleton states',
  type: HostSettingsRowsSkeleton,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Skeleton states',
  type: HostEventRowsSkeleton,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Skeleton states',
  type: HostAnalyticsReportSkeleton,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Skeleton states',
  type: HostChartSkeleton,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Skeleton states',
  type: HostRosterSkeleton,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Skeleton states',
  type: HostInlineSkeletonIcon,
  path: '[P1 product surfaces]/Host operations/Components',
)
Widget hostLoadingSkeletonCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'Host loading skeletons',
    contractId: 'component.host.loading_skeletons',
    children: [
      _StateCard(
        label: 'route loading body',
        child: _DeviceFrame(
          child: Scaffold(body: HostRouteLoadingBody(showTabRail: true)),
        ),
      ),
      _StateCard(
        label: 'summary and tab rail',
        child: Column(
          children: [HostTabRailSkeleton(), gapH12, HostSummarySkeleton()],
        ),
      ),
      _StateCard(
        label: 'row and settings groups',
        child: Column(
          children: [
            HostEventRowsSkeleton(count: 2),
            gapH12,
            HostSettingsRowsSkeleton(rowCount: 2),
          ],
        ),
      ),
      _StateCard(
        label: 'analytics and roster',
        child: Column(
          children: [
            HostAnalyticsReportSkeleton(),
            gapH12,
            HostRosterSkeleton(count: 3),
            gapH12,
            HostInlineSkeletonIcon(),
          ],
        ),
      ),
      _StateCard(label: 'chart', child: HostChartSkeleton()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Metric grid skeleton states',
  type: HostAnalyticsMetricGridSkeleton,
  path: '[P1 product surfaces]/Host operations/Components',
)
Widget hostAnalyticsMetricGridSkeletonCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'HostAnalyticsMetricGridSkeleton',
    contractId: 'component.host.analytics.metric_grid_skeleton',
    children: [
      _StateCard(
        label: 'two metrics',
        child: SizedBox(width: 360, child: HostAnalyticsMetricGridSkeleton()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Roster primitive states',
  type: CatchRosterTileCell,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Roster primitive states',
  type: CatchRosterActionCell,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Roster primitive states',
  type: CatchRosterDecideTarget,
  path: '[P1 product surfaces]/Host operations/Components',
)
Widget hostRosterPrimitiveCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'Catch roster primitives',
    contractId: 'component.host.roster_primitives',
    children: [
      _StateCard(
        label: 'filter tiles',
        child: CatchRosterTiles(
          selected: 'booked',
          onSelect: (_) {},
          items: const [
            CatchRosterTile(id: 'all', value: '42', label: 'All'),
            CatchRosterTile(
              id: 'booked',
              value: '30',
              label: 'Booked',
              tone: CatchBadgeTone.success,
            ),
            CatchRosterTile(
              id: 'waitlist',
              value: '12',
              label: 'Wait',
              tone: CatchBadgeTone.warning,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'decision row',
        child: CatchRosterTable(
          columns: const ['Guest', 'Signal', 'Host action'],
          rows: [
            CatchRosterRow(
              person: 'Rhea Kapoor',
              meta: 'Arriving 7:10 PM',
              signal: 'Request',
              tone: CatchBadgeTone.brand,
              action: CatchRosterDecideAction(
                onProfile: () {},
                onApprove: () {},
                onDecline: () {},
              ),
            ),
            CatchRosterRow(
              person: 'Aarav Mehta',
              meta: 'Checked in',
              signal: 'In',
              tone: CatchBadgeTone.success,
              action: CatchRosterButtonAction(label: 'Undo', onPressed: () {}),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Tool card states',
  type: HostClubManagementPanel,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Tool card states',
  type: HostStatChip,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Tool card states',
  type: HostEventToolsCarousel,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Tool card states',
  type: HostEventToolsPageIndicator,
  path: '[P1 product surfaces]/Host operations/Components',
)
@widgetbook.UseCase(
  name: 'Tool card states',
  type: HostEventToolCard,
  path: '[P1 product surfaces]/Host operations/Components',
)
Widget hostToolCardCatalogStates(BuildContext context) {
  final tools = [
    HostEventToolItem(
      event: HostOperationsFixtures.upcomingEvent,
      attendanceState: HostEventAttendanceState.open,
    ),
    HostEventToolItem(
      event: HostOperationsFixtures.privateEvent,
      attendanceState: HostEventAttendanceState.closed,
    ),
  ];
  return _HostCatalog(
    title: 'Host tool cards',
    contractId: 'component.host.tool_cards',
    children: [
      _StateCard(
        label: 'club management panel',
        child: HostClubManagementPanel(
          club: _club,
          events: HostOperationsFixtures.eventsByClub[_club.id] ?? const [],
          onEditClub: () {},
          onCreateEvent: () {},
        ),
      ),
      _StateCard(
        label: 'stat chip',
        child: HostStatChip(
          label: 'Booked',
          value: '30',
          icon: CatchIcons.checkCircleOutlineRounded,
        ),
      ),
      _StateCard(
        label: 'event tools carousel',
        child: HostEventToolsCarousel(
          tools: tools,
          onManageEvent: (_) {},
          onTakeAttendance: (_) {},
          onViewReport: (_) {},
        ),
      ),
      _StateCard(
        label: 'event tool card',
        child: HostEventToolCard(
          item: tools.first,
          cardIndex: 0,
          cardCount: tools.length,
          onManageEvent: (_) {},
          onTakeAttendance: (_) {},
          onViewReport: (_) {},
        ),
      ),
      const _StateCard(
        label: 'page indicator',
        child: HostEventToolsPageIndicator(selectedIndex: 0, itemCount: 2),
      ),
    ],
  );
}

Widget _hostAnalyticsExactCatalog(BuildContext context, String focus) {
  return _HostCatalog(
    title: focus,
    contractId: 'component.host.analytics.${_hostComponentSlug(focus)}',
    children: [
      _StateCard(
        label: 'exact component',
        child: _HostComponentFrame(child: _hostAnalyticsPreviewFor(focus)),
      ),
    ],
  );
}

Widget _hostAnalyticsPreviewFor(String focus) {
  final report = HostOperationsFixtures.analyticsReport;
  return switch (focus) {
    'HostAnalyticsBar' => const SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: HostAnalyticsBar(value: 18, maxValue: 42)),
          gapW8,
          Expanded(child: HostAnalyticsBar(value: 32, maxValue: 42)),
          gapW8,
          Expanded(child: HostAnalyticsBar(value: 42, maxValue: 42)),
        ],
      ),
    ),
    'HostAnalyticsControls' => HostAnalyticsControls(
      rangePreset: HostAnalyticsRangePreset.custom,
      granularity: HostAnalyticsGranularity.week,
      customStartDate: _hostAnalyticsDateDaysAgo(30),
      customEndDate: _hostAnalyticsDateDaysAgo(0),
      selectedEventId: report.topEvents.first.eventId,
      onRangeChanged: (_) {},
      onGranularityChanged: (_) {},
      onPickStartDate: () {},
      onPickEndDate: () {},
      onClearEvent: () {},
    ),
    'HostAnalyticsDataQualityPanel' => HostAnalyticsDataQualityPanel(
      rows: report.dataQuality,
    ),
    'HostAnalyticsDateButton' => HostAnalyticsDateButton(
      label: 'Start',
      value: _hostFormatAnalyticsDate(_hostAnalyticsDateDaysAgo(30)),
      onTap: () {},
    ),
    'HostAnalyticsEventList' => HostAnalyticsEventList(
      events: report.topEvents,
      selectedEventId: report.topEvents.first.eventId,
      onEventSelected: (_) {},
      onClearEvent: () {},
    ),
    'HostAnalyticsEventTile' => HostAnalyticsEventTile(
      event: report.topEvents.first,
      divider: false,
      selected: true,
      onTap: () {},
    ),
    'HostAnalyticsInlineStat' => const HostAnalyticsInlineStat(
      label: 'Bookings',
      value: '126',
    ),
    'HostAnalyticsMetricGrid' => HostAnalyticsMetricGrid(
      metrics: report.summaryCards,
    ),
    'HostAnalyticsMetricTile' => HostAnalyticsMetricTile(
      metric: report.summaryCards.first,
    ),
    'HostAnalyticsReportView' => HostAnalyticsReportView(
      report: report,
      selectedEventId: report.topEvents.first.eventId,
      onEventSelected: (_) {},
      onClearEvent: () {},
    ),
    'HostAnalyticsReviewDiscoveryPanel' => HostAnalyticsReviewDiscoveryPanel(
      report: report,
    ),
    'HostAnalyticsSection' => HostAnalyticsSection(
      label: 'Section label',
      child: HostAnalyticsMetricTile(metric: report.summaryCards.first),
    ),
    'HostAnalyticsTrendPanel' => HostAnalyticsTrendPanel(points: report.trend),
    _ => Text('No exact preview registered for $focus.'),
  };
}

Widget _hostHomeExactCatalog(BuildContext context, String focus) {
  return _HostCatalog(
    title: focus,
    contractId: 'component.host.home.${_hostComponentSlug(focus)}',
    children: [
      _StateCard(
        label: 'exact component',
        child: _HostHomeSectionFrame(child: _hostHomePreviewFor(focus)),
      ),
    ],
  );
}

Widget _hostHomePreviewFor(String focus) {
  final club = HostOperationsFixtures.primaryClub;
  final event = HostOperationsFixtures.upcomingEvent;
  final clubs = HostOperationsFixtures.clubs;
  final state = HostHomeTodayDashboardState.fromAsync(
    AsyncData<List<Event>>([event, HostOperationsFixtures.privateEvent]),
  );
  final tasks = HostHomeTodayTaskData.forEvent(event);
  return switch (focus) {
    'HostEmptyState' => const HostEmptyState(
      title: 'No clubs yet',
      body: 'Create a club to start hosting events.',
    ),
    'HostSectionLabel' => const HostSectionLabel(label: 'TODAY'),
    'HostTodayAvatarDot' => Builder(
      builder: (context) {
        final activity = ActivityPalette.resolve(
          context,
          club.hostDefaults.primaryActivityKind,
        );
        return SizedBox(
          width: CatchSpacing.s16,
          height: CatchSpacing.s8,
          child: Stack(
            children: [
              HostTodayAvatarDot(left: 0, fill: activity.deep, label: 'M'),
            ],
          ),
        );
      },
    ),
    'HostTodayAvatarStack' => Builder(
      builder: (context) => HostTodayAvatarStack(
        activity: ActivityPalette.resolve(
          context,
          club.hostDefaults.primaryActivityKind,
        ),
      ),
    ),
    'HostTodayClubPill' => HostTodayClubPill(
      club: club,
      currentUid: _hostUid,
      clubs: clubs,
      showClubPicker: true,
      onSwitchClubIndex: (_) {},
    ),
    'HostTodayCountdownPill' => HostTodayCountdownPill(event: event),
    'HostTodayDashboardCard' => HostTodayDashboardCard(
      club: club,
      currentUid: _hostUid,
      clubs: clubs,
      showClubPicker: true,
      onSwitchClubIndex: (_) {},
      onViewEvents: () {},
      onCreateEvent: (_) {},
      onManageEvent: (_, _) {},
    ),
    'HostTodayDashboardSection' => HostTodayDashboardSection(
      club: club,
      currentUid: _hostUid,
      clubs: clubs,
      showClubPicker: true,
      state: state,
      onSwitchClubIndex: (_) {},
      onViewEvents: () {},
      onCreateEvent: (_) {},
      onManageEvent: (_, _) {},
    ),
    'HostTodayEmptyEvents' => HostTodayEmptyEvents(
      club: club,
      onCreateEvent: (_) {},
      onViewEvents: () {},
    ),
    'HostTodayEventHero' => HostTodayEventHero(event: event, onPressed: () {}),
    'HostTodayHeader' => HostTodayHeader(
      club: club,
      currentUid: _hostUid,
      clubs: clubs,
      showClubPicker: true,
      onSwitchClubIndex: (_) {},
    ),
    'HostTodayHeroMetric' => const HostTodayHeroMetric(
      value: '10',
      label: 'Going',
    ),
    'HostTodayLoadingBody' => const HostTodayLoadingBody(),
    'HostTodayTaskCard' => HostTodayTaskCard(
      task: tasks.first,
      onPrimary: () {},
    ),
    _ => Text('No exact preview registered for $focus.'),
  };
}

Widget _hostClubExactCatalog(BuildContext context, String focus) {
  return _HostCatalog(
    title: focus,
    contractId: 'component.host.club.${_hostComponentSlug(focus)}',
    children: [
      _StateCard(
        label: 'exact component',
        child: _HostComponentFrame(child: _hostClubPreviewFor(focus)),
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
      currentUid: _hostUid,
      isOwner: true,
      clubs: HostOperationsFixtures.clubs,
      showClubPicker: true,
      onSelectClubIndex: (_) {},
      onSelectTab: (_) {},
      onPreviewClub: (_) {},
      onOpenSettings: () {},
    ),
    'HostClubPreviewPane' => HostClubPreviewPane(
      club: club,
      onPreviewClub: (_) {},
    ),
    'HostClubProfileCard' => HostClubProfileCard(
      club: club,
      currentUid: _hostUid,
      isOwner: true,
      onPreviewClub: (_) {},
    ),
    'HostClubTabRail' => HostClubTabRail(
      selected: HostClubTab.organizer,
      onChanged: (_) {},
    ),
    'HostEventsClubCard' => HostEventsClubCard(
      club: club,
      currentUid: _hostUid,
      onCreateEvent: (_) {},
      onManageEvent: (_, _) {},
    ),
    'HostInlineAgeRangeEditor' => HostClubProfileCard(
      club: club,
      currentUid: _hostUid,
      isOwner: true,
      initialExpandedField: 'ageRange',
      onPreviewClub: (_) {},
    ),
    'HostInlineOptionEditor' => HostClubProfileCard(
      club: club,
      currentUid: _hostUid,
      isOwner: true,
      initialExpandedField: 'primaryActivityKind',
      onPreviewClub: (_) {},
    ),
    'HostInlineTextEntryEditor' => HostClubProfileCard(
      club: club,
      currentUid: _hostUid,
      isOwner: true,
      initialExpandedField: 'name',
      onPreviewClub: (_) {},
    ),
    'HostOrganizerHeader' => HostOrganizerHeader(club: club),
    'HostOrganizerMetricGrid' => HostOrganizerMetricGrid(
      club: club,
      eventsLoaded: true,
      eventCount: events.length,
      activeEventCount: events.where((event) => !event.isCancelled).length,
    ),
    'HostOrganizerMetricRow' => HostOrganizerMetricRow(items: metricItems),
    'HostOrganizerMetricTile' => HostOrganizerMetricTile(
      item: metricItems.first,
    ),
    'HostOrganizerPayoutPrompt' => HostOrganizerPayoutPrompt(
      uid: _hostUid,
      onManagePayouts: () {},
    ),
    'HostOrganizerSectionHeader' => const HostOrganizerSectionHeader(
      label: 'Team',
      actionLabel: 'Manage',
    ),
    'HostOrganizerTeamCard' => HostOrganizerTeamCard(
      profiles: team,
      currentUid: _hostUid,
    ),
    'HostOrganizerTeamRow' => HostOrganizerTeamRow(
      profile: team.first,
      currentUid: _hostUid,
      divider: false,
    ),
    'HostOrganizerTrendStrip' => HostOrganizerTrendStrip(
      memberCount: club.memberCount,
      activeEventCount: events.length,
      onTap: () {},
    ),
    'HostPaymentAccountCard' => HostPaymentAccountCard(
      club: club,
      account: payment,
    ),
    'HostPaymentAccountControllerCard' => HostPaymentAccountControllerCard(
      club: club,
    ),
    'HostPaymentAccountContentCard' => HostPaymentAccountContentCard(
      account: payment,
      actionErrorMessage: null,
      onboardingPending: false,
      refreshPending: false,
      onShowPayoutsHandoff: (_, _) async {},
      onRefresh: () async {},
    ),
    'HostPaymentAccountErrorCard' => HostPaymentAccountErrorCard(
      error: StateError('Widgetbook payout status failed'),
      onRetry: () {},
    ),
    'HostPaymentAccountLoadingCard' => const HostPaymentAccountLoadingCard(),
    'HostTeamManagementSection' => HostTeamManagementSection(
      club: club,
      currentUid: _hostUid,
    ),
    'HostTeamOwnerHostRow' => HostTeamOwnerHostRow(
      host: team.first,
      canManage: true,
      onTransfer: () {},
      onRemove: () {},
    ),
    'HostTrendKpi' => const HostTrendKpi(value: '188', label: 'Members'),
    _ => Text('No exact preview registered for $focus.'),
  };
}

Widget _hostEventManageExactCatalog(BuildContext context, String focus) {
  return _HostCatalog(
    title: focus,
    contractId: 'component.host.event_manage.${_hostComponentSlug(focus)}',
    children: [
      _StateCard(
        label: 'exact component',
        child: _HostManageComponentFrame(
          child: _hostEventManagePreviewFor(focus),
        ),
      ),
    ],
  );
}

Widget _hostEventManagePreviewFor(String focus) {
  final event = HostOperationsFixtures.privateEvent;
  final club = HostOperationsFixtures.primaryClub;
  final roster = EventParticipationRoster.fromParticipations(
    HostOperationsFixtures.participations,
  );
  final viewModel = _hostAttendanceViewModel();
  final profiles = _hostAttendeeProfiles();
  final inviteCode = HostOperationsFixtures.privateAccess.inviteCode;
  final filters = const [
    HostRosterFilterSpec(
      filter: HostRosterFilter.all,
      label: 'All',
      value: 3,
      tone: CatchBadgeTone.solid,
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
    'HostCapacityTile' => const HostCapacityTile(
      value: '11',
      suffix: '/12',
      label: 'Booked',
    ),
    'HostEventActionsSection' => HostEventActionsSection(
      club: club,
      event: event,
      actionState: HostEventActionDisplayState.resolve(
        event: event,
        roster: roster,
        cancelEventPending: false,
        deleteEventPending: false,
      ),
      actionError: null,
      privateLinkActionState: HostPrivateLinkActionState.resolve(
        club: club,
        event: event,
        accessAsync: AsyncData<EventPrivateAccess?>(
          HostOperationsFixtures.privateAccess,
        ),
        inviteLinksAsync: AsyncData<List<EventInviteLink>>(
          HostOperationsFixtures.inviteLinks,
        ),
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
        markAttendancePending: false,
        approveJoinRequestPending: false,
        declineJoinRequestPending: false,
        createWaitlistOfferPending: false,
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
    'HostEventSummaryCard' => HostEventSummaryCard(club: club, event: event),
    'HostEventSummaryRow' => HostEventSummaryRow(
      icon: CatchIcons.locationOnOutlined,
      label: 'Meet',
      value: 'Carter Road Jetty',
    ),
    'HostExportReportButton' => HostExportReportButton(
      label: 'Ops CSV',
      isExporting: false,
      onExport: () async {},
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
      onCopyInviteLink: (_, _) {},
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
      onCopyInviteLink: (_, _) {},
      onDisableInviteLink: (_) {},
    ),
    'HostManageMetaItem' => Builder(
      builder: (context) => HostManageMetaItem(
        icon: CatchIcons.groupsOutlined,
        label: '11 / 12 spots',
        color: CatchTokens.of(context).ink2,
      ),
    ),
    'HostManageMetaRow' => HostManageMetaRow(event: event),
    'HostManageSectionPicker' => HostManageSectionPicker(
      selectedSection: HostEventManageSection.setup,
      onChanged: (_) {},
    ),
    'HostParticipationLifecycleBoard' => HostParticipationLifecycleBoard(
      viewModel: viewModel,
      mode: HostEventParticipantsMode.live,
      profiles: profiles,
      scrollable: false,
      showHeader: true,
      usesRequestApproval: false,
      mutationState: HostParticipantsMutationDisplayState.resolve(
        markAttendancePending: false,
        approveJoinRequestPending: false,
        declineJoinRequestPending: false,
        createWaitlistOfferPending: false,
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
            club: club,
            event: event,
            access: HostOperationsFixtures.privateAccess,
            inviteLinksAsync: AsyncData<List<EventInviteLink>>(
              HostOperationsFixtures.inviteLinks,
            ),
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
          onCopyInviteLink: (_, _) {},
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
        onCopyInviteLink: (_, _) {},
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

Widget _hostSettingsExactCatalog(BuildContext context, String focus) {
  return _HostCatalog(
    title: focus,
    contractId: 'component.host.settings.${_hostComponentSlug(focus)}',
    children: [
      _StateCard(
        label: 'exact component',
        child: _hostSettingsPreviewFor(focus),
      ),
    ],
  );
}

Widget _hostSettingsPreviewFor(String focus) {
  final profile = _hostProfileVariant(HostProfileStatus.active);
  return switch (focus) {
    'HostProfileEditorSheet' => _HostComponentFrame(
      child: HostProfileEditorSheet(profile: profile),
    ),
    'HostSettingsClubRows' => const _DeviceFrame(
      child: _HostSettingsClubsFrame(),
    ),
    'HostSettingsClubsEmptyState' => const _DeviceFrame(
      child: _HostSettingsClubsFrame(clubs: []),
    ),
    'HostSettingsProfileRows' => _DeviceFrame(
      child: _HostSettingsProfileFrame(profile: profile),
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

DateTime _hostAnalyticsDateDaysAgo(int days) {
  final today = DateUtils.dateOnly(DateTime.now());
  return DateTime(today.year, today.month, today.day - days);
}

String _hostFormatAnalyticsDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String _hostComponentSlug(String name) {
  return name
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match.group(1)}_${match.group(2)}',
      )
      .toLowerCase();
}

@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostClubsScaffold,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostClubTabRail,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostClubOrganizerOverview,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostOrganizerHeader,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostOrganizerPayoutPrompt,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostOrganizerMetricGrid,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostOrganizerMetricRow,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostOrganizerMetricTile,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostOrganizerSectionHeader,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostOrganizerTeamCard,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostOrganizerTeamRow,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostOrganizerTrendStrip,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostTrendKpi,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostClubProfileCard,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostClubInsightsPane,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostAnalyticsControls,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostAnalyticsDateButton,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostAnalyticsReportView,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostAnalyticsMetricGrid,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostAnalyticsMetricTile,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostAnalyticsTrendPanel,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostAnalyticsBar,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostAnalyticsEventList,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostAnalyticsEventTile,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostAnalyticsReviewDiscoveryPanel,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostAnalyticsDataQualityPanel,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostAnalyticsInlineStat,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostAnalyticsSection,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostInlineTextEntryEditor,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostInlineOptionEditor,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostInlineAgeRangeEditor,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostClubPreviewPane,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostPaymentAccountCard,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostPaymentAccountControllerCard,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostPaymentAccountContentCard,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostPaymentAccountLoadingCard,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostPaymentAccountErrorCard,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostTeamManagementSection,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host clubs route states',
  type: HostTeamOwnerHostRow,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
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
          child: _HostShellScope(
            child: _HostTeamAddHostSheetPreview(
              mode: _HostTeamAddHostSheetPreviewMode.pending,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'add error',
        child: const _DeviceFrame(
          child: _HostShellScope(
            child: _HostTeamAddHostSheetPreview(
              mode: _HostTeamAddHostSheetPreviewMode.error,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'add offline',
        child: const _DeviceFrame(
          child: _HostShellScope(
            child: _HostTeamAddHostSheetPreview(
              mode: _HostTeamAddHostSheetPreviewMode.offline,
            ),
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
  name: 'Covered by host settings route states',
  type: HostSettingsSection,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host settings route states',
  type: HostSettingsProfileRows,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host settings route states',
  type: HostSettingsClubsEmptyState,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host settings route states',
  type: HostSettingsClubRows,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host settings route states',
  type: HostProfileEditorSheet,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
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
  name: 'Route state renderer',
  type: HostCreateEventRouteStateView,
  path: '[P1 product surfaces]/Host create event',
)
Widget hostCreateEventRouteStateViewCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'HostCreateEventRouteStateView',
    contractId: 'component.host.event.create_route_state_view',
    children: [
      _StateCard(
        label: 'ready',
        child: _DeviceFrame(
          child: _HostCreateEventScope(
            child: HostCreateEventRouteStateView(
              clubId: _club.id,
              state: HostCreateEventRouteState.initial(_club),
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
  name: 'Direct form states',
  type: CreateClubScreen,
  path: '[P1 product surfaces]/Host create club',
)
Widget createClubScreenCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'CreateClubScreen',
    contractId: 'screen.host.club.create.form',
    children: [
      _StateCard(
        label: 'draft restored',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: CreateClubScreen(
              initialDraft: HostOperationsFixtures.clubDraft,
              restoreSavedDraft: false,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'media picked',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
            child: CreateClubScreen(
              initialDraft: HostOperationsFixtures.clubDraft,
              initialPickedClubPhotos: _createClubPickedPhotos(),
              initialProfileImage: _createClubProfileImage(),
              restoreSavedDraft: false,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'edit mode',
        child: _DeviceFrame(
          child: _HostCreateClubScope(
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
  name: 'Form states',
  type: ClubBasicsStep,
  path: '[P1 product surfaces]/Host create club',
)
Widget clubBasicsStepCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'ClubBasicsStep',
    contractId: 'component.host.club.basics_step',
    children: [
      _StateCard(
        label: 'prefilled',
        child: _DeviceFrame(child: _ClubBasicsStepFrame()),
      ),
      _StateCard(
        label: 'validation',
        child: _DeviceFrame(child: _ClubBasicsStepFrame(validate: true)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Form states',
  type: ClubDetailsStep,
  path: '[P1 product surfaces]/Host create club',
)
Widget clubDetailsStepCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'ClubDetailsStep',
    contractId: 'component.host.club.details_step',
    children: [
      _StateCard(
        label: 'prefilled',
        child: _DeviceFrame(child: _ClubDetailsStepFrame()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contact states',
  type: CreateClubContactFields,
  path: '[P1 product surfaces]/Host create club',
)
Widget createClubContactFieldsCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'CreateClubContactFields',
    contractId: 'component.host.club.contact_fields',
    children: [
      _StateCard(
        label: 'filled',
        child: _DeviceFrame(child: _CreateClubContactFieldsFrame()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Media states',
  type: CreateClubPhotosPicker,
  path: '[P1 product surfaces]/Host create club',
)
Widget createClubPhotosPickerCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'CreateClubPhotosPicker',
    contractId: 'component.host.club.photos_picker',
    children: [
      _StateCard(
        label: 'empty',
        child: _DeviceFrame(
          child: CreateClubPhotosPicker(
            photos: const [],
            onAddPhotos: () {},
            onRemovePhoto: (_) {},
            onReorderPhoto: (_, _) {},
          ),
        ),
      ),
      _StateCard(
        label: 'edit strip',
        child: _DeviceFrame(
          child: CreateClubPhotosPicker(
            photos: _orderedPhotoPreviews('club-photo', 3),
            onAddPhotos: () {},
            onRemovePhoto: (_) {},
            onReorderPhoto: (_, _) {},
            variant: CreateClubPhotosPickerVariant.editStrip,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photos label states',
  type: EditClubPhotosLabel,
  path: '[P1 product surfaces]/Host create club',
)
Widget editClubPhotosLabelCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'EditClubPhotosLabel',
    contractId: 'component.host.club.edit_photos_label',
    children: [
      _StateCard(
        label: 'three photos',
        child: SizedBox(width: 320, child: EditClubPhotosLabel(count: 3)),
      ),
      _StateCard(
        label: 'empty strip',
        child: SizedBox(width: 320, child: EditClubPhotosLabel(count: 0)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Image states',
  type: CreateClubProfileImagePicker,
  path: '[P1 product surfaces]/Host create club',
)
Widget createClubProfileImagePickerCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'CreateClubProfileImagePicker',
    contractId: 'component.host.club.profile_image_picker',
    children: [
      _StateCard(
        label: 'standard',
        child: _DeviceFrame(
          child: CreateClubProfileImagePicker(
            imageBytes: _createClubPngBytes(),
            onTap: () {},
          ),
        ),
      ),
      _StateCard(
        label: 'edit logo',
        child: _DeviceFrame(
          child: CreateClubProfileImagePicker(
            imageBytes: _createClubPngBytes(),
            onTap: () {},
            variant: CreateClubProfileImagePickerVariant.editLogo,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile image tile states',
  type: ClubProfileImageTile,
  path: '[P1 product surfaces]/Host create club',
)
Widget clubProfileImageTileCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'ClubProfileImageTile',
    contractId: 'component.host.club.profile_image_tile',
    children: [
      _StateCard(
        label: 'empty large',
        child: ClubProfileImageTile(
          imageBytes: null,
          existingImageUrl: null,
          onTap: () {},
          size: CatchLayout.clubProfileImagePickerExtent,
          showEmptyLabel: true,
        ),
      ),
      _StateCard(
        label: 'logo filled',
        child: ClubProfileImageTile(
          imageBytes: _createClubPngBytes(),
          existingImageUrl: null,
          onTap: () {},
          size: 64,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Defaults states',
  type: ClubHostDefaultsStep,
  path: '[P1 product surfaces]/Host create club',
)
Widget clubHostDefaultsStepCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'ClubHostDefaultsStep',
    contractId: 'component.host.club.host_defaults_step',
    children: [
      _StateCard(
        label: 'prefilled',
        child: _DeviceFrame(child: _ClubHostDefaultsStepFrame()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Policy defaults states',
  type: ClubPolicyDefaultsCard,
  path: '[P1 product surfaces]/Host create club',
)
Widget clubPolicyDefaultsCardCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'ClubPolicyDefaultsCard',
    contractId: 'component.host.club.policy_defaults_card',
    children: [
      _StateCard(
        label: 'editable',
        child: _DeviceFrame(child: _ClubPolicyDefaultsCardFrame()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Event success defaults states',
  type: ClubEventSuccessDefaultsStep,
  path: '[P1 product surfaces]/Host create club',
)
Widget clubEventSuccessDefaultsStepCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'ClubEventSuccessDefaultsStep',
    contractId: 'component.host.club.event_success_defaults_step',
    children: [
      _StateCard(
        label: 'activity-aware defaults',
        child: _DeviceFrame(child: _ClubEventSuccessDefaultsStepFrame()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Direct screen states',
  type: CreateEventScreen,
  path: '[P1 product surfaces]/Host create event',
)
Widget createEventScreenCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'CreateEventScreen',
    contractId: 'screen.host.event.create.form',
    children: [
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
        label: 'validation',
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
    ],
  );
}

@widgetbook.UseCase(
  name: 'Success states',
  type: CreateEventSuccessScreen,
  path: '[P1 product surfaces]/Host create event',
)
Widget createEventSuccessScreenCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'CreateEventSuccessScreen',
    contractId: 'screen.host.event.create.success',
    children: [
      _StateCard(
        label: 'public event',
        child: _DeviceFrame(
          child: CreateEventSuccessScreen(
            club: _club,
            event: _editableEvent,
            onManageEvent: () {},
            onDone: () {},
          ),
        ),
      ),
      _StateCard(
        label: 'invite only',
        child: _DeviceFrame(
          child: CreateEventSuccessScreen(
            club: _club,
            event: _privateEvent,
            inviteCode: 'SEAFACE',
            onManageEvent: () {},
            onDone: () {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Header states',
  type: CreateEventStepHeader,
  path: '[P1 product surfaces]/Host create event',
)
Widget createEventStepHeaderCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'CreateEventStepHeader',
    contractId: 'component.host.event.step_header',
    children: [
      _StateCard(
        label: 'step 1',
        child: _DeviceFrame(
          child: CreateEventStepHeader(
            title: 'Event basics',
            clubName: _club.name,
            currentStep: 0,
            totalSteps: 5,
            onBack: () {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Footer states',
  type: StepperFooter,
  path: '[P1 product surfaces]/Host shared',
)
Widget stepperFooterCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'StepperFooter',
    contractId: 'component.host.stepper_footer',
    children: [
      _StateCard(
        label: 'save and next',
        child: _DeviceFrame(
          child: Column(
            children: [
              const Expanded(child: SizedBox.shrink()),
              StepperFooter(
                isLastStep: false,
                isLoading: false,
                onPrimary: () {},
                onSaveDraft: () {},
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'last step loading',
        child: _DeviceFrame(
          child: Column(
            children: [
              const Expanded(child: SizedBox.shrink()),
              StepperFooter(
                isLastStep: true,
                isLoading: true,
                onPrimary: () {},
                onSaveDraft: null,
                lastStepLabel: 'Schedule event',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Dialog states',
  type: CreateEventUnsavedChangesDialog,
  path: '[P1 product surfaces]/Host create event',
)
Widget createEventUnsavedChangesDialogCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'CreateEventUnsavedChangesDialog',
    contractId: 'component.host.event.unsaved_changes_dialog',
    children: [
      _StateCard(
        label: 'save or discard',
        child: const _DeviceFrame(
          child: Center(child: CreateEventUnsavedChangesDialog()),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Delete confirmation',
  type: DraftDeleteConfirmationDialog,
  path: '[P1 product surfaces]/Host create event',
)
Widget draftDeleteConfirmationDialogCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'DraftDeleteConfirmationDialog',
    contractId: 'component.host.event.draft_delete_dialog',
    children: [
      _StateCard(
        label: 'saved draft',
        child: _DeviceFrame(
          child: Center(
            child: DraftDeleteConfirmationDialog(
              draft: HostOperationsFixtures.eventDraft,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo picker states',
  type: CreateEventPhotoPicker,
  path: '[P1 product surfaces]/Host create event',
)
Widget createEventPhotoPickerCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'CreateEventPhotoPicker',
    contractId: 'component.host.event.photo_picker',
    children: [
      _StateCard(
        label: 'empty',
        child: _DeviceFrame(
          child: CreateEventPhotoPicker(
            photos: const [],
            onAddPhotos: () {},
            onRemovePhoto: (_) {},
            onReorderPhoto: (_, _) {},
          ),
        ),
      ),
      _StateCard(
        label: 'filled',
        child: _DeviceFrame(
          child: CreateEventPhotoPicker(
            photos: _orderedPhotoPreviews('event-photo', 3),
            onAddPhotos: () {},
            onRemovePhoto: (_) {},
            onReorderPhoto: (_, _) {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Draft sheet states',
  type: DraftPickerSheet,
  path: '[P1 product surfaces]/Host create event',
)
Widget draftPickerSheetCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'DraftPickerSheet',
    contractId: 'component.host.event.draft_picker_sheet',
    children: [
      _StateCard(
        label: 'with drafts',
        child: _DeviceFrame(
          child: DraftPickerSheet(
            drafts: [HostOperationsFixtures.eventDraft],
            onSelectDraft: (_) {},
            onStartFresh: () {},
            onDeleteDraft: (_) async {},
          ),
        ),
      ),
      _StateCard(
        label: 'empty',
        child: _DeviceFrame(
          child: DraftPickerSheet(
            drafts: const [],
            onSelectDraft: (_) {},
            onStartFresh: () {},
            onDeleteDraft: (_) async {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Draft card states',
  type: DraftCard,
  path: '[P1 product surfaces]/Host create event',
)
Widget draftCardCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'DraftCard',
    contractId: 'component.host.event.draft_card',
    children: [
      _StateCard(
        label: 'saved draft',
        child: DraftCard(
          draft: HostOperationsFixtures.eventDraft,
          isDeleting: false,
          onSelect: () {},
          onDelete: () {},
        ),
      ),
      _StateCard(
        label: 'delete pending',
        child: DraftCard(
          draft: HostOperationsFixtures.eventDraft,
          isDeleting: true,
          onSelect: () {},
          onDelete: () {},
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Details step states',
  type: EventDetailsStep,
  path: '[P1 product surfaces]/Host create event',
)
Widget eventDetailsStepCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'EventDetailsStep',
    contractId: 'component.host.event.details_step',
    children: [
      _StateCard(
        label: 'run event',
        child: _DeviceFrame(child: _EventDetailsStepFrame()),
      ),
      _StateCard(
        label: 'custom activity',
        child: _DeviceFrame(
          child: _EventDetailsStepFrame(customActivity: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Where step states',
  type: WhereStep,
  path: '[P1 product surfaces]/Host create event',
)
Widget whereStepCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'WhereStep',
    contractId: 'component.host.event.where_step',
    children: [
      _StateCard(
        label: 'selected location',
        child: _DeviceFrame(child: _WhereStepFrame()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'When step states',
  type: WhenStep,
  path: '[P1 product surfaces]/Host create event',
)
Widget whenStepCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'WhenStep',
    contractId: 'component.host.event.when_step',
    children: [
      _StateCard(
        label: 'scheduled',
        child: _DeviceFrame(child: _WhenStepFrame()),
      ),
      _StateCard(
        label: 'schedule error',
        child: _DeviceFrame(child: _WhenStepFrame(scheduleError: true)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Policy step states',
  type: EventPolicyStep,
  path: '[P1 product surfaces]/Host create event',
)
Widget eventPolicyStepCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'EventPolicyStep',
    contractId: 'component.host.event.policy_step',
    children: [
      _StateCard(
        label: 'open capacity',
        child: _DeviceFrame(child: _EventPolicyStepFrame()),
      ),
      _StateCard(
        label: 'invite only',
        child: _DeviceFrame(child: _EventPolicyStepFrame(inviteOnly: true)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Event success step states',
  type: EventSuccessStep,
  path: '[P1 product surfaces]/Host create event',
)
Widget eventSuccessStepCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'EventSuccessStep',
    contractId: 'component.host.event.success_step',
    children: [
      _StateCard(
        label: 'run guide defaults',
        child: _DeviceFrame(child: _EventSuccessStepFrame()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Direct screen states',
  type: EditHostedEventScreen,
  path: '[P1 product surfaces]/Host edit event',
)
Widget editHostedEventScreenCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'EditHostedEventScreen',
    contractId: 'screen.host.event.edit.form',
    children: [
      _StateCard(
        label: 'editable',
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
        label: 'policy locked',
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
    ],
  );
}

@widgetbook.UseCase(
  name: 'Scope notice states',
  type: EditHostedEventScopeNotice,
  path: '[P1 product surfaces]/Host edit event',
)
Widget editHostedEventScopeNoticeCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'EditHostedEventScopeNotice',
    contractId: 'component.host.event.edit_scope_notice',
    children: [
      _StateCard(
        label: 'fully editable',
        child: _DeviceFrame(
          child: EditHostedEventScopeNotice(
            isCancelled: false,
            scheduleLocked: false,
            policyLocked: false,
          ),
        ),
      ),
      _StateCard(
        label: 'schedule locked',
        child: _DeviceFrame(
          child: EditHostedEventScopeNotice(
            isCancelled: false,
            scheduleLocked: true,
            policyLocked: true,
          ),
        ),
      ),
      _StateCard(
        label: 'cancelled',
        child: _DeviceFrame(
          child: EditHostedEventScopeNotice(
            isCancelled: true,
            scheduleLocked: true,
            policyLocked: true,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Editable policy states',
  type: EditableHostedEventPolicyCard,
  path: '[P1 product surfaces]/Host edit event',
)
Widget editableHostedEventPolicyCardCatalogStates(BuildContext context) {
  return const _HostCatalog(
    title: 'EditableHostedEventPolicyCard',
    contractId: 'component.host.event.edit_policy_card',
    children: [
      _StateCard(
        label: 'open capacity',
        child: _DeviceFrame(child: _EditableHostedEventPolicyCardFrame()),
      ),
      _StateCard(
        label: 'invite only',
        child: _DeviceFrame(
          child: _EditableHostedEventPolicyCardFrame(inviteOnly: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Read-only policy states',
  type: ReadOnlyHostedEventPolicyCard,
  path: '[P1 product surfaces]/Host edit event',
)
Widget readOnlyHostedEventPolicyCardCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'ReadOnlyHostedEventPolicyCard',
    contractId: 'component.host.event.read_only_policy_card',
    children: [
      _StateCard(
        label: 'locked policy',
        child: _DeviceFrame(
          child: ReadOnlyHostedEventPolicyCard(event: _privateEvent),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Read-only schedule states',
  type: ReadOnlyHostedEventScheduleCard,
  path: '[P1 product surfaces]/Host edit event',
)
Widget readOnlyHostedEventScheduleCardCatalogStates(BuildContext context) {
  return _HostCatalog(
    title: 'ReadOnlyHostedEventScheduleCard',
    contractId: 'component.host.event.read_only_schedule_card',
    children: [
      _StateCard(
        label: 'started event',
        child: _DeviceFrame(
          child: ReadOnlyHostedEventScheduleCard(event: _privateEvent),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostEventManageScreen,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostManageMetaRow,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostManageMetaItem,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostManageSectionPicker,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostPrivateAccessCard,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostPrivateAccessShell,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostPrivateAccessBody,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostInviteLinksList,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostInviteLinkRow,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostFullCapacityApron,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostFullCapacityBanner,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostCapacityTile,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostEventActionsSection,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostActionRow,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostEventSummaryCard,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostEventSummaryRow,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostEventAttendancePanel,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostEventParticipantsPanel,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostEventParticipantsList,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostParticipationLifecycleBoard,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostRosterSearchBar,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostRosterFilterHeader,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostWaitlistBulkOfferAction,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Covered by host event manage route states',
  type: HostExportReportButton,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
@widgetbook.UseCase(
  name: 'Route and section states',
  type: HostEventManageRouteScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget hostEventManageRouteAndSectionStates(BuildContext context) {
  final eventSuccessNow = DateTime(2026, 6, 1, 18);
  final eventSuccessLivePlan =
      EventSuccessPlan.defaultForEvent(
        _privateEvent,
        now: eventSuccessNow,
      ).copyWith(
        activeStepIndex: 1,
        status: EventSuccessPlanStatus.live,
        frozenAt: eventSuccessNow,
      );
  final eventSuccessReportPlan = eventSuccessLivePlan.copyWith(
    activeStepIndex: 3,
    status: EventSuccessPlanStatus.complete,
    completedAt: eventSuccessNow.add(const Duration(hours: 2)),
  );
  final eventSuccessCheckInPlan = _hostManageLivePlanForModule(
    event: _privateEvent,
    now: eventSuccessNow,
    moduleId: EventSuccessModuleCatalog.checkIn.id,
  );
  final eventSuccessCuePlan = _hostManageLivePlanForModule(
    event: _privateEvent,
    now: eventSuccessNow,
    moduleId: EventSuccessModuleCatalog.socialMissions.id,
  );
  final eventSuccessHostOverridePlan = _hostManageLivePlanForModule(
    event: _privateEvent,
    now: eventSuccessNow,
    moduleId: EventSuccessModuleCatalog.microPods.id,
  );
  final eventSuccessRevealEvent = _hostManageLiveRevealEvent(_privateEvent);
  final eventSuccessRevealPlan =
      _hostManageLivePlanForModule(
        event: eventSuccessRevealEvent,
        now: eventSuccessNow,
        moduleId: EventSuccessModuleCatalog.liveReveal.id,
      ).copyWith(
        revealStatus: EventSuccessRevealStatus.revealed,
        activeRevealRoundIndex: 0,
        revealStartedAt: eventSuccessNow.subtract(const Duration(minutes: 2)),
      );
  final microPodAssignments = _hostManageMicroPodAssignments(
    event: _privateEvent,
    now: eventSuccessNow,
  );
  final hostOverrideAssignments = _hostManageMicroPodAssignments(
    event: _privateEvent,
    now: eventSuccessNow,
    source: 'host_override_v1',
  );
  final rotationAssignments = _hostManageRotationAssignments(
    event: _privateEvent,
    now: eventSuccessNow,
  );
  final wingmanRequests = _hostManageWingmanRequests(
    event: _privateEvent,
    now: eventSuccessNow,
  );

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
        label: 'live plan loading',
        child: const _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.live,
            planValue: AsyncLoading<EventSuccessPlan?>(),
          ),
        ),
      ),
      _StateCard(
        label: 'live plan error',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.live,
            planValue: AsyncError<EventSuccessPlan?>(
              StateError('Event Success setup failed'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'live plan offline',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.live,
            planValue: AsyncError<EventSuccessPlan?>(
              obviousOfflineException(),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'live wingman requests',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.live,
            planValue: AsyncData<EventSuccessPlan?>(eventSuccessLivePlan),
            wingmanRequests: wingmanRequests,
            wingmanProfiles: _hostManageProfilesFor([
              for (final request in wingmanRequests) ...[
                request.requesterUid,
                request.targetUid,
              ],
            ]),
          ),
        ),
      ),
      _StateCard(
        label: 'live check-in QR',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.live,
            planValue: AsyncData<EventSuccessPlan?>(eventSuccessCheckInPlan),
            child: _hostManageLiveSectionPreview(
              event: _privateEvent,
              liveRoster: const SizedBox.shrink(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'live conversation cues',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.live,
            planValue: AsyncData<EventSuccessPlan?>(eventSuccessCuePlan),
            child: _hostManageLiveSectionPreview(event: _privateEvent),
          ),
        ),
      ),
      _StateCard(
        label: 'live micro-pods assigned',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.live,
            planValue: AsyncData<EventSuccessPlan?>(eventSuccessLivePlan),
            assignments: microPodAssignments,
            assignmentPeerProfiles: _hostManageProfilesFor(
              _hostManageAssignmentParticipantUids(microPodAssignments),
            ),
            preferences: _hostManagePreferences(
              event: _privateEvent,
              now: eventSuccessNow,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'live reveal round revealed',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            event: eventSuccessRevealEvent,
            initialSection: HostEventManageSection.live,
            planValue: AsyncData<EventSuccessPlan?>(eventSuccessRevealPlan),
            assignments: microPodAssignments,
            assignmentPeerProfiles: _hostManageProfilesFor(
              _hostManageAssignmentParticipantUids(microPodAssignments),
            ),
            preferences: _hostManagePreferences(
              event: eventSuccessRevealEvent,
              now: eventSuccessNow,
            ),
            child: _hostManageLiveSectionPreview(
              event: eventSuccessRevealEvent,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'live host override edited',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.live,
            planValue: AsyncData<EventSuccessPlan?>(
              eventSuccessHostOverridePlan,
            ),
            assignments: hostOverrideAssignments,
            assignmentPeerProfiles: _hostManageProfilesFor(
              _hostManageAssignmentParticipantUids(hostOverrideAssignments),
            ),
            preferences: _hostManagePreferences(
              event: _privateEvent,
              now: eventSuccessNow,
            ),
            child: _hostManageLiveSectionPreview(event: _privateEvent),
          ),
        ),
      ),
      _StateCard(
        label: 'live guided rotations assigned',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.live,
            planValue: AsyncData<EventSuccessPlan?>(eventSuccessLivePlan),
            rotationAssignments: rotationAssignments,
            rotationPeerProfiles: _hostManageProfilesFor(
              _hostManageAssignmentParticipantUids(rotationAssignments),
            ),
            preferences: _hostManagePreferences(
              event: _privateEvent,
              now: eventSuccessNow,
            ),
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
        label: 'report scorecard loading',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.report,
            planValue: AsyncData<EventSuccessPlan?>(eventSuccessReportPlan),
            scorecardValue: const AsyncLoading<EventSuccessScorecard?>(),
          ),
        ),
      ),
      _StateCard(
        label: 'report scorecard error',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.report,
            planValue: AsyncData<EventSuccessPlan?>(eventSuccessReportPlan),
            scorecardValue: AsyncError<EventSuccessScorecard?>(
              StateError('Scorecard failed'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'report scorecard offline',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            initialSection: HostEventManageSection.report,
            planValue: AsyncData<EventSuccessPlan?>(eventSuccessReportPlan),
            scorecardValue: AsyncError<EventSuccessScorecard?>(
              obviousOfflineException(),
              StackTrace.empty,
            ),
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
        label: 'private access offline',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            privateAccessValue: AsyncError<EventPrivateAccess?>(
              obviousOfflineException(),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'private access missing code',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            privateAccessValue: AsyncData<EventPrivateAccess?>(
              HostOperationsFixtures.privateAccess.copyWith(inviteCode: ''),
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
        label: 'invite links offline',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            inviteLinksValue: AsyncError<List<EventInviteLink>>(
              obviousOfflineException(),
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
        label: 'invite links disabled row',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            inviteLinksValue: AsyncData<List<EventInviteLink>>(
              _hostManageDisabledInviteLinks,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'invite links long label source',
        child: _DeviceFrame(
          child: _HostManageRouteScope(
            inviteLinksValue: AsyncData<List<EventInviteLink>>(
              _hostManageLongLabelInviteLinks,
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

// Exact host coverage entries. These point narrow promoted classes at the
// catalog route/component state that renders the owning workflow.
@widgetbook.UseCase(
  name: 'Exact catalog',
  type: CatchRosterActionCell,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictCatchRosterActionCellCatalogStates(BuildContext context) =>
    hostRosterPrimitiveCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: CatchRosterDecideTarget,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictCatchRosterDecideTargetCatalogStates(BuildContext context) =>
    hostRosterPrimitiveCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAccountScreen,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAccountScreenCatalogStates(BuildContext context) =>
    hostSettingsRouteStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostActionRow,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostActionRowCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostActionRow');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsBar,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsBarCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsBar');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsControls,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsControlsCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsControls');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsDataQualityPanel,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsDataQualityPanelCatalogStates(
  BuildContext context,
) => _hostAnalyticsExactCatalog(context, 'HostAnalyticsDataQualityPanel');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsDateButton,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsDateButtonCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsDateButton');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsEventList,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsEventListCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsEventList');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsEventTile,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsEventTileCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsEventTile');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsInlineStat,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsInlineStatCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsInlineStat');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsMetricGrid,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsMetricGridCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsMetricGrid');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsMetricTile,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsMetricTileCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsMetricTile');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsReportSkeleton,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsReportSkeletonCatalogStates(
  BuildContext context,
) => hostLoadingSkeletonCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsReportView,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsReportViewCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsReportView');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsReviewDiscoveryPanel,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsReviewDiscoveryPanelCatalogStates(
  BuildContext context,
) => _hostAnalyticsExactCatalog(context, 'HostAnalyticsReviewDiscoveryPanel');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsSection,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsSectionCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsSection');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsTrendPanel,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsTrendPanelCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsTrendPanel');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAuthRequiredScreen,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAuthRequiredScreenCatalogStates(BuildContext context) =>
    hostHomeRouteStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostCapacityTile,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostCapacityTileCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostCapacityTile');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostChartSkeleton,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostChartSkeletonCatalogStates(BuildContext context) =>
    hostLoadingSkeletonCatalogStates(context);

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
  type: HostClubPreviewPane,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostClubPreviewPaneCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostClubPreviewPane');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostClubProfileCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostClubProfileCardCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostClubProfileCard');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostClubsScreen,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostClubsScreenCatalogStates(BuildContext context) =>
    hostClubsRouteStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostClubTabRail,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostClubTabRailCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostClubTabRail');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEmptyState,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEmptyStateCatalogStates(BuildContext context) =>
    _hostHomeExactCatalog(context, 'HostEmptyState');

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
) => hostEventManageRouteAndSectionStates(context);

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
  type: HostEventRows,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventRowsCatalogStates(BuildContext context) =>
    hostHomeEventSectionStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventRowsSkeleton,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventRowsSkeletonCatalogStates(BuildContext context) =>
    hostLoadingSkeletonCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventsClubCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventsClubCardCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostEventsClubCard');

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
  type: HostEventToolCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventToolCardCatalogStates(BuildContext context) =>
    hostToolCardCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventToolsCarousel,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventToolsCarouselCatalogStates(BuildContext context) =>
    hostToolCardCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostEventToolsPageIndicator,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostEventToolsPageIndicatorCatalogStates(
  BuildContext context,
) => hostToolCardCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostExportReportButton,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostExportReportButtonCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostExportReportButton');

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
  type: HostInlineAgeRangeEditor,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostInlineAgeRangeEditorCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostInlineAgeRangeEditor');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostInlineOptionEditor,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostInlineOptionEditorCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostInlineOptionEditor');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostInlineSkeletonIcon,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostInlineSkeletonIconCatalogStates(BuildContext context) =>
    hostLoadingSkeletonCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostInlineTextEntryEditor,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostInlineTextEntryEditorCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostInlineTextEntryEditor');

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

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostLoadingScreen,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostLoadingScreenCatalogStates(BuildContext context) =>
    hostHomeRouteStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostManageMetaItem,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostManageMetaItemCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostManageMetaItem');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostManageMetaRow,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostManageMetaRowCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostManageMetaRow');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostManageSectionPicker,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostManageSectionPickerCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostManageSectionPicker');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostOperationsHomeScreen,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostOperationsHomeScreenCatalogStates(BuildContext context) =>
    hostHomeRouteStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostOrganizerHeader,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostOrganizerHeaderCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostOrganizerHeader');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostOrganizerMetricGrid,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostOrganizerMetricGridCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostOrganizerMetricGrid');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostOrganizerMetricRow,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostOrganizerMetricRowCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostOrganizerMetricRow');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostOrganizerMetricTile,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostOrganizerMetricTileCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostOrganizerMetricTile');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostOrganizerPayoutPrompt,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostOrganizerPayoutPromptCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostOrganizerPayoutPrompt');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostOrganizerSectionHeader,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostOrganizerSectionHeaderCatalogStates(
  BuildContext context,
) => _hostClubExactCatalog(context, 'HostOrganizerSectionHeader');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostOrganizerTeamCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostOrganizerTeamCardCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostOrganizerTeamCard');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostOrganizerTeamRow,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostOrganizerTeamRowCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostOrganizerTeamRow');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostOrganizerTrendStrip,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostOrganizerTrendStripCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostOrganizerTrendStrip');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostParticipationLifecycleBoard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostParticipationLifecycleBoardCatalogStates(
  BuildContext context,
) => _hostEventManageExactCatalog(context, 'HostParticipationLifecycleBoard');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostPaymentAccountCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostPaymentAccountCardCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostPaymentAccountCard');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostPaymentAccountControllerCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostPaymentAccountControllerCardCatalogStates(
  BuildContext context,
) => _hostClubExactCatalog(context, 'HostPaymentAccountControllerCard');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostPaymentAccountContentCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostPaymentAccountContentCardCatalogStates(
  BuildContext context,
) => _hostClubExactCatalog(context, 'HostPaymentAccountContentCard');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostPaymentAccountErrorCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostPaymentAccountErrorCardCatalogStates(
  BuildContext context,
) => _hostClubExactCatalog(context, 'HostPaymentAccountErrorCard');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostPaymentAccountLoadingCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostPaymentAccountLoadingCardCatalogStates(
  BuildContext context,
) => _hostClubExactCatalog(context, 'HostPaymentAccountLoadingCard');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostPrivateAccessBody,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostPrivateAccessBodyCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostPrivateAccessBody');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostPrivateAccessCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostPrivateAccessCardCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostPrivateAccessCard');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostPrivateAccessShell,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostPrivateAccessShellCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostPrivateAccessShell');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostProfileEditorSheet,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostProfileEditorSheetCatalogStates(BuildContext context) =>
    _hostSettingsExactCatalog(context, 'HostProfileEditorSheet');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostRosterFilterHeader,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostRosterFilterHeaderCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostRosterFilterHeader');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostRosterSearchBar,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostRosterSearchBarCatalogStates(BuildContext context) =>
    _hostEventManageExactCatalog(context, 'HostRosterSearchBar');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostRosterSkeleton,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostRosterSkeletonCatalogStates(BuildContext context) =>
    hostLoadingSkeletonCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostSectionLabel,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostSectionLabelCatalogStates(BuildContext context) =>
    _hostHomeExactCatalog(context, 'HostSectionLabel');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostSettingsClubRows,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostSettingsClubRowsCatalogStates(BuildContext context) =>
    _hostSettingsExactCatalog(context, 'HostSettingsClubRows');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostSettingsClubsEmptyState,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostSettingsClubsEmptyStateCatalogStates(
  BuildContext context,
) => _hostSettingsExactCatalog(context, 'HostSettingsClubsEmptyState');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostSettingsProfileRows,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostSettingsProfileRowsCatalogStates(BuildContext context) =>
    _hostSettingsExactCatalog(context, 'HostSettingsProfileRows');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostSettingsRowsSkeleton,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostSettingsRowsSkeletonCatalogStates(BuildContext context) =>
    hostLoadingSkeletonCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostStatChip,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostStatChipCatalogStates(BuildContext context) =>
    hostToolCardCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostSummarySkeleton,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostSummarySkeletonCatalogStates(BuildContext context) =>
    hostLoadingSkeletonCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTabRailSkeleton,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTabRailSkeletonCatalogStates(BuildContext context) =>
    hostLoadingSkeletonCatalogStates(context);

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTeamManagementSection,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTeamManagementSectionCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostTeamManagementSection');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTeamOwnerHostRow,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTeamOwnerHostRowCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostTeamOwnerHostRow');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTodayAvatarDot,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTodayAvatarDotCatalogStates(BuildContext context) =>
    _hostHomeExactCatalog(context, 'HostTodayAvatarDot');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTodayAvatarStack,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTodayAvatarStackCatalogStates(BuildContext context) =>
    _hostHomeExactCatalog(context, 'HostTodayAvatarStack');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTodayClubPill,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTodayClubPillCatalogStates(BuildContext context) =>
    _hostHomeExactCatalog(context, 'HostTodayClubPill');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTodayCountdownPill,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTodayCountdownPillCatalogStates(BuildContext context) =>
    _hostHomeExactCatalog(context, 'HostTodayCountdownPill');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTodayDashboardCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTodayDashboardCardCatalogStates(BuildContext context) =>
    _hostHomeExactCatalog(context, 'HostTodayDashboardCard');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTodayDashboardSection,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTodayDashboardSectionCatalogStates(BuildContext context) =>
    _hostHomeExactCatalog(context, 'HostTodayDashboardSection');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTodayEmptyEvents,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTodayEmptyEventsCatalogStates(BuildContext context) =>
    _hostHomeExactCatalog(context, 'HostTodayEmptyEvents');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTodayEventHero,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTodayEventHeroCatalogStates(BuildContext context) =>
    _hostHomeExactCatalog(context, 'HostTodayEventHero');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTodayHeader,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTodayHeaderCatalogStates(BuildContext context) =>
    _hostHomeExactCatalog(context, 'HostTodayHeader');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTodayHeroMetric,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTodayHeroMetricCatalogStates(BuildContext context) =>
    _hostHomeExactCatalog(context, 'HostTodayHeroMetric');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTodayLoadingBody,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTodayLoadingBodyCatalogStates(BuildContext context) =>
    _hostHomeExactCatalog(context, 'HostTodayLoadingBody');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTodayTaskCard,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTodayTaskCardCatalogStates(BuildContext context) =>
    _hostHomeExactCatalog(context, 'HostTodayTaskCard');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostTrendKpi,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostTrendKpiCatalogStates(BuildContext context) =>
    _hostClubExactCatalog(context, 'HostTrendKpi');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostWaitlistBulkOfferAction,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostWaitlistBulkOfferActionCatalogStates(
  BuildContext context,
) => _hostEventManageExactCatalog(context, 'HostWaitlistBulkOfferAction');

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

List<OrderedPhotoPreview> _orderedPhotoPreviews(String prefix, int count) {
  final bytes = _createClubPngBytes();
  return [
    for (var index = 0; index < count; index++)
      OrderedPhotoPreview(id: '$prefix-$index', bytes: bytes),
  ];
}

class _ClubBasicsStepFrame extends StatefulWidget {
  const _ClubBasicsStepFrame({this.validate = false});

  final bool validate;

  @override
  State<_ClubBasicsStepFrame> createState() => _ClubBasicsStepFrameState();
}

class _ClubBasicsStepFrameState extends State<_ClubBasicsStepFrame> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _areaController;
  CityOption? _selectedCity;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.validate ? '' : 'Sea Face Social Run Club',
    );
    _areaController = TextEditingController(
      text: widget.validate ? '' : 'Bandra West',
    );
    _selectedCity = widget.validate ? null : cityOptionByName(_club.location);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClubBasicsStep(
      formKey: _formKey,
      autovalidateMode: widget.validate
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      nameController: _nameController,
      selectedCity: _selectedCity,
      onCityChanged: (city) => setState(() => _selectedCity = city),
      areaController: _areaController,
      clubPhotoPreviews: widget.validate
          ? const []
          : _orderedPhotoPreviews('club-basics-photo', 2),
      existingImageUrl: null,
      profileImageBytes: widget.validate ? null : _createClubPngBytes(),
      existingProfileImageUrl: null,
      onPickClubPhotos: () {},
      onRemoveClubPhoto: (_) {},
      onReorderClubPhoto: (_, _) {},
      onPickProfileImage: () {},
    );
  }
}

class _ClubDetailsStepFrame extends StatefulWidget {
  const _ClubDetailsStepFrame();

  @override
  State<_ClubDetailsStepFrame> createState() => _ClubDetailsStepFrameState();
}

class _ClubDetailsStepFrameState extends State<_ClubDetailsStepFrame> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _instagramController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text:
          'Structured social runs with warm arrivals, conversational pacing, and a post-run cafe table.',
    );
    _instagramController = TextEditingController(text: 'seafaceruns');
    _phoneController = TextEditingController(text: '9876543210');
    _emailController = TextEditingController(text: 'hosts@seaface.example');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _instagramController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClubDetailsStep(
      formKey: _formKey,
      descriptionController: _descriptionController,
      instagramController: _instagramController,
      phoneController: _phoneController,
      emailController: _emailController,
    );
  }
}

class _CreateClubContactFieldsFrame extends StatefulWidget {
  const _CreateClubContactFieldsFrame();

  @override
  State<_CreateClubContactFieldsFrame> createState() =>
      _CreateClubContactFieldsFrameState();
}

class _CreateClubContactFieldsFrameState
    extends State<_CreateClubContactFieldsFrame> {
  late final TextEditingController _instagramController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _instagramController = TextEditingController(text: 'seafaceruns');
    _phoneController = TextEditingController(text: '9876543210');
    _emailController = TextEditingController(text: 'hosts@seaface.example');
  }

  @override
  void dispose() {
    _instagramController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.content,
      child: CreateClubContactFields(
        instagramController: _instagramController,
        phoneController: _phoneController,
        emailController: _emailController,
      ),
    );
  }
}

class _ClubHostDefaultsStepFrame extends StatefulWidget {
  const _ClubHostDefaultsStepFrame();

  @override
  State<_ClubHostDefaultsStepFrame> createState() =>
      _ClubHostDefaultsStepFrameState();
}

class _ClubHostDefaultsStepFrameState
    extends State<_ClubHostDefaultsStepFrame> {
  final _formKey = GlobalKey<FormState>();
  var _defaults = _club.hostDefaults;

  @override
  Widget build(BuildContext context) {
    return ClubHostDefaultsStep(
      formKey: _formKey,
      defaults: _defaults,
      currencyCode: currencyCodeForCityName(_club.location),
      onChanged: (defaults) => setState(() => _defaults = defaults),
    );
  }
}

class _ClubPolicyDefaultsCardFrame extends StatefulWidget {
  const _ClubPolicyDefaultsCardFrame();

  @override
  State<_ClubPolicyDefaultsCardFrame> createState() =>
      _ClubPolicyDefaultsCardFrameState();
}

class _ClubPolicyDefaultsCardFrameState
    extends State<_ClubPolicyDefaultsCardFrame> {
  var _defaults = _club.hostDefaults.eventPolicy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.content,
      child: ClubPolicyDefaultsCard(
        defaults: _defaults,
        currencyCode: currencyCodeForCityName(_club.location),
        onChanged: (defaults) => setState(() => _defaults = defaults),
      ),
    );
  }
}

class _ClubEventSuccessDefaultsStepFrame extends StatefulWidget {
  const _ClubEventSuccessDefaultsStepFrame();

  @override
  State<_ClubEventSuccessDefaultsStepFrame> createState() =>
      _ClubEventSuccessDefaultsStepFrameState();
}

class _ClubEventSuccessDefaultsStepFrameState
    extends State<_ClubEventSuccessDefaultsStepFrame> {
  final _formKey = GlobalKey<FormState>();
  var _defaults = _club.hostDefaults;

  @override
  Widget build(BuildContext context) {
    return ClubEventSuccessDefaultsStep(
      formKey: _formKey,
      defaults: _defaults,
      onChanged: (defaults) => setState(() => _defaults = defaults),
    );
  }
}

class _EventDetailsStepFrame extends StatefulWidget {
  const _EventDetailsStepFrame({this.customActivity = false});

  final bool customActivity;

  @override
  State<_EventDetailsStepFrame> createState() => _EventDetailsStepFrameState();
}

class _EventDetailsStepFrameState extends State<_EventDetailsStepFrame> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _distanceController;
  late final TextEditingController _customActivityLabelController;
  late final TextEditingController _descriptionController;
  late ActivityKind _activityKind;
  late EventInteractionModel _interactionModel;
  PaceLevel? _pace = PaceLevel.easy;

  @override
  void initState() {
    super.initState();
    _activityKind = widget.customActivity
        ? ActivityKind.openActivity
        : ActivityKind.socialRun;
    _interactionModel = _activityKind.defaultInteractionModel;
    _distanceController = TextEditingController(text: '5');
    _customActivityLabelController = TextEditingController(text: 'Salsa mixer');
    _descriptionController = TextEditingController(
      text: 'A relaxed format with clear arrival cues and a hosted welcome.',
    );
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _customActivityLabelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EventDetailsStep(
      formKey: _formKey,
      photoPreviews: _orderedPhotoPreviews('event-details-photo', 2),
      onPickPhotos: () {},
      onRemovePhoto: (_) {},
      onReorderPhoto: (_, _) {},
      distanceController: _distanceController,
      customActivityLabelController: _customActivityLabelController,
      descriptionController: _descriptionController,
      selectedActivityKind: _activityKind,
      onActivityKindChanged: (activityKind) => setState(() {
        _activityKind = activityKind;
        _interactionModel = activityKind.defaultInteractionModel;
      }),
      selectedInteractionModel: _interactionModel,
      onInteractionModelChanged: (model) =>
          setState(() => _interactionModel = model),
      selectedPace: _pace,
      onPaceChanged: (pace) => setState(() => _pace = pace),
    );
  }
}

class _WhereStepFrame extends StatefulWidget {
  const _WhereStepFrame();

  @override
  State<_WhereStepFrame> createState() => _WhereStepFrameState();
}

class _WhereStepFrameState extends State<_WhereStepFrame> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _meetingPointController;
  late final TextEditingController _locationDetailsController;

  @override
  void initState() {
    super.initState();
    _meetingPointController = TextEditingController(
      text: 'Carter Road Amphitheatre',
    );
    _locationDetailsController = TextEditingController(
      text: 'Meet by the sea-facing steps.',
    );
  }

  @override
  void dispose() {
    _meetingPointController.dispose();
    _locationDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WhereStep(
      formKey: _formKey,
      meetingPointController: _meetingPointController,
      locationDetailsController: _locationDetailsController,
      startingPoint: const LocationCoordinate(19.0706, 72.8223),
      onMeetingPointChanged: (_) {},
      onPickLocation: () {},
    );
  }
}

class _WhenStepFrame extends StatefulWidget {
  const _WhenStepFrame({this.scheduleError = false});

  final bool scheduleError;

  @override
  State<_WhenStepFrame> createState() => _WhenStepFrameState();
}

class _WhenStepFrameState extends State<_WhenStepFrame> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _startTimeController;
  var _durationMinutes = 75;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: '02/07/2030');
    _startTimeController = TextEditingController(text: '6:30 PM');
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WhenStep(
      formKey: _formKey,
      dateController: _dateController,
      startTimeController: _startTimeController,
      durationMinutes: _durationMinutes,
      onPickDate: () {},
      onPickTime: () {},
      onDecreaseDuration: _durationMinutes > 30
          ? () => setState(() => _durationMinutes -= 15)
          : null,
      onIncreaseDuration: _durationMinutes < 240
          ? () => setState(() => _durationMinutes += 15)
          : null,
      formatDuration: EventFormatters.durationMinutes,
      scheduleErrorText: widget.scheduleError
          ? 'Choose a start time later than now'
          : null,
    );
  }
}

class _EventPolicyStepFrame extends StatefulWidget {
  const _EventPolicyStepFrame({this.inviteOnly = false});

  final bool inviteOnly;

  @override
  State<_EventPolicyStepFrame> createState() => _EventPolicyStepFrameState();
}

class _EventPolicyStepFrameState extends State<_EventPolicyStepFrame> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _capacityController;
  late final TextEditingController _priceController;
  late final TextEditingController _inviteCodeController;
  late final TextEditingController _dynamicPricingStepController;
  late final TextEditingController _dynamicPricingMaxController;
  late final TextEditingController _minAgeController;
  late final TextEditingController _maxAgeController;
  late final TextEditingController _maxMenController;
  late final TextEditingController _maxWomenController;
  late EventAdmissionPreset _admissionPreset;
  var _cohortCapsEnabled = false;
  var _dynamicPricingEnabled = false;
  var _cancellationPolicyId = EventCancellationPolicyId.standard;

  @override
  void initState() {
    super.initState();
    _admissionPreset = widget.inviteOnly
        ? EventAdmissionPreset.inviteOnly
        : EventAdmissionPreset.openCapacity;
    _capacityController = TextEditingController(text: '24');
    _priceController = TextEditingController(text: '0');
    _inviteCodeController = TextEditingController(text: 'SEAFACE');
    _dynamicPricingStepController = TextEditingController(text: '250');
    _dynamicPricingMaxController = TextEditingController(text: '1500');
    _minAgeController = TextEditingController(text: '24');
    _maxAgeController = TextEditingController(text: '38');
    _maxMenController = TextEditingController(text: '12');
    _maxWomenController = TextEditingController(text: '12');
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _priceController.dispose();
    _inviteCodeController.dispose();
    _dynamicPricingStepController.dispose();
    _dynamicPricingMaxController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _maxMenController.dispose();
    _maxWomenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EventPolicyStep(
      formKey: _formKey,
      capacityController: _capacityController,
      priceController: _priceController,
      currencyCode: currencyCodeForCityName(_club.location),
      inviteCodeController: _inviteCodeController,
      dynamicPricingStepController: _dynamicPricingStepController,
      dynamicPricingMaxController: _dynamicPricingMaxController,
      minAgeController: _minAgeController,
      maxAgeController: _maxAgeController,
      maxMenController: _maxMenController,
      maxWomenController: _maxWomenController,
      admissionPreset: _admissionPreset,
      onAdmissionPresetChanged: (preset) =>
          setState(() => _admissionPreset = preset),
      cohortCapsEnabled: _cohortCapsEnabled,
      onCohortCapsEnabledChanged: (enabled) =>
          setState(() => _cohortCapsEnabled = enabled),
      dynamicPricingEnabled: _dynamicPricingEnabled,
      onDynamicPricingChanged: (enabled) =>
          setState(() => _dynamicPricingEnabled = enabled),
      cancellationPolicyId: _cancellationPolicyId,
      onCancellationPolicyChanged: (policyId) =>
          setState(() => _cancellationPolicyId = policyId),
    );
  }
}

class _EventSuccessStepFrame extends StatefulWidget {
  const _EventSuccessStepFrame();

  @override
  State<_EventSuccessStepFrame> createState() => _EventSuccessStepFrameState();
}

class _EventSuccessStepFrameState extends State<_EventSuccessStepFrame> {
  var _defaults = const EventSuccessDefaults();

  @override
  Widget build(BuildContext context) {
    return EventSuccessStep(
      activityKind: ActivityKind.socialRun,
      eventSuccessDefaults: _defaults,
      targetAttendeeCount: 24,
      onEventSuccessDefaultsChanged: (defaults) =>
          setState(() => _defaults = defaults),
    );
  }
}

class _EditableHostedEventPolicyCardFrame extends StatefulWidget {
  const _EditableHostedEventPolicyCardFrame({this.inviteOnly = false});

  final bool inviteOnly;

  @override
  State<_EditableHostedEventPolicyCardFrame> createState() =>
      _EditableHostedEventPolicyCardFrameState();
}

class _EditableHostedEventPolicyCardFrameState
    extends State<_EditableHostedEventPolicyCardFrame> {
  late final TextEditingController _capacityController;
  late final TextEditingController _priceController;
  late final TextEditingController _minAgeController;
  late final TextEditingController _maxAgeController;
  late final TextEditingController _maxMenController;
  late final TextEditingController _maxWomenController;
  late final TextEditingController _inviteCodeController;
  late final TextEditingController _dynamicPricingStepController;
  late final TextEditingController _dynamicPricingMaxController;
  late EventAdmissionPreset _admissionPreset;
  var _cohortCapsEnabled = false;
  var _dynamicPricingEnabled = false;
  var _cancellationPolicyId = EventCancellationPolicyId.standard;

  @override
  void initState() {
    super.initState();
    _admissionPreset = widget.inviteOnly
        ? EventAdmissionPreset.inviteOnly
        : EventAdmissionPreset.openCapacity;
    _capacityController = TextEditingController(text: '24');
    _priceController = TextEditingController(text: '0');
    _minAgeController = TextEditingController(text: '24');
    _maxAgeController = TextEditingController(text: '38');
    _maxMenController = TextEditingController(text: '12');
    _maxWomenController = TextEditingController(text: '12');
    _inviteCodeController = TextEditingController(text: 'SEAFACE');
    _dynamicPricingStepController = TextEditingController(text: '250');
    _dynamicPricingMaxController = TextEditingController(text: '1500');
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _priceController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _maxMenController.dispose();
    _maxWomenController.dispose();
    _inviteCodeController.dispose();
    _dynamicPricingStepController.dispose();
    _dynamicPricingMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.content,
      child: EditableHostedEventPolicyCard(
        currencyCode: currencyCodeForCityName(_club.location),
        capacityController: _capacityController,
        priceController: _priceController,
        minAgeController: _minAgeController,
        maxAgeController: _maxAgeController,
        maxMenController: _maxMenController,
        maxWomenController: _maxWomenController,
        inviteCodeController: _inviteCodeController,
        dynamicPricingStepController: _dynamicPricingStepController,
        dynamicPricingMaxController: _dynamicPricingMaxController,
        admissionPreset: _admissionPreset,
        onAdmissionPresetChanged: (preset) =>
            setState(() => _admissionPreset = preset),
        cohortCapsEnabled: _cohortCapsEnabled,
        onCohortCapsEnabledChanged: (enabled) =>
            setState(() => _cohortCapsEnabled = enabled),
        dynamicPricingEnabled: _dynamicPricingEnabled,
        onDynamicPricingChanged: (enabled) =>
            setState(() => _dynamicPricingEnabled = enabled),
        cancellationPolicyId: _cancellationPolicyId,
        onCancellationPolicyChanged: (policyId) =>
            setState(() => _cancellationPolicyId = policyId),
        privateAccessAsync: const AsyncData<Object?>(null),
      ),
    );
  }
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

class _HostComponentFrame extends StatelessWidget {
  const _HostComponentFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _DeviceFrame(
      child: _HostShellScope(child: _HostComponentScaffold(child: child)),
    );
  }
}

class _HostManageComponentFrame extends StatelessWidget {
  const _HostManageComponentFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _DeviceFrame(
      child: _HostManageRouteScope(child: _HostComponentScaffold(child: child)),
    );
  }
}

class _HostComponentScaffold extends StatelessWidget {
  const _HostComponentScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: ListView(
        padding: CatchInsets.pageBodyUnderHeader,
        children: [child],
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
    final eventClubIds = <String>{
      for (final club in HostOperationsFixtures.clubs) club.id,
      for (final club in effectiveHostedClubs) club.id,
      for (final club in effectiveOwnedClubs) club.id,
      ...clubEventStreams.keys,
    };
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
    for (final clubId in eventClubIds) {
      overrides.add(
        watchEventsForClubProvider(clubId).overrideWith(
          (ref) =>
              clubEventStreams[clubId] ??
              Stream<List<Event>>.value(
                HostOperationsFixtures.eventsByClub[clubId] ?? const [],
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

enum _HostTeamAddHostSheetPreviewMode { ready, pending, error, offline }

class _HostTeamAddHostSheetPreview extends StatelessWidget {
  const _HostTeamAddHostSheetPreview({
    this.mode = _HostTeamAddHostSheetPreviewMode.ready,
  });

  final _HostTeamAddHostSheetPreviewMode mode;

  @override
  Widget build(BuildContext context) {
    final actionState = switch (mode) {
      _HostTeamAddHostSheetPreviewMode.ready =>
        const HostTeamAddHostActionState(),
      _HostTeamAddHostSheetPreviewMode.pending =>
        const HostTeamAddHostActionState(isSaving: true),
      _HostTeamAddHostSheetPreviewMode.error => HostTeamAddHostActionState(
        errorMessage: appErrorMessage(
          StateError('Widgetbook add host failed'),
          context: AppErrorContext.club,
        ),
      ),
      _HostTeamAddHostSheetPreviewMode.offline => HostTeamAddHostActionState(
        errorMessage: appErrorMessage(
          obviousOfflineException(),
          context: AppErrorContext.club,
        ),
      ),
    };

    return Scaffold(
      body: SafeArea(
        child: HostTeamAddHostSheet(
          clubId: 'design-host-sea-face',
          actionState: actionState,
        ),
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

Widget _hostManageLiveSectionPreview({
  required Event event,
  Widget? liveRoster,
}) {
  return EventSuccessHostSection(
    event: event,
    initialTab: EventSuccessHostTab.live,
    showTabs: false,
    liveRoster: liveRoster,
  );
}

Event _hostManageLiveRevealEvent(Event event) {
  return event.copyWith(
    eventFormat: EventFormatSnapshot.custom(
      label: 'trivia night',
      interactionModel: EventInteractionModel.teamRotations,
    ),
    distanceKm: 0,
    capacityLimit: 30,
    bookedCount: 24,
    checkedInCount: 18,
  );
}

EventSuccessPlan _hostManageLivePlanForModule({
  required Event event,
  required DateTime now,
  required String moduleId,
}) {
  final basePlan = EventSuccessPlan.defaultForEvent(
    event,
    now: now,
  ).copyWith(status: EventSuccessPlanStatus.live, frozenAt: now);
  final runtime = EventSuccessRuntime(plan: basePlan, event: event, now: now);
  final steps = runtime.runOfShowSteps;
  final activeIndex = steps.indexWhere(
    (step) => step.moduleIds.contains(moduleId),
  );
  return basePlan.copyWith(activeStepIndex: activeIndex < 0 ? 0 : activeIndex);
}

List<EventSuccessAssignment> _hostManageMicroPodAssignments({
  required Event event,
  required DateTime now,
  String source = 'widgetbook_fixture',
}) {
  return [
    _hostManageAssignment(
      event: event,
      uid: HostOperationsFixtures.guestUid,
      label: 'Pod A',
      title: 'Pace Pod A',
      peerUids: const [
        HostOperationsFixtures.secondGuestUid,
        HostOperationsFixtures.waitlistUid,
      ],
      now: now,
      source: source,
    ),
    _hostManageAssignment(
      event: event,
      uid: HostOperationsFixtures.secondGuestUid,
      label: 'Pod A',
      title: 'Pace Pod A',
      peerUids: const [
        HostOperationsFixtures.guestUid,
        HostOperationsFixtures.waitlistUid,
      ],
      now: now,
      source: source,
    ),
    _hostManageAssignment(
      event: event,
      uid: HostOperationsFixtures.waitlistUid,
      label: 'Pod B',
      title: 'Pace Pod B',
      peerUids: const [HostOperationsFixtures.guestUid],
      now: now,
      source: source,
    ),
  ];
}

EventSuccessAssignment _hostManageAssignment({
  required Event event,
  required String uid,
  required String label,
  required String title,
  required List<String> peerUids,
  required DateTime now,
  String source = 'widgetbook_fixture',
}) {
  return EventSuccessAssignment(
    id: eventSuccessAssignmentId(
      eventId: event.id,
      moduleId: EventSuccessModuleCatalog.microPods.id,
      uid: uid,
    ),
    eventId: event.id,
    clubId: event.clubId,
    uid: uid,
    moduleId: EventSuccessModuleCatalog.microPods.id,
    label: label,
    displayTitle: title,
    displaySubtitle: 'Start here, then follow the host cue.',
    peerUids: peerUids,
    unitKind: 'pods',
    unitLabel: label,
    source: source,
    createdAt: now.subtract(const Duration(minutes: 12)),
    updatedAt: now,
  );
}

List<EventSuccessAssignment> _hostManageRotationAssignments({
  required Event event,
  required DateTime now,
}) {
  final round0 = event.startTime.add(const Duration(minutes: 15));
  final round1 = round0.add(const Duration(minutes: 15));
  return [
    _hostManageRotationAssignment(
      event: event,
      uid: HostOperationsFixtures.guestUid,
      peerUids: const [
        HostOperationsFixtures.secondGuestUid,
        HostOperationsFixtures.waitlistUid,
      ],
      slots: [
        _hostManageRotationSlot(
          index: 0,
          startsAt: round0,
          peerUid: HostOperationsFixtures.secondGuestUid,
          compatibility: 'mutual_interest',
        ),
        _hostManageRotationSlot(
          index: 1,
          startsAt: round1,
          peerUid: HostOperationsFixtures.waitlistUid,
          compatibility: 'questionnaire_match',
        ),
      ],
      now: now,
    ),
    _hostManageRotationAssignment(
      event: event,
      uid: HostOperationsFixtures.secondGuestUid,
      peerUids: const [HostOperationsFixtures.guestUid],
      slots: [
        _hostManageRotationSlot(
          index: 0,
          startsAt: round0,
          peerUid: HostOperationsFixtures.guestUid,
          compatibility: 'mutual_interest',
        ),
      ],
      now: now,
    ),
  ];
}

EventSuccessAssignment _hostManageRotationAssignment({
  required Event event,
  required String uid,
  required List<String> peerUids,
  required List<EventSuccessRotationSlot> slots,
  required DateTime now,
}) {
  return EventSuccessAssignment(
    id: eventSuccessAssignmentId(
      eventId: event.id,
      moduleId: EventSuccessModuleCatalog.guidedRotations.id,
      uid: uid,
    ),
    eventId: event.id,
    clubId: event.clubId,
    uid: uid,
    moduleId: EventSuccessModuleCatalog.guidedRotations.id,
    label: 'Rotation schedule',
    displayTitle: 'Guided rotation schedule',
    displaySubtitle: 'Host-edited preview schedule.',
    peerUids: peerUids,
    rotationSlots: slots,
    source: 'host_override_v1',
    createdAt: now.subtract(const Duration(minutes: 12)),
    updatedAt: now,
  );
}

EventSuccessRotationSlot _hostManageRotationSlot({
  required int index,
  required DateTime startsAt,
  required String peerUid,
  required String compatibility,
}) {
  return EventSuccessRotationSlot(
    roundIndex: index,
    label: 'Round ${index + 1}',
    startsAt: startsAt,
    endsAt: startsAt.add(const Duration(minutes: 15)),
    peerUid: peerUid,
    compatibility: compatibility,
  );
}

List<EventSuccessPreference> _hostManagePreferences({
  required Event event,
  required DateTime now,
}) {
  return [
    EventSuccessPreference(
      id: eventSuccessPreferenceId(
        eventId: event.id,
        uid: HostOperationsFixtures.waitlistUid,
      ),
      eventId: event.id,
      clubId: event.clubId,
      uid: HostOperationsFixtures.waitlistUid,
      microPodsOptedOut: false,
      guidedRotationsOptedOut: false,
      createdAt: now.subtract(const Duration(minutes: 20)),
      updatedAt: now.subtract(const Duration(minutes: 3)),
    ),
  ];
}

List<EventSuccessWingmanRequest> _hostManageWingmanRequests({
  required Event event,
  required DateTime now,
}) {
  return [
    EventSuccessWingmanRequest(
      id: eventSuccessWingmanRequestId(
        eventId: event.id,
        uid: HostOperationsFixtures.guestUid,
      ),
      eventId: event.id,
      clubId: event.clubId,
      requesterUid: HostOperationsFixtures.guestUid,
      targetUid: HostOperationsFixtures.secondGuestUid,
      status: EventSuccessWingmanRequestStatus.active,
      hostVisibleConsent: true,
      note: 'Pair me if it feels natural.',
      createdAt: now.subtract(const Duration(minutes: 8)),
      updatedAt: now.subtract(const Duration(minutes: 2)),
    ),
    EventSuccessWingmanRequest(
      id: eventSuccessWingmanRequestId(
        eventId: event.id,
        uid: HostOperationsFixtures.waitlistUid,
      ),
      eventId: event.id,
      clubId: event.clubId,
      requesterUid: HostOperationsFixtures.waitlistUid,
      targetUid: HostOperationsFixtures.guestUid,
      status: EventSuccessWingmanRequestStatus.active,
      hostVisibleConsent: true,
      note: 'I would like a quick intro near the host table.',
      createdAt: now.subtract(const Duration(minutes: 5)),
      updatedAt: now.subtract(const Duration(minutes: 1)),
    ),
  ];
}

List<String> _hostManageAssignmentParticipantUids(
  List<EventSuccessAssignment> assignments,
) {
  final uids = <String>{
    for (final assignment in assignments) ...[
      assignment.uid,
      ...assignment.allPeerUids,
    ],
  }.toList()..sort();
  return uids;
}

List<String> _hostManageWingmanProfileUids(
  List<EventSuccessWingmanRequest> requests,
) {
  final uids = <String>{
    for (final request in requests) ...[
      request.requesterUid,
      request.targetUid,
    ],
  }.toList()..sort();
  return uids;
}

List<PublicProfile> _hostManageProfilesFor(List<String> uids) {
  const names = <String, String>{
    HostOperationsFixtures.guestUid: 'Aarav Mehta',
    HostOperationsFixtures.secondGuestUid: 'Rhea Kapoor',
    HostOperationsFixtures.waitlistUid: 'Kabir Jain',
  };
  return [
    for (final uid in uids.toSet())
      PublicProfile(
        uid: uid,
        name: names[uid] ?? 'Guest',
        age: 29,
        gender: Gender.man,
        city: 'Mumbai',
      ),
  ];
}

class _HostManageRouteScope extends StatelessWidget {
  const _HostManageRouteScope({
    this.child,
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
    this.scorecardValue,
    this.assignments = const <EventSuccessAssignment>[],
    this.rotationAssignments = const <EventSuccessAssignment>[],
    this.preferences = const <EventSuccessPreference>[],
    this.wingmanRequests = const <EventSuccessWingmanRequest>[],
    this.assignmentPeerProfiles = const <PublicProfile>[],
    this.rotationPeerProfiles = const <PublicProfile>[],
    this.wingmanProfiles = const <PublicProfile>[],
    this.participations,
    this.initialSection = HostEventManageSection.setup,
    this.initialParticipantSearchQuery = '',
    this.themeMode = ThemeMode.light,
  });

  final Widget? child;
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
  final AsyncValue<EventSuccessScorecard?>? scorecardValue;
  final List<EventSuccessAssignment> assignments;
  final List<EventSuccessAssignment> rotationAssignments;
  final List<EventSuccessPreference> preferences;
  final List<EventSuccessWingmanRequest> wingmanRequests;
  final List<PublicProfile> assignmentPeerProfiles;
  final List<PublicProfile> rotationPeerProfiles;
  final List<PublicProfile> wingmanProfiles;
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
          watchEventSuccessScorecardProvider(
            effectiveEvent.id,
          ).overrideWith((ref) => _streamValue(scorecardValue, null)),
          watchEventSuccessAssignmentsProvider(effectiveEvent.id).overrideWith((
            ref,
          ) {
            return Stream<List<EventSuccessAssignment>>.value(assignments);
          }),
          watchEventSuccessRotationAssignmentsProvider(
            effectiveEvent.id,
          ).overrideWith((ref) {
            return Stream<List<EventSuccessAssignment>>.value(
              rotationAssignments,
            );
          }),
          watchEventSuccessPreferencesProvider(effectiveEvent.id).overrideWith((
            ref,
          ) {
            return Stream<List<EventSuccessPreference>>.value(preferences);
          }),
          watchEventSuccessWingmanRequestsProvider(
            effectiveEvent.id,
          ).overrideWith((ref) {
            return Stream<List<EventSuccessWingmanRequest>>.value(
              wingmanRequests,
            );
          }),
          if (assignments.isNotEmpty)
            eventSuccessAssignmentPeerProfilesProvider(
              eventSuccessPeerUidsKey(
                _hostManageAssignmentParticipantUids(assignments),
              ),
            ).overrideWith((ref) async => assignmentPeerProfiles),
          if (rotationAssignments.isNotEmpty)
            eventSuccessAssignmentPeerProfilesProvider(
              eventSuccessPeerUidsKey(
                _hostManageAssignmentParticipantUids(rotationAssignments),
              ),
            ).overrideWith((ref) async => rotationPeerProfiles),
          if (wingmanRequests.isNotEmpty)
            eventSuccessAssignmentPeerProfilesProvider(
              eventSuccessPeerUidsKey(
                _hostManageWingmanProfileUids(wingmanRequests),
              ),
            ).overrideWith((ref) async => wingmanProfiles),
        ],
        child: _ThemedHostPreview(
          themeMode: themeMode,
          child:
              child ??
              HostEventManageRouteScreen(
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
