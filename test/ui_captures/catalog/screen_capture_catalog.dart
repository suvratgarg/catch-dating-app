import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_screen.dart';
import 'package:catch_dating_app/auth/presentation/auth_session_controller.dart';
import 'package:catch_dating_app/calendar/presentation/calendar_screen.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/data/suvbot_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_input_bar.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_share_card.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/catch_club_dock.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_body.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/block_user_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/dashboard/presentation/activity_controller.dart';
import 'package:catch_dating_app/dashboard/presentation/activity_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_arrival_mission.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/event_success/event_success_companion_clock.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_effects_controller.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/events/domain/event_invite_link.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/events/presentation/attendance_sheet_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_screen.dart';
import 'package:catch_dating_app/events/presentation/saved_events_screen.dart';
import 'package:catch_dating_app/events/presentation/widgets/who_is_going.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_map_screen.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_repository.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:catch_dating_app/hosts/data/host_analytics_repository.dart';
import 'package:catch_dating_app/hosts/data/host_profile_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_screen.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_club_edit_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_create_club_screen.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_team_management_controller.dart';
import 'package:catch_dating_app/hosts/presentation/edit_hosted_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_success_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_profile_controller.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_card.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_controller.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_team_management_section.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/labs/design_fixtures/catches_surface_fixtures.dart';
import 'package:catch_dating_app/labs/design_fixtures/event_success_companion_fixtures.dart';
import 'package:catch_dating_app/labs/design_fixtures/host_operations_fixtures.dart';
import 'package:catch_dating_app/labs/design_fixtures/matches_chat_surface_fixtures.dart';
import 'package:catch_dating_app/labs/design_fixtures/profile_surface_fixtures.dart';
import 'package:catch_dating_app/labs/design_fixtures/utility_surface_fixtures.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/matches/presentation/host_inbox_filter.dart';
import 'package:catch_dating_app/matches/presentation/matches_list_screen.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chats_list.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chats_sliver_header.dart';
import 'package:catch_dating_app/matches/presentation/widgets/match_celebration_dialog.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:catch_dating_app/payments/data/host_payment_account_repository.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_screen.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/data/public_profiles_lookup.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_screen.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_screen.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_state.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_controller.dart';
import 'package:catch_dating_app/safety/presentation/settings_screen.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_screen.dart';
import 'package:catch_dating_app/swipes/presentation/filters_screen.dart';
import 'package:catch_dating_app/swipes/presentation/profile_redesign/catch_profile_view.dart';
import 'package:catch_dating_app/swipes/presentation/profile_redesign/profile_view.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_queue_notifier.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_screen.dart';
import 'package:catch_dating_app/user_analytics/data/user_analytics_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show
        AsyncData,
        AsyncError,
        AsyncLoading,
        AsyncValue,
        ConsumerState,
        ConsumerStatefulWidget;
import 'package:image_picker/image_picker.dart';

import '../../clubs/clubs_test_helpers.dart' as club_test;
import '../../events/events_test_helpers.dart';
import '../fixtures/sales_demo_synthetic_fixtures.dart';
import '../support/capture_device.dart';

class ScreenCaptureEntry {
  const ScreenCaptureEntry({
    required this.id,
    required this.routeIds,
    required this.device,
    required this.builder,
    this.precache = const <ImageProvider<Object>>[],
    this.marketingFixtureKeys = const <String>[],
    this.providerOverrides = const [],
    this.textScale = 1.0,
    this.disableAnimations = false,
  });

  final String id;
  final List<String> routeIds;
  final CaptureDevice device;
  final WidgetBuilder builder;
  final List<ImageProvider<Object>> precache;
  final List<String> marketingFixtureKeys;
  final Iterable providerOverrides;
  final double textScale;
  final bool disableAnimations;
}

final _profileHeroImage = FileImage(File('test/goldens/fixtures/portrait.jpg'));
const _clubHeroPortraitAssetPath = 'assets/fixtures/club_hero_portrait.jpg';
const _clubHeroPortraitAssetImage = AssetImage(_clubHeroPortraitAssetPath);
const _profilePortraitAssetPath = 'assets/fixtures/profile_portrait.jpg';
const _profilePortraitAssetImage = AssetImage(_profilePortraitAssetPath);
final _captureFixtures = salesDemoSyntheticFixtures;
final _captureAnalyticsOverride = appAnalyticsProvider.overrideWithValue(
  AppAnalytics(reporter: _NoOpAnalyticsReporter(), shouldCollect: false),
);
final _eventDetailClub = club_test.buildClub(
  id: 'club-event-detail-capture',
  name: 'Bandra Dawn Club',
  description: 'Warm coastal starts, easy pacing, and coffee after.',
  hostUserId: 'host-mira',
  hostName: 'Mira Shah',
  tags: const ['social run', 'coffee', 'beginner'],
  memberCount: 128,
  rating: 4.8,
  reviewCount: 42,
);
final _eventDetailEvent = buildEvent(
  id: 'event-detail-member',
  clubId: _eventDetailClub.id,
  startTime: DateTime(2030, 6, 12, 7),
  endTime: DateTime(2030, 6, 12, 8, 15),
  meetingPoint: 'Carter Road Amphitheatre',
  startingPointLat: 19.0706,
  startingPointLng: 72.8223,
  locationDetails: 'Meet by the sea-facing steps',
  distanceKm: 6,
  bookedCount: 12,
  checkedInCount: 0,
  capacityLimit: 24,
  description:
      'A conversational coastal loop with regroup points, coffee after, and a host who keeps the pace social.',
);
final _eventDetailUser = buildUser(
  name: 'Aanya Shah',
  email: 'aanya@example.com',
  phoneNumber: '+919870000001',
);
final _eventDetailHostUser = buildUser(
  uid: 'host-mira',
  name: 'Mira Shah',
  email: 'mira@example.com',
  phoneNumber: '+919870000002',
);
final _eventDetailClubsRepository = club_test.FakeClubsRepository()
  ..clubsById[_eventDetailClub.id] = _eventDetailClub;
final _eventDetailFullEvent = _eventDetailEvent.copyWith(
  id: 'event-detail-full',
  bookedCount: _eventDetailEvent.capacityLimit,
  waitlistedCount: 4,
);
final _eventDetailWaitlistEvent = _eventDetailFullEvent.copyWith(
  id: 'event-detail-waitlist',
);
final _eventDetailWaitlistOfferEvent = _eventDetailFullEvent.copyWith(
  id: 'event-detail-waitlist-offer',
);
final _eventDetailPastEvent = _eventDetailEvent.copyWith(
  id: 'event-detail-past',
  startTime: DateTime(2026, 6, 1, 7),
  endTime: DateTime(2026, 6, 1, 8, 15),
);
final _eventDetailAttendedEvent = _eventDetailPastEvent.copyWith(
  id: 'event-detail-attended',
);
final _eventDetailCancelledEvent = _eventDetailEvent.copyWith(
  id: 'event-detail-cancelled',
  status: EventLifecycleStatus.cancelled,
  cancelledAt: DateTime(2030, 6, 1, 10),
  cancellationReason: 'Host cancelled this event.',
);
List<EventParticipation> _eventDetailParticipationsFor(
  Event event, {
  EventParticipation? viewerParticipation,
}) {
  return [
    ?viewerParticipation,
    for (var index = 2; index <= 13; index += 1)
      buildEventParticipation(
        event: event,
        uid: 'runner-$index',
        createdAt: DateTime(2026, 5, index.clamp(1, 28), 7),
      ),
  ];
}

FakeEventParticipationRepository _eventDetailParticipationRepositoryFor(
  Event event, {
  EventParticipation? viewerParticipation,
}) {
  return FakeEventParticipationRepository()
    ..eventParticipations[event.id] = _eventDetailParticipationsFor(
      event,
      viewerParticipation: viewerParticipation,
    );
}

final _eventDetailPublicProfileRepository = FakePublicProfileRepository()
  ..profiles = [
    buildPublicProfile(
      uid: _eventDetailUser.uid,
      name: _eventDetailUser.name,
      gender: _eventDetailUser.gender,
    ),
    buildPublicProfile(
      uid: _eventDetailHostUser.uid,
      name: _eventDetailHostUser.name,
      gender: _eventDetailHostUser.gender,
    ),
    for (var index = 2; index <= 13; index += 1)
      buildPublicProfile(uid: 'runner-$index', name: 'Runner $index'),
  ];

EventDetailViewModel _eventDetailCaptureViewModel({
  Event? event,
  UserProfile? userProfile,
  bool isAuthenticated = true,
  bool isHost = false,
  bool isSaved = true,
  EventParticipation? participation,
  List<Review>? reviews,
}) {
  final resolvedEvent = event ?? _eventDetailEvent;
  return EventDetailViewModel(
    event: resolvedEvent,
    userProfile: userProfile ?? (isAuthenticated ? _eventDetailUser : null),
    reviews:
        reviews ??
        [
          buildReview(
            eventId: resolvedEvent.id,
            reviewerUserId: 'runner-2',
            reviewerName: 'Neha',
            comment: 'Warm hosting, clear route, and easy conversation.',
            createdAt: DateTime(2026, 5, 20),
          ),
        ],
    isAuthenticated: isAuthenticated,
    isHost: isHost,
    isSaved: isSaved,
    participation: participation,
  );
}

Iterable _eventDetailCaptureProviderOverrides({
  Event? event,
  AsyncValue<EventDetailViewModel?>? viewModel,
  EventParticipation? viewerParticipation,
  bool includeCompanionPlan = false,
}) {
  final resolvedEvent = event ?? _eventDetailEvent;
  final resolvedViewModel =
      viewModel ??
      AsyncData(
        _eventDetailCaptureViewModel(
          event: resolvedEvent,
          participation: viewerParticipation,
        ),
      );
  return [
    eventDetailViewModelProvider(
      resolvedEvent.id,
    ).overrideWith((ref) => resolvedViewModel),
    paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
    eventParticipationRepositoryProvider.overrideWithValue(
      _eventDetailParticipationRepositoryFor(
        resolvedEvent,
        viewerParticipation: viewerParticipation,
      ),
    ),
    publicProfileRepositoryProvider.overrideWithValue(
      _eventDetailPublicProfileRepository,
    ),
    clubsRepositoryProvider.overrideWithValue(_eventDetailClubsRepository),
    watchEventSuccessPlanProvider(resolvedEvent.id).overrideWith(
      (ref) => Stream.value(
        includeCompanionPlan
            ? EventSuccessPlan.defaultForEvent(
                resolvedEvent,
                now: DateTime(2030, 6),
              )
            : null,
      ),
    ),
  ];
}

EventParticipation _buildEventDetailSignedUpParticipation(Event event) =>
    buildEventParticipation(
      event: event,
      uid: _eventDetailUser.uid,
      createdAt: DateTime(2026, 5, 8, 7),
    );

EventParticipation _buildEventDetailWaitlistedParticipation(
  Event event, {
  bool activeOffer = false,
}) => buildEventParticipation(
  event: event,
  uid: _eventDetailUser.uid,
  status: EventParticipationStatus.waitlisted,
  createdAt: DateTime(2026, 5, 8, 7),
  waitlistOfferStatus: activeOffer ? EventWaitlistOfferStatus.active : null,
  waitlistOfferedAt: activeOffer ? DateTime(2030, 6, 11, 16) : null,
  waitlistOfferExpiresAt: activeOffer ? DateTime(2030, 6, 11, 21) : null,
  waitlistOfferId: activeOffer ? 'capture-waitlist-offer' : null,
);

EventParticipation _buildEventDetailAttendedParticipation(Event event) =>
    buildEventParticipation(
      event: event,
      uid: _eventDetailUser.uid,
      status: EventParticipationStatus.attended,
      createdAt: DateTime(2026, 5, 8, 7),
    );

final _eventDetailSignedUpParticipation =
    _buildEventDetailSignedUpParticipation(_eventDetailEvent);
final _eventDetailWaitlistedParticipation =
    _buildEventDetailWaitlistedParticipation(_eventDetailWaitlistEvent);
final _eventDetailWaitlistOfferParticipation =
    _buildEventDetailWaitlistedParticipation(
      _eventDetailWaitlistOfferEvent,
      activeOffer: true,
    );
final _eventDetailAttendedParticipation =
    _buildEventDetailAttendedParticipation(_eventDetailAttendedEvent);

const _memberDiscoveryCities = [
  CityData(
    name: 'mumbai',
    label: 'Bandra',
    latitude: 19.076,
    longitude: 72.8777,
  ),
  CityData(
    name: 'delhi',
    label: 'Delhi',
    latitude: 28.7041,
    longitude: 77.1025,
  ),
];
final _memberDiscoveryClubs = [
  _captureFixtures.captureClub(
    id: 'club-discovery-quizzicals',
    name: 'The Quizzicals',
    description: 'Pub quiz nights with teams drawn at the door.',
    area: 'Khar',
    hostName: 'Aarav',
    tags: const ['pub quiz', 'teams', 'tonight'],
    memberCount: 74,
    reviewCount: 19,
    nextEventAt: DateTime(2026, 6, 11, 19, 30),
    nextEventLabel: 'Thu 7:30 PM',
  ),
  _captureFixtures.captureClub(
    id: 'club-discovery-table',
    name: 'Table for Strangers',
    description: 'Hosted dinners for people who want better first hellos.',
    area: 'Pali Hill',
    hostName: 'Kabir',
    tags: const ['dinner', 'conversation', 'new'],
    memberCount: 86,
    rating: 4.7,
    reviewCount: 31,
    nextEventAt: DateTime(2026, 6, 12, 20),
    nextEventLabel: 'Fri 8:00 PM',
  ),
  _captureFixtures.captureClub(
    id: 'club-discovery-pickle',
    name: 'Pickleball Social',
    description: 'Friendly doubles, rotating partners, and no pressure.',
    area: 'Juhu',
    hostName: 'Tara',
    tags: const ['pickleball', 'mixed doubles', 'weekend'],
    memberCount: 64,
    rating: 4.6,
    reviewCount: 18,
    nextEventAt: DateTime(2026, 6, 13, 18),
    nextEventLabel: 'Sat 6:00 PM',
  ),
];
final _memberDiscoveryEvents = [
  _captureFixtures.captureEvent(
    id: 'event-discovery-trivia',
    club: _memberDiscoveryClubs[0],
    startTime: DateTime(2026, 6, 11, 19, 30),
    meetingPoint: 'Khar Social',
    startingPointLat: 19.0698,
    startingPointLng: 72.8381,
    activityKind: ActivityKind.pubQuiz,
    distanceKm: 0,
    bookedCount: 24,
    capacityLimit: 30,
    description: 'Teams drawn at the door for a no-phones trivia night.',
  ),
  _captureFixtures.captureEvent(
    id: 'event-discovery-long-table',
    club: _memberDiscoveryClubs[1],
    startTime: DateTime(2026, 6, 12, 20),
    meetingPoint: 'Pali Village Cafe',
    startingPointLat: 19.0634,
    startingPointLng: 72.8296,
    activityKind: ActivityKind.dinner,
    distanceKm: 0,
    bookedCount: 10,
    capacityLimit: 14,
    priceInPaise: 120000,
    description: 'A long-table dinner built around hosted prompts.',
  ),
  _captureFixtures.captureEvent(
    id: 'event-discovery-pickle-open',
    club: _memberDiscoveryClubs[2],
    startTime: DateTime(2026, 6, 13, 18),
    meetingPoint: 'Juhu court 2',
    startingPointLat: 19.1075,
    startingPointLng: 72.8263,
    activityKind: ActivityKind.pickleball,
    distanceKm: 0,
    bookedCount: 11,
    capacityLimit: 16,
    priceInPaise: 60000,
    description: 'Rotating mixed doubles with a host who balances teams.',
  ),
  _captureFixtures.captureEvent(
    id: 'event-discovery-cocktail-round',
    club: _memberDiscoveryClubs[0],
    startTime: DateTime(2026, 6, 15, 20),
    meetingPoint: 'Khar Social',
    startingPointLat: 19.0698,
    startingPointLng: 72.8381,
    activityKind: ActivityKind.barCrawl,
    distanceKm: 0,
    bookedCount: 18,
    capacityLimit: 24,
    priceInPaise: 90000,
    description:
        'Small groups rotate through low-pressure conversation rounds.',
  ),
  _captureFixtures.captureEvent(
    id: 'event-discovery-open-format',
    club: _memberDiscoveryClubs[1],
    startTime: DateTime(2026, 6, 17, 19),
    meetingPoint: 'Pali Village Cafe',
    startingPointLat: 19.0634,
    startingPointLng: 72.8296,
    activityKind: ActivityKind.singlesMixer,
    distanceKm: 0,
    bookedCount: 16,
    capacityLimit: 22,
    priceInPaise: 80000,
    description: 'A hosted mixer with prompts, table moves, and easy exits.',
  ),
];
final _memberDiscoveryItems = [
  for (final event in _memberDiscoveryEvents)
    ExploreEventItem(
      event: event,
      club: _memberDiscoveryClubs.firstWhere((club) => club.id == event.clubId),
      distanceFromUserKm: switch (event.id) {
        'event-discovery-long-table' => 2.4,
        'event-discovery-pickle-open' => 4.8,
        'event-discovery-weekend-walk' => 1.3,
        _ => 0.8,
      },
    ),
];

List<Object> _exploreProviderOverrides({
  AsyncValue<List<Club>>? sourceClubs,
  AsyncValue<ExploreViewModel>? viewModel,
  AsyncValue<ExploreFeedViewModel>? feed,
  String? uid = _captureViewerUid,
  Set<String> joinedClubIds = const <String>{},
}) {
  final effectiveSourceClubs =
      sourceClubs ?? AsyncData<List<Club>>(_memberDiscoveryClubs);
  final effectiveViewModel =
      viewModel ??
      AsyncData(
        ExploreViewModel.partition(
          clubs: _memberDiscoveryClubs,
          joinedClubIds: joinedClubIds,
        ),
      );
  final effectiveFeed =
      feed ?? AsyncData(ExploreFeedViewModel(items: _memberDiscoveryItems));

  return [
    cityListProvider.overrideWith((ref) async => _memberDiscoveryCities),
    deviceLocationProvider.overrideWith(_CaptureDeviceLocation.new),
    uidProvider.overrideWith((ref) => Stream.value(uid)),
    watchUserProfileProvider.overrideWith(
      (ref) => Stream.value(uid == null ? null : _captureViewer),
    ),
    exploreSourceClubsProvider.overrideWithValue(effectiveSourceClubs),
    exploreViewModelProvider.overrideWithValue(effectiveViewModel),
    exploreFeedViewModelProvider.overrideWithValue(effectiveFeed),
  ];
}

Widget _exploreCapture({
  String? searchQuery,
  _ExploreCaptureFilterSeed seedFilters = const _ExploreCaptureFilterSeed(),
  Widget child = const ExploreScreen(enableEventMapNetworkTiles: false),
}) {
  return _ExploreCaptureStateSeed(
    searchQuery: searchQuery,
    seedFilters: seedFilters,
    child: child,
  );
}

class _CaptureDeviceLocation extends DeviceLocation {
  @override
  Future<LocationCoordinate?> build() async => null;
}

class _CaptureMatchRepository implements MatchRepository {
  const _CaptureMatchRepository({required this.matches});

  final List<Match> matches;

  @override
  Stream<Match?> watchMatch({required String matchId}) =>
      Stream.value(_matchFor(matchId));

  @override
  Stream<List<Match>> watchMatchesForUser({required String uid}) =>
      Stream.value([
        for (final match in matches)
          if (!match.isBlocked &&
              (match.user1Id == uid || match.user2Id == uid))
            match,
      ]);

  @override
  Future<void> resetUnread({
    required String matchId,
    required String uid,
  }) async {}

  Match? _matchFor(String id) {
    for (final match in matches) {
      if (match.id == id) return match;
    }
    return null;
  }
}

class _CaptureConversationRepository implements ConversationRepository {
  const _CaptureConversationRepository({required this.messagesByConversation});

  final Map<String, List<ChatMessage>> messagesByConversation;

  @override
  Stream<List<ChatMessage>> watchMessages({required String conversationId}) =>
      Stream.value(messagesByConversation[conversationId] ?? const []);

  @override
  String createMessageId({required String conversationId}) =>
      '$conversationId-new-message';

  @override
  Future<void> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {}

  @override
  Future<void> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String messageId,
    required String imageUrl,
  }) async {}

  @override
  Future<void> markRead({
    required String conversationId,
    required String uid,
  }) async {}
}

class _NoopEventSuccessLiveEffectsController
    extends EventSuccessLiveEffectsController {
  @override
  Future<void> play(EventSuccessLiveEffectKind kind) async {}

  @override
  Future<void> playAmbientBed(EventSuccessAmbientBed bed) async {}

  @override
  Future<void> stopAmbientBed() async {}

  @override
  Future<void> dispose() async {}
}

class _NoopCelebrationEffectsController extends CelebrationEffectsController {
  @override
  Future<void> play(CelebrationMomentKind kind) async {}

  @override
  Future<void> dispose() async {}
}

final _postRunEvent = buildEvent(
  id: 'event-post-run-catches',
  clubId: 'club-post-run',
  startTime: DateTime(2026, 5, 30, 7),
  endTime: DateTime(2026, 5, 30, 8, 10),
  meetingPoint: 'Carter Road Amphitheatre',
  startingPointLat: 19.0706,
  startingPointLng: 72.8223,
  bookedCount: 22,
  checkedInCount: 19,
  capacityLimit: 24,
  description: 'A post-run social loop with structured conversation prompts.',
);
final _postRunViewer =
    buildUser(
      uid: 'runner-viewer',
      name: 'Rohan Mehta',
      email: 'rohan@example.com',
    ).copyWith(
      city: 'Mumbai',
      relationshipGoal: RelationshipGoal.relationship,
      activityPreferences: const ActivityPreferences(
        running: RunningPreferences(
          paceMinSecsPerKm: 315,
          paceMaxSecsPerKm: 390,
          preferredDistances: [PreferredDistance.fiveK, PreferredDistance.tenK],
          runningReasons: [RunReason.community, RunReason.social],
          preferredRunTimes: [PreferredRunTime.earlyMorning],
          version: currentRunPreferencesVersion,
        ),
      ),
    );
final _postRunViewerParticipation = buildEventParticipation(
  event: _postRunEvent,
  uid: _postRunViewer.uid,
  status: EventParticipationStatus.attended,
  createdAt: DateTime(2026, 5, 28, 9),
);
final _postRunProfiles = [
  buildPublicProfile(
    uid: 'runner-meera',
    name: 'Meera',
    age: 28,
    gender: Gender.woman,
    bio:
        'Ask me about the bookshop detour I take after long runs and the breakfast order I defend every Sunday.',
  ).copyWith(
    city: 'Bandra',
    height: 168,
    occupation: 'Brand strategist',
    company: 'Studio Coast',
    education: EducationLevel.masters,
    languages: const [Language.english, Language.hindi],
    relationshipGoal: RelationshipGoal.relationship,
    drinking: DrinkingHabit.socially,
    workout: WorkoutFrequency.often,
    activityPreferences: const ActivityPreferences(
      running: RunningPreferences(
        paceMinSecsPerKm: 320,
        paceMaxSecsPerKm: 400,
        preferredDistances: [PreferredDistance.fiveK, PreferredDistance.tenK],
        runningReasons: [RunReason.mindfulness, RunReason.social],
        preferredRunTimes: [PreferredRunTime.earlyMorning],
        version: currentRunPreferencesVersion,
      ),
    ),
  ),
  buildPublicProfile(
    uid: 'runner-isha',
    name: 'Isha',
    age: 27,
    gender: Gender.woman,
    bio: 'Easy miles, strong coffee, and one excellent playlist per week.',
  ).copyWith(
    city: 'Juhu',
    occupation: 'Architect',
    relationshipGoal: RelationshipGoal.casual,
    workout: WorkoutFrequency.often,
  ),
];

final _catchesOpenEvent = CatchesSurfaceFixtures.openWindowEvent(
  id: 'capture-catches-open',
);
final _catchesClosingSoonEvent = CatchesSurfaceFixtures.closingSoonEvent();
final _catchesClosedEvent = CatchesSurfaceFixtures.closedWindowEvent();
final _catchesUpcomingEvent = CatchesSurfaceFixtures.upcomingEvent();

List<Object> _swipeHubProviderOverrides({
  AsyncValue<String?> uidValue = const AsyncData<String?>(
    CatchesSurfaceFixtures.viewerUid,
  ),
  AsyncValue<List<Event>>? eventsValue,
}) {
  final uid = switch (uidValue) {
    AsyncData(:final value) => value,
    _ => null,
  };
  return [
    uidProvider.overrideWithValue(uidValue),
    if (uid != null)
      watchAttendedEventsProvider(uid).overrideWithValue(
        eventsValue ??
            AsyncData<List<Event>>([
              _catchesOpenEvent,
              _catchesClosingSoonEvent,
            ]),
      ),
  ];
}

NetworkException _catchesOfflineException({required String action}) {
  return obviousOfflineException(
    context: BackendErrorContext(
      service: BackendService.firestore,
      action: action,
      resource: 'catches',
    ),
  );
}

List<Object> _swipeDeckProviderOverrides({
  required Event event,
  String? uid = CatchesSurfaceFixtures.viewerUid,
  Stream<Event?>? eventStream,
  Stream<UserProfile?>? profileStream,
  EventParticipation? participation,
  Future<List<PublicProfile>> Function()? queue,
  Set<String> vibeIds = const <String>{},
  SwipeRepository swipeRepository = const _CaptureNoopSwipeRepository(),
}) {
  final viewerParticipation =
      participation ??
      CatchesSurfaceFixtures.attendedParticipation(event: event);

  return [
    uidProvider.overrideWithValue(AsyncData<String?>(uid)),
    watchUserProfileProvider.overrideWith(
      (ref) =>
          profileStream ??
          Stream<UserProfile?>.value(
            uid == null ? null : CatchesSurfaceFixtures.viewer,
          ),
    ),
    watchEventProvider(
      event.id,
    ).overrideWith((ref) => eventStream ?? Stream<Event?>.value(event)),
    watchEventParticipationProvider(
      event.id,
      CatchesSurfaceFixtures.viewerUid,
    ).overrideWith(
      (ref) => Stream<EventParticipation?>.value(viewerParticipation),
    ),
    swipeQueueProvider(event.id, vibeIds: vibeIds).overrideWithBuild((
      ref,
      notifier,
    ) async {
      if (queue != null) return queue();
      final candidates = CatchesSurfaceFixtures.candidates;
      if (vibeIds.isEmpty) return candidates;
      return [
        ...candidates.where((profile) => vibeIds.contains(profile.uid)),
        ...candidates.where((profile) => !vibeIds.contains(profile.uid)),
      ];
    }),
    swipeRepositoryProvider.overrideWithValue(swipeRepository),
  ];
}

class _CaptureNoopSwipeRepository implements SwipeRepository {
  const _CaptureNoopSwipeRepository();

  @override
  Future<Set<String>> fetchSwipedUserIds({required String uid}) async =>
      const <String>{};

  @override
  Future<void> recordSwipe({required Swipe swipe}) async {}
}

const _matchChatViewerUid = 'nyc_jordan_ellis_002';
final _matchChatOtherProfile = _captureFixtures.publicProfile(
  'nyc_maya_shah_001',
);
final _matchChatEvent = buildEvent(
  id: 'event-match-chat-context',
  clubId: 'club-nyc-riverside',
  startTime: DateTime(2026, 5, 29, 7, 30),
  endTime: DateTime(2026, 5, 29, 8, 30),
  meetingPoint: 'Pier 57, Hudson River Park',
  startingPointLat: 40.7421,
  startingPointLng: -74.0089,
  locationDetails: 'Meet by the south entrance benches',
  bookedCount: 18,
  checkedInCount: 16,
  capacityLimit: 22,
  description:
      'A conversational riverside loop with a hosted coffee stop after.',
);
final _matchChatMatch = Match(
  id: 'match-chat-context',
  user1Id: _matchChatViewerUid,
  user2Id: _matchChatOtherProfile.uid,
  eventIds: [_matchChatEvent.id],
  createdAt: DateTime(2026, 5, 29, 9, 2),
  lastMessageAt: DateTime(2026, 5, 29, 9, 31),
  lastMessagePreview: 'Only if you send the gallery shortlist first.',
  lastMessageSenderId: _matchChatOtherProfile.uid,
  unreadCounts: const {_matchChatViewerUid: 1},
);
final _matchChatMessages = [
  ChatMessage(
    id: 'match-chat-message-1',
    senderId: _matchChatOtherProfile.uid,
    text:
        'I still think the coffee detour was the best part of that last mile.',
    sentAt: DateTime(2026, 5, 29, 9, 8),
  ),
  ChatMessage(
    id: 'match-chat-message-2',
    senderId: _matchChatViewerUid,
    text: 'Strong take. I had us at least tied with the bagel debate.',
    sentAt: DateTime(2026, 5, 29, 9, 11),
  ),
  ChatMessage(
    id: 'match-chat-message-3',
    senderId: _matchChatOtherProfile.uid,
    text: 'Fair. You made a real case for sesame, even if everything wins.',
    sentAt: DateTime(2026, 5, 29, 9, 16),
  ),
  ChatMessage(
    id: 'match-chat-message-4',
    senderId: _matchChatViewerUid,
    text: 'Next one: gallery night after the Thursday evening run?',
    sentAt: DateTime(2026, 5, 29, 9, 20),
  ),
  ChatMessage(
    id: 'match-chat-message-5',
    senderId: _matchChatOtherProfile.uid,
    text: 'Deal. If it is bad, you choose the next place.',
    sentAt: DateTime(2026, 5, 29, 9, 24),
  ),
  ChatMessage(
    id: 'match-chat-message-6',
    senderId: _matchChatViewerUid,
    text: 'I am taking the bagel win as official.',
    sentAt: DateTime(2026, 5, 29, 9, 28),
  ),
  ChatMessage(
    id: 'match-chat-message-7',
    senderId: _matchChatOtherProfile.uid,
    text: 'Only if you send the gallery shortlist first.',
    sentAt: DateTime(2026, 5, 29, 9, 31),
  ),
];
final _matchChatMatchRepository = _CaptureMatchRepository(
  matches: [_matchChatMatch],
);
final _matchChatConversationRepository = _CaptureConversationRepository(
  messagesByConversation: {_matchChatMatch.id: _matchChatMessages},
);

final _captureNow = DateTime(2026, 5, 31, 9);
const _captureViewerUid = 'runner-viewer';
final _captureViewer =
    buildUser(
      uid: _captureViewerUid,
      name: 'Rohan Mehta',
      email: 'rohan@example.com',
      phoneNumber: '+919870000001',
    ).copyWith(
      city: 'in-mh-mumbai',
      relationshipGoal: RelationshipGoal.relationship,
      activityPreferences: const ActivityPreferences(
        running: RunningPreferences(
          paceMinSecsPerKm: 320,
          paceMaxSecsPerKm: 395,
          preferredDistances: [PreferredDistance.fiveK, PreferredDistance.tenK],
          runningReasons: [RunReason.community, RunReason.social],
          preferredRunTimes: [PreferredRunTime.earlyMorning],
          version: currentRunPreferencesVersion,
        ),
      ),
    );

ClubMembership _captureMembership({
  required String clubId,
  required String uid,
  ClubMembershipRole role = ClubMembershipRole.member,
}) => ClubMembership(
  id: clubMembershipId(clubId: clubId, uid: uid),
  clubId: clubId,
  uid: uid,
  role: role,
  status: ClubMembershipStatus.active,
  pushNotificationsEnabled: true,
  joinedAt: DateTime(2026, 1, 12),
);

final _dashboardJoinedClub = _captureFixtures.captureClub(
  id: 'club-dashboard-dawn',
  name: 'Bandra Dawn Club',
  description: 'Coastal loops for people who want an easy first hello.',
  area: 'Bandra',
  hostName: 'Mira',
  tags: const ['social run', 'coffee', 'beginner'],
  memberCount: 142,
  reviewCount: 48,
  nextEventAt: DateTime(2026, 6, 4, 6, 30),
  nextEventLabel: 'Thu 6:30 AM',
);
final _dashboardHostClub = _captureFixtures.hostDemoClub();
final _dashboardSignedUpEvent = _captureFixtures.captureEvent(
  id: 'event-dashboard-next',
  club: _dashboardJoinedClub,
  startTime: DateTime(2026, 6, 4, 6, 30),
  endTime: DateTime(2026, 6, 4, 7, 40),
  meetingPoint: 'Bandra Fort gate',
  bookedCount: 18,
  capacityLimit: 24,
  description: 'A conversational dawn loop with coffee after.',
);
final _dashboardCheckInEvent = _captureFixtures.captureEvent(
  id: 'event-dashboard-check-in',
  club: _dashboardJoinedClub,
  startTime: _captureNow.add(const Duration(minutes: 5)),
  endTime: _captureNow.add(const Duration(hours: 1, minutes: 10)),
  meetingPoint: 'Bandra Fort gate',
  bookedCount: 18,
  capacityLimit: 24,
  description: 'A conversational dawn loop with coffee after.',
);
final _dashboardHostEvent = _captureFixtures.hostDemoEvent(
  role: 'hostEventSetup',
  club: _dashboardHostClub,
);
final _dashboardEditableHostEvent = _dashboardHostEvent.copyWith(
  id: 'event-host-editable',
  startTime: DateTime(2030, 7, 2, 18, 30),
  endTime: DateTime(2030, 7, 2, 20),
  bookedCount: 0,
  waitlistedCount: 0,
  checkedInCount: 0,
);
final _dashboardPrivateAccessHostEvent = _dashboardEditableHostEvent.copyWith(
  id: 'event-host-private-access',
  capacityLimit: 12,
  priceInPaise: 0,
  eventPolicy: EventPolicyBundle.inviteOnlyEvent(
    capacityLimit: 12,
    basePriceInPaise: 0,
    inviteCodeHint: 'SEAFACE',
  ),
);
final _dashboardValidationHostEvent = _dashboardEditableHostEvent.copyWith(
  id: 'event-host-validation',
  meetingPoint: '',
  meetingLocation: const EventMeetingLocation(
    name: '',
    address: 'Carter Road, Bandra West',
    placeId: 'capture-carter-road-empty-label',
    latitude: 19.0706,
    longitude: 72.8223,
    notes: 'Meet by the sea-facing steps',
  ),
  distanceKm: 0,
);
final _dashboardPinnedLocationHostEvent = _dashboardEditableHostEvent.copyWith(
  id: 'event-host-pinned-location',
  meetingPoint: 'Carter Road Amphitheatre',
  meetingLocation: const EventMeetingLocation(
    name: 'Carter Road Amphitheatre',
    address: 'Carter Road, Bandra West',
    placeId: 'capture-carter-road',
    latitude: 19.0706,
    longitude: 72.8223,
    notes: 'Meet by the sea-facing steps',
  ),
  startingPointLat: 19.0706,
  startingPointLng: 72.8223,
  locationDetails: 'Meet by the sea-facing steps',
);
final _dashboardCancelledHostEvent = _dashboardEditableHostEvent.copyWith(
  id: 'event-host-cancelled',
  status: EventLifecycleStatus.cancelled,
  cancelledAt: _captureNow.subtract(const Duration(hours: 2)),
  cancellationReason: 'Capture cancellation.',
);
final _dashboardRecommendedEvent = _captureFixtures.captureEvent(
  id: 'event-dashboard-recommended',
  club: _memberDiscoveryClubs[2],
  startTime: DateTime(2026, 6, 6, 18),
  meetingPoint: 'Juhu court 2',
  activityKind: ActivityKind.pickleball,
  distanceKm: 0,
  bookedCount: 10,
  capacityLimit: 16,
  priceInPaise: 60000,
  description: 'Rotating doubles with a host who balances teams.',
);
final _dashboardSignedUpEvents = [_dashboardSignedUpEvent];
final _dashboardSavedEvents = [
  _dashboardRecommendedEvent,
  _memberDiscoveryEvents[1],
  _memberDiscoveryEvents[2],
];
final _dashboardAttendedEvents = [
  _captureFixtures.captureEvent(
    id: 'event-dashboard-attended',
    club: _dashboardJoinedClub,
    startTime: DateTime(2026, 5, 30, 7),
    endTime: DateTime(2026, 5, 30, 8, 5),
    meetingPoint: 'Carter Road Amphitheatre',
    bookedCount: 20,
    checkedInCount: 18,
    capacityLimit: 24,
    description: 'Easy miles and a coffee line that did not feel awkward.',
  ),
];
final _dashboardAfterEventFocusEvent = _captureFixtures.captureEvent(
  id: 'event-dashboard-after-focus',
  club: _dashboardJoinedClub,
  startTime: _captureNow.subtract(const Duration(hours: 3)),
  endTime: _captureNow.subtract(const Duration(hours: 2)),
  meetingPoint: 'Carter Road Amphitheatre',
  bookedCount: 20,
  checkedInCount: 18,
  capacityLimit: 24,
  description: 'Easy miles and a coffee line that did not feel awkward.',
);
final _dashboardNotifications = [
  ActivityNotification(
    id: 'notification-dashboard-match',
    uid: _captureViewerUid,
    type: ActivityNotificationType.match,
    title: 'New match',
    body: 'Maya matched after Sunday Table Club.',
    createdAt: DateTime(2026, 5, 31, 8, 40),
  ),
];
Stream<T> _captureLoadingStream<T>() => Stream<T>.empty();

Stream<T> _captureErrorStream<T>(String message) =>
    Stream<T>.error(StateError(message), StackTrace.empty);

final _profileCaptureViewerNoNetwork = ProfileSurfaceFixtures.viewer.copyWith(
  profilePhotos: const [],
);
final _profileCaptureTargetNoNetwork = ProfileSurfaceFixtures
    .targetPublicProfile
    .copyWith(profilePhotos: const []);
final _profileCaptureOwnNoNetwork = ProfileSurfaceFixtures.ownPublicProfile
    .copyWith(profilePhotos: const []);
final _publicProfileReferenceProfile = ProfileSurfaceFixtures
    .targetPublicProfile
    .copyWith(
      name: 'Aanya',
      age: 27,
      city: 'Bandra',
      occupation: 'Designer',
      profilePhotos: [
        for (final photo
            in ProfileSurfaceFixtures.targetPublicProfile.profilePhotos)
          photo.copyWith(url: _profilePortraitAssetPath),
      ],
    );

List<Object> _selfProfileProviderOverrides({
  Stream<UserProfile?>? profileStream,
  UserProfile? profile,
  Set<int> uploadLoadingIndices = const <int>{},
}) {
  final effectiveProfile = profile ?? ProfileSurfaceFixtures.viewer;
  return [
    uidProvider.overrideWithValue(
      const AsyncData<String?>(ProfileSurfaceFixtures.viewerUid),
    ),
    watchUserProfileProvider.overrideWith(
      (ref) => profileStream ?? Stream<UserProfile?>.value(effectiveProfile),
    ),
    userProfileRepositoryProvider.overrideWithValue(
      ProfileFixtureUserProfileRepository(profile: effectiveProfile),
    ),
    photoUploadControllerProvider.overrideWithValue((
      loadingIndices: uploadLoadingIndices,
      uploadError: null,
    )),
    userAnalyticsRepositoryProvider.overrideWithValue(
      ProfileFixtureUserAnalyticsRepository(
        report: ProfileSurfaceFixtures.analyticsReport,
      ),
    ),
  ];
}

List<Object> _publicProfileProviderOverrides({
  String uid = ProfileSurfaceFixtures.targetUid,
  PublicProfile? profile,
  Stream<PublicProfile?>? profileStream,
}) {
  final effectiveProfile =
      profile ??
      (uid == ProfileSurfaceFixtures.ownUid
          ? _profileCaptureOwnNoNetwork
          : _profileCaptureTargetNoNetwork);
  return [
    uidProvider.overrideWithValue(
      const AsyncData<String?>(ProfileSurfaceFixtures.viewerUid),
    ),
    watchUserProfileProvider.overrideWith(
      (ref) => Stream<UserProfile?>.value(ProfileSurfaceFixtures.viewer),
    ),
    watchPublicProfileProvider(uid).overrideWith(
      (ref) => profileStream ?? Stream<PublicProfile?>.value(effectiveProfile),
    ),
    publicProfileRepositoryProvider.overrideWithValue(
      ProfileFixturePublicProfileRepository({
        uid: effectiveProfile,
        ProfileSurfaceFixtures.targetUid: _profileCaptureTargetNoNetwork,
        ProfileSurfaceFixtures.ownUid: _profileCaptureOwnNoNetwork,
      }),
    ),
    safetyRepositoryProvider.overrideWithValue(
      const ProfileFixtureSafetyRepository(),
    ),
  ];
}

Widget _selfProfileCapture({int initialTabIndex = 0}) =>
    ProfileScreen(initialTabIndex: initialTabIndex);

Widget _publicProfileCapture({
  String uid = ProfileSurfaceFixtures.targetUid,
  PublicProfile? initialProfile,
}) => PublicProfileScreen(uid: uid, initialProfile: initialProfile);

class _PublicProfilePendingOverlayCapture extends StatelessWidget {
  const _PublicProfilePendingOverlayCapture();

  @override
  Widget build(BuildContext context) {
    return PublicProfileBody(
      profile: _profileCaptureTargetNoNetwork,
      submitting: true,
      viewerProfile: ProfileSurfaceFixtures.viewer,
    );
  }
}

class _PublicProfileReportSheetCapture extends StatelessWidget {
  const _PublicProfileReportSheetCapture();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: PublicProfileReportSheet(
        profileName: ProfileSurfaceFixtures.targetPublicProfile.name,
        onReasonSelected: (_) {},
      ),
    );
  }
}

class _PublicProfileBlockDialogCapture extends StatefulWidget {
  const _PublicProfileBlockDialogCapture();

  @override
  State<_PublicProfileBlockDialogCapture> createState() =>
      _PublicProfileBlockDialogCaptureState();
}

class _PublicProfileBlockDialogCaptureState
    extends State<_PublicProfileBlockDialogCapture> {
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shown) return;
    _shown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        showBlockUserDialog(
          context: context,
          name: ProfileSurfaceFixtures.targetPublicProfile.name,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

NetworkException _dashboardOfflineException({required String action}) {
  return obviousOfflineException(
    context: BackendErrorContext(
      service: BackendService.firestore,
      action: action,
      resource: 'dashboard',
    ),
  );
}

List<Object> _dashboardProviderOverrides({
  Stream<UserProfile?>? profileStream,
  Stream<List<ClubMembership>>? membershipsStream,
  Stream<List<Event>>? signedUpEventsStream,
  List<ClubMembership>? memberships,
  List<Event>? signedUpEvents,
  AsyncValue<List<Event>>? attendedEvents,
  AsyncValue<List<ActivityNotification>>? notifications,
  AsyncValue<WeeklyActivitySnapshot>? weeklyActivity,
  AsyncValue<List<Review>>? reviews,
  AsyncValue<List<DashboardEventRecommendationCandidate>>? recommendations,
}) {
  final effectiveMemberships =
      memberships ??
      [
        _captureMembership(
          clubId: _dashboardJoinedClub.id,
          uid: _captureViewerUid,
        ),
      ];
  final effectiveSignedUpEvents = signedUpEvents ?? _dashboardSignedUpEvents;
  final followedClubIds = effectiveMemberships
      .map((membership) => membership.clubId)
      .toList(growable: false);
  final recommendationsQuery = DashboardRecommendationsQuery(
    userId: _captureViewerUid,
    followedClubIds: followedClubIds,
  );

  return [
    dashboardNowProvider.overrideWithValue(_captureNow),
    uidProvider.overrideWith((ref) => Stream.value(_captureViewerUid)),
    watchUserProfileProvider.overrideWith(
      (ref) => profileStream ?? Stream.value(_captureViewer),
    ),
    watchActiveClubMembershipsForUserProvider(_captureViewerUid).overrideWith(
      (ref) =>
          membershipsStream ??
          Stream<List<ClubMembership>>.value(effectiveMemberships),
    ),
    watchSignedUpEventsProvider(_captureViewerUid).overrideWith(
      (ref) =>
          signedUpEventsStream ??
          Stream<List<Event>>.value(effectiveSignedUpEvents),
    ),
    watchAttendedEventsProvider(
      _captureViewerUid,
    ).overrideWithValue(attendedEvents ?? AsyncData(_dashboardAttendedEvents)),
    watchActivityNotificationsProvider(
      _captureViewerUid,
    ).overrideWithValue(notifications ?? AsyncData(_dashboardNotifications)),
    clubsRepositoryProvider.overrideWith((ref) => _captureClubsRepository),
    watchClubsHostedByProvider(
      _captureViewerUid,
    ).overrideWithValue(AsyncData([_dashboardHostClub])),
    watchClubsOwnedByProvider(
      _captureViewerUid,
    ).overrideWithValue(const AsyncData([])),
    watchEventsForClubProvider(
      _dashboardHostClub.id,
    ).overrideWithValue(AsyncData([_dashboardHostEvent])),
    weeklyActivityProvider.overrideWithValue(
      weeklyActivity ??
          AsyncData(
            WeeklyActivitySnapshot.permissionRequired(
              referenceDate: _captureNow,
              platformLabel: 'Apple Health',
            ),
          ),
    ),
    watchReviewsByUserProvider(
      _captureViewerUid,
    ).overrideWithValue(reviews ?? const AsyncData<List<Review>>([])),
    dashboardRecommendedEventsProvider(recommendationsQuery).overrideWithValue(
      recommendations ??
          AsyncData([
            DashboardEventRecommendationCandidate(
              event: _dashboardRecommendedEvent,
              clubName: _memberDiscoveryClubs[2].name,
              clubLocation: _memberDiscoveryClubs[2].location,
            ),
          ]),
    ),
  ];
}

enum _DashboardCheckInMutationMode { pending, error }

class _DashboardCheckInMutationCapture extends ConsumerStatefulWidget {
  const _DashboardCheckInMutationCapture({required this.mode});

  final _DashboardCheckInMutationMode mode;

  @override
  ConsumerState<_DashboardCheckInMutationCapture> createState() =>
      _DashboardCheckInMutationCaptureState();
}

class _DashboardCheckInMutationCaptureState
    extends ConsumerState<_DashboardCheckInMutationCapture> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) return;
      _started = true;
      EventBookingController.selfCheckInMutation.reset(ref);
      switch (widget.mode) {
        case _DashboardCheckInMutationMode.pending:
          _runPending(EventBookingController.selfCheckInMutation);
          break;
        case _DashboardCheckInMutationMode.error:
          _runError(EventBookingController.selfCheckInMutation);
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _runPending(Mutation<void> mutation) {
    final completer = Completer<void>();
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError(Mutation<void> mutation) {
    unawaited(
      mutation
          .run(ref, (_) async => throw StateError('Capture check-in failed'))
          .catchError((_) {}),
    );
  }

  @override
  Widget build(BuildContext context) => const DashboardScreen();
}

final _captureClubsRepository = club_test.FakeClubsRepository()
  ..clubsById[_dashboardJoinedClub.id] = _dashboardJoinedClub
  ..clubsById[_dashboardHostClub.id] = _dashboardHostClub
  ..clubsById[_memberDiscoveryClubs[0].id] = _memberDiscoveryClubs[0]
  ..clubsById[_memberDiscoveryClubs[1].id] = _memberDiscoveryClubs[1]
  ..clubsById[_memberDiscoveryClubs[2].id] = _memberDiscoveryClubs[2];

final _clubDetailClub = _captureFixtures.captureClub(
  id: 'club-detail-member',
  name: 'Sea Face Social',
  description:
      'A member-led running club for low-pressure miles, good coffee, and people who remember your name.',
  area: 'Bandra',
  hostName: 'Mira',
  tags: const ['running', 'coffee', 'members only'],
  memberCount: 214,
  rating: 4.9,
  reviewCount: 58,
  nextEventAt: DateTime(2026, 6, 2, 6, 45),
  nextEventLabel: 'Tue 6:45 AM',
);
final _clubDetailEvents = [
  _captureFixtures.captureEvent(
    id: 'event-club-detail-sunrise',
    club: _clubDetailClub,
    startTime: DateTime(2026, 6, 2, 6, 45),
    meetingPoint: 'Bandstand promenade',
    distanceKm: 6,
    bookedCount: 16,
    capacityLimit: 22,
    description: 'Morning miles with regroup points and a cafe finish.',
  ),
  _captureFixtures.captureEvent(
    id: 'event-club-detail-weekend',
    club: _clubDetailClub,
    startTime: DateTime(2026, 6, 7, 8),
    meetingPoint: 'Bandra Fort gate',
    activityKind: ActivityKind.walking,
    distanceKm: 3,
    bookedCount: 19,
    capacityLimit: 28,
    description: 'A social weekend walk for new members.',
  ),
];
final _clubDetailReviews = [
  buildReview(
    id: 'review-club-detail-1',
    clubId: _clubDetailClub.id,
    reviewerUserId: 'runner-neha',
    reviewerName: 'Neha',
    comment: 'Friendly hosts, clear routes, and zero awkward hovering.',
    createdAt: DateTime(2026, 5, 24),
  ),
];

ClubDetailViewModel _clubDetailViewModel({
  Club? club,
  String? uid = _captureViewerUid,
  bool isHost = false,
  bool isMember = true,
  bool isAuthenticated = true,
  List<Event>? upcomingEvents,
  List<Review>? reviews,
  UserProfile? userProfile,
  bool includeUserProfile = true,
}) {
  return ClubDetailViewModel(
    club: club ?? _clubDetailClub,
    isHost: isHost,
    isMember: isMember,
    upcomingEvents: upcomingEvents ?? _clubDetailEvents,
    reviews: reviews ?? _clubDetailReviews,
    userProfile: includeUserProfile ? userProfile ?? _captureViewer : null,
    uid: uid,
    isAuthenticated: isAuthenticated,
  );
}

List<Object> _clubDetailProviderOverrides({
  String? uid = _captureViewerUid,
  ClubMembership? membership,
  required AsyncValue<ClubDetailViewModel?> viewModel,
}) {
  final effectiveUid = uid;
  return [
    uidProvider.overrideWith((ref) => Stream.value(effectiveUid)),
    watchUserProfileProvider.overrideWith(
      (ref) => Stream.value(effectiveUid == null ? null : _captureViewer),
    ),
    if (effectiveUid != null)
      watchClubMembershipProvider(
        _clubDetailClub.id,
        effectiveUid,
      ).overrideWith((ref) => Stream.value(membership)),
    clubDetailViewModelProvider(
      _clubDetailClub.id,
    ).overrideWith((ref) => viewModel),
  ];
}

Widget _clubDetailScreenCapture({bool includeInitialClub = true}) {
  return ClubDetailScreen(
    clubId: _clubDetailClub.id,
    initialClub: includeInitialClub ? _clubDetailClub : null,
  );
}

Widget _clubDetailMutationCapture({
  required bool isMember,
  required bool isAuthenticated,
  bool isMutating = false,
  Object? mutationError,
}) {
  final dockState = !isAuthenticated
      ? CatchClubDockState.guest
      : isMember
      ? CatchClubDockState.member
      : CatchClubDockState.visitor;
  final footnote = switch (dockState) {
    CatchClubDockState.visitor => 'FREE TO JOIN · LEAVE ANYTIME',
    CatchClubDockState.member => 'MEMBER · MANAGE ANYTIME',
    _ => null,
  };

  return Scaffold(
    body: Column(
      children: [
        if (mutationError != null)
          CatchErrorBanner.fromError(
            mutationError,
            context: AppErrorContext.club,
            onRetry: () {},
          ),
        Expanded(
          child: ClubDetailBody(
            club: _clubDetailClub,
            upcoming: _clubDetailEvents,
            reviews: _clubDetailReviews,
            userProfile: isAuthenticated ? _captureViewer : null,
            uid: isAuthenticated ? _captureViewerUid : null,
            isHost: false,
            isMember: isMember,
            isMutating: isMutating,
            clubPushNotificationsEnabled: isMember,
            isClubPushMutating: false,
            isAuthenticated: isAuthenticated,
          ),
        ),
      ],
    ),
    bottomNavigationBar: CatchClubDock(
      state: dockState,
      activityKind: _clubDetailClub.hostDefaults.primaryActivityKind,
      members: _clubDetailClub.memberCount,
      footnote: footnote,
      isJoinLoading: isMutating,
      onSignIn: () {},
      onJoin: () {},
      onManage: () {},
      onBell: () {},
    ),
  );
}

class _AppRoleCapture extends StatefulWidget {
  const _AppRoleCapture({required this.role, required this.child});

  final AppRole role;
  final Widget child;

  @override
  State<_AppRoleCapture> createState() => _AppRoleCaptureState();
}

class _AppRoleCaptureState extends State<_AppRoleCapture> {
  @override
  void initState() {
    super.initState();
    AppConfig.configureEntrypointRole(widget.role);
  }

  @override
  void didUpdateWidget(_AppRoleCapture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      AppConfig.configureEntrypointRole(widget.role);
    }
  }

  @override
  void dispose() {
    AppConfig.resetEntrypointRoleOverrideForTesting();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ReferenceChromeSafeArea extends StatelessWidget {
  const _ReferenceChromeSafeArea({required this.child});

  static const _fallbackInsets = EdgeInsets.only(top: 44, bottom: 44);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final padding = media.padding;
    final resolvedPadding = EdgeInsets.only(
      top: padding.top == 0 ? _fallbackInsets.top : padding.top,
      bottom: padding.bottom == 0 ? _fallbackInsets.bottom : padding.bottom,
      left: padding.left,
      right: padding.right,
    );

    return MediaQuery(
      data: media.copyWith(
        padding: resolvedPadding,
        viewPadding: resolvedPadding,
      ),
      child: child,
    );
  }
}

List<Object> _hostOperationsProviderOverrides({
  List<Club>? hostedClubs,
  List<Club>? ownedClubs,
  AsyncValue<HostProfile?>? hostProfile,
  AsyncValue<List<Club>>? hostedClubsAsync,
  AsyncValue<List<Club>>? ownedClubsAsync,
  Map<String, AsyncValue<List<Event>>> clubEvents = const {},
  AsyncValue<HostPaymentAccount?>? paymentAccountValue,
  HostAnalyticsRepository analyticsRepository =
      const HostFixtureAnalyticsRepository(),
}) {
  final uid = HostOperationsFixtures.hostUid;
  final hosted = hostedClubs ?? HostOperationsFixtures.clubs;
  final owned =
      ownedClubs ??
      [HostOperationsFixtures.primaryClub, HostOperationsFixtures.dinnerClub];
  final eventClubIds = <String>{
    for (final club in HostOperationsFixtures.clubs) club.id,
    for (final club in hosted) club.id,
    for (final club in owned) club.id,
    ...clubEvents.keys,
  };

  return [
    uidProvider.overrideWithValue(AsyncData<String?>(uid)),
    watchUserProfileProvider.overrideWith(
      (ref) => Stream.value(HostOperationsFixtures.owner),
    ),
    if (hostProfile == null)
      watchHostProfileProvider(
        uid,
      ).overrideWith((ref) => Stream.value(HostOperationsFixtures.hostProfile))
    else
      watchHostProfileProvider(uid).overrideWithValue(hostProfile),
    if (hostedClubsAsync == null)
      watchClubsHostedByProvider(
        uid,
      ).overrideWith((ref) => Stream.value(hosted))
    else
      watchClubsHostedByProvider(uid).overrideWithValue(hostedClubsAsync),
    if (ownedClubsAsync == null)
      watchClubsOwnedByProvider(uid).overrideWith((ref) => Stream.value(owned))
    else
      watchClubsOwnedByProvider(uid).overrideWithValue(ownedClubsAsync),
    watchHostPaymentAccountProvider(uid).overrideWithValue(
      paymentAccountValue ?? const AsyncData<HostPaymentAccount?>(null),
    ),
    hostClubEditControllerProvider.overrideWithValue(
      const _CaptureNoopHostClubEditActions(),
    ),
    hostPaymentAccountControllerProvider.overrideWithValue(
      const _CaptureNoopHostPaymentAccountActions(),
    ),
    hostAnalyticsRepositoryProvider.overrideWithValue(analyticsRepository),
    for (final clubId in eventClubIds)
      if (clubEvents.containsKey(clubId))
        watchEventsForClubProvider(
          clubId,
        ).overrideWithValue(clubEvents[clubId]!)
      else
        watchEventsForClubProvider(clubId).overrideWith(
          (ref) => Stream.value(
            HostOperationsFixtures.eventsByClub[clubId] ?? const <Event>[],
          ),
        ),
  ];
}

Widget _hostPayoutCardCapture() {
  return _AppRoleCapture(
    role: AppRole.host,
    child: Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: HostPaymentAccountCard(
            club: HostOperationsFixtures.primaryClub,
          ),
        ),
      ),
    ),
  );
}

class _HostTeamSectionCapture extends StatelessWidget {
  const _HostTeamSectionCapture();

  @override
  Widget build(BuildContext context) {
    return _AppRoleCapture(
      role: AppRole.host,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: HostTeamManagementSection(
              club: HostOperationsFixtures.primaryClub,
              currentUid: HostOperationsFixtures.hostUid,
            ),
          ),
        ),
      ),
    );
  }
}

enum _HostClubsMutationCaptureMode {
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

class _HostClubsMutationCapture extends ConsumerStatefulWidget {
  const _HostClubsMutationCapture({required this.mode, required this.child});

  final _HostClubsMutationCaptureMode mode;
  final Widget child;

  @override
  ConsumerState<_HostClubsMutationCapture> createState() =>
      _HostClubsMutationCaptureState();
}

class _HostClubsMutationCaptureState
    extends ConsumerState<_HostClubsMutationCapture> {
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
      case _HostClubsMutationCaptureMode.inlinePending:
        _runPending(HostClubEditController.updateClubMutation);
        break;
      case _HostClubsMutationCaptureMode.inlineError:
        _runError(
          HostClubEditController.updateClubMutation,
          StateError('Capture club update failed'),
        );
        break;
      case _HostClubsMutationCaptureMode.inlineOffline:
        _runError(
          HostClubEditController.updateClubMutation,
          obviousOfflineException(),
        );
        break;
      case _HostClubsMutationCaptureMode.payoutSetupPending:
        _runPending(HostPaymentAccountController.startOnboardingMutation);
        break;
      case _HostClubsMutationCaptureMode.payoutSetupError:
        _runError(
          HostPaymentAccountController.startOnboardingMutation,
          StateError('Capture payout setup failed'),
        );
        break;
      case _HostClubsMutationCaptureMode.payoutSetupOffline:
        _runError(
          HostPaymentAccountController.startOnboardingMutation,
          obviousOfflineException(),
        );
        break;
      case _HostClubsMutationCaptureMode.payoutRefreshPending:
        _runPending(HostPaymentAccountController.refreshStatusMutation);
        break;
      case _HostClubsMutationCaptureMode.payoutRefreshError:
        _runError(
          HostPaymentAccountController.refreshStatusMutation,
          StateError('Capture payout refresh failed'),
        );
        break;
      case _HostClubsMutationCaptureMode.payoutRefreshOffline:
        _runError(
          HostPaymentAccountController.refreshStatusMutation,
          obviousOfflineException(),
        );
        break;
      case _HostClubsMutationCaptureMode.teamPending:
        _runPending(HostTeamManagementController.removeHostMutation);
        break;
      case _HostClubsMutationCaptureMode.teamError:
        _runError(
          HostTeamManagementController.removeHostMutation,
          StateError('Capture host team update failed'),
        );
        break;
      case _HostClubsMutationCaptureMode.teamOffline:
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

final class _CaptureNoopHostClubEditActions implements HostClubEditActions {
  const _CaptureNoopHostClubEditActions();

  @override
  Future<void> updateClub({
    required String clubId,
    required UpdateClubPatch patch,
  }) async {}
}

final class _CaptureNoopHostPaymentAccountActions
    implements HostPaymentAccountActions {
  const _CaptureNoopHostPaymentAccountActions();

  @override
  Future<void> refreshStatus() async {}

  @override
  Future<void> startOnboarding({
    required String country,
    required String defaultCurrency,
  }) async {}
}

List<Object> _hostCreateClubProviderOverrides() {
  return [
    uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
    watchUserProfileProvider.overrideWith(
      (ref) => Stream.value(_captureViewer),
    ),
  ];
}

Widget _createClubCapture({
  int initialStep = 0,
  bool useDraft = false,
  bool showValidation = false,
  bool usePickedMedia = false,
}) {
  return CreateClubScreen(
    initialDraft: useDraft ? HostOperationsFixtures.clubDraft : null,
    initialStep: initialStep,
    restoreSavedDraft: false,
    formAutovalidateMode: showValidation
        ? AutovalidateMode.always
        : AutovalidateMode.disabled,
    initialPickedClubPhotos: usePickedMedia
        ? _createClubPickedPhotos()
        : const <PickedClubPhoto>[],
    initialProfileImage: usePickedMedia ? _createClubProfileImage() : null,
  );
}

Widget _createEventCapture({
  int initialStep = 0,
  bool useDraft = true,
  bool showValidation = false,
  bool usePickedMedia = false,
  EventDraft? draft,
}) {
  return CreateEventScreen(
    club: _dashboardHostClub,
    initialDraft: draft ?? (useDraft ? _hostEventSetupDraft : null),
    initialStep: initialStep,
    formAutovalidateMode: showValidation
        ? AutovalidateMode.always
        : AutovalidateMode.disabled,
    initialPickedEventPhotos: usePickedMedia
        ? _createEventPickedPhotos()
        : const <PickedEventPhoto>[],
    loadMapTiles: false,
    now: () => _captureNow,
  );
}

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

enum _HostCreateClubMutationCaptureMode {
  saveDraftPending,
  saveDraftError,
  submitPending,
  submitError,
  submitOffline,
}

class _HostCreateClubMutationCapture extends ConsumerStatefulWidget {
  const _HostCreateClubMutationCapture({
    required this.mode,
    required this.child,
  });

  final _HostCreateClubMutationCaptureMode mode;
  final Widget child;

  @override
  ConsumerState<_HostCreateClubMutationCapture> createState() =>
      _HostCreateClubMutationCaptureState();
}

class _HostCreateClubMutationCaptureState
    extends ConsumerState<_HostCreateClubMutationCapture> {
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
        case _HostCreateClubMutationCaptureMode.saveDraftPending:
          _runPending(CreateClubDraftController.saveDraftMutation);
          break;
        case _HostCreateClubMutationCaptureMode.saveDraftError:
          _runError(
            CreateClubDraftController.saveDraftMutation,
            StateError('Capture club draft save failed'),
          );
          break;
        case _HostCreateClubMutationCaptureMode.submitPending:
          _runPending(CreateClubController.submitMutation);
          break;
        case _HostCreateClubMutationCaptureMode.submitError:
          _runError(
            CreateClubController.submitMutation,
            StateError('Capture club submit failed'),
          );
          break;
        case _HostCreateClubMutationCaptureMode.submitOffline:
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

enum _HostCreateEventMutationCaptureMode {
  saveDraftPending,
  saveDraftError,
  submitPending,
  submitError,
  submitOffline,
}

class _HostCreateEventMutationCapture extends ConsumerStatefulWidget {
  const _HostCreateEventMutationCapture({
    required this.mode,
    required this.child,
  });

  final _HostCreateEventMutationCaptureMode mode;
  final Widget child;

  @override
  ConsumerState<_HostCreateEventMutationCapture> createState() =>
      _HostCreateEventMutationCaptureState();
}

class _HostCreateEventMutationCaptureState
    extends ConsumerState<_HostCreateEventMutationCapture> {
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
        case _HostCreateEventMutationCaptureMode.saveDraftPending:
          _runPending(CreateEventDraftController.saveDraftMutation);
          break;
        case _HostCreateEventMutationCaptureMode.saveDraftError:
          _runError(
            CreateEventDraftController.saveDraftMutation,
            StateError('Capture event draft save failed'),
          );
          break;
        case _HostCreateEventMutationCaptureMode.submitPending:
          _runPending(CreateEventController.submitMutation);
          break;
        case _HostCreateEventMutationCaptureMode.submitError:
          _runError(
            CreateEventController.submitMutation,
            StateError('Capture event submit failed'),
          );
          break;
        case _HostCreateEventMutationCaptureMode.submitOffline:
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

List<Object> _hostEditClubProviderOverrides({
  String? uid,
  AsyncValue<Club?>? clubValue,
  Club? fallbackClub,
}) {
  final club = fallbackClub ?? _dashboardHostClub;
  final effectiveUid =
      uid ?? club.ownerOrPrimaryHostUserId ?? _captureViewerUid;
  return [
    uidProvider.overrideWithValue(AsyncData<String?>(effectiveUid)),
    watchUserProfileProvider.overrideWith(
      (ref) => Stream.value(
        effectiveUid == HostOperationsFixtures.hostUid
            ? HostOperationsFixtures.owner
            : _captureViewer,
      ),
    ),
    if (clubValue != null)
      fetchClubProvider(club.id).overrideWithValue(clubValue),
  ];
}

List<Object> _hostCreateEventProviderOverrides({
  AsyncValue<Club?>? clubValue,
  List<EventDraft> drafts = const <EventDraft>[],
}) {
  return [
    uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
    watchUserProfileProvider.overrideWith(
      (ref) => Stream.value(_captureViewer),
    ),
    fetchClubProvider(
      _dashboardHostClub.id,
    ).overrideWithValue(clubValue ?? AsyncData<Club?>(_dashboardHostClub)),
    deviceLocationProvider.overrideWith(_CaptureDeviceLocation.new),
    eventDraftRepositoryProvider.overrideWithValue(
      HostFixtureEventDraftRepository(drafts: drafts),
    ),
    eventRepositoryProvider.overrideWith((ref) => FakeEventRepository()),
  ];
}

final class _CaptureLoadingAnalyticsRepository
    implements HostAnalyticsRepository {
  const _CaptureLoadingAnalyticsRepository();

  @override
  Future<HostAnalyticsReport> getHostAnalytics(HostAnalyticsQuery query) {
    return Completer<HostAnalyticsReport>().future;
  }
}

List<Object> _hostEditEventProviderOverrides({
  String? uid,
  AsyncValue<Club?>? clubValue,
  AsyncValue<Event?>? eventValue,
  AsyncValue<EventPrivateAccess?>? privateAccessValue,
  Event? event,
}) {
  final effectiveEvent = event ?? _dashboardEditableHostEvent;
  final effectiveUid =
      uid ??
      _dashboardHostClub.ownerOrPrimaryHostUserId ??
      HostOperationsFixtures.hostUid;
  return [
    uidProvider.overrideWithValue(AsyncData<String?>(effectiveUid)),
    watchUserProfileProvider.overrideWith(
      (ref) => Stream.value(
        effectiveUid == HostOperationsFixtures.hostUid
            ? HostOperationsFixtures.owner
            : _captureViewer,
      ),
    ),
    fetchClubProvider(
      _dashboardHostClub.id,
    ).overrideWithValue(clubValue ?? AsyncData<Club?>(_dashboardHostClub)),
    watchEventProvider(
      effectiveEvent.id,
    ).overrideWithValue(eventValue ?? AsyncData<Event?>(effectiveEvent)),
    watchEventPrivateAccessProvider(effectiveEvent.id).overrideWithValue(
      privateAccessValue ?? const AsyncData<EventPrivateAccess?>(null),
    ),
    deviceLocationProvider.overrideWith(_CaptureDeviceLocation.new),
    eventRepositoryProvider.overrideWith((ref) => FakeEventRepository()),
  ];
}

enum _HostProfileMutationCaptureMode {
  createPending,
  createError,
  createOffline,
  editorSheet,
  savePending,
  saveError,
  saveOffline,
  signOutError,
  signOutOffline,
}

class _HostProfileMutationCapture extends ConsumerStatefulWidget {
  const _HostProfileMutationCapture({
    required this.mode,
    required this.child,
    this.showEditorSheet = false,
  });

  final _HostProfileMutationCaptureMode mode;
  final Widget child;
  final bool showEditorSheet;

  @override
  ConsumerState<_HostProfileMutationCapture> createState() =>
      _HostProfileMutationCaptureState();
}

class _HostProfileMutationCaptureState
    extends ConsumerState<_HostProfileMutationCapture> {
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

  void _resetMutations() {
    HostProfileController.ensureProfileMutation.reset(ref);
    HostProfileController.saveProfileMutation.reset(ref);
    AuthSessionController.signOutMutation.reset(ref);
  }

  void _seed() {
    switch (widget.mode) {
      case _HostProfileMutationCaptureMode.createPending:
        _runPending(HostProfileController.ensureProfileMutation);
        break;
      case _HostProfileMutationCaptureMode.createError:
        _runError(
          HostProfileController.ensureProfileMutation,
          StateError('Capture host profile create failed'),
        );
        break;
      case _HostProfileMutationCaptureMode.createOffline:
        _runError(
          HostProfileController.ensureProfileMutation,
          obviousOfflineException(),
        );
        break;
      case _HostProfileMutationCaptureMode.editorSheet:
        _openEditorSheet();
        break;
      case _HostProfileMutationCaptureMode.savePending:
        _openEditorSheet();
        _runAfterNextFrame(
          () => _runPending(HostProfileController.saveProfileMutation),
        );
        break;
      case _HostProfileMutationCaptureMode.saveError:
        _openEditorSheet();
        _runAfterNextFrame(
          () => _runError(
            HostProfileController.saveProfileMutation,
            StateError('Capture host profile save failed'),
          ),
        );
        break;
      case _HostProfileMutationCaptureMode.saveOffline:
        _openEditorSheet();
        _runAfterNextFrame(
          () => _runError(
            HostProfileController.saveProfileMutation,
            obviousOfflineException(),
          ),
        );
        break;
      case _HostProfileMutationCaptureMode.signOutError:
        _runError(
          AuthSessionController.signOutMutation,
          StateError('Capture host sign out failed'),
        );
        break;
      case _HostProfileMutationCaptureMode.signOutOffline:
        _runError(
          AuthSessionController.signOutMutation,
          obviousOfflineException(),
        );
        break;
    }
  }

  void _openEditorSheet() {
    if (!widget.showEditorSheet) return;
    unawaited(
      showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) =>
            HostProfileEditorSheet(profile: HostOperationsFixtures.hostProfile),
      ),
    );
  }

  void _runAfterNextFrame(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) callback();
    });
  }

  void _runPending(Mutation<void> mutation) {
    final completer = Completer<void>();
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError(Mutation<void> mutation, Object error) {
    unawaited(mutation.run(ref, (_) async => throw error).catchError((_) {}));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

enum _HostEditEventMutationCaptureMode { submitPending, submitError }

class _HostEditEventMutationCapture extends ConsumerStatefulWidget {
  const _HostEditEventMutationCapture({
    required this.mode,
    required this.child,
  });

  final _HostEditEventMutationCaptureMode mode;
  final Widget child;

  @override
  ConsumerState<_HostEditEventMutationCapture> createState() =>
      _HostEditEventMutationCaptureState();
}

class _HostEditEventMutationCaptureState
    extends ConsumerState<_HostEditEventMutationCapture> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) return;
      _started = true;
      EventBookingController.updateHostedEventMutation.reset(ref);
      switch (widget.mode) {
        case _HostEditEventMutationCaptureMode.submitPending:
          _runPending(EventBookingController.updateHostedEventMutation);
          break;
        case _HostEditEventMutationCaptureMode.submitError:
          _runError(
            EventBookingController.updateHostedEventMutation,
            StateError('Capture host event update failed'),
          );
          break;
      }
    });
  }

  void _runPending(Mutation<void> mutation) {
    final completer = Completer<void>();
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError(Mutation<void> mutation, Object error) {
    unawaited(mutation.run(ref, (_) async => throw error).catchError((_) {}));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

List<Object> _hostClubDetailProviderOverrides({
  String? uid = HostOperationsFixtures.hostUid,
  Club? club,
  ClubMembership? membership,
  AsyncValue<ClubDetailViewModel?>? viewModel,
}) {
  final effectiveClub = club ?? _hostClubDetailReferenceClub;
  return [
    uidProvider.overrideWithValue(AsyncData<String?>(uid)),
    watchUserProfileProvider.overrideWith(
      (ref) => Stream.value(uid == null ? null : HostOperationsFixtures.owner),
    ),
    if (uid != null)
      watchClubMembershipProvider(
        effectiveClub.id,
        uid,
      ).overrideWith((ref) => Stream<ClubMembership?>.value(membership)),
    clubDetailViewModelProvider(effectiveClub.id).overrideWith(
      (ref) =>
          viewModel ??
          AsyncData<ClubDetailViewModel?>(
            _hostClubDetailViewModel(club: effectiveClub, uid: uid),
          ),
    ),
  ];
}

ClubDetailViewModel _hostClubDetailViewModel({
  Club? club,
  String? uid = HostOperationsFixtures.hostUid,
  bool? isHost,
  List<Event>? upcomingEvents,
  List<Review> reviews = const <Review>[],
}) {
  final effectiveClub = club ?? _hostClubDetailReferenceClub;
  final defaultEvents = effectiveClub.id == _hostClubDetailReferenceClub.id
      ? _hostClubDetailReferenceEvents
      : HostOperationsFixtures.eventsByClub[effectiveClub.id] ??
            const <Event>[];
  return ClubDetailViewModel(
    club: effectiveClub,
    isHost: isHost ?? (uid != null && effectiveClub.isHostedBy(uid)),
    isMember: false,
    upcomingEvents: upcomingEvents ?? defaultEvents,
    reviews: reviews,
    userProfile: uid == null ? null : HostOperationsFixtures.owner,
    uid: uid,
    isAuthenticated: uid != null,
  );
}

List<Object> _hostManageRouteProviderOverrides({
  String? uid,
  Club? club,
  Event? event,
  AsyncValue<Club?>? clubValue,
  AsyncValue<Event?>? eventValue,
  AsyncValue<AttendanceSheetViewModel?>? attendanceValue,
  AsyncValue<Map<String, (String, String?)>>? attendeeProfilesValue,
  AsyncValue<EventPrivateAccess?>? privateAccessValue,
  AsyncValue<List<EventInviteLink>>? inviteLinksValue,
  AsyncValue<EventSuccessPlan?>? planValue,
  AsyncValue<EventSuccessScorecard?>? scorecardValue,
  List<EventParticipation>? participations,
}) {
  final effectiveUid = uid ?? HostOperationsFixtures.hostUid;
  final effectiveClub = club ?? HostOperationsFixtures.primaryClub;
  final effectiveEvent = event ?? HostOperationsFixtures.privateEvent;
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
  return [
    uidProvider.overrideWithValue(AsyncData<String?>(effectiveUid)),
    fetchClubProvider(
      effectiveClub.id,
    ).overrideWithValue(clubValue ?? AsyncData<Club?>(effectiveClub)),
    watchEventProvider(
      effectiveEvent.id,
    ).overrideWithValue(eventValue ?? AsyncData<Event?>(effectiveEvent)),
    watchEventParticipationRosterProvider(
      effectiveEvent.id,
    ).overrideWith((ref) => Stream.value(roster)),
    watchEventParticipationsForEventProvider(
      effectiveEvent.id,
    ).overrideWith((ref) => Stream.value(effectiveParticipations)),
    attendanceSheetViewModelProvider(
      effectiveEvent.id,
    ).overrideWithValue(effectiveAttendanceValue),
    attendeeProfilesProvider(profileIds).overrideWithValue(
      attendeeProfilesValue ??
          AsyncData<Map<String, (String, String?)>>(profiles),
    ),
    watchEventPrivateAccessProvider(effectiveEvent.id).overrideWithValue(
      privateAccessValue ??
          AsyncData<EventPrivateAccess?>(HostOperationsFixtures.privateAccess),
    ),
    watchEventInviteLinksProvider(effectiveEvent.id).overrideWithValue(
      inviteLinksValue ??
          AsyncData<List<EventInviteLink>>(HostOperationsFixtures.inviteLinks),
    ),
    watchEventSuccessPlanProvider(
      effectiveEvent.id,
    ).overrideWithValue(planValue ?? const AsyncData<EventSuccessPlan?>(null)),
    watchEventSuccessScorecardProvider(effectiveEvent.id).overrideWithValue(
      scorecardValue ?? const AsyncData<EventSuccessScorecard?>(null),
    ),
  ];
}

Widget _hostManageRouteCapture({
  Club? club,
  Event? event,
  bool includeInitialEvent = true,
  HostEventManageSection initialSection = HostEventManageSection.setup,
  String initialParticipantSearchQuery = '',
}) {
  final effectiveClub = club ?? HostOperationsFixtures.primaryClub;
  final effectiveEvent = event ?? HostOperationsFixtures.privateEvent;
  return _AppRoleCapture(
    role: AppRole.host,
    child: HostEventManageRouteScreen(
      clubId: effectiveClub.id,
      eventId: effectiveEvent.id,
      initialEvent: includeInitialEvent ? effectiveEvent : null,
      initialSection: initialSection,
      initialParticipantSearchQuery: initialParticipantSearchQuery,
    ),
  );
}

List<Object> _hostManageLiveWindowProviderOverrides() => [
  uidProvider.overrideWith((ref) => Stream.value(_captureViewerUid)),
  watchUserProfileProvider.overrideWith((ref) => Stream.value(_captureViewer)),
  watchEventProvider(
    _hostLiveWindowEvent.id,
  ).overrideWith((ref) => Stream.value(_hostLiveWindowEvent)),
  eventParticipationRepositoryProvider.overrideWithValue(
    _hostParticipationRepository,
  ),
  publicProfileRepositoryProvider.overrideWithValue(
    _hostPublicProfileRepository,
  ),
  watchEventSuccessPlanProvider(
    _hostLiveWindowEvent.id,
  ).overrideWith((ref) => Stream.value(_hostLiveWindowPlan)),
  watchEventSuccessScorecardProvider(
    _hostLiveWindowEvent.id,
  ).overrideWith((ref) => Stream.value(null)),
  ..._hostEventSuccessProviderOverrides,
];

enum _HostManageAttendanceMutationCaptureMode { pending, error }

class _HostManageAttendanceMutationCapture extends ConsumerStatefulWidget {
  const _HostManageAttendanceMutationCapture({
    required this.mode,
    required this.child,
  });

  final _HostManageAttendanceMutationCaptureMode mode;
  final Widget child;

  @override
  ConsumerState<_HostManageAttendanceMutationCapture> createState() =>
      _HostManageAttendanceMutationCaptureState();
}

class _HostManageAttendanceMutationCaptureState
    extends ConsumerState<_HostManageAttendanceMutationCapture> {
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
      case _HostManageAttendanceMutationCaptureMode.pending:
        _runPending(EventBookingController.createWaitlistOfferMutation);
        break;
      case _HostManageAttendanceMutationCaptureMode.error:
        _runError(
          EventBookingController.markAttendanceMutation,
          StateError('Capture Host Manage attendance mutation failed'),
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

enum _HostManageInviteLinkMutationCaptureMode { pending, error }

class _HostManageInviteLinkMutationCapture extends ConsumerStatefulWidget {
  const _HostManageInviteLinkMutationCapture({
    required this.mode,
    required this.child,
  });

  final _HostManageInviteLinkMutationCaptureMode mode;
  final Widget child;

  @override
  ConsumerState<_HostManageInviteLinkMutationCapture> createState() =>
      _HostManageInviteLinkMutationCaptureState();
}

class _HostManageInviteLinkMutationCaptureState
    extends ConsumerState<_HostManageInviteLinkMutationCapture> {
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
      case _HostManageInviteLinkMutationCaptureMode.pending:
        _runPending(HostEventManageController.createInviteLinkMutation);
        break;
      case _HostManageInviteLinkMutationCaptureMode.error:
        _runError(
          HostEventManageController.disableInviteLinkMutation,
          StateError('Capture Host Manage invite link mutation failed'),
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

enum _HostManagePrivateLinkShareMutationCaptureMode { pending, error }

class _HostManagePrivateLinkShareMutationCapture
    extends ConsumerStatefulWidget {
  const _HostManagePrivateLinkShareMutationCapture({
    required this.mode,
    required this.child,
  });

  final _HostManagePrivateLinkShareMutationCaptureMode mode;
  final Widget child;

  @override
  ConsumerState<_HostManagePrivateLinkShareMutationCapture> createState() =>
      _HostManagePrivateLinkShareMutationCaptureState();
}

class _HostManagePrivateLinkShareMutationCaptureState
    extends ConsumerState<_HostManagePrivateLinkShareMutationCapture> {
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
      case _HostManagePrivateLinkShareMutationCaptureMode.pending:
        _runPending(HostEventManageController.sharePrivateLinkMutation);
        break;
      case _HostManagePrivateLinkShareMutationCaptureMode.error:
        _runError(
          HostEventManageController.sharePrivateLinkMutation,
          StateError('Capture Host Manage private link share failed'),
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

enum _HostManageReportExportMutationCaptureMode { pending, error }

class _HostManageReportExportMutationCapture extends ConsumerStatefulWidget {
  const _HostManageReportExportMutationCapture({
    required this.mode,
    required this.child,
  });

  final _HostManageReportExportMutationCaptureMode mode;
  final Widget child;

  @override
  ConsumerState<_HostManageReportExportMutationCapture> createState() =>
      _HostManageReportExportMutationCaptureState();
}

class _HostManageReportExportMutationCaptureState
    extends ConsumerState<_HostManageReportExportMutationCapture> {
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
      case _HostManageReportExportMutationCaptureMode.pending:
        _runPending(HostEventManageController.shareRevenueReportMutation);
        break;
      case _HostManageReportExportMutationCaptureMode.error:
        _runError(
          HostEventManageController.shareOpsReportMutation,
          StateError('Capture Host Manage report export failed'),
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

enum _HostManageActionMutationCaptureMode {
  cancelPending,
  cancelError,
  deletePending,
  deleteError,
}

class _HostManageActionMutationCapture extends ConsumerStatefulWidget {
  const _HostManageActionMutationCapture({
    required this.mode,
    required this.child,
  });

  final _HostManageActionMutationCaptureMode mode;
  final Widget child;

  @override
  ConsumerState<_HostManageActionMutationCapture> createState() =>
      _HostManageActionMutationCaptureState();
}

class _HostManageActionMutationCaptureState
    extends ConsumerState<_HostManageActionMutationCapture> {
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
      case _HostManageActionMutationCaptureMode.cancelPending:
        _runPending(EventBookingController.hostCancelEventMutation);
        break;
      case _HostManageActionMutationCaptureMode.cancelError:
        _runError(
          EventBookingController.hostCancelEventMutation,
          StateError('Capture Host Manage cancel event failed'),
        );
        break;
      case _HostManageActionMutationCaptureMode.deletePending:
        _runPending(EventBookingController.deleteEventMutation);
        break;
      case _HostManageActionMutationCaptureMode.deleteError:
        _runError(
          EventBookingController.deleteEventMutation,
          StateError('Capture Host Manage delete event failed'),
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

final _hostInquiryMatch = MatchesChatSurfaceFixtures.hostInquiryMatches.first;
final _hostInquiryMessages = <ChatMessage>[
  MatchesChatSurfaceFixtures.message(
    id: 'host-inquiry-message-1',
    senderId: MatchesChatSurfaceFixtures.guestUid,
    text: 'Is there parking near the start?',
    sentAt: MatchesChatSurfaceFixtures.now.subtract(
      const Duration(minutes: 18),
    ),
  ),
  MatchesChatSurfaceFixtures.message(
    id: 'host-inquiry-message-2',
    senderId: MatchesChatSurfaceFixtures.hostUid,
    text: 'Yes. Park near the jetty and meet us by the sea-facing steps.',
    sentAt: MatchesChatSurfaceFixtures.now.subtract(
      const Duration(minutes: 12),
    ),
  ),
];

List<Object> _hostInboxProviderOverrides({
  String? uid = MatchesChatSurfaceFixtures.hostUid,
  AsyncValue<ChatsListViewModel>? viewModel,
  List<Match>? matches,
  Object? matchesError,
}) {
  final effectiveMatches =
      matches ?? MatchesChatSurfaceFixtures.hostInquiryMatches;
  final effectiveViewModel =
      viewModel ??
      AsyncData<ChatsListViewModel>(
        _matchesListViewModelFor(
          uid: uid ?? MatchesChatSurfaceFixtures.hostUid,
          matches: effectiveMatches,
          hostMode: true,
        ),
      );

  return [
    uidProvider.overrideWithValue(AsyncData<String?>(uid)),
    chatsListViewModelProvider.overrideWithValue(effectiveViewModel),
    matchRepositoryProvider.overrideWithValue(
      MatchesChatFixtureMatchRepository(
        matches: effectiveMatches,
        matchesError: matchesError,
      ),
    ),
    if (uid != null)
      watchMatchesForUserProvider(uid).overrideWith((ref) {
        if (matchesError != null) {
          return Stream<List<Match>>.error(matchesError, StackTrace.empty);
        }
        return Stream<List<Match>>.value(effectiveMatches);
      }),
    watchClubProvider(
      MatchesChatSurfaceFixtures.club.id,
    ).overrideWith((ref) => Stream.value(MatchesChatSurfaceFixtures.club)),
    for (final profile in MatchesChatSurfaceFixtures.profiles.values)
      watchPublicProfileProvider(
        profile.uid,
      ).overrideWith((ref) => Stream.value(profile)),
  ];
}

List<Object> _hostChatProviderOverrides({
  String? uid = MatchesChatSurfaceFixtures.hostUid,
  Match? match,
  String? matchId,
  List<ChatMessage>? messages,
  bool matchLoading = false,
  Object? matchError,
  bool messagesLoading = false,
  Object? messagesError,
  bool includeEvent = true,
  bool includeClub = true,
}) {
  final effectiveMatch = match ?? _hostInquiryMatch;
  final id = matchId ?? effectiveMatch.id;
  final hasMatch = matchId == null || match != null;
  final effectiveMessages = messages ?? _hostInquiryMessages;
  final matchRepository = MatchesChatFixtureMatchRepository(
    matches: [if (hasMatch) effectiveMatch],
    matchById: {id: hasMatch ? effectiveMatch : null},
    matchError: matchError,
  );
  final conversationRepository = MatchesChatFixtureConversationRepository(
    messagesByConversationId: {id: effectiveMessages},
    loading: messagesLoading,
    messagesError: messagesError,
    failSends: true,
  );
  final effectiveEvent = includeEvent ? MatchesChatSurfaceFixtures.event : null;
  final effectiveClub = includeClub ? MatchesChatSurfaceFixtures.club : null;

  return [
    uidProvider.overrideWithValue(AsyncData<String?>(uid)),
    matchRepositoryProvider.overrideWithValue(matchRepository),
    conversationRepositoryProvider.overrideWithValue(conversationRepository),
    safetyRepositoryProvider.overrideWithValue(
      const MatchesChatFixtureSafetyRepository(),
    ),
    externalShareControllerProvider.overrideWithValue(
      ExternalShareController((_) async {}),
    ),
    matchStreamProvider(id).overrideWith((ref) {
      if (matchLoading) return MatchesChatSurfaceFixtures.loadingStream();
      if (matchError != null) {
        return Stream<Match?>.error(matchError, StackTrace.empty);
      }
      return Stream<Match?>.value(hasMatch ? effectiveMatch : null);
    }),
    watchConversationMessagesProvider(id).overrideWith(
      (ref) => conversationRepository.watchMessages(conversationId: id),
    ),
    watchClubProvider(
      MatchesChatSurfaceFixtures.club.id,
    ).overrideWith((ref) => Stream<Club?>.value(effectiveClub)),
    watchEventProvider(
      MatchesChatSurfaceFixtures.event.id,
    ).overrideWith((ref) => Stream<Event?>.value(effectiveEvent)),
    for (final profile in MatchesChatSurfaceFixtures.profiles.values)
      watchPublicProfileProvider(
        profile.uid,
      ).overrideWith((ref) => Stream.value(profile)),
  ];
}

Widget _hostChatCapture({Match? match, String? matchId}) {
  final effectiveMatch = match ?? _hostInquiryMatch;
  final id = matchId ?? effectiveMatch.id;
  return _AppRoleCapture(
    role: AppRole.host,
    child: ChatScreen(matchId: id),
  );
}

final _matchesCaptureConsumerMatches =
    MatchesChatSurfaceFixtures.populatedMatches;
final _matchesCaptureDuplicateMatches = <Match>[
  MatchesChatSurfaceFixtures.activeConversationMatch(
    id: 'design-match-taylor-older',
    preview: 'Earlier thread from the same event.',
    lastMessageAt: MatchesChatSurfaceFixtures.now.subtract(
      const Duration(hours: 5),
    ),
  ),
  MatchesChatSurfaceFixtures.activeConversationMatch(
    id: 'design-match-taylor-latest',
    preview: 'This row should win after duplicate collapse.',
    lastMessageAt: MatchesChatSurfaceFixtures.now.subtract(
      const Duration(minutes: 14),
    ),
  ),
  MatchesChatSurfaceFixtures.newMatch(),
];

NetworkException _matchesOfflineException({required String action}) {
  return MatchesChatSurfaceFixtures.offlineException(action: action);
}

List<Object> _matchesListProviderOverrides({
  String? uid = MatchesChatSurfaceFixtures.viewerUid,
  AsyncValue<ChatsListViewModel>? viewModel,
  List<Match>? matches,
  Object? matchesError,
}) {
  final effectiveMatches = matches ?? _matchesCaptureConsumerMatches;
  final effectiveViewModel =
      viewModel ??
      AsyncData<ChatsListViewModel>(
        _matchesListViewModelFor(
          uid: uid ?? MatchesChatSurfaceFixtures.viewerUid,
          matches: effectiveMatches,
        ),
      );
  final matchRepository = MatchesChatFixtureMatchRepository(
    matches: effectiveMatches,
    matchesError: matchesError,
  );

  return [
    uidProvider.overrideWithValue(AsyncData<String?>(uid)),
    chatsListViewModelProvider.overrideWithValue(effectiveViewModel),
    matchRepositoryProvider.overrideWithValue(matchRepository),
    if (uid != null)
      watchMatchesForUserProvider(uid).overrideWith((ref) {
        if (matchesError != null) {
          return Stream<List<Match>>.error(matchesError, StackTrace.empty);
        }
        return Stream<List<Match>>.value(effectiveMatches);
      }),
    watchEventProvider(MatchesChatSurfaceFixtures.eventId).overrideWith(
      (ref) => Stream<Event?>.value(MatchesChatSurfaceFixtures.event),
    ),
    watchClubProvider(MatchesChatSurfaceFixtures.clubId).overrideWith(
      (ref) => Stream<Club?>.value(MatchesChatSurfaceFixtures.club),
    ),
    ..._matchesPublicProfileOverrides,
  ];
}

ChatsListViewModel _matchesListViewModelFor({
  required String uid,
  required List<Match> matches,
  bool hostMode = false,
}) {
  final roleMatches = hostMode || AppConfig.appRole.isHost
      ? matches.where((match) => match.isClubHostInquiry).toList()
      : matches;
  final collapsed = collapseMatchesByOtherUser(roleMatches, uid);
  final newMatches = <ChatThreadPreview>[];
  final conversations = <ChatThreadPreview>[];

  for (final match in collapsed) {
    final preview = _matchesThreadPreviewFor(match: match, uid: uid);
    if (preview.hasConversation) {
      conversations.add(preview);
    } else {
      newMatches.add(preview);
    }
  }

  newMatches.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return ChatsListViewModel(
    newMatches: List.unmodifiable(newMatches),
    conversations: List.unmodifiable(conversations),
    totalThreadCount: collapsed.length,
  );
}

ChatThreadPreview _matchesThreadPreviewFor({
  required Match match,
  required String uid,
}) {
  final otherUid = match.otherId(uid);
  final profile = MatchesChatSurfaceFixtures.profileFor(otherUid);
  ClubHostProfile? hostProfile;
  if (match.isClubHostInquiry) {
    for (final host in MatchesChatSurfaceFixtures.club.displayHostProfiles) {
      if (host.uid == otherUid) {
        hostProfile = host;
        break;
      }
    }
  }

  final displayName = hostProfile?.displayName ?? profile.name;
  final hasConversation = match.lastMessagePreview != null;
  final previewText = !hasConversation
      ? match.isClubHostInquiry
            ? 'Ask the host'
            : 'You matched!'
      : match.lastMessageSenderId == uid
      ? 'You: ${match.lastMessagePreview}'
      : match.lastMessagePreview!;

  return ChatThreadPreview(
    match: match,
    matchId: match.id,
    otherUid: otherUid,
    displayName: displayName,
    photoUrl: hostProfile?.avatarUrl ?? profile.primaryPhotoThumbnailUrl,
    previewText: previewText,
    timestamp: match.lastMessageAt ?? match.createdAt,
    unreadCount: match.unreadConversationCountFor(uid),
    hasConversation: hasConversation,
    eventIds: match.eventIds,
  );
}

List<Object> _hostUnreadOnlyInboxProviderOverrides() {
  final matches = MatchesChatSurfaceFixtures.hostInquiryMatches
      .map((match) => match.copyWith(unreadCounts: const <String, int>{}))
      .toList(growable: false);
  return _hostInboxProviderOverrides(
    matches: matches,
    viewModel: AsyncData<ChatsListViewModel>(
      _matchesListViewModelFor(
        uid: MatchesChatSurfaceFixtures.hostUid,
        matches: matches,
        hostMode: true,
      ),
    ),
  );
}

List<Object> _hostUnreadFilteredInboxProviderOverrides() {
  final matches = MatchesChatSurfaceFixtures.hostInquiryMatches;
  return _hostInboxProviderOverrides(
    matches: matches,
    viewModel: AsyncData<ChatsListViewModel>(
      _matchesListViewModelFor(
        uid: MatchesChatSurfaceFixtures.hostUid,
        matches: matches,
        hostMode: true,
      ),
    ),
  );
}

List<Object> _hostInboxSearchEmptyProviderOverrides() {
  return _hostInboxProviderOverrides(
    viewModel: AsyncData<ChatsListViewModel>(
      ChatsListViewModel(
        newMatches: const <ChatThreadPreview>[],
        conversations: const <ChatThreadPreview>[],
        totalThreadCount: MatchesChatSurfaceFixtures.hostInquiryMatches.length,
      ),
    ),
  );
}

List<Object> _hostNewInquiryProviderOverrides() {
  final matches = [
    MatchesChatSurfaceFixtures.hostInquiryMatches.first.copyWith(
      id: 'design-host-inquiry-new',
      lastMessageAt: null,
      lastMessagePreview: null,
      lastMessageSenderId: null,
    ),
  ];
  return _hostInboxProviderOverrides(
    matches: matches,
    viewModel: AsyncData<ChatsListViewModel>(
      _matchesListViewModelFor(
        uid: MatchesChatSurfaceFixtures.hostUid,
        matches: matches,
        hostMode: true,
      ),
    ),
  );
}

List<Object> get _matchesPublicProfileOverrides {
  const uids = [
    MatchesChatSurfaceFixtures.taylorUid,
    MatchesChatSurfaceFixtures.morganUid,
    MatchesChatSurfaceFixtures.guestUid,
    'design-chat-guest-2',
    'design-chat-isha',
  ];

  return [
    for (final uid in uids)
      watchPublicProfileProvider(uid).overrideWith(
        (ref) => Stream<PublicProfile?>.value(
          MatchesChatSurfaceFixtures.profileFor(uid),
        ),
      ),
  ];
}

Widget _matchesListCapture({
  String searchQuery = '',
  AppRole role = AppRole.consumer,
  Widget child = const ChatsListScreen(),
}) {
  return _AppRoleCapture(
    role: role,
    child: _ChatSearchQuerySeed(query: searchQuery, child: child),
  );
}

class _ChatSearchQuerySeed extends ConsumerStatefulWidget {
  const _ChatSearchQuerySeed({required this.query, required this.child});

  final String query;
  final Widget child;

  @override
  ConsumerState<_ChatSearchQuerySeed> createState() =>
      _ChatSearchQuerySeedState();
}

class _ChatSearchQuerySeedState extends ConsumerState<_ChatSearchQuerySeed> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(chatSearchQueryProvider.notifier);
      if (widget.query.isEmpty) {
        notifier.clear();
      } else {
        notifier.setQuery(widget.query);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _HostUnreadOnlyInboxCapture extends StatelessWidget {
  const _HostUnreadOnlyInboxCapture();

  @override
  Widget build(BuildContext context) {
    return _AppRoleCapture(
      role: AppRole.host,
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              ...ChatsSliverHeader(
                hostFilter: HostInboxFilter.unread,
                onHostFilterChanged: (_) {},
              ).buildSlivers(context),
              const ChatsList(hostFilter: HostInboxFilter.unread),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchCelebrationCapture extends StatelessWidget {
  const _MatchCelebrationCapture();

  @override
  Widget build(BuildContext context) {
    final match = MatchesChatSurfaceFixtures.activeConversationMatch();
    return MatchCelebrationDialog(
      match: match,
      otherUid: match.otherId(MatchesChatSurfaceFixtures.viewerUid),
      onSendMessage: () {},
      onKeepSwiping: () {},
    );
  }
}

List<Object> _matchChatProviderOverrides({
  String? uid = MatchesChatSurfaceFixtures.viewerUid,
  Match? match,
  String? matchId,
  List<ChatMessage>? messages,
  bool messagesLoading = false,
  Object? messagesError,
  Object? matchError,
  Event? event,
  bool includeEvent = true,
  SuvbotRepository suvbotRepository =
      const MatchesChatFixtureSuvbotRepository(),
}) {
  final effectiveMatch =
      match ?? MatchesChatSurfaceFixtures.activeConversationMatch();
  final id = matchId ?? effectiveMatch.id;
  final effectiveMessages =
      messages ?? MatchesChatSurfaceFixtures.conversationMessages;
  final matchRepository = MatchesChatFixtureMatchRepository(
    matches: [if (matchId == null || match != null) effectiveMatch],
    matchById: {id: matchId == null || match != null ? effectiveMatch : null},
    matchError: matchError,
  );
  final conversationRepository = MatchesChatFixtureConversationRepository(
    messagesByConversationId: {id: effectiveMessages},
    loading: messagesLoading,
    messagesError: messagesError,
    failSends: true,
  );
  final effectiveEvent = includeEvent
      ? event ?? MatchesChatSurfaceFixtures.event
      : null;

  return [
    uidProvider.overrideWithValue(AsyncData<String?>(uid)),
    matchRepositoryProvider.overrideWithValue(matchRepository),
    conversationRepositoryProvider.overrideWithValue(conversationRepository),
    suvbotRepositoryProvider.overrideWithValue(suvbotRepository),
    safetyRepositoryProvider.overrideWithValue(
      const MatchesChatFixtureSafetyRepository(),
    ),
    externalShareControllerProvider.overrideWithValue(
      ExternalShareController((_) async {}),
    ),
    matchStreamProvider(id).overrideWith((ref) {
      if (matchError != null) {
        return Stream<Match?>.error(matchError, StackTrace.empty);
      }
      return Stream<Match?>.value(
        matchId == null || match != null ? effectiveMatch : null,
      );
    }),
    watchConversationMessagesProvider(id).overrideWith(
      (ref) => conversationRepository.watchMessages(conversationId: id),
    ),
    watchEventProvider(
      MatchesChatSurfaceFixtures.eventId,
    ).overrideWith((ref) => Stream<Event?>.value(effectiveEvent)),
    watchClubProvider(MatchesChatSurfaceFixtures.clubId).overrideWith(
      (ref) => Stream<Club?>.value(MatchesChatSurfaceFixtures.club),
    ),
    ..._matchesPublicProfileOverrides,
  ];
}

Widget _matchChatCapture({
  Match? match,
  String? matchId,
  PublicProfile? initialProfile,
  AppRole role = AppRole.consumer,
  bool includeInitialProfile = true,
}) {
  final effectiveMatch =
      match ?? MatchesChatSurfaceFixtures.activeConversationMatch();
  final id = matchId ?? effectiveMatch.id;
  return _AppRoleCapture(
    role: role,
    child: ChatScreen(
      matchId: id,
      otherProfile: !includeInitialProfile || role == AppRole.host
          ? null
          : initialProfile ??
                MatchesChatSurfaceFixtures.profileFor(
                  effectiveMatch.otherId(MatchesChatSurfaceFixtures.viewerUid),
                ),
    ),
  );
}

class _ChatShareCardCapture extends StatelessWidget {
  const _ChatShareCardCapture();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ChatShareCardSheet(
            messages: MatchesChatSurfaceFixtures.conversationMessages,
            currentUid: MatchesChatSurfaceFixtures.viewerUid,
            event: MatchesChatSurfaceFixtures.event,
            share: ExternalShareController((_) async {}),
          ),
        ),
      ),
    );
  }
}

class _ChatComposerStatesCapture extends StatefulWidget {
  const _ChatComposerStatesCapture({this.role = AppRole.consumer});

  final AppRole role;

  @override
  State<_ChatComposerStatesCapture> createState() =>
      _ChatComposerStatesCaptureState();
}

class _ChatComposerStatesCaptureState
    extends State<_ChatComposerStatesCapture> {
  late final TextEditingController _readyController;
  late final TextEditingController _sendingController;
  late final TextEditingController _imagePendingController;
  late final TextEditingController _disabledController;

  @override
  void initState() {
    super.initState();
    _readyController = TextEditingController(text: 'That last loop was fun.');
    _sendingController = TextEditingController(text: 'Sending this now...');
    _imagePendingController = TextEditingController(
      text: 'Uploading a photo...',
    );
    _disabledController = TextEditingController();
  }

  @override
  void dispose() {
    _readyController.dispose();
    _sendingController.dispose();
    _imagePendingController.dispose();
    _disabledController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppRoleCapture(
      role: widget.role,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              ChatInputBar(
                controller: _readyController,
                sending: false,
                onSend: () {},
                onSendImage: () {},
              ),
              const SizedBox(height: 12),
              ChatInputBar(
                controller: _sendingController,
                sending: true,
                onSend: () {},
                onSendImage: () {},
              ),
              const SizedBox(height: 12),
              ChatInputBar(
                controller: _imagePendingController,
                sending: false,
                sendingImage: true,
                onSend: () {},
                onSendImage: () {},
              ),
              const SizedBox(height: 12),
              ChatInputBar(
                controller: _disabledController,
                sending: false,
                disabledReason: 'This chat is closed.',
                onSend: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _hostEvent = _captureFixtures.hostDemoEvent(
  role: 'hostLiveConsole',
  club: _dashboardHostClub,
);
final _hostLiveWindowNow = DateTime.now();
final _hostLiveWindowEvent = _hostEvent.copyWith(
  startTime: _hostLiveWindowNow.subtract(const Duration(minutes: 45)),
  endTime: _hostLiveWindowNow.add(const Duration(minutes: 45)),
);
final _hostEventSetupDraft = _captureFixtures.hostSetupDraft(
  id: 'host-event-setup-capture-draft',
  club: _dashboardHostClub,
  savedAt: _captureNow,
);
final _hostEventCustomActivityDraft = _hostEventSetupDraft.copyWith(
  id: 'host-event-custom-activity-capture-draft',
  activityKind: 'openActivity',
  customActivityLabel: 'Salsa mixer',
  interactionModel: 'hostLedProgram',
  distance: null,
  paceName: null,
);
final _hostGuestProfiles = _captureFixtures.rosterProfiles(
  count: (_hostEvent.bookedCount ?? 0) + (_hostEvent.waitlistedCount ?? 0),
);
final _hostParticipations = _captureFixtures.participationsForProfiles(
  event: _hostEvent,
  profiles: _hostGuestProfiles,
  attendedCount:
      _hostEvent.checkedInCount ?? salesDemoHostScenario.defaultCheckedInCount,
  waitlistedCount:
      _hostEvent.waitlistedCount ??
      salesDemoHostScenario.defaultWaitlistedCount,
  createdAt: DateTime(2026, 5, 28, 10),
);
final _hostParticipationRepository = FakeEventParticipationRepository()
  ..eventParticipations[_hostEvent.id] = _hostParticipations;
final _hostPublicProfileRepository = FakePublicProfileRepository()
  ..profiles = _hostGuestProfiles;
final _hostAttendeeIds = [
  for (final participation in _hostParticipations)
    if (participation.status != EventParticipationStatus.waitlisted)
      participation.uid,
];
final _hostWaitlistedIds = [
  for (final participation in _hostParticipations)
    if (participation.status == EventParticipationStatus.waitlisted)
      participation.uid,
];
final _hostProfileIds = [
  for (final participation in _hostParticipations) participation.uid,
];
final _hostProfileRows = <String, (String, String?)>{
  for (final profile in _hostGuestProfiles)
    profile.uid: (profile.name, profile.primaryPhotoThumbnailUrl),
};
final _hostAttendanceViewModel = AttendanceSheetViewModel(
  event: _hostEvent,
  attendeeIds: _hostAttendeeIds,
  attendedIds: {
    for (final participation in _hostParticipations)
      if (participation.status == EventParticipationStatus.attended)
        participation.uid,
  },
  waitlistedIds: _hostWaitlistedIds,
  profileIds: _hostProfileIds,
  participationsByUid: {
    for (final participation in _hostParticipations)
      participation.uid: participation,
  },
);
final _hostLivePlan =
    EventSuccessPlan.defaultForEvent(_hostEvent, now: _captureNow).copyWith(
      activeStepIndex: 1,
      status: EventSuccessPlanStatus.live,
      frozenAt: _captureNow,
    );
final _hostLiveReferenceClub = _dashboardHostClub.copyWith(
  name: 'Bandra Social',
);
final _hostManageReferenceClub = _hostLiveReferenceClub.copyWith(
  ownerUserId: _captureViewerUid,
  hostUserId: _captureViewerUid,
  hostUserIds: const [_captureViewerUid],
  hostProfiles: const [
    ClubHostProfile(
      uid: _captureViewerUid,
      displayName: 'Mira Shah',
      role: ClubHostRole.owner,
    ),
  ],
);
final _hostManageReferenceEvent = _hostEvent.copyWith(
  id: 'host-manage-reference-trivia',
  clubId: _hostManageReferenceClub.id,
  startTime: DateTime(2026, 6, 9, 20),
  endTime: DateTime(2026, 6, 9, 22),
  meetingPoint: 'The Daily Bar',
  meetingLocation: const EventMeetingLocation(
    name: 'The Daily Bar',
    address: 'Bandra West, Mumbai',
    latitude: 19.0607,
    longitude: 72.8362,
  ),
  locationDetails: 'The Daily Bar',
  eventFormat: EventFormatSnapshot.custom(
    label: 'trivia night',
    interactionModel: EventInteractionModel.teamRotations,
  ),
  distanceKm: 0,
  bookedCount: 24,
  checkedInCount: 0,
  waitlistedCount: 6,
  capacityLimit: 30,
  priceInPaise: 0,
  eventPolicy: EventPolicyBundle.inviteOnlyEvent(
    capacityLimit: 30,
    basePriceInPaise: 0,
    inviteCodeHint: 'BANDRA',
  ),
);
final _hostTodayReferenceClub = _hostManageReferenceClub.copyWith(
  id: 'host-home-reference-bandra-social',
  name: 'Bandra Social',
  area: 'Khar',
  location: 'Mumbai',
  ownerUserId: HostOperationsFixtures.hostUid,
  hostUserId: HostOperationsFixtures.hostUid,
  hostUserIds: const [HostOperationsFixtures.hostUid],
  hostProfiles: const [
    ClubHostProfile(
      uid: HostOperationsFixtures.hostUid,
      displayName: 'Aanya Rao',
      role: ClubHostRole.owner,
    ),
  ],
  hostDefaults: const ClubHostDefaults(
    primaryActivityKind: ActivityKind.pubQuiz,
    supportedActivityKinds: [ActivityKind.pubQuiz],
  ),
);
final _hostTodayReferenceEvent = _hostManageReferenceEvent.copyWith(
  id: 'host-home-reference-trivia',
  clubId: _hostTodayReferenceClub.id,
  eventFormat: const EventFormatSnapshot(
    activityKind: ActivityKind.pubQuiz,
    interactionModel: EventInteractionModel.teamRotations,
    customActivityLabel: 'Trivia Night',
  ),
);
final _hostManageFullReferenceEvent = _hostManageReferenceEvent.copyWith(
  id: 'host-manage-reference-trivia-full',
  waitlistedCohortCounts: const {EventCohortIds.womenInterestedInMen: 6},
);
final _hostManageReferenceProfiles = _captureFixtures.rosterProfiles(count: 30);
final _hostManageReferenceParticipations = _captureFixtures
    .participationsForProfiles(
      event: _hostManageReferenceEvent,
      profiles: _hostManageReferenceProfiles,
      waitlistedCount: 6,
      createdAt: DateTime(2026, 6, 8, 16),
    );
final _hostManageFullReferenceParticipations = [
  for (final participation in _hostManageReferenceParticipations)
    participation.copyWith(eventId: _hostManageFullReferenceEvent.id),
];
final _hostClubDetailReferenceClub = HostOperationsFixtures.primaryClub.copyWith(
  name: 'Sunday sea-face crew',
  description:
      'The standing Saturday run - an easy 5K along the Bandra seafront as the light goes gold, coffee and bun maska after. No medals, no Strava pressure. Just show up, move, linger.',
  location: 'in-mh-mumbai',
  locationCityId: 'in-mh-mumbai',
  locationMarketId: 'in-mh-mumbai',
  area: 'Bandra',
  imageUrl: _clubHeroPortraitAssetPath,
  profileImageUrl: _clubHeroPortraitAssetPath,
  clubPhotos: [
    _hostClubDetailPhoto('club-detail-run-1', 0),
    _hostClubDetailPhoto('club-detail-run-2', 1),
    _hostClubDetailPhoto('club-detail-run-3', 2),
  ],
  tags: const ['Beginners ok', 'Coffee after'],
  memberCount: 124,
  rating: 4.7,
  reviewCount: 23,
  createdAt: DateTime(2025, 1, 12),
  nextEventAt: DateTime(2025, 6, 14, 6, 30),
  nextEventLabel: 'Sat 6:30 AM',
  instagramHandle: '@sundayseaface',
  phoneNumber: '+91 98200 11223',
  email: 'hello@seafacecrew.in',
  hostProfiles: const [
    ClubHostProfile(
      uid: HostOperationsFixtures.hostUid,
      displayName: 'Priya Kapoor',
      avatarUrl: _clubHeroPortraitAssetPath,
      role: ClubHostRole.owner,
    ),
    ClubHostProfile(
      uid: HostOperationsFixtures.coHostUid,
      displayName: 'Arjun Mehta',
    ),
    ClubHostProfile(uid: 'design-host-sana', displayName: 'Sana Iyer'),
  ],
  hostDefaults: const ClubHostDefaults(
    supportedActivityKinds: [ActivityKind.running, ActivityKind.walking],
  ),
);
final _hostEditClubReferenceClub = _hostClubDetailReferenceClub.copyWith(
  id: 'host-edit-club-reference',
  description: 'Dawn runs along the Bandra seafront every Sunday, then coffee.',
  ownerUserId: HostOperationsFixtures.hostUid,
  hostUserId: HostOperationsFixtures.hostUid,
  hostUserIds: const [HostOperationsFixtures.hostUid],
  instagramHandle: 'sundayseaface',
  clubPhotos: [
    _hostClubDetailPhoto('host-edit-club-1', 0),
    _hostClubDetailPhoto('host-edit-club-2', 1),
    _hostClubDetailPhoto('host-edit-club-3', 2),
    _hostClubDetailPhoto('host-edit-club-4', 3),
  ],
);
final _hostClubDetailReferenceEvents = [
  _hostEvent.copyWith(
    id: 'host-club-detail-run-14',
    clubId: _hostClubDetailReferenceClub.id,
    startTime: DateTime(2025, 6, 14, 6, 30),
    endTime: DateTime(2025, 6, 14, 8),
    meetingPoint: 'Carter Road jetty',
    meetingLocation: const EventMeetingLocation(
      name: 'Carter Road jetty',
      address: 'Carter Road, Bandra West',
      latitude: 19.0702,
      longitude: 72.8228,
    ),
    locationDetails: 'Meet by the jetty',
    eventFormat: const EventFormatSnapshot.socialRun(),
    distanceKm: 5,
    pace: PaceLevel.easy,
    bookedCount: 12,
    capacityLimit: 16,
    priceInPaise: 0,
    description: 'An easy 5K along the Bandra seafront with coffee after.',
  ),
  _hostEvent.copyWith(
    id: 'host-club-detail-run-15',
    clubId: _hostClubDetailReferenceClub.id,
    startTime: DateTime(2025, 6, 21, 6, 30),
    endTime: DateTime(2025, 6, 21, 8),
    meetingPoint: 'Carter Road jetty',
    eventFormat: const EventFormatSnapshot.socialRun(),
    distanceKm: 5,
    pace: PaceLevel.easy,
    bookedCount: 8,
    capacityLimit: 16,
    priceInPaise: 0,
  ),
  _hostEvent.copyWith(
    id: 'host-club-detail-run-16',
    clubId: _hostClubDetailReferenceClub.id,
    startTime: DateTime(2025, 6, 28, 6, 30),
    endTime: DateTime(2025, 6, 28, 8),
    meetingPoint: 'Carter Road jetty',
    eventFormat: const EventFormatSnapshot.socialRun(),
    distanceKm: 5,
    pace: PaceLevel.easy,
    bookedCount: 0,
    capacityLimit: 16,
    priceInPaise: 0,
  ),
];

UploadedPhoto _hostClubDetailPhoto(String id, int position) {
  return UploadedPhoto(
    id: id,
    url: _clubHeroPortraitAssetPath,
    storagePath: 'fixtures/$id.jpg',
    thumbnailUrl: _clubHeroPortraitAssetPath,
    thumbnailStoragePath: 'fixtures/$id-thumb.jpg',
    position: position,
    createdAt: DateTime(2025, 1, 12),
    updatedAt: DateTime(2025, 1, 12),
  );
}

final _hostCreateSuccessReferenceClub = _dashboardHostClub.copyWith(
  name: 'Sunday sea-face crew',
);
final _hostCreateSuccessReferenceEvent = _hostEvent.copyWith(
  clubId: _hostCreateSuccessReferenceClub.id,
  startTime: DateTime(2025, 6, 22, 6, 30),
  endTime: DateTime(2025, 6, 22, 8),
  meetingPoint: 'Carter Road jetty, Bandra West',
  meetingLocation: const EventMeetingLocation(
    name: 'Carter Road jetty, Bandra West',
    address: 'Carter Road, Bandra West',
    latitude: 19.0702,
    longitude: 72.8228,
  ),
  locationDetails: 'Meet by the jetty',
  eventFormat: const EventFormatSnapshot.socialRun(),
  distanceKm: 5,
  pace: PaceLevel.easy,
  capacityLimit: 10,
  bookedCount: 0,
  checkedInCount: 0,
  waitlistedCount: 0,
);
final _hostLiveReferenceEvent = _hostEvent.copyWith(
  startTime: DateTime(2026, 6, 9, 20),
  endTime: DateTime(2026, 6, 9, 22),
  meetingPoint: 'The Daily Bar',
  locationDetails: 'The Daily Bar',
  eventFormat: EventFormatSnapshot.custom(
    label: 'trivia night',
    interactionModel: EventInteractionModel.teamRotations,
  ),
  distanceKm: 0,
  bookedCount: 24,
  checkedInCount: 18,
  waitlistedCount: 0,
  capacityLimit: 30,
);
final _hostLiveReferenceProfiles = _captureFixtures.rosterProfiles(count: 24);
final _hostLiveReferenceParticipations = _captureFixtures
    .participationsForProfiles(
      event: _hostLiveReferenceEvent,
      profiles: _hostLiveReferenceProfiles,
      attendedCount: 18,
      createdAt: DateTime(2026, 6, 9, 18),
    );
final _hostLiveReferenceParticipationRepository =
    FakeEventParticipationRepository()
      ..eventParticipations[_hostLiveReferenceEvent.id] =
          _hostLiveReferenceParticipations;
final _hostLiveReferencePublicProfileRepository = FakePublicProfileRepository()
  ..profiles = _hostLiveReferenceProfiles;
final _hostLiveReferencePlan =
    EventSuccessPlan.defaultForEvent(
      _hostLiveReferenceEvent,
      now: _captureNow,
    ).copyWith(
      activeStepIndex: 1,
      status: EventSuccessPlanStatus.live,
      frozenAt: _captureNow,
    );
final _hostLiveWindowPlan =
    EventSuccessPlan.defaultForEvent(
      _hostLiveWindowEvent,
      now: _hostLiveWindowNow,
    ).copyWith(
      activeStepIndex: 1,
      status: EventSuccessPlanStatus.live,
      frozenAt: _hostLiveWindowNow,
    );
final _hostReportPlan = _hostLivePlan.copyWith(
  status: EventSuccessPlanStatus.complete,
  activeStepIndex: 3,
  completedAt: _captureNow.add(const Duration(hours: 2)),
);
final _hostReportScorecard = _hostDemoScorecard(
  salesDemoHostScenario.eventByRole('hostPostEventReport').scorecard!,
);

EventSuccessScorecard _hostDemoScorecard(
  SalesDemoHostScorecardFixture fixture,
) {
  return EventSuccessScorecard(
    bookedCount: fixture.intValue('bookedCount'),
    checkedInCount: fixture.intValue('checkedInCount'),
    attendeesWhoMetTwoPlusPeople: fixture.intValue(
      'attendeesWhoMetTwoPlusPeople',
    ),
    mutualMatchCount: fixture.intValue('mutualMatchCount'),
    chatStartedCount: fixture.intValue('chatStartedCount'),
    averageWelcomeRating: fixture.doubleValue('averageWelcomeRating'),
    averageStructureRating: fixture.doubleValue('averageStructureRating'),
    safetyIncidentCount: fixture.intValue('safetyIncidentCount'),
    catchSentCount: fixture.intValue('catchSentCount'),
    attendeesWhoCaughtSomeone: fixture.intValue('attendeesWhoCaughtSomeone'),
    catchRecipientCount: fixture.intValue('catchRecipientCount'),
    catchRate: fixture.doubleValue('catchRate'),
    feedbackResponseCount: fixture.intValue('feedbackResponseCount'),
    assignmentParticipantCount: fixture.intValue('assignmentParticipantCount'),
    assignmentOptOutCount: fixture.intValue('assignmentOptOutCount'),
    wingmanRequestCount: fixture.intValue('wingmanRequestCount'),
    funnel: _hostDemoFunnel(fixture.mapValue('funnel')),
  );
}

EventSuccessHostFunnel _hostDemoFunnel(Map<String, Object?>? json) {
  if (json == null) return EventSuccessHostFunnel.empty;
  return EventSuccessHostFunnel(
    inviteLinkCount: _fixtureInt(json, 'inviteLinkCount'),
    inviteOpenCount: _fixtureInt(json, 'inviteOpenCount'),
    totalDemandCount: _fixtureInt(json, 'totalDemandCount'),
    requestCount: _fixtureInt(json, 'requestCount'),
    pendingRequestCount: _fixtureInt(json, 'pendingRequestCount'),
    approvedRequestCount: _fixtureInt(json, 'approvedRequestCount'),
    declinedRequestCount: _fixtureInt(json, 'declinedRequestCount'),
    directSignupCount: _fixtureInt(json, 'directSignupCount'),
    waitlistJoinCount: _fixtureInt(json, 'waitlistJoinCount'),
    waitlistOfferCount: _fixtureInt(json, 'waitlistOfferCount'),
    waitlistOfferActiveCount: _fixtureInt(json, 'waitlistOfferActiveCount'),
    waitlistOfferAcceptedCount: _fixtureInt(json, 'waitlistOfferAcceptedCount'),
    waitlistOfferDeclinedCount: _fixtureInt(json, 'waitlistOfferDeclinedCount'),
    waitlistOfferExpiredCount: _fixtureInt(json, 'waitlistOfferExpiredCount'),
    checkoutStartedCount: _fixtureInt(json, 'checkoutStartedCount'),
    paymentPendingCount: _fixtureInt(json, 'paymentPendingCount'),
    paymentCompletedCount: _fixtureInt(json, 'paymentCompletedCount'),
    paymentFailedCount: _fixtureInt(json, 'paymentFailedCount'),
    paymentRefundedCount: _fixtureInt(json, 'paymentRefundedCount'),
    bookedCount: _fixtureInt(json, 'bookedCount'),
    checkedInCount: _fixtureInt(json, 'checkedInCount'),
    noShowCount: _fixtureInt(json, 'noShowCount'),
    catchSentCount: _fixtureInt(json, 'catchSentCount'),
    attendeesWhoCaughtSomeone: _fixtureInt(json, 'attendeesWhoCaughtSomeone'),
    mutualMatchCount: _fixtureInt(json, 'mutualMatchCount'),
    chatStartedCount: _fixtureInt(json, 'chatStartedCount'),
    repeatAttendeeCount: _fixtureInt(json, 'repeatAttendeeCount'),
  );
}

int _fixtureInt(Map<String, Object?> json, String key) {
  final value = json[key];
  return value is num ? value.round() : 0;
}

final _hostEventSuccessProviderOverrides = [
  watchEventSuccessAssignmentsProvider(
    _hostEvent.id,
  ).overrideWith((ref) => Stream.value(const <EventSuccessAssignment>[])),
  watchEventSuccessRotationAssignmentsProvider(
    _hostEvent.id,
  ).overrideWith((ref) => Stream.value(const <EventSuccessAssignment>[])),
  watchEventSuccessPreferencesProvider(
    _hostEvent.id,
  ).overrideWith((ref) => Stream.value(const <EventSuccessPreference>[])),
  watchEventSuccessWingmanRequestsProvider(
    _hostEvent.id,
  ).overrideWith((ref) => Stream.value(const <EventSuccessWingmanRequest>[])),
  attendanceSheetViewModelProvider(
    _hostEvent.id,
  ).overrideWithValue(AsyncData(_hostAttendanceViewModel)),
  attendeeProfilesProvider(
    _hostProfileIds,
  ).overrideWith((ref) async => _hostProfileRows),
];

final _matchesListProfiles = [
  _matchChatOtherProfile,
  _captureFixtures.publicProfile('nyc_sofia_martinez_003'),
  _captureFixtures.publicProfile('nyc_priya_desai_007'),
];
final _matchesListMatches = [
  _matchChatMatch,
  Match(
    id: 'match-list-new-sofia',
    user1Id: _matchChatViewerUid,
    user2Id: _matchesListProfiles[1].uid,
    eventIds: ['event-discovery-pickle-open'],
    createdAt: DateTime(2026, 5, 30, 19, 12),
    unreadCounts: const {_matchChatViewerUid: 0},
  ),
  Match(
    id: 'match-list-priya',
    user1Id: _matchesListProfiles[2].uid,
    user2Id: _matchChatViewerUid,
    eventIds: ['event-dashboard-next'],
    createdAt: DateTime(2026, 5, 30, 8, 55),
    lastMessageAt: DateTime(2026, 5, 30, 10, 8),
    lastMessagePreview: 'Next dawn loop, same coffee place?',
    lastMessageSenderId: _matchesListProfiles[2].uid,
    unreadCounts: const {_matchChatViewerUid: 2},
  ),
];
final _matchesListMatchRepository = _CaptureMatchRepository(
  matches: _matchesListMatches,
);

final _eventSuccessCompanionEvent = buildEvent(
  id: 'event-success-companion-capture',
  clubId: _dashboardJoinedClub.id,
  startTime: DateTime(2026, 5, 31, 9, 20),
  endTime: DateTime(2026, 5, 31, 10, 30),
  meetingPoint: 'Bandra Fort gate',
  bookedCount: 18,
  checkedInCount: 0,
  capacityLimit: 22,
  description:
      'A live event guide for arrivals, prompts, and post-run openers.',
);
final _eventSuccessCompanionPlan = EventSuccessPlan.defaultForEvent(
  _eventSuccessCompanionEvent,
  now: _captureNow,
);
final _eventSuccessCompanionParticipation = buildEventParticipation(
  event: _eventSuccessCompanionEvent,
  uid: _captureViewerUid,
  createdAt: DateTime(2026, 5, 29, 9),
);

List<Object> _eventSuccessCompanionRouteProviderOverrides({
  AsyncValue<String?> uidValue = const AsyncData<String?>(_captureViewerUid),
  AsyncValue<Event?>? eventValue,
  AsyncValue<UserProfile?>? profileValue,
  AsyncValue<EventParticipation?>? participationValue,
  AsyncValue<EventSuccessPlan?>? planValue,
}) {
  return [
    uidProvider.overrideWithValue(uidValue),
    watchEventProvider(_eventSuccessCompanionEvent.id).overrideWithValue(
      eventValue ?? AsyncData<Event?>(_eventSuccessCompanionEvent),
    ),
    watchUserProfileProvider.overrideWithValue(
      profileValue ?? AsyncData<UserProfile?>(_captureViewer),
    ),
    watchEventParticipationProvider(
      _eventSuccessCompanionEvent.id,
      _captureViewerUid,
    ).overrideWithValue(
      participationValue ??
          AsyncData<EventParticipation?>(_eventSuccessCompanionParticipation),
    ),
    watchEventSuccessPlanProvider(
      _eventSuccessCompanionEvent.id,
    ).overrideWithValue(
      planValue ?? AsyncData<EventSuccessPlan?>(_eventSuccessCompanionPlan),
    ),
    eventSuccessCompanionClockProvider.overrideWithValue(
      AsyncData<DateTime>(_captureNow),
    ),
    eventSuccessLiveEffectsControllerProvider.overrideWith(
      (ref) => _NoopEventSuccessLiveEffectsController(),
    ),
  ];
}

List<Object> _eventSuccessCompanionProviderOverrides() => [
  uidProvider.overrideWithValue(
    const AsyncData<String?>(EventSuccessCompanionFixtures.viewerUid),
  ),
  eventSuccessLiveEffectsControllerProvider.overrideWith(
    (ref) => _NoopEventSuccessLiveEffectsController(),
  ),
];

Widget _eventSuccessCompanionCapture({
  Event? event,
  EventSuccessPlan? plan,
  EventParticipation? participation,
  List<PublicProfile> wingmanRequestCandidates = const [],
  EventSuccessWingmanRequest? wingmanRequest,
  EventSuccessCompatibilityResponse? compatibilityResponse,
  EventSuccessFeedback? existingFeedback,
  EventSuccessAssignment? assignment,
  List<PublicProfile> assignmentPeerProfiles = const [],
  bool assignmentPeersLoading = false,
  bool microPodsOptedOut = false,
  EventSuccessAssignment? rotationAssignment,
  List<PublicProfile> rotationPeerProfiles = const [],
  bool rotationPeersLoading = false,
  bool guidedRotationsOptedOut = false,
  EventSuccessArrivalMission? arrivalMission,
  DateTime? now,
  Future<void> Function(List<String> answerIds)? onSaveCompatibilityAnswers,
  Future<void> Function()? onStartArrivalMission,
  Future<void> Function(EventSuccessArrivalMission mission, String answerId)?
  onCompleteArrivalMission,
  VoidCallback? onSkipArrivalMission,
}) {
  final resolvedEvent = event ?? EventSuccessCompanionFixtures.socialEvent;
  return EventSuccessCompanionScreen(
    event: resolvedEvent,
    plan: plan ?? EventSuccessCompanionFixtures.basePlan,
    userProfile: EventSuccessCompanionFixtures.viewer,
    participation:
        participation ??
        EventSuccessCompanionFixtures.signedUpParticipation(
          event: resolvedEvent,
        ),
    wingmanRequestCandidates: wingmanRequestCandidates,
    wingmanRequest: wingmanRequest,
    compatibilityResponse: compatibilityResponse,
    existingFeedback: existingFeedback,
    assignment: assignment,
    assignmentPeerProfiles: assignmentPeerProfiles,
    assignmentPeersLoading: assignmentPeersLoading,
    microPodsOptedOut: microPodsOptedOut,
    rotationAssignment: rotationAssignment,
    rotationPeerProfiles: rotationPeerProfiles,
    rotationPeersLoading: rotationPeersLoading,
    guidedRotationsOptedOut: guidedRotationsOptedOut,
    arrivalMission: arrivalMission,
    now: now,
    onSaveCompatibilityAnswers: onSaveCompatibilityAnswers,
    onStartArrivalMission: onStartArrivalMission,
    onCompleteArrivalMission: onCompleteArrivalMission,
    onSkipArrivalMission: onSkipArrivalMission,
  );
}

NetworkException _eventSuccessCompanionOfflineException({
  required String action,
}) {
  return obviousOfflineException(
    context: BackendErrorContext(
      service: BackendService.firestore,
      action: action,
      resource: 'eventSuccessCompanion',
    ),
  );
}

final _reviewHistoryEvents = [
  _captureFixtures.captureEvent(
    id: 'event-review-history-dawn',
    club: _dashboardJoinedClub,
    startTime: DateTime(2026, 5, 24, 7),
    endTime: DateTime(2026, 5, 24, 8, 10),
    meetingPoint: 'Carter Road Amphitheatre',
    bookedCount: 18,
    checkedInCount: 16,
    capacityLimit: 22,
    description: 'A completed social run with a warm review.',
  ),
  _captureFixtures.captureEvent(
    id: 'event-review-history-table',
    club: _dashboardHostClub,
    startTime: DateTime(2026, 5, 18, 20),
    endTime: DateTime(2026, 5, 18, 22),
    meetingPoint: 'Pali Village Cafe',
    activityKind: ActivityKind.dinner,
    distanceKm: 0,
    checkedInCount: 12,
    capacityLimit: 16,
    priceInPaise: 120000,
    description: 'A hosted table with structured prompts and warm exits.',
  ),
  _captureFixtures.captureEvent(
    id: 'event-review-history-walk',
    club: _dashboardJoinedClub,
    startTime: DateTime(2026, 5, 11, 8),
    endTime: DateTime(2026, 5, 11, 9),
    meetingPoint: 'Bandra Fort gate',
    activityKind: ActivityKind.walking,
    distanceKm: 3,
    bookedCount: 20,
    checkedInCount: 18,
    capacityLimit: 28,
    description: 'A low-pressure walk with a coffee handoff after.',
  ),
];
final _reviewHistoryReviews = _captureFixtures.reviewsByViewer(
  events: _reviewHistoryEvents,
  reviewerUserId: _captureViewerUid,
  reviewerName: _captureViewer.name,
  firstCreatedAt: DateTime(2026, 5, 25),
);
final _reviewHistoryMissingContextReviews = [
  Review(
    id: 'review-history-missing-event',
    clubId: _dashboardJoinedClub.id,
    eventId: 'event-review-history-missing',
    reviewerUserId: _captureViewerUid,
    reviewerName: _captureViewer.name,
    rating: 4,
    comment: 'Still worth remembering, even without event context.',
    createdAt: DateTime(2026, 5, 12),
  ),
  Review(
    id: 'review-history-legacy-club',
    clubId: _dashboardJoinedClub.id,
    reviewerUserId: _captureViewerUid,
    reviewerName: _captureViewer.name,
    rating: 5,
    comment: 'A legacy club review with no event attached.',
    createdAt: DateTime(2026, 5, 5),
  ),
];

List<Object> _reviewsHistoryProviderOverrides({
  AsyncValue<String?> uid = const AsyncData(_captureViewerUid),
  Stream<UserProfile?>? profileStream,
  AsyncValue<List<Review>>? reviews,
  AsyncValue<List<Event>>? events,
}) {
  final effectiveReviews = reviews ?? AsyncData(_reviewHistoryReviews);
  final overrides = <Object>[
    uidProvider.overrideWithValue(uid),
    watchUserProfileProvider.overrideWith(
      (ref) => profileStream ?? Stream.value(_captureViewer),
    ),
  ];
  final viewerUid = switch (uid) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (viewerUid == null) return overrides;

  overrides.add(
    watchReviewsByUserProvider(viewerUid).overrideWithValue(effectiveReviews),
  );

  final reviewValues = switch (effectiveReviews) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (reviewValues == null || reviewValues.isEmpty) return overrides;

  final eventIds = ReviewsHistoryState.eventIdsFor(reviewValues);
  if (eventIds.isEmpty) return overrides;

  final effectiveEvents =
      events ??
      AsyncData([
        for (final event in _reviewHistoryEvents)
          if (eventIds.contains(event.id)) event,
      ]);
  overrides.add(
    watchEventsByIdsProvider(
      EventsByIdQuery(eventIds),
    ).overrideWithValue(effectiveEvents),
  );

  return overrides;
}

final _eventRecapEvent = _captureFixtures.captureEvent(
  id: 'event-recap-capture',
  club: _dashboardJoinedClub,
  startTime: DateTime.now().subtract(const Duration(hours: 11)),
  endTime: DateTime.now().subtract(const Duration(hours: 10)),
  meetingPoint: 'Carter Road Amphitheatre',
  bookedCount: 12,
  checkedInCount: 10,
  capacityLimit: 18,
  description: 'A completed run with enough remembered people for recap.',
);
final _eventRecapProfiles = [
  ..._matchesListProfiles,
  ..._captureFixtures.publicProfiles(const [
    'nyc_aisha_williams_005',
    'nyc_marcus_chen_008',
  ]),
];
final _eventRecapParticipations = [
  buildEventParticipation(
    event: _eventRecapEvent,
    uid: _captureViewerUid,
    status: EventParticipationStatus.attended,
    createdAt: DateTime(2026, 5, 30, 7),
  ),
  for (final profile in _eventRecapProfiles)
    buildEventParticipation(
      event: _eventRecapEvent,
      uid: profile.uid,
      status: EventParticipationStatus.attended,
      createdAt: DateTime(2026, 5, 30, 7, 5),
    ),
];
final _eventRecapParticipationRepository = FakeEventParticipationRepository()
  ..eventParticipations[_eventRecapEvent.id] = _eventRecapParticipations;

final _activityScreenNotifications = UtilitySurfaceFixtures.notifications;

enum _ActivityMarkAllReadCaptureMode { pending, error }

class _ActivityMarkAllReadCapture extends ConsumerStatefulWidget {
  const _ActivityMarkAllReadCapture({required this.mode});

  final _ActivityMarkAllReadCaptureMode mode;

  @override
  ConsumerState<_ActivityMarkAllReadCapture> createState() =>
      _ActivityMarkAllReadCaptureState();
}

class _ActivityMarkAllReadCaptureState
    extends ConsumerState<_ActivityMarkAllReadCapture> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) return;
      _started = true;
      ActivityController.markAllReadMutation.reset(ref);
      switch (widget.mode) {
        case _ActivityMarkAllReadCaptureMode.pending:
          _runPending(ActivityController.markAllReadMutation);
          break;
        case _ActivityMarkAllReadCaptureMode.error:
          _runError(ActivityController.markAllReadMutation);
          break;
      }
    });
  }

  void _runPending(Mutation<void> mutation) {
    final completer = Completer<void>();
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError(Mutation<void> mutation) {
    final error = StateError('Capture mark all read failed');
    unawaited(
      mutation.run(ref, (_) async => throw error).catchError((_) {
        if (!mounted) return;
        showCatchErrorSnackBar(context, error);
      }),
    );
  }

  @override
  Widget build(BuildContext context) => const ActivityScreen();
}

class _ActivityDeepLinkErrorCapture extends StatefulWidget {
  const _ActivityDeepLinkErrorCapture();

  @override
  State<_ActivityDeepLinkErrorCapture> createState() =>
      _ActivityDeepLinkErrorCaptureState();
}

class _ActivityDeepLinkErrorCaptureState
    extends State<_ActivityDeepLinkErrorCapture> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _shown) return;
      _shown = true;
      showCatchErrorSnackBar(
        context,
        const ExternalActionException('Could not open this activity update.'),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const ActivityScreen();
}

final _paymentHistoryPayments = UtilitySurfaceFixtures.payments;
final _paymentHistoryEvents = [
  for (var index = 0; index < _paymentHistoryPayments.length; index += 1)
    _paymentHistoryEventFor(_paymentHistoryPayments[index], index),
];

Event _paymentHistoryEventFor(Payment payment, int index) {
  final start = UtilitySurfaceFixtures.now.add(
    Duration(days: index + 2, hours: index),
  );
  return UtilitySurfaceFixtures.event.copyWith(
    id: payment.eventId,
    startTime: start,
    endTime: start.add(const Duration(hours: 1, minutes: 30)),
    priceInPaise: payment.amount,
  );
}

List<Object> _paymentHistoryProviderOverrides({
  AsyncValue<String?> uid = const AsyncData(UtilitySurfaceFixtures.viewerUid),
  AsyncValue<List<Payment>>? payments,
  AsyncValue<List<Event>>? events,
}) {
  final effectivePayments = payments ?? AsyncData(_paymentHistoryPayments);
  final overrides = <Object>[uidProvider.overrideWithValue(uid)];
  final viewerUid = switch (uid) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (viewerUid == null) return overrides;

  overrides.add(
    watchPaymentsForUserProvider(
      viewerUid,
    ).overrideWithValue(effectivePayments),
  );

  final paymentValues = switch (effectivePayments) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (paymentValues == null || paymentValues.isEmpty) return overrides;

  final eventIds = {for (final payment in paymentValues) payment.eventId};
  final effectiveEvents =
      events ??
      AsyncData([
        for (final event in _paymentHistoryEvents)
          if (eventIds.contains(event.id)) event,
      ]);
  overrides.add(
    watchEventsByIdsProvider(
      EventsByIdQuery(eventIds),
    ).overrideWithValue(effectiveEvents),
  );

  return overrides;
}

class _PaymentReceiptSheetCapture extends StatelessWidget {
  const _PaymentReceiptSheetCapture({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: PaymentReceiptSheet(
          payment: payment,
          eventTitle: UtilitySurfaceFixtures.eventTitleForPayment(payment),
          onHelp: payment.signUpFailed ? () {} : null,
        ),
      ),
    );
  }
}

class _PaymentSupportSnackBarCapture extends StatefulWidget {
  const _PaymentSupportSnackBarCapture({required this.payment});

  final Payment payment;

  @override
  State<_PaymentSupportSnackBarCapture> createState() =>
      _PaymentSupportSnackBarCaptureState();
}

class _PaymentSupportSnackBarCaptureState
    extends State<_PaymentSupportSnackBarCapture> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _shown) return;
      _shown = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please contact Catch support for assistance with this booking.',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) =>
      _PaymentReceiptSheetCapture(payment: widget.payment);
}

final _settingsBlockedUsers = UtilitySurfaceFixtures.blockedUsers;

List<Object> _settingsAccountProviderOverrides({
  Stream<UserProfile?>? profileStream,
  Stream<List<BlockedUser>>? blockedUsersStream,
  List<BlockedUser> blockedUsers = const <BlockedUser>[],
  Map<String, PublicProfile> publicProfiles = const <String, PublicProfile>{},
}) {
  final profileQuery = PublicProfilesQuery(
    blockedUsers.map((blocked) => blocked.uid),
  );
  return <Object>[
    uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
    watchUserProfileProvider.overrideWith(
      (ref) => profileStream ?? Stream.value(_captureViewer),
    ),
    watchBlockedUsersProvider.overrideWith(
      (ref) => blockedUsersStream ?? Stream.value(blockedUsers),
    ),
    publicProfilesByIdsProvider(
      profileQuery,
    ).overrideWith((ref) async => publicProfiles),
  ];
}

enum _SettingsMutationCaptureMode {
  preferencePending,
  preferenceError,
  preferenceOffline,
  deletePending,
  deleteError,
  deleteOffline,
  signOutPending,
  signOutError,
  signOutOffline,
  unblockPending,
  unblockError,
  unblockOffline,
}

class _SettingsMutationCapture extends ConsumerStatefulWidget {
  const _SettingsMutationCapture({required this.mode});

  final _SettingsMutationCaptureMode mode;

  @override
  ConsumerState<_SettingsMutationCapture> createState() =>
      _SettingsMutationCaptureState();
}

class _SettingsMutationCaptureState
    extends ConsumerState<_SettingsMutationCapture> {
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

  void _resetMutations() {
    SettingsController.savePreferenceMutation.reset(ref);
    SettingsController.requestAccountDeletionMutation.reset(ref);
    SettingsController.unblockUserMutation.reset(ref);
    AuthSessionController.signOutMutation.reset(ref);
  }

  void _seed() {
    switch (widget.mode) {
      case _SettingsMutationCaptureMode.preferencePending:
        _runPending(SettingsController.savePreferenceMutation);
        break;
      case _SettingsMutationCaptureMode.preferenceError:
        _runError(
          SettingsController.savePreferenceMutation,
          StateError('Capture preference save failed'),
        );
        break;
      case _SettingsMutationCaptureMode.preferenceOffline:
        _runError(
          SettingsController.savePreferenceMutation,
          obviousOfflineException(),
        );
        break;
      case _SettingsMutationCaptureMode.deletePending:
        _runPending(SettingsController.requestAccountDeletionMutation);
        break;
      case _SettingsMutationCaptureMode.deleteError:
        _runError(
          SettingsController.requestAccountDeletionMutation,
          StateError('Capture delete account failed'),
        );
        break;
      case _SettingsMutationCaptureMode.deleteOffline:
        _runError(
          SettingsController.requestAccountDeletionMutation,
          obviousOfflineException(),
        );
        break;
      case _SettingsMutationCaptureMode.signOutPending:
        _runPending(AuthSessionController.signOutMutation);
        break;
      case _SettingsMutationCaptureMode.signOutError:
        _runError(
          AuthSessionController.signOutMutation,
          StateError('Capture sign out failed'),
        );
        break;
      case _SettingsMutationCaptureMode.signOutOffline:
        _runError(
          AuthSessionController.signOutMutation,
          obviousOfflineException(),
        );
        break;
      case _SettingsMutationCaptureMode.unblockPending:
        _runPending(SettingsController.unblockUserMutation);
        break;
      case _SettingsMutationCaptureMode.unblockError:
        _runError(
          SettingsController.unblockUserMutation,
          StateError('Capture unblock failed'),
        );
        break;
      case _SettingsMutationCaptureMode.unblockOffline:
        _runError(
          SettingsController.unblockUserMutation,
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
    unawaited(mutation.run(ref, (_) async => throw error).catchError((_) {}));
  }

  @override
  Widget build(BuildContext context) => const SettingsScreen();
}

final screenCaptureCatalog = <ScreenCaptureEntry>[
  ScreenCaptureEntry(
    id: 'profile_self',
    routeIds: const <String>['profileScreen'],
    device: CaptureDevice.reviewTall,
    precache: <ImageProvider<Object>>[_profileHeroImage],
    builder: (context) =>
        CatchProfileView(data: _profileFixture, onReact: (target, comment) {}),
  ),
  ScreenCaptureEntry(
    id: 'profile_self_loading',
    routeIds: const <String>['profileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _selfProfileProviderOverrides(
      profileStream: _captureLoadingStream<UserProfile?>(),
    ),
    builder: (context) => _selfProfileCapture(),
  ),
  ScreenCaptureEntry(
    id: 'profile_self_error',
    routeIds: const <String>['profileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _selfProfileProviderOverrides(
      profileStream: _captureErrorStream<UserProfile?>(
        'Capture profile failed',
      ),
    ),
    builder: (context) => _selfProfileCapture(),
  ),
  ScreenCaptureEntry(
    id: 'profile_self_offline',
    routeIds: const <String>['profileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _selfProfileProviderOverrides(
      profileStream: Stream<UserProfile?>.error(
        ProfileSurfaceFixtures.offlineException(action: 'load profile'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _selfProfileCapture(),
  ),
  ScreenCaptureEntry(
    id: 'profile_self_unavailable',
    routeIds: const <String>['profileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _selfProfileProviderOverrides(
      profileStream: Stream<UserProfile?>.value(null),
    ),
    builder: (context) => _selfProfileCapture(),
  ),
  ScreenCaptureEntry(
    id: 'profile_self_edit_tab',
    routeIds: const <String>['profileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _selfProfileProviderOverrides(),
    builder: (context) => _selfProfileCapture(),
  ),
  ScreenCaptureEntry(
    id: 'profile_self_preview_tab',
    routeIds: const <String>['profileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _selfProfileProviderOverrides(
      profile: _profileCaptureViewerNoNetwork,
    ),
    builder: (context) => _selfProfileCapture(initialTabIndex: 1),
  ),
  ScreenCaptureEntry(
    id: 'profile_self_photo_upload_pending',
    routeIds: const <String>['profileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _selfProfileProviderOverrides(
      uploadLoadingIndices: const <int>{1},
    ),
    builder: (context) => _selfProfileCapture(),
  ),
  ScreenCaptureEntry(
    id: 'profile_self_text_scale_2',
    routeIds: const <String>['profileScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _selfProfileProviderOverrides(),
    builder: (context) => _selfProfileCapture(),
  ),
  ScreenCaptureEntry(
    id: 'profile_self_reduced_motion',
    routeIds: const <String>['profileScreen'],
    device: CaptureDevice.reviewTall,
    disableAnimations: true,
    providerOverrides: _selfProfileProviderOverrides(),
    builder: (context) => _selfProfileCapture(),
  ),
  ScreenCaptureEntry(
    id: 'start_welcome',
    routeIds: const <String>['startScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [_captureAnalyticsOverride],
    builder: (context) => const WelcomePage(playIntro: false),
  ),
  ScreenCaptureEntry(
    id: 'auth_phone_entry',
    routeIds: const <String>['authScreen'],
    device: CaptureDevice.reviewPhone,
    builder: (context) => const AuthScreen(),
  ),
  ScreenCaptureEntry(
    id: 'onboarding_welcome',
    routeIds: const <String>['onboardingScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [
      _captureAnalyticsOverride,
      uidProvider.overrideWithValue(const AsyncData(null)),
      watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
    ],
    builder: (context) => const OnboardingScreen(),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_member',
    routeIds: const <String>[
      'eventDetailScreen',
      'calendarEventDetailScreen',
      'savedEventDetailScreen',
      'dashboardEventDetailScreen',
    ],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailEvent.clubId,
      eventId: _eventDetailEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_member_ticket',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailEvent.clubId,
      eventId: _eventDetailEvent.id,
      presentationMode: EventDetailPresentationMode.ticket,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_member_spotlight',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailEvent.clubId,
      eventId: _eventDetailEvent.id,
      presentationMode: EventDetailPresentationMode.spotlightDark,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_loading',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      viewModel: const AsyncLoading<EventDetailViewModel?>(),
    ),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailEvent.clubId,
      eventId: _eventDetailEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_not_found',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      viewModel: const AsyncData<EventDetailViewModel?>(null),
    ),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailEvent.clubId,
      eventId: _eventDetailEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_error',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      viewModel: AsyncError<EventDetailViewModel?>(
        StateError('Capture event detail load failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailEvent.clubId,
      eventId: _eventDetailEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_guest',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      viewModel: AsyncData(
        _eventDetailCaptureViewModel(isAuthenticated: false, isSaved: false),
      ),
    ),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailEvent.clubId,
      eventId: _eventDetailEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_host_app',
    routeIds: const <String>['hostAppEventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      viewModel: AsyncData(
        _eventDetailCaptureViewModel(
          userProfile: _eventDetailHostUser,
          isHost: true,
          isSaved: false,
        ),
      ),
    ),
    builder: (context) => _AppRoleCapture(
      role: AppRole.host,
      child: EventDetailScreen(
        clubId: _eventDetailEvent.clubId,
        eventId: _eventDetailEvent.id,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_offline',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      viewModel: AsyncError<EventDetailViewModel?>(
        StateError('No network connection for Event Detail'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailEvent.clubId,
      eventId: _eventDetailEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_text_scale_2',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _eventDetailCaptureProviderOverrides(),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailEvent.clubId,
      eventId: _eventDetailEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_reduced_motion',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    disableAnimations: true,
    providerOverrides: _eventDetailCaptureProviderOverrides(),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailEvent.clubId,
      eventId: _eventDetailEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_booking_signed_up',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      viewerParticipation: _eventDetailSignedUpParticipation,
      includeCompanionPlan: true,
    ),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailEvent.clubId,
      eventId: _eventDetailEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_booking_waitlist',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      event: _eventDetailWaitlistEvent,
      viewerParticipation: _eventDetailWaitlistedParticipation,
    ),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailWaitlistEvent.clubId,
      eventId: _eventDetailWaitlistEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_booking_waitlist_offer',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      event: _eventDetailWaitlistOfferEvent,
      viewerParticipation: _eventDetailWaitlistOfferParticipation,
    ),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailWaitlistOfferEvent.clubId,
      eventId: _eventDetailWaitlistOfferEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_booking_full',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      event: _eventDetailFullEvent,
    ),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailFullEvent.clubId,
      eventId: _eventDetailFullEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_booking_attended',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      event: _eventDetailAttendedEvent,
      viewerParticipation: _eventDetailAttendedParticipation,
    ),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailAttendedEvent.clubId,
      eventId: _eventDetailAttendedEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_booking_past',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      event: _eventDetailPastEvent,
    ),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailPastEvent.clubId,
      eventId: _eventDetailPastEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_detail_booking_cancelled',
    routeIds: const <String>['eventDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      event: _eventDetailCancelledEvent,
    ),
    builder: (context) => EventDetailScreen(
      clubId: _eventDetailCancelledEvent.clubId,
      eventId: _eventDetailCancelledEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _dashboardProviderOverrides(),
    builder: (context) => const DashboardScreen(),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home_loading',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _dashboardProviderOverrides(
      signedUpEventsStream: _captureLoadingStream<List<Event>>(),
    ),
    builder: (context) => const DashboardScreen(),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home_profile_error',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _dashboardProviderOverrides(
      profileStream: _captureErrorStream<UserProfile?>(
        'Capture dashboard profile failed',
      ),
    ),
    builder: (context) => const DashboardScreen(),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home_offline',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _dashboardProviderOverrides(
      profileStream: Stream<UserProfile?>.error(
        _dashboardOfflineException(action: 'load dashboard'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => const DashboardScreen(),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home_memberships_error',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _dashboardProviderOverrides(
      membershipsStream: _captureErrorStream<List<ClubMembership>>(
        'Capture dashboard memberships failed',
      ),
    ),
    builder: (context) => const DashboardScreen(),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home_booked_events_error',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _dashboardProviderOverrides(
      signedUpEventsStream: _captureErrorStream<List<Event>>(
        'Capture dashboard booked events failed',
      ),
    ),
    builder: (context) => const DashboardScreen(),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home_empty_start',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _dashboardProviderOverrides(
      memberships: const [],
      signedUpEvents: const [],
      recommendations:
          const AsyncData<List<DashboardEventRecommendationCandidate>>([]),
    ),
    builder: (context) => const DashboardScreen(),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home_recommendations_loading',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _dashboardProviderOverrides(
      recommendations:
          const AsyncLoading<List<DashboardEventRecommendationCandidate>>(),
    ),
    builder: (context) => const DashboardScreen(),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home_recommendations_error',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _dashboardProviderOverrides(
      recommendations: AsyncError<List<DashboardEventRecommendationCandidate>>(
        StateError('Capture dashboard recommendations failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => const DashboardScreen(),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home_self_check_in',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _dashboardProviderOverrides(
      signedUpEvents: [_dashboardCheckInEvent],
      attendedEvents: const AsyncData<List<Event>>([]),
      recommendations:
          const AsyncData<List<DashboardEventRecommendationCandidate>>([]),
    ),
    builder: (context) => const DashboardScreen(),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home_self_check_in_pending',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _dashboardProviderOverrides(
      signedUpEvents: [_dashboardCheckInEvent],
      attendedEvents: const AsyncData<List<Event>>([]),
      recommendations:
          const AsyncData<List<DashboardEventRecommendationCandidate>>([]),
    ),
    builder: (context) => const _DashboardCheckInMutationCapture(
      mode: _DashboardCheckInMutationMode.pending,
    ),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home_self_check_in_error',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _dashboardProviderOverrides(
      signedUpEvents: [_dashboardCheckInEvent],
      attendedEvents: const AsyncData<List<Event>>([]),
      recommendations:
          const AsyncData<List<DashboardEventRecommendationCandidate>>([]),
    ),
    builder: (context) => const _DashboardCheckInMutationCapture(
      mode: _DashboardCheckInMutationMode.error,
    ),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home_after_event_focus',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _dashboardProviderOverrides(
      attendedEvents: AsyncData([_dashboardAfterEventFocusEvent]),
      reviews: const AsyncData<List<Review>>([]),
      recommendations:
          const AsyncData<List<DashboardEventRecommendationCandidate>>([]),
    ),
    builder: (context) => const DashboardScreen(),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home_text_scale_2',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _dashboardProviderOverrides(),
    builder: (context) => const DashboardScreen(),
  ),
  ScreenCaptureEntry(
    id: 'dashboard_home_reduced_motion',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    disableAnimations: true,
    providerOverrides: _dashboardProviderOverrides(),
    builder: (context) => const DashboardScreen(),
  ),
  ScreenCaptureEntry(
    id: 'host_home_dashboard',
    routeIds: const <String>['hostHomeScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostedClubs: [_hostTodayReferenceClub],
      ownedClubs: [_hostTodayReferenceClub],
      clubEvents: {
        _hostTodayReferenceClub.id: AsyncData<List<Event>>([
          _hostTodayReferenceEvent,
        ]),
      },
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostOperationsHomeScreen(
        initialClubId: 'host-home-reference-bandra-social',
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_home_events_list',
    routeIds: const <String>['hostHomeScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostOperationsHomeScreen(initialTab: HostHomeTab.events),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_home_signed_out',
    routeIds: const <String>['hostHomeScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData<String?>(null)),
    ],
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostOperationsHomeScreen(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_home_clubs_loading',
    routeIds: const <String>['hostHomeScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostedClubsAsync: const AsyncLoading<List<Club>>(),
      ownedClubsAsync: const AsyncLoading<List<Club>>(),
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostOperationsHomeScreen(initialTab: HostHomeTab.events),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_home_clubs_error',
    routeIds: const <String>['hostHomeScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostedClubsAsync: AsyncError<List<Club>>(
        StateError('Capture host home clubs failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostOperationsHomeScreen(initialTab: HostHomeTab.events),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_home_clubs_offline',
    routeIds: const <String>['hostHomeScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostedClubsAsync: AsyncError<List<Club>>(
        obviousOfflineException(),
        StackTrace.empty,
      ),
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostOperationsHomeScreen(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_home_empty_clubs',
    routeIds: const <String>['hostHomeScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostedClubs: const <Club>[],
      ownedClubs: const <Club>[],
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostOperationsHomeScreen(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_home_events_loading',
    routeIds: const <String>['hostHomeScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      clubEvents: {
        HostOperationsFixtures.primaryClub.id:
            const AsyncLoading<List<Event>>(),
      },
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostOperationsHomeScreen(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_home_events_error',
    routeIds: const <String>['hostHomeScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      clubEvents: {
        HostOperationsFixtures.primaryClub.id: AsyncError<List<Event>>(
          StateError('Capture host home events failed'),
          StackTrace.empty,
        ),
      },
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostOperationsHomeScreen(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_home_events_offline',
    routeIds: const <String>['hostHomeScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      clubEvents: {
        HostOperationsFixtures.dinnerClub.id: AsyncError<List<Event>>(
          obviousOfflineException(),
          StackTrace.empty,
        ),
      },
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostOperationsHomeScreen(
        initialClubId: 'design-host-table-club',
        initialTab: HostHomeTab.events,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_home_cohost_empty_events',
    routeIds: const <String>['hostHomeScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostedClubs: [HostOperationsFixtures.coHostedClub],
      ownedClubs: const <Club>[],
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostOperationsHomeScreen(
        initialClubId: 'design-host-cohost-club',
        initialTab: HostHomeTab.events,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_home_text_scale_2',
    routeIds: const <String>['hostHomeScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostOperationsHomeScreen(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_home_reduced_motion',
    routeIds: const <String>['hostHomeScreen'],
    device: CaptureDevice.reviewTall,
    disableAnimations: true,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostOperationsHomeScreen(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_home_light_dark',
    routeIds: const <String>['hostHomeScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostOperationsHomeScreen(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_management',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostClubsScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_signed_out',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData<String?>(null)),
    ],
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostClubsScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_loading',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostedClubsAsync: const AsyncLoading<List<Club>>(),
      ownedClubsAsync: const AsyncLoading<List<Club>>(),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostClubsScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_error',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      ownedClubsAsync: AsyncError<List<Club>>(
        StateError('Capture host clubs failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostClubsScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_offline',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      ownedClubsAsync: AsyncError<List<Club>>(
        obviousOfflineException(),
        StackTrace.empty,
      ),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostClubsScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_empty',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostedClubs: const <Club>[],
      ownedClubs: const <Club>[],
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostClubsScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_cohost_edit',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostedClubs: [HostOperationsFixtures.coHostedClub],
      ownedClubs: const <Club>[],
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostClubsScreen(
        initialClubId: 'design-host-cohost-club',
        initialTab: HostClubTab.edit,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_inline_edit_pending',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _HostClubsMutationCapture(
      mode: _HostClubsMutationCaptureMode.inlinePending,
      child: _AppRoleCapture(
        role: AppRole.host,
        child: HostClubsScreen(initialExpandedEditField: 'name'),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_inline_edit_error',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _HostClubsMutationCapture(
      mode: _HostClubsMutationCaptureMode.inlineError,
      child: _AppRoleCapture(
        role: AppRole.host,
        child: HostClubsScreen(initialExpandedEditField: 'name'),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_inline_edit_offline',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _HostClubsMutationCapture(
      mode: _HostClubsMutationCaptureMode.inlineOffline,
      child: _AppRoleCapture(
        role: AppRole.host,
        child: HostClubsScreen(initialExpandedEditField: 'name'),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_insights_report',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostClubsScreen(initialTab: HostClubTab.insights),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_insights_loading',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      analyticsRepository: const _CaptureLoadingAnalyticsRepository(),
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostClubsScreen(initialTab: HostClubTab.insights),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_insights_error',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      analyticsRepository: HostFixtureAnalyticsRepository(
        error: StateError('Capture host analytics failed'),
      ),
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostClubsScreen(initialTab: HostClubTab.insights),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_insights_offline',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      analyticsRepository: HostFixtureAnalyticsRepository(
        error: obviousOfflineException(),
      ),
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostClubsScreen(initialTab: HostClubTab.insights),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_preview_tab',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostClubsScreen(initialTab: HostClubTab.preview),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_payout_loading',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostOperationsProviderOverrides(
      paymentAccountValue: const AsyncLoading<HostPaymentAccount?>(),
    ),
    builder: (context) => _hostPayoutCardCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_payout_ready',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostOperationsProviderOverrides(
      paymentAccountValue: const AsyncData<HostPaymentAccount?>(
        HostOperationsFixtures.readyPaymentAccount,
      ),
    ),
    builder: (context) => _hostPayoutCardCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_payout_restricted',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostOperationsProviderOverrides(
      paymentAccountValue: const AsyncData<HostPaymentAccount?>(
        HostOperationsFixtures.restrictedPaymentAccount,
      ),
    ),
    builder: (context) => _hostPayoutCardCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_payout_error',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostOperationsProviderOverrides(
      paymentAccountValue: AsyncError<HostPaymentAccount?>(
        StateError('Capture payout status failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _hostPayoutCardCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_payout_offline',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostOperationsProviderOverrides(
      paymentAccountValue: AsyncError<HostPaymentAccount?>(
        obviousOfflineException(),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _hostPayoutCardCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_payout_setup_pending',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => _HostClubsMutationCapture(
      mode: _HostClubsMutationCaptureMode.payoutSetupPending,
      child: _hostPayoutCardCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_payout_setup_error',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => _HostClubsMutationCapture(
      mode: _HostClubsMutationCaptureMode.payoutSetupError,
      child: _hostPayoutCardCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_payout_setup_offline',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => _HostClubsMutationCapture(
      mode: _HostClubsMutationCaptureMode.payoutSetupOffline,
      child: _hostPayoutCardCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_payout_refresh_pending',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostOperationsProviderOverrides(
      paymentAccountValue: const AsyncData<HostPaymentAccount?>(
        HostOperationsFixtures.readyPaymentAccount,
      ),
    ),
    builder: (context) => _HostClubsMutationCapture(
      mode: _HostClubsMutationCaptureMode.payoutRefreshPending,
      child: _hostPayoutCardCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_payout_refresh_error',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostOperationsProviderOverrides(
      paymentAccountValue: const AsyncData<HostPaymentAccount?>(
        HostOperationsFixtures.readyPaymentAccount,
      ),
    ),
    builder: (context) => _HostClubsMutationCapture(
      mode: _HostClubsMutationCaptureMode.payoutRefreshError,
      child: _hostPayoutCardCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_payout_refresh_offline',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostOperationsProviderOverrides(
      paymentAccountValue: const AsyncData<HostPaymentAccount?>(
        HostOperationsFixtures.readyPaymentAccount,
      ),
    ),
    builder: (context) => _HostClubsMutationCapture(
      mode: _HostClubsMutationCaptureMode.payoutRefreshOffline,
      child: _hostPayoutCardCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_team_pending',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _HostClubsMutationCapture(
      mode: _HostClubsMutationCaptureMode.teamPending,
      child: _HostTeamSectionCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_team_error',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _HostClubsMutationCapture(
      mode: _HostClubsMutationCaptureMode.teamError,
      child: _HostTeamSectionCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_team_offline',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _HostClubsMutationCapture(
      mode: _HostClubsMutationCaptureMode.teamOffline,
      child: _HostTeamSectionCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_text_scale_2',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostClubsScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_reduced_motion',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    disableAnimations: true,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostClubsScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_clubs_light_dark',
    routeIds: const <String>['hostClubsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostClubsScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_active_profile',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostAccountScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_text_scale_2',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostAccountScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_reduced_motion',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    disableAnimations: true,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostAccountScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_profile_loading',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: const AsyncLoading<HostProfile?>(),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostAccountScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_profile_error',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: AsyncError<HostProfile?>(
        StateError('Capture host profile failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostAccountScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_profile_offline',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: AsyncError<HostProfile?>(
        obviousOfflineException(),
        StackTrace.empty,
      ),
      hostedClubs: const <Club>[],
      ownedClubs: const <Club>[],
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostAccountScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_no_profile',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: const AsyncData<HostProfile?>(null),
      hostedClubs: const <Club>[],
      ownedClubs: const <Club>[],
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostAccountScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_create_profile_pending',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: const AsyncData<HostProfile?>(null),
      hostedClubs: const <Club>[],
      ownedClubs: const <Club>[],
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.createPending,
        child: HostAccountScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_create_profile_error',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: const AsyncData<HostProfile?>(null),
      hostedClubs: const <Club>[],
      ownedClubs: const <Club>[],
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.createError,
        child: HostAccountScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_create_profile_offline',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: const AsyncData<HostProfile?>(null),
      hostedClubs: const <Club>[],
      ownedClubs: const <Club>[],
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.createOffline,
        child: HostAccountScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_fallback_profile',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: const AsyncData<HostProfile?>(null),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostAccountScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_clubs_loading',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostedClubsAsync: const AsyncLoading<List<Club>>(),
      ownedClubsAsync: const AsyncLoading<List<Club>>(),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostAccountScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_clubs_error',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostedClubsAsync: AsyncError<List<Club>>(
        StateError('Capture hosted clubs failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostAccountScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_clubs_offline',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostedClubsAsync: AsyncError<List<Club>>(
        obviousOfflineException(),
        StackTrace.empty,
      ),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostAccountScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_profile_editor_sheet',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.editorSheet,
        showEditorSheet: true,
        child: HostAccountScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_save_profile_pending',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.savePending,
        showEditorSheet: true,
        child: HostAccountScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_save_profile_error',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.saveError,
        showEditorSheet: true,
        child: HostAccountScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_save_profile_offline',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.saveOffline,
        showEditorSheet: true,
        child: HostAccountScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_sign_out_error',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.signOutError,
        child: HostAccountScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_settings_sign_out_offline',
    routeIds: const <String>['hostSettingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.signOutOffline,
        child: HostAccountScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_profile_populated',
    routeIds: const <String>['hostProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostProfileScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_profile_validation_error',
    routeIds: const <String>['hostProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: AsyncData<HostProfile?>(
        HostOperationsFixtures.hostProfileMissingDisplayName,
      ),
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: HostProfileScreen(formAutovalidateMode: AutovalidateMode.always),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_profile_text_scale_2',
    routeIds: const <String>['hostProfileScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostProfileScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_profile_reduced_motion',
    routeIds: const <String>['hostProfileScreen'],
    device: CaptureDevice.reviewTall,
    disableAnimations: true,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostProfileScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_profile_loading',
    routeIds: const <String>['hostProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: const AsyncLoading<HostProfile?>(),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostProfileScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_profile_error',
    routeIds: const <String>['hostProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: AsyncError<HostProfile?>(
        StateError('Capture host profile failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostProfileScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_profile_offline',
    routeIds: const <String>['hostProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: AsyncError<HostProfile?>(
        obviousOfflineException(),
        StackTrace.empty,
      ),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostProfileScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_profile_missing',
    routeIds: const <String>['hostProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: const AsyncData<HostProfile?>(null),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: HostProfileScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_profile_create_pending',
    routeIds: const <String>['hostProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: const AsyncData<HostProfile?>(null),
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.createPending,
        child: HostProfileScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_profile_create_error',
    routeIds: const <String>['hostProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: const AsyncData<HostProfile?>(null),
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.createError,
        child: HostProfileScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_profile_create_offline',
    routeIds: const <String>['hostProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(
      hostProfile: const AsyncData<HostProfile?>(null),
    ),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.createOffline,
        child: HostProfileScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_profile_save_pending',
    routeIds: const <String>['hostProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.savePending,
        child: HostProfileScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_profile_save_error',
    routeIds: const <String>['hostProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.saveError,
        child: HostProfileScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_profile_save_offline',
    routeIds: const <String>['hostProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostOperationsProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _HostProfileMutationCapture(
        mode: _HostProfileMutationCaptureMode.saveOffline,
        child: HostProfileScreen(),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'club_detail_member',
    routeIds: const <String>['clubDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _clubDetailProviderOverrides(
      membership: _captureMembership(
        clubId: _clubDetailClub.id,
        uid: _captureViewerUid,
      ),
      viewModel: AsyncData(_clubDetailViewModel()),
    ),
    builder: (context) => _clubDetailScreenCapture(),
  ),
  ScreenCaptureEntry(
    id: 'club_detail_visitor',
    routeIds: const <String>['clubDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _clubDetailProviderOverrides(
      viewModel: AsyncData(_clubDetailViewModel(isMember: false)),
    ),
    builder: (context) => _clubDetailScreenCapture(),
  ),
  ScreenCaptureEntry(
    id: 'club_detail_guest',
    routeIds: const <String>['clubDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _clubDetailProviderOverrides(
      uid: null,
      viewModel: AsyncData(
        _clubDetailViewModel(
          uid: null,
          isMember: false,
          isAuthenticated: false,
          includeUserProfile: false,
        ),
      ),
    ),
    builder: (context) => _clubDetailScreenCapture(),
  ),
  ScreenCaptureEntry(
    id: 'club_detail_host_public',
    routeIds: const <String>['clubDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _clubDetailProviderOverrides(
      uid: _clubDetailClub.ownerOrPrimaryHostUserId,
      membership: _captureMembership(
        clubId: _clubDetailClub.id,
        uid: _clubDetailClub.ownerOrPrimaryHostUserId ?? 'host-mira',
        role: ClubMembershipRole.owner,
      ),
      viewModel: AsyncData(
        _clubDetailViewModel(
          uid: _clubDetailClub.ownerOrPrimaryHostUserId,
          isHost: true,
        ),
      ),
    ),
    builder: (context) =>
        _AppRoleCapture(role: AppRole.host, child: _clubDetailScreenCapture()),
  ),
  ScreenCaptureEntry(
    id: 'host_club_detail_public',
    routeIds: const <String>['hostClubDetailScreen'],
    device: CaptureDevice.reviewTall,
    precache: const <ImageProvider<Object>>[_clubHeroPortraitAssetImage],
    providerOverrides: _hostClubDetailProviderOverrides(),
    builder: (context) => _AppRoleCapture(
      role: AppRole.host,
      child: ClubDetailScreen(
        clubId: _hostClubDetailReferenceClub.id,
        initialClub: _hostClubDetailReferenceClub,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_club_detail_initial_loading',
    routeIds: const <String>['hostClubDetailScreen'],
    device: CaptureDevice.reviewTall,
    precache: const <ImageProvider<Object>>[_clubHeroPortraitAssetImage],
    providerOverrides: _hostClubDetailProviderOverrides(
      viewModel: const AsyncLoading<ClubDetailViewModel?>(),
    ),
    builder: (context) => _AppRoleCapture(
      role: AppRole.host,
      child: ClubDetailScreen(
        clubId: _hostClubDetailReferenceClub.id,
        initialClub: _hostClubDetailReferenceClub,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_club_detail_loading',
    routeIds: const <String>['hostClubDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostClubDetailProviderOverrides(
      viewModel: const AsyncLoading<ClubDetailViewModel?>(),
    ),
    builder: (context) => _AppRoleCapture(
      role: AppRole.host,
      child: ClubDetailScreen(clubId: _hostClubDetailReferenceClub.id),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_club_detail_error',
    routeIds: const <String>['hostClubDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostClubDetailProviderOverrides(
      viewModel: AsyncError<ClubDetailViewModel?>(
        StateError('Capture host club detail failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _AppRoleCapture(
      role: AppRole.host,
      child: ClubDetailScreen(clubId: _hostClubDetailReferenceClub.id),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_club_detail_offline',
    routeIds: const <String>['hostClubDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostClubDetailProviderOverrides(
      viewModel: AsyncError<ClubDetailViewModel?>(
        obviousOfflineException(),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _AppRoleCapture(
      role: AppRole.host,
      child: ClubDetailScreen(clubId: _hostClubDetailReferenceClub.id),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_club_detail_not_found',
    routeIds: const <String>['hostClubDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostClubDetailProviderOverrides(
      viewModel: const AsyncData<ClubDetailViewModel?>(null),
    ),
    builder: (context) => _AppRoleCapture(
      role: AppRole.host,
      child: ClubDetailScreen(clubId: _hostClubDetailReferenceClub.id),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_club_detail_signed_out',
    routeIds: const <String>['hostClubDetailScreen'],
    device: CaptureDevice.reviewTall,
    precache: const <ImageProvider<Object>>[_clubHeroPortraitAssetImage],
    providerOverrides: _hostClubDetailProviderOverrides(
      uid: null,
      viewModel: AsyncData<ClubDetailViewModel?>(
        _hostClubDetailViewModel(uid: null, isHost: false),
      ),
    ),
    builder: (context) => _AppRoleCapture(
      role: AppRole.host,
      child: ClubDetailScreen(
        clubId: _hostClubDetailReferenceClub.id,
        initialClub: _hostClubDetailReferenceClub,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_club_detail_non_host_preview',
    routeIds: const <String>['hostClubDetailScreen'],
    device: CaptureDevice.reviewTall,
    precache: const <ImageProvider<Object>>[_clubHeroPortraitAssetImage],
    providerOverrides: _hostClubDetailProviderOverrides(
      uid: 'design-host-non-team',
      viewModel: AsyncData<ClubDetailViewModel?>(
        _hostClubDetailViewModel(uid: 'design-host-non-team', isHost: false),
      ),
    ),
    builder: (context) => _AppRoleCapture(
      role: AppRole.host,
      child: ClubDetailScreen(
        clubId: _hostClubDetailReferenceClub.id,
        initialClub: _hostClubDetailReferenceClub,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_club_detail_empty_schedule',
    routeIds: const <String>['hostClubDetailScreen'],
    device: CaptureDevice.reviewTall,
    precache: const <ImageProvider<Object>>[_clubHeroPortraitAssetImage],
    providerOverrides: _hostClubDetailProviderOverrides(
      viewModel: AsyncData<ClubDetailViewModel?>(
        _hostClubDetailViewModel(upcomingEvents: const <Event>[]),
      ),
    ),
    builder: (context) => _AppRoleCapture(
      role: AppRole.host,
      child: ClubDetailScreen(
        clubId: _hostClubDetailReferenceClub.id,
        initialClub: _hostClubDetailReferenceClub,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_club_detail_text_scale_2',
    routeIds: const <String>['hostClubDetailScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    precache: const <ImageProvider<Object>>[_clubHeroPortraitAssetImage],
    providerOverrides: _hostClubDetailProviderOverrides(),
    builder: (context) => _AppRoleCapture(
      role: AppRole.host,
      child: ClubDetailScreen(
        clubId: _hostClubDetailReferenceClub.id,
        initialClub: _hostClubDetailReferenceClub,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_club_detail_reduced_motion',
    routeIds: const <String>['hostClubDetailScreen'],
    device: CaptureDevice.reviewTall,
    disableAnimations: true,
    precache: const <ImageProvider<Object>>[_clubHeroPortraitAssetImage],
    providerOverrides: _hostClubDetailProviderOverrides(),
    builder: (context) => _AppRoleCapture(
      role: AppRole.host,
      child: ClubDetailScreen(
        clubId: _hostClubDetailReferenceClub.id,
        initialClub: _hostClubDetailReferenceClub,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_club_detail_light_dark',
    routeIds: const <String>['hostClubDetailScreen'],
    device: CaptureDevice.reviewTall,
    precache: const <ImageProvider<Object>>[_clubHeroPortraitAssetImage],
    providerOverrides: _hostClubDetailProviderOverrides(),
    builder: (context) => _AppRoleCapture(
      role: AppRole.host,
      child: ClubDetailScreen(
        clubId: _hostClubDetailReferenceClub.id,
        initialClub: _hostClubDetailReferenceClub,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'club_detail_missing',
    routeIds: const <String>['clubDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _clubDetailProviderOverrides(
      viewModel: const AsyncData<ClubDetailViewModel?>(null),
    ),
    builder: (context) => _clubDetailScreenCapture(includeInitialClub: false),
  ),
  ScreenCaptureEntry(
    id: 'club_detail_error',
    routeIds: const <String>['clubDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _clubDetailProviderOverrides(
      viewModel: AsyncError<ClubDetailViewModel?>(
        StateError('Capture club detail load failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _clubDetailScreenCapture(includeInitialClub: false),
  ),
  ScreenCaptureEntry(
    id: 'club_detail_join_pending',
    routeIds: const <String>['clubDetailScreen'],
    device: CaptureDevice.reviewTall,
    builder: (context) => _clubDetailMutationCapture(
      isMember: false,
      isAuthenticated: true,
      isMutating: true,
    ),
  ),
  ScreenCaptureEntry(
    id: 'club_detail_mutation_error',
    routeIds: const <String>['clubDetailScreen'],
    device: CaptureDevice.reviewTall,
    builder: (context) => _clubDetailMutationCapture(
      isMember: false,
      isAuthenticated: true,
      mutationError: StateError('Could not join this club.'),
    ),
  ),
  ScreenCaptureEntry(
    id: 'club_detail_offline',
    routeIds: const <String>['clubDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _clubDetailProviderOverrides(
      viewModel: AsyncError<ClubDetailViewModel?>(
        StateError('No network connection for Club Detail'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _clubDetailScreenCapture(includeInitialClub: false),
  ),
  ScreenCaptureEntry(
    id: 'club_detail_text_scale_2',
    routeIds: const <String>['clubDetailScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _clubDetailProviderOverrides(
      membership: _captureMembership(
        clubId: _clubDetailClub.id,
        uid: _captureViewerUid,
      ),
      viewModel: AsyncData(_clubDetailViewModel()),
    ),
    builder: (context) => _clubDetailScreenCapture(),
  ),
  ScreenCaptureEntry(
    id: 'club_detail_reduced_motion',
    routeIds: const <String>['clubDetailScreen'],
    device: CaptureDevice.reviewTall,
    disableAnimations: true,
    providerOverrides: _clubDetailProviderOverrides(
      membership: _captureMembership(
        clubId: _clubDetailClub.id,
        uid: _captureViewerUid,
      ),
      viewModel: AsyncData(_clubDetailViewModel()),
    ),
    builder: (context) => _clubDetailScreenCapture(),
  ),
  ScreenCaptureEntry(
    id: 'calendar_planned_events',
    routeIds: const <String>['calendarScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchSignedUpEventsProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_dashboardSignedUpEvents)),
      watchSavedEventDetailsForUserProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_dashboardSavedEvents)),
      clubsRepositoryProvider.overrideWith((ref) => _captureClubsRepository),
    ],
    builder: (context) => const CalendarScreen(),
  ),
  ScreenCaptureEntry(
    id: 'saved_events_list',
    routeIds: const <String>['savedEventsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchSavedEventDetailsForUserProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_dashboardSavedEvents)),
      clubsRepositoryProvider.overrideWith((ref) => _captureClubsRepository),
    ],
    builder: (context) => const SavedEventsScreen(),
  ),
  ScreenCaptureEntry(
    id: 'filters_preferences',
    routeIds: const <String>['filtersScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
    ],
    builder: (context) => const FiltersScreen(),
  ),
  ScreenCaptureEntry(
    id: 'event_location_map',
    routeIds: const <String>['eventLocationMapScreen'],
    device: CaptureDevice.reviewPhone,
    builder: (context) => EventLocationMapScreen(
      event: _eventDetailEvent,
      enableNetworkTiles: false,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_location_map_loading',
    routeIds: const <String>['eventLocationMapScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      viewModel: const AsyncLoading<EventDetailViewModel?>(),
    ),
    builder: (context) => EventLocationMapRouteScreen(
      eventId: _eventDetailEvent.id,
      enableNetworkTiles: false,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_location_map_error',
    routeIds: const <String>['eventLocationMapScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      viewModel: AsyncError<EventDetailViewModel?>(
        StateError('Capture event location map load failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => EventLocationMapRouteScreen(
      eventId: _eventDetailEvent.id,
      enableNetworkTiles: false,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_location_map_not_found',
    routeIds: const <String>['eventLocationMapScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _eventDetailCaptureProviderOverrides(
      viewModel: const AsyncData<EventDetailViewModel?>(null),
    ),
    builder: (context) => EventLocationMapRouteScreen(
      eventId: _eventDetailEvent.id,
      enableNetworkTiles: false,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_location_map_no_coordinate',
    routeIds: const <String>['eventLocationMapScreen'],
    device: CaptureDevice.reviewPhone,
    builder: (context) => EventLocationMapScreen(
      event: buildEvent(
        id: 'event-location-map-no-coordinate',
        meetingPoint: 'Secret start line',
        locationDetails: 'Host will add the exact pin shortly.',
      ),
      enableNetworkTiles: false,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_location_map_text_scale_2',
    routeIds: const <String>['eventLocationMapScreen'],
    device: CaptureDevice.reviewPhone,
    textScale: 2,
    builder: (context) => EventLocationMapScreen(
      event: _eventDetailEvent,
      enableNetworkTiles: false,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_location_map_reduced_motion',
    routeIds: const <String>['eventLocationMapScreen'],
    device: CaptureDevice.reviewPhone,
    disableAnimations: true,
    builder: (context) => EventLocationMapScreen(
      event: _eventDetailEvent,
      enableNetworkTiles: false,
    ),
  ),
  ScreenCaptureEntry(
    id: 'member_event_discovery',
    routeIds: const <String>['exploreScreen'],
    device: CaptureDevice.reviewTall,
    marketingFixtureKeys: const <String>['salesDemo.member.eventDiscovery'],
    providerOverrides: [
      cityListProvider.overrideWith((ref) async => _memberDiscoveryCities),
      selectedExploreCityProvider.overrideWithValue(
        _memberDiscoveryCities.first,
      ),
      deviceLocationProvider.overrideWith(_CaptureDeviceLocation.new),
      uidProvider.overrideWith((ref) => Stream.value(null)),
      watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
      exploreSourceClubsProvider.overrideWithValue(
        AsyncData(_memberDiscoveryClubs),
      ),
      exploreViewModelProvider.overrideWithValue(
        AsyncData(
          ExploreViewModel.partition(
            clubs: _memberDiscoveryClubs,
            joinedClubIds: const <String>{},
          ),
        ),
      ),
      exploreFeedViewModelProvider.overrideWithValue(
        AsyncData(ExploreFeedViewModel(items: _memberDiscoveryItems)),
      ),
    ],
    builder: (context) =>
        const ExploreScreen(enableEventMapNetworkTiles: false),
  ),
  ScreenCaptureEntry(
    id: 'explore_loading',
    routeIds: const <String>['exploreScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _exploreProviderOverrides(
      sourceClubs: const AsyncLoading<List<Club>>(),
      viewModel: const AsyncLoading<ExploreViewModel>(),
      feed: const AsyncLoading<ExploreFeedViewModel>(),
    ),
    builder: (context) => _exploreCapture(),
  ),
  ScreenCaptureEntry(
    id: 'explore_club_source_error',
    routeIds: const <String>['exploreScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _exploreProviderOverrides(
      sourceClubs: AsyncError<List<Club>>(
        StateError('Capture Explore clubs failed'),
        StackTrace.empty,
      ),
      viewModel: AsyncError<ExploreViewModel>(
        StateError('Capture Explore clubs failed'),
        StackTrace.empty,
      ),
      feed: const AsyncLoading<ExploreFeedViewModel>(),
    ),
    builder: (context) => _exploreCapture(),
  ),
  ScreenCaptureEntry(
    id: 'explore_feed_error',
    routeIds: const <String>['exploreScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _exploreProviderOverrides(
      feed: AsyncError<ExploreFeedViewModel>(
        StateError('Capture Explore feed failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _exploreCapture(),
  ),
  ScreenCaptureEntry(
    id: 'explore_empty_city',
    routeIds: const <String>['exploreScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _exploreProviderOverrides(
      sourceClubs: const AsyncData<List<Club>>([]),
      viewModel: const AsyncData(
        ExploreViewModel(joinedClubs: [], allClubs: []),
      ),
      feed: const AsyncData(ExploreFeedViewModel(items: [])),
    ),
    builder: (context) => _exploreCapture(),
  ),
  ScreenCaptureEntry(
    id: 'explore_no_search_results',
    routeIds: const <String>['exploreScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _exploreProviderOverrides(
      viewModel: const AsyncData(
        ExploreViewModel(joinedClubs: [], allClubs: []),
      ),
      feed: const AsyncData(ExploreFeedViewModel(items: [])),
    ),
    builder: (context) =>
        _exploreCapture(searchQuery: 'supperclub marathoners worli'),
  ),
  ScreenCaptureEntry(
    id: 'explore_search_query',
    routeIds: const <String>['exploreScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _exploreProviderOverrides(),
    builder: (context) => _exploreCapture(searchQuery: 'pickleball'),
  ),
  ScreenCaptureEntry(
    id: 'explore_filters_active',
    routeIds: const <String>['exploreScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _exploreProviderOverrides(),
    builder: (context) => _exploreCapture(
      seedFilters: const _ExploreCaptureFilterSeed(
        time: ExploreTimeFilter.weekend,
        distance: ExploreDistanceFilter.threeKm,
        activity: ActivityKind.pickleball,
        highRatedOnly: true,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'explore_text_scale_2',
    routeIds: const <String>['exploreScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _exploreProviderOverrides(),
    builder: (context) => _exploreCapture(),
  ),
  ScreenCaptureEntry(
    id: 'explore_reduced_motion',
    routeIds: const <String>['exploreScreen'],
    device: CaptureDevice.reviewTall,
    disableAnimations: true,
    providerOverrides: _exploreProviderOverrides(),
    builder: (context) => _exploreCapture(),
  ),
  ScreenCaptureEntry(
    id: 'explore_map',
    routeIds: const <String>['exploreMapScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [
      deviceLocationProvider.overrideWith(_CaptureDeviceLocation.new),
      exploreFeedViewModelProvider.overrideWithValue(
        AsyncData(ExploreFeedViewModel(items: _memberDiscoveryItems)),
      ),
    ],
    builder: (context) => const ExploreMapScreen(enableNetworkTiles: false),
  ),
  ScreenCaptureEntry(
    id: 'explore_map_loading',
    routeIds: const <String>['exploreMapScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _exploreProviderOverrides(
      feed: const AsyncLoading<ExploreFeedViewModel>(),
    ),
    builder: (context) => _exploreCapture(
      child: const ExploreMapScreen(enableNetworkTiles: false),
    ),
  ),
  ScreenCaptureEntry(
    id: 'explore_map_error',
    routeIds: const <String>['exploreMapScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _exploreProviderOverrides(
      feed: AsyncError<ExploreFeedViewModel>(
        StateError('Capture Explore map feed failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _exploreCapture(
      child: const ExploreMapScreen(enableNetworkTiles: false),
    ),
  ),
  ScreenCaptureEntry(
    id: 'create_club_basics',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) => const CreateClubScreen(restoreSavedDraft: false),
  ),
  ScreenCaptureEntry(
    id: 'create_club_basics_validation',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) => _createClubCapture(showValidation: true),
  ),
  ScreenCaptureEntry(
    id: 'create_club_picked_media',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) =>
        _createClubCapture(useDraft: true, usePickedMedia: true),
  ),
  ScreenCaptureEntry(
    id: 'create_club_draft_restored',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) => _createClubCapture(useDraft: true),
  ),
  ScreenCaptureEntry(
    id: 'create_club_details',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) => _createClubCapture(initialStep: 1, useDraft: true),
  ),
  ScreenCaptureEntry(
    id: 'create_club_host_defaults',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) => _createClubCapture(initialStep: 2, useDraft: true),
  ),
  ScreenCaptureEntry(
    id: 'create_club_event_success_defaults',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) => _createClubCapture(initialStep: 3, useDraft: true),
  ),
  ScreenCaptureEntry(
    id: 'create_club_save_draft_pending',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) => _HostCreateClubMutationCapture(
      mode: _HostCreateClubMutationCaptureMode.saveDraftPending,
      child: _createClubCapture(useDraft: true),
    ),
  ),
  ScreenCaptureEntry(
    id: 'create_club_save_draft_error',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) => _HostCreateClubMutationCapture(
      mode: _HostCreateClubMutationCaptureMode.saveDraftError,
      child: _createClubCapture(useDraft: true),
    ),
  ),
  ScreenCaptureEntry(
    id: 'create_club_submit_pending',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) => _HostCreateClubMutationCapture(
      mode: _HostCreateClubMutationCaptureMode.submitPending,
      child: _createClubCapture(initialStep: 3, useDraft: true),
    ),
  ),
  ScreenCaptureEntry(
    id: 'create_club_submit_error',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) => _HostCreateClubMutationCapture(
      mode: _HostCreateClubMutationCaptureMode.submitError,
      child: _createClubCapture(initialStep: 3, useDraft: true),
    ),
  ),
  ScreenCaptureEntry(
    id: 'create_club_submit_offline',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) => _HostCreateClubMutationCapture(
      mode: _HostCreateClubMutationCaptureMode.submitOffline,
      child: _createClubCapture(initialStep: 3, useDraft: true),
    ),
  ),
  ScreenCaptureEntry(
    id: 'create_club_text_scale_2',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    textScale: 2,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) => _createClubCapture(initialStep: 1, useDraft: true),
  ),
  ScreenCaptureEntry(
    id: 'create_club_reduced_motion',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    disableAnimations: true,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) => _createClubCapture(initialStep: 2, useDraft: true),
  ),
  ScreenCaptureEntry(
    id: 'create_club_light_dark',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateClubProviderOverrides(),
    builder: (context) => _createClubCapture(initialStep: 3, useDraft: true),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_basics',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditClubProviderOverrides(
      fallbackClub: _hostEditClubReferenceClub,
    ),
    builder: (context) => CreateClubScreen(
      initialClub: _hostEditClubReferenceClub,
      restoreSavedDraft: false,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_validation_error',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditClubProviderOverrides(
      fallbackClub: _hostEditClubReferenceClub,
    ),
    builder: (context) => CreateClubScreen(
      initialClub: _hostEditClubReferenceClub.copyWith(
        name: '',
        area: '',
        description: '',
        location: '',
      ),
      restoreSavedDraft: false,
      formAutovalidateMode: AutovalidateMode.always,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_media_replacement',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditClubProviderOverrides(
      fallbackClub: _hostEditClubReferenceClub,
    ),
    builder: (context) => CreateClubScreen(
      initialClub: _hostEditClubReferenceClub,
      restoreSavedDraft: false,
      initialPickedClubPhotos: _createClubPickedPhotos(),
      initialProfileImage: _createClubProfileImage(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_submit_pending',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditClubProviderOverrides(
      fallbackClub: _hostEditClubReferenceClub,
    ),
    builder: (context) => _HostCreateClubMutationCapture(
      mode: _HostCreateClubMutationCaptureMode.submitPending,
      child: CreateClubScreen(
        initialClub: _hostEditClubReferenceClub,
        restoreSavedDraft: false,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_submit_error',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditClubProviderOverrides(
      fallbackClub: _hostEditClubReferenceClub,
    ),
    builder: (context) => _HostCreateClubMutationCapture(
      mode: _HostCreateClubMutationCaptureMode.submitError,
      child: CreateClubScreen(
        initialClub: _hostEditClubReferenceClub,
        restoreSavedDraft: false,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_route_loading',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditClubProviderOverrides(
      clubValue: const AsyncLoading<Club?>(),
    ),
    builder: (context) =>
        HostEditClubRouteScreen(clubId: _dashboardHostClub.id),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_route_error',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditClubProviderOverrides(
      clubValue: AsyncError<Club?>(
        StateError('Capture Host Edit Club fetch failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) =>
        HostEditClubRouteScreen(clubId: _dashboardHostClub.id),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_route_offline',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditClubProviderOverrides(
      clubValue: AsyncError<Club?>(obviousOfflineException(), StackTrace.empty),
    ),
    builder: (context) =>
        HostEditClubRouteScreen(clubId: _dashboardHostClub.id),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_not_found',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditClubProviderOverrides(
      clubValue: const AsyncData<Club?>(null),
    ),
    builder: (context) =>
        HostEditClubRouteScreen(clubId: _dashboardHostClub.id),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_cohost_media',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditClubProviderOverrides(
      uid: HostOperationsFixtures.hostUid,
      fallbackClub: HostOperationsFixtures.coHostedClub,
    ),
    builder: (context) => CreateClubScreen(
      initialClub: HostOperationsFixtures.coHostedClub,
      restoreSavedDraft: false,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_forbidden',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditClubProviderOverrides(
      uid: HostOperationsFixtures.guestUid,
    ),
    builder: (context) => HostEditClubRouteScreen(
      clubId: _dashboardHostClub.id,
      initialClub: _dashboardHostClub,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_text_scale_2',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    textScale: 2,
    providerOverrides: _hostEditClubProviderOverrides(),
    builder: (context) => CreateClubScreen(
      initialClub: _dashboardHostClub,
      restoreSavedDraft: false,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_reduced_motion',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    disableAnimations: true,
    providerOverrides: _hostEditClubProviderOverrides(
      uid: HostOperationsFixtures.hostUid,
      fallbackClub: HostOperationsFixtures.coHostedClub,
    ),
    builder: (context) => CreateClubScreen(
      initialClub: HostOperationsFixtures.coHostedClub,
      restoreSavedDraft: false,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_light_dark',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditClubProviderOverrides(),
    builder: (context) => CreateClubScreen(
      initialClub: _dashboardHostClub,
      restoreSavedDraft: false,
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_create_route_loading',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(
      clubValue: const AsyncLoading<Club?>(),
    ),
    builder: (context) =>
        HostCreateEventRouteScreen(clubId: _dashboardHostClub.id),
  ),
  ScreenCaptureEntry(
    id: 'host_create_route_error',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(
      clubValue: AsyncError<Club?>(
        StateError('Capture Host Create Event club failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) =>
        HostCreateEventRouteScreen(clubId: _dashboardHostClub.id),
  ),
  ScreenCaptureEntry(
    id: 'host_create_route_offline',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(
      clubValue: AsyncError<Club?>(obviousOfflineException(), StackTrace.empty),
    ),
    builder: (context) =>
        HostCreateEventRouteScreen(clubId: _dashboardHostClub.id),
  ),
  ScreenCaptureEntry(
    id: 'host_create_not_found',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(
      clubValue: const AsyncData<Club?>(null),
    ),
    builder: (context) =>
        HostCreateEventRouteScreen(clubId: _dashboardHostClub.id),
  ),
  ScreenCaptureEntry(
    id: 'host_create_basics_validation',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) =>
        _createEventCapture(useDraft: false, showValidation: true),
  ),
  ScreenCaptureEntry(
    id: 'host_create_custom_activity',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) =>
        _createEventCapture(draft: _hostEventCustomActivityDraft),
  ),
  ScreenCaptureEntry(
    id: 'host_create_event_photos',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => _createEventCapture(usePickedMedia: true),
  ),
  ScreenCaptureEntry(
    id: 'host_create_location_selected',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => _createEventCapture(initialStep: 1),
  ),
  ScreenCaptureEntry(
    id: 'host_create_draft_picker',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(
      drafts: [_hostEventSetupDraft],
    ),
    builder: (context) => _createEventCapture(useDraft: false),
  ),
  ScreenCaptureEntry(
    id: 'host_create_draft_restored',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => _createEventCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_create_save_draft_pending',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => _HostCreateEventMutationCapture(
      mode: _HostCreateEventMutationCaptureMode.saveDraftPending,
      child: _createEventCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_create_save_draft_error',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => _HostCreateEventMutationCapture(
      mode: _HostCreateEventMutationCaptureMode.saveDraftError,
      child: _createEventCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_create_submit_pending',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => _HostCreateEventMutationCapture(
      mode: _HostCreateEventMutationCaptureMode.submitPending,
      child: _createEventCapture(initialStep: 4),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_create_submit_error',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => _HostCreateEventMutationCapture(
      mode: _HostCreateEventMutationCaptureMode.submitError,
      child: _createEventCapture(initialStep: 4),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_create_submit_offline',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => _HostCreateEventMutationCapture(
      mode: _HostCreateEventMutationCaptureMode.submitOffline,
      child: _createEventCapture(initialStep: 4),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_create_success_manage',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: [
      ..._hostCreateEventProviderOverrides(),
      celebrationEffectsControllerProvider.overrideWithValue(
        _NoopCelebrationEffectsController(),
      ),
    ],
    builder: (context) => CreateEventSuccessScreen(
      club: _hostCreateSuccessReferenceClub,
      event: _hostCreateSuccessReferenceEvent,
      eventDisplayName: 'Sundowner 5K, Bandra seafront',
      onManageEvent: () {},
      onDone: () {},
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_event_setup',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    marketingFixtureKeys: const <String>['salesDemo.host.eventSetup'],
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => CreateEventScreen(
      club: _dashboardHostClub,
      initialDraft: _hostEventSetupDraft,
      initialStep: 3,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_create_basics',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    marketingFixtureKeys: const <String>['salesDemo.host.createBasics'],
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => CreateEventScreen(
      club: _dashboardHostClub,
      initialDraft: _hostEventSetupDraft,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_create_location',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    marketingFixtureKeys: const <String>['salesDemo.host.createLocation'],
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => CreateEventScreen(
      club: _dashboardHostClub,
      initialDraft: _hostEventSetupDraft,
      initialStep: 1,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_create_schedule',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    marketingFixtureKeys: const <String>['salesDemo.host.createSchedule'],
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => CreateEventScreen(
      club: _dashboardHostClub,
      initialDraft: _hostEventSetupDraft,
      initialStep: 2,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_create_policy',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    marketingFixtureKeys: const <String>['salesDemo.host.createPolicy'],
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => CreateEventScreen(
      club: _dashboardHostClub,
      initialDraft: _hostEventSetupDraft,
      initialStep: 3,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_create_guide',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    marketingFixtureKeys: const <String>['salesDemo.host.createGuide'],
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => CreateEventScreen(
      club: _dashboardHostClub,
      initialDraft: _hostEventSetupDraft,
      initialStep: 4,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_create_text_scale_2',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    textScale: 2,
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => CreateEventScreen(
      club: _dashboardHostClub,
      initialDraft: _hostEventSetupDraft,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_create_reduced_motion',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    disableAnimations: true,
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => CreateEventScreen(
      club: _dashboardHostClub,
      initialDraft: _hostEventSetupDraft,
      initialStep: 2,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_create_light_dark',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostCreateEventProviderOverrides(),
    builder: (context) => CreateEventScreen(
      club: _dashboardHostClub,
      initialDraft: _hostEventSetupDraft,
      initialStep: 4,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditEventProviderOverrides(
      event: _dashboardHostEvent,
    ),
    builder: (context) => EditHostedEventScreen(
      club: _dashboardHostClub,
      event: _dashboardHostEvent,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_route_loading',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditEventProviderOverrides(
      clubValue: const AsyncLoading<Club?>(),
      eventValue: const AsyncLoading<Event?>(),
    ),
    builder: (context) => EditHostedEventRouteScreen(
      clubId: _dashboardHostClub.id,
      eventId: _dashboardEditableHostEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_route_error',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditEventProviderOverrides(
      clubValue: AsyncError<Club?>(
        StateError('Capture Host Edit Event club failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => EditHostedEventRouteScreen(
      clubId: _dashboardHostClub.id,
      eventId: _dashboardEditableHostEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_offline',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditEventProviderOverrides(
      clubValue: AsyncError<Club?>(obviousOfflineException(), StackTrace.empty),
    ),
    builder: (context) => EditHostedEventRouteScreen(
      clubId: _dashboardHostClub.id,
      eventId: _dashboardEditableHostEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_not_found',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditEventProviderOverrides(
      eventValue: const AsyncData<Event?>(null),
    ),
    builder: (context) => EditHostedEventRouteScreen(
      clubId: _dashboardHostClub.id,
      eventId: _dashboardEditableHostEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_unauthorized',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditEventProviderOverrides(
      uid: HostOperationsFixtures.guestUid,
    ),
    builder: (context) => EditHostedEventRouteScreen(
      clubId: _dashboardHostClub.id,
      eventId: _dashboardEditableHostEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_schedule_locked',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditEventProviderOverrides(
      event: _dashboardHostEvent,
    ),
    builder: (context) => EditHostedEventScreen(
      club: _dashboardHostClub,
      event: _dashboardHostEvent,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_cancelled',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditEventProviderOverrides(
      event: _dashboardCancelledHostEvent,
    ),
    builder: (context) => EditHostedEventScreen(
      club: _dashboardHostClub,
      event: _dashboardCancelledHostEvent,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_private_access_loading',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostEditEventProviderOverrides(
      event: _dashboardPrivateAccessHostEvent,
      privateAccessValue: const AsyncLoading<EventPrivateAccess?>(),
    ),
    builder: (context) => EditHostedEventScreen(
      club: _dashboardHostClub,
      event: _dashboardPrivateAccessHostEvent,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_validation_error',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostEditEventProviderOverrides(
      event: _dashboardValidationHostEvent,
    ),
    builder: (context) => EditHostedEventScreen(
      club: _dashboardHostClub,
      event: _dashboardValidationHostEvent,
      loadMapTiles: false,
      now: () => _captureNow,
      formAutovalidateMode: AutovalidateMode.always,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_location_selected',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditEventProviderOverrides(
      event: _dashboardPinnedLocationHostEvent,
    ),
    builder: (context) => EditHostedEventScreen(
      club: _dashboardHostClub,
      event: _dashboardPinnedLocationHostEvent,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_submit_pending',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditEventProviderOverrides(
      event: _dashboardEditableHostEvent,
    ),
    builder: (context) => _HostEditEventMutationCapture(
      mode: _HostEditEventMutationCaptureMode.submitPending,
      child: EditHostedEventScreen(
        club: _dashboardHostClub,
        event: _dashboardEditableHostEvent,
        loadMapTiles: false,
        now: () => _captureNow,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_submit_error',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditEventProviderOverrides(
      event: _dashboardEditableHostEvent,
    ),
    builder: (context) => _HostEditEventMutationCapture(
      mode: _HostEditEventMutationCaptureMode.submitError,
      child: EditHostedEventScreen(
        club: _dashboardHostClub,
        event: _dashboardEditableHostEvent,
        loadMapTiles: false,
        now: () => _captureNow,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_text_scale_2',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.iphone17Pro,
    textScale: 2,
    providerOverrides: _hostEditEventProviderOverrides(
      event: _dashboardEditableHostEvent,
    ),
    builder: (context) => EditHostedEventScreen(
      club: _dashboardHostClub,
      event: _dashboardEditableHostEvent,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_reduced_motion',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.iphone17Pro,
    disableAnimations: true,
    providerOverrides: _hostEditEventProviderOverrides(
      event: _dashboardEditableHostEvent,
    ),
    builder: (context) => EditHostedEventScreen(
      club: _dashboardHostClub,
      event: _dashboardEditableHostEvent,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'edit_hosted_event_light_dark',
    routeIds: const <String>['hostAppEditEventScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostEditEventProviderOverrides(
      event: _dashboardEditableHostEvent,
    ),
    builder: (context) => EditHostedEventScreen(
      club: _dashboardHostClub,
      event: _dashboardEditableHostEvent,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_route_loading',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      clubValue: const AsyncLoading<Club?>(),
      eventValue: const AsyncLoading<Event?>(),
    ),
    builder: (context) => _hostManageRouteCapture(includeInitialEvent: false),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_initial_event_extra',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      eventValue: const AsyncLoading<Event?>(),
    ),
    builder: (context) => _hostManageRouteCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_route_error',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      clubValue: AsyncError<Club?>(
        StateError('Capture Host Manage club failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _hostManageRouteCapture(includeInitialEvent: false),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_route_offline',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      clubValue: AsyncError<Club?>(obviousOfflineException(), StackTrace.empty),
    ),
    builder: (context) => _hostManageRouteCapture(includeInitialEvent: false),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_not_found',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      eventValue: const AsyncData<Event?>(null),
    ),
    builder: (context) => _hostManageRouteCapture(includeInitialEvent: false),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_unauthorized',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      uid: HostOperationsFixtures.guestUid,
    ),
    builder: (context) => _hostManageRouteCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_attendance_loading',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      attendanceValue: const AsyncLoading<AttendanceSheetViewModel?>(),
    ),
    builder: (context) => _hostManageRouteCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_attendance_error',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      attendanceValue: AsyncError<AttendanceSheetViewModel?>(
        StateError('Capture Host Manage attendance failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _hostManageRouteCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_attendance_empty',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      attendanceValue: const AsyncData<AttendanceSheetViewModel?>(null),
    ),
    builder: (context) => _hostManageRouteCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_attendee_profiles_loading',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      attendeeProfilesValue:
          const AsyncLoading<Map<String, (String, String?)>>(),
    ),
    builder: (context) => _hostManageRouteCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_attendee_profiles_error',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      attendeeProfilesValue: AsyncError<Map<String, (String, String?)>>(
        StateError('Capture Host Manage profile lookup failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _hostManageRouteCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_filtered_roster_empty',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(),
    builder: (context) => _hostManageRouteCapture(
      initialParticipantSearchQuery: 'no matching guest',
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_private_access_loading',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(
      privateAccessValue: const AsyncLoading<EventPrivateAccess?>(),
    ),
    builder: (context) => _hostManageRouteCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_private_access_error',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(
      privateAccessValue: AsyncError<EventPrivateAccess?>(
        StateError('Capture Host Manage private access failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _hostManageRouteCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_invite_links_loading',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(
      inviteLinksValue: const AsyncLoading<List<EventInviteLink>>(),
    ),
    builder: (context) => _hostManageRouteCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_invite_links_error',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(
      inviteLinksValue: AsyncError<List<EventInviteLink>>(
        StateError('Capture Host Manage invite links failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _hostManageRouteCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_invite_links_empty',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(
      inviteLinksValue: const AsyncData<List<EventInviteLink>>(
        <EventInviteLink>[],
      ),
    ),
    builder: (context) => _hostManageRouteCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_invite_link_mutation_pending',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(),
    builder: (context) => _HostManageInviteLinkMutationCapture(
      mode: _HostManageInviteLinkMutationCaptureMode.pending,
      child: _hostManageRouteCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_invite_link_mutation_error',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(),
    builder: (context) => _HostManageInviteLinkMutationCapture(
      mode: _HostManageInviteLinkMutationCaptureMode.error,
      child: _hostManageRouteCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_private_link_share_pending',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(),
    builder: (context) => _HostManagePrivateLinkShareMutationCapture(
      mode: _HostManagePrivateLinkShareMutationCaptureMode.pending,
      child: _hostManageRouteCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_private_link_share_error',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(),
    builder: (context) => _HostManagePrivateLinkShareMutationCapture(
      mode: _HostManagePrivateLinkShareMutationCaptureMode.error,
      child: _hostManageRouteCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_edit_event_action',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(),
    builder: (context) => _hostManageRouteCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_cancel_event_pending',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(),
    builder: (context) => _HostManageActionMutationCapture(
      mode: _HostManageActionMutationCaptureMode.cancelPending,
      child: _hostManageRouteCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_cancel_event_error',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(),
    builder: (context) => _HostManageActionMutationCapture(
      mode: _HostManageActionMutationCaptureMode.cancelError,
      child: _hostManageRouteCapture(),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_delete_event_pending',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(
      event: HostOperationsFixtures.unusedEvent,
      participations: const <EventParticipation>[],
    ),
    builder: (context) => _HostManageActionMutationCapture(
      mode: _HostManageActionMutationCaptureMode.deletePending,
      child: _hostManageRouteCapture(event: HostOperationsFixtures.unusedEvent),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_delete_event_error',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(
      event: HostOperationsFixtures.unusedEvent,
      participations: const <EventParticipation>[],
    ),
    builder: (context) => _HostManageActionMutationCapture(
      mode: _HostManageActionMutationCaptureMode.deleteError,
      child: _hostManageRouteCapture(event: HostOperationsFixtures.unusedEvent),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_cancelled_event',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      event: HostOperationsFixtures.cancelledEvent,
    ),
    builder: (context) =>
        _hostManageRouteCapture(event: HostOperationsFixtures.cancelledEvent),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_text_scale_2',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    textScale: 2,
    providerOverrides: _hostManageRouteProviderOverrides(),
    builder: (context) => _hostManageRouteCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_reduced_motion',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    disableAnimations: true,
    providerOverrides: _hostManageRouteProviderOverrides(),
    builder: (context) =>
        _hostManageRouteCapture(initialSection: HostEventManageSection.live),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_light_dark',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(),
    builder: (context) =>
        _hostManageRouteCapture(initialSection: HostEventManageSection.report),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_report_export_pending',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(),
    builder: (context) => _HostManageReportExportMutationCapture(
      mode: _HostManageReportExportMutationCaptureMode.pending,
      child: _hostManageRouteCapture(
        initialSection: HostEventManageSection.report,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_report_export_error',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostManageRouteProviderOverrides(),
    builder: (context) => _HostManageReportExportMutationCapture(
      mode: _HostManageReportExportMutationCaptureMode.error,
      child: _hostManageRouteCapture(
        initialSection: HostEventManageSection.report,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_setup_private_access',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      uid: _captureViewerUid,
      club: _hostManageReferenceClub,
      event: _hostManageReferenceEvent,
      participations: _hostManageReferenceParticipations,
    ),
    builder: (context) => _hostManageRouteCapture(
      club: _hostManageReferenceClub,
      event: _hostManageReferenceEvent,
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_full_waitlist_apron',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      uid: _captureViewerUid,
      club: _hostManageReferenceClub,
      event: _hostManageFullReferenceEvent,
      participations: _hostManageFullReferenceParticipations,
    ),
    builder: (context) => _hostManageRouteCapture(
      club: _hostManageReferenceClub,
      event: _hostManageFullReferenceEvent,
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_attendance_mutation_pending',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageLiveWindowProviderOverrides(),
    builder: (context) => _HostManageAttendanceMutationCapture(
      mode: _HostManageAttendanceMutationCaptureMode.pending,
      child: HostEventManageScreen(
        club: _dashboardHostClub,
        event: _hostLiveWindowEvent,
        onBackToSuccess: () {},
        initialSection: HostEventManageSection.live,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_attendance_mutation_error',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageLiveWindowProviderOverrides(),
    builder: (context) => _HostManageAttendanceMutationCapture(
      mode: _HostManageAttendanceMutationCaptureMode.error,
      child: HostEventManageScreen(
        club: _dashboardHostClub,
        event: _hostLiveWindowEvent,
        onBackToSuccess: () {},
        initialSection: HostEventManageSection.live,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_attendance_roster',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: [
      uidProvider.overrideWith((ref) => Stream.value(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      watchEventProvider(
        _hostEvent.id,
      ).overrideWith((ref) => Stream.value(_hostEvent)),
      eventParticipationRepositoryProvider.overrideWithValue(
        _hostParticipationRepository,
      ),
      publicProfileRepositoryProvider.overrideWithValue(
        _hostPublicProfileRepository,
      ),
      watchEventSuccessPlanProvider(
        _hostEvent.id,
      ).overrideWith((ref) => Stream.value(_hostLivePlan)),
      watchEventSuccessScorecardProvider(
        _hostEvent.id,
      ).overrideWith((ref) => Stream.value(null)),
      ..._hostEventSuccessProviderOverrides,
    ],
    builder: (context) => HostEventManageScreen(
      club: _dashboardHostClub,
      event: _hostEvent,
      onBackToSuccess: () {},
      initialSection: HostEventManageSection.guests,
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_manage_live_unavailable',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostManageRouteProviderOverrides(
      planValue: const AsyncData<EventSuccessPlan?>(null),
    ),
    builder: (context) =>
        _hostManageRouteCapture(initialSection: HostEventManageSection.live),
  ),
  ScreenCaptureEntry(
    id: 'host_live_console',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    marketingFixtureKeys: const <String>['salesDemo.host.liveConsole'],
    providerOverrides: [
      uidProvider.overrideWith((ref) => Stream.value(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      watchEventProvider(
        _hostLiveReferenceEvent.id,
      ).overrideWith((ref) => Stream.value(_hostLiveReferenceEvent)),
      eventParticipationRepositoryProvider.overrideWithValue(
        _hostLiveReferenceParticipationRepository,
      ),
      publicProfileRepositoryProvider.overrideWithValue(
        _hostLiveReferencePublicProfileRepository,
      ),
      watchEventSuccessPlanProvider(
        _hostLiveReferenceEvent.id,
      ).overrideWith((ref) => Stream.value(_hostLiveReferencePlan)),
      watchEventSuccessScorecardProvider(
        _hostLiveReferenceEvent.id,
      ).overrideWith((ref) => Stream.value(null)),
      ..._hostEventSuccessProviderOverrides,
    ],
    builder: (context) => HostEventManageScreen(
      club: _hostLiveReferenceClub,
      event: _hostLiveReferenceEvent,
      onBackToSuccess: () {},
      initialSection: HostEventManageSection.live,
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_post_event_report',
    routeIds: const <String>['hostAppEventManageScreen'],
    device: CaptureDevice.iphone17Pro,
    marketingFixtureKeys: const <String>['salesDemo.host.postEventReport'],
    providerOverrides: [
      uidProvider.overrideWith((ref) => Stream.value(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      watchEventProvider(
        _hostEvent.id,
      ).overrideWith((ref) => Stream.value(_hostEvent)),
      eventParticipationRepositoryProvider.overrideWithValue(
        _hostParticipationRepository,
      ),
      publicProfileRepositoryProvider.overrideWithValue(
        _hostPublicProfileRepository,
      ),
      watchEventSuccessPlanProvider(
        _hostEvent.id,
      ).overrideWith((ref) => Stream.value(_hostReportPlan)),
      watchEventSuccessScorecardProvider(
        _hostEvent.id,
      ).overrideWith((ref) => Stream.value(_hostReportScorecard)),
      ..._hostEventSuccessProviderOverrides,
    ],
    builder: (context) => HostEventManageScreen(
      club: _dashboardHostClub,
      event: _hostEvent,
      onBackToSuccess: () {},
      initialSection: HostEventManageSection.report,
    ),
  ),
  ScreenCaptureEntry(
    id: 'post_run_catch_window',
    routeIds: const <String>['swipeEventScreen'],
    device: CaptureDevice.reviewTall,
    marketingFixtureKeys: const <String>['salesDemo.member.postRunCatchWindow'],
    providerOverrides: [
      uidProvider.overrideWith((ref) => Stream.value(_postRunViewer.uid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_postRunViewer),
      ),
      watchEventProvider(
        _postRunEvent.id,
      ).overrideWith((ref) => Stream.value(_postRunEvent)),
      watchEventParticipationProvider(
        _postRunEvent.id,
        _postRunViewer.uid,
      ).overrideWith((ref) => Stream.value(_postRunViewerParticipation)),
      swipeQueueProvider(
        _postRunEvent.id,
      ).overrideWithBuild((ref, notifier) async => _postRunProfiles),
    ],
    builder: (context) =>
        SwipeScreen(eventId: _postRunEvent.id, now: _captureNow),
  ),
  ScreenCaptureEntry(
    id: 'swipe_hub_active',
    routeIds: const <String>['swipeHubScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeHubProviderOverrides(),
    builder: (context) => SwipeHubScreen(now: CatchesSurfaceFixtures.now),
  ),
  ScreenCaptureEntry(
    id: 'swipe_hub_uid_loading',
    routeIds: const <String>['swipeHubScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeHubProviderOverrides(
      uidValue: const AsyncLoading<String?>(),
    ),
    builder: (context) => SwipeHubScreen(now: CatchesSurfaceFixtures.now),
  ),
  ScreenCaptureEntry(
    id: 'swipe_hub_uid_error',
    routeIds: const <String>['swipeHubScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeHubProviderOverrides(
      uidValue: AsyncError<String?>(
        StateError('Capture Catches session failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => SwipeHubScreen(now: CatchesSurfaceFixtures.now),
  ),
  ScreenCaptureEntry(
    id: 'swipe_hub_signed_out',
    routeIds: const <String>['swipeHubScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeHubProviderOverrides(
      uidValue: const AsyncData<String?>(null),
    ),
    builder: (context) => SwipeHubScreen(now: CatchesSurfaceFixtures.now),
  ),
  ScreenCaptureEntry(
    id: 'swipe_hub_attended_events_loading',
    routeIds: const <String>['swipeHubScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeHubProviderOverrides(
      eventsValue: const AsyncLoading<List<Event>>(),
    ),
    builder: (context) => SwipeHubScreen(now: CatchesSurfaceFixtures.now),
  ),
  ScreenCaptureEntry(
    id: 'swipe_hub_attended_events_error',
    routeIds: const <String>['swipeHubScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeHubProviderOverrides(
      eventsValue: AsyncError<List<Event>>(
        StateError('Capture Catches events failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => SwipeHubScreen(now: CatchesSurfaceFixtures.now),
  ),
  ScreenCaptureEntry(
    id: 'swipe_hub_offline',
    routeIds: const <String>['swipeHubScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeHubProviderOverrides(
      eventsValue: AsyncError<List<Event>>(
        _catchesOfflineException(action: 'load attended events'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => SwipeHubScreen(now: CatchesSurfaceFixtures.now),
  ),
  ScreenCaptureEntry(
    id: 'swipe_hub_empty',
    routeIds: const <String>['swipeHubScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeHubProviderOverrides(
      eventsValue: AsyncData<List<Event>>([_catchesClosedEvent]),
    ),
    builder: (context) => SwipeHubScreen(now: CatchesSurfaceFixtures.now),
  ),
  ScreenCaptureEntry(
    id: 'swipe_hub_text_scale_2',
    routeIds: const <String>['swipeHubScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _swipeHubProviderOverrides(),
    builder: (context) => SwipeHubScreen(now: CatchesSurfaceFixtures.now),
  ),
  ScreenCaptureEntry(
    id: 'swipe_hub_reduced_motion',
    routeIds: const <String>['swipeHubScreen'],
    device: CaptureDevice.reviewTall,
    disableAnimations: true,
    providerOverrides: _swipeHubProviderOverrides(),
    builder: (context) => SwipeHubScreen(now: CatchesSurfaceFixtures.now),
  ),
  ScreenCaptureEntry(
    id: 'swipe_event_queue_loading',
    routeIds: const <String>['swipeEventScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeDeckProviderOverrides(
      event: _catchesOpenEvent,
      queue: () => Completer<List<PublicProfile>>().future,
    ),
    builder: (context) => SwipeScreen(
      eventId: _catchesOpenEvent.id,
      now: CatchesSurfaceFixtures.now,
    ),
  ),
  ScreenCaptureEntry(
    id: 'swipe_event_queue_error',
    routeIds: const <String>['swipeEventScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeDeckProviderOverrides(
      event: _catchesOpenEvent,
      queue: () => Future<List<PublicProfile>>.error(
        StateError('Capture Catches queue failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => SwipeScreen(
      eventId: _catchesOpenEvent.id,
      now: CatchesSurfaceFixtures.now,
    ),
  ),
  ScreenCaptureEntry(
    id: 'swipe_event_offline',
    routeIds: const <String>['swipeEventScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeDeckProviderOverrides(
      event: _catchesOpenEvent,
      queue: () => Future<List<PublicProfile>>.error(
        _catchesOfflineException(action: 'load swipe candidates'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => SwipeScreen(
      eventId: _catchesOpenEvent.id,
      now: CatchesSurfaceFixtures.now,
    ),
  ),
  ScreenCaptureEntry(
    id: 'swipe_event_empty_queue',
    routeIds: const <String>['swipeEventScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeDeckProviderOverrides(
      event: _catchesOpenEvent,
      queue: () async => const <PublicProfile>[],
    ),
    builder: (context) => SwipeScreen(
      eventId: _catchesOpenEvent.id,
      now: CatchesSurfaceFixtures.now,
    ),
  ),
  ScreenCaptureEntry(
    id: 'swipe_event_missing',
    routeIds: const <String>['swipeEventScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeDeckProviderOverrides(
      event: _catchesOpenEvent,
      eventStream: Stream<Event?>.value(null),
      queue: () async => const <PublicProfile>[],
    ),
    builder: (context) => SwipeScreen(
      eventId: _catchesOpenEvent.id,
      now: CatchesSurfaceFixtures.now,
    ),
  ),
  ScreenCaptureEntry(
    id: 'swipe_event_sign_in_required',
    routeIds: const <String>['swipeEventScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeDeckProviderOverrides(
      event: _catchesOpenEvent,
      uid: null,
      profileStream: Stream<UserProfile?>.value(null),
      queue: () async => const <PublicProfile>[],
    ),
    builder: (context) => SwipeScreen(
      eventId: _catchesOpenEvent.id,
      now: CatchesSurfaceFixtures.now,
    ),
  ),
  ScreenCaptureEntry(
    id: 'swipe_event_in_progress',
    routeIds: const <String>['swipeEventScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeDeckProviderOverrides(
      event: _catchesUpcomingEvent,
      participation: CatchesSurfaceFixtures.attendedParticipation(
        event: _catchesUpcomingEvent,
      ),
      queue: () async => const <PublicProfile>[],
    ),
    builder: (context) => SwipeScreen(
      eventId: _catchesUpcomingEvent.id,
      now: CatchesSurfaceFixtures.now,
    ),
  ),
  ScreenCaptureEntry(
    id: 'swipe_event_did_not_attend',
    routeIds: const <String>['swipeEventScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeDeckProviderOverrides(
      event: _catchesOpenEvent,
      participation: CatchesSurfaceFixtures.signedUpParticipation(
        event: _catchesOpenEvent,
      ),
      queue: () async => const <PublicProfile>[],
    ),
    builder: (context) => SwipeScreen(
      eventId: _catchesOpenEvent.id,
      now: CatchesSurfaceFixtures.now,
    ),
  ),
  ScreenCaptureEntry(
    id: 'swipe_event_window_closed',
    routeIds: const <String>['swipeEventScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _swipeDeckProviderOverrides(
      event: _catchesClosedEvent,
      participation: CatchesSurfaceFixtures.attendedParticipation(
        event: _catchesClosedEvent,
      ),
      queue: () async => const <PublicProfile>[],
    ),
    builder: (context) => SwipeScreen(
      eventId: _catchesClosedEvent.id,
      now: CatchesSurfaceFixtures.now,
    ),
  ),
  ScreenCaptureEntry(
    id: 'swipe_event_text_scale_2',
    routeIds: const <String>['swipeEventScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _swipeDeckProviderOverrides(event: _catchesOpenEvent),
    builder: (context) => SwipeScreen(
      eventId: _catchesOpenEvent.id,
      now: CatchesSurfaceFixtures.now,
    ),
  ),
  ScreenCaptureEntry(
    id: 'swipe_event_reduced_motion',
    routeIds: const <String>['swipeEventScreen'],
    device: CaptureDevice.reviewTall,
    disableAnimations: true,
    providerOverrides: _swipeDeckProviderOverrides(event: _catchesOpenEvent),
    builder: (context) => SwipeScreen(
      eventId: _catchesOpenEvent.id,
      now: CatchesSurfaceFixtures.now,
    ),
  ),
  ScreenCaptureEntry(
    id: 'notifications_activity',
    routeIds: const <String>['notificationsScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchActivityNotificationsProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_activityScreenNotifications)),
      watchSignedUpEventsProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_dashboardSignedUpEvents)),
    ],
    builder: (context) => const ActivityScreen(),
  ),
  ScreenCaptureEntry(
    id: 'notifications_mark_all_read_pending',
    routeIds: const <String>['notificationsScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchActivityNotificationsProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_activityScreenNotifications)),
      watchSignedUpEventsProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_dashboardSignedUpEvents)),
    ],
    builder: (context) => const _ActivityMarkAllReadCapture(
      mode: _ActivityMarkAllReadCaptureMode.pending,
    ),
  ),
  ScreenCaptureEntry(
    id: 'notifications_mark_all_read_error',
    routeIds: const <String>['notificationsScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchActivityNotificationsProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_activityScreenNotifications)),
      watchSignedUpEventsProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_dashboardSignedUpEvents)),
    ],
    builder: (context) => const _ActivityMarkAllReadCapture(
      mode: _ActivityMarkAllReadCaptureMode.error,
    ),
  ),
  ScreenCaptureEntry(
    id: 'notifications_deep_link_error',
    routeIds: const <String>['notificationsScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchActivityNotificationsProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_activityScreenNotifications)),
      watchSignedUpEventsProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_dashboardSignedUpEvents)),
    ],
    builder: (context) => const _ActivityDeepLinkErrorCapture(),
  ),
  ScreenCaptureEntry(
    id: 'notifications_uid_loading',
    routeIds: const <String>['notificationsScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [uidProvider.overrideWithValue(const AsyncLoading())],
    builder: (context) => const ActivityScreen(),
  ),
  ScreenCaptureEntry(
    id: 'notifications_signed_out',
    routeIds: const <String>['notificationsScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [uidProvider.overrideWithValue(const AsyncData(null))],
    builder: (context) => const ActivityScreen(),
  ),
  ScreenCaptureEntry(
    id: 'notifications_activity_loading',
    routeIds: const <String>['notificationsScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchActivityNotificationsProvider(
        _captureViewerUid,
      ).overrideWithValue(const AsyncLoading()),
    ],
    builder: (context) => const ActivityScreen(),
  ),
  ScreenCaptureEntry(
    id: 'notifications_activity_error',
    routeIds: const <String>['notificationsScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchActivityNotificationsProvider(_captureViewerUid).overrideWithValue(
        AsyncError<List<ActivityNotification>>(
          StateError('Activity unavailable'),
          StackTrace.empty,
        ),
      ),
    ],
    builder: (context) => const ActivityScreen(),
  ),
  ScreenCaptureEntry(
    id: 'notifications_empty',
    routeIds: const <String>['notificationsScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchActivityNotificationsProvider(
        _captureViewerUid,
      ).overrideWithValue(const AsyncData(<ActivityNotification>[])),
    ],
    builder: (context) => const ActivityScreen(),
  ),
  ScreenCaptureEntry(
    id: 'notifications_text_scale_2',
    routeIds: const <String>['notificationsScreen'],
    device: CaptureDevice.reviewPhone,
    textScale: 2,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchActivityNotificationsProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_activityScreenNotifications)),
    ],
    builder: (context) => const ActivityScreen(),
  ),
  ScreenCaptureEntry(
    id: 'notifications_reduced_motion',
    routeIds: const <String>['notificationsScreen'],
    device: CaptureDevice.reviewPhone,
    disableAnimations: true,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchActivityNotificationsProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_activityScreenNotifications)),
    ],
    builder: (context) => const ActivityScreen(),
  ),
  ScreenCaptureEntry(
    id: 'event_recap_attendees',
    routeIds: const <String>['eventRecapScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchEventProvider(
        _eventRecapEvent.id,
      ).overrideWith((ref) => Stream.value(_eventRecapEvent)),
      eventParticipationRepositoryProvider.overrideWithValue(
        _eventRecapParticipationRepository,
      ),
      for (final profile in _eventRecapProfiles)
        watchPublicProfileProvider(
          profile.uid,
        ).overrideWith((ref) => Stream.value(profile)),
    ],
    builder: (context) => EventRecapScreen(eventId: _eventRecapEvent.id),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_route_loading',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionRouteProviderOverrides(
      eventValue: const AsyncLoading<Event?>(),
    ),
    builder: (context) => EventSuccessCompanionRouteScreen(
      clubId: _eventSuccessCompanionEvent.clubId,
      eventId: _eventSuccessCompanionEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_event_load_error',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionRouteProviderOverrides(
      eventValue: AsyncError<Event?>(
        StateError('Capture companion event failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => EventSuccessCompanionRouteScreen(
      clubId: _eventSuccessCompanionEvent.clubId,
      eventId: _eventSuccessCompanionEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_event_not_found',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionRouteProviderOverrides(
      eventValue: const AsyncData<Event?>(null),
    ),
    builder: (context) => EventSuccessCompanionRouteScreen(
      clubId: _eventSuccessCompanionEvent.clubId,
      eventId: _eventSuccessCompanionEvent.id,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_sign_in_required',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionRouteProviderOverrides(
      uidValue: const AsyncData<String?>(null),
    ),
    builder: (context) => EventSuccessCompanionRouteScreen(
      clubId: _eventSuccessCompanionEvent.clubId,
      eventId: _eventSuccessCompanionEvent.id,
      initialEvent: _eventSuccessCompanionEvent,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_no_booking',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionRouteProviderOverrides(
      participationValue: const AsyncData<EventParticipation?>(null),
    ),
    builder: (context) => EventSuccessCompanionRouteScreen(
      clubId: _eventSuccessCompanionEvent.clubId,
      eventId: _eventSuccessCompanionEvent.id,
      initialEvent: _eventSuccessCompanionEvent,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_profile_loading',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionRouteProviderOverrides(
      profileValue: const AsyncLoading<UserProfile?>(),
    ),
    builder: (context) => EventSuccessCompanionRouteScreen(
      clubId: _eventSuccessCompanionEvent.clubId,
      eventId: _eventSuccessCompanionEvent.id,
      initialEvent: _eventSuccessCompanionEvent,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_participation_error',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionRouteProviderOverrides(
      participationValue: AsyncError<EventParticipation?>(
        StateError('Capture companion participation failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => EventSuccessCompanionRouteScreen(
      clubId: _eventSuccessCompanionEvent.clubId,
      eventId: _eventSuccessCompanionEvent.id,
      initialEvent: _eventSuccessCompanionEvent,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_plan_loading',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionRouteProviderOverrides(
      planValue: const AsyncLoading<EventSuccessPlan?>(),
    ),
    builder: (context) => EventSuccessCompanionRouteScreen(
      clubId: _eventSuccessCompanionEvent.clubId,
      eventId: _eventSuccessCompanionEvent.id,
      initialEvent: _eventSuccessCompanionEvent,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_plan_error',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionRouteProviderOverrides(
      planValue: AsyncError<EventSuccessPlan?>(
        StateError('Capture companion plan failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => EventSuccessCompanionRouteScreen(
      clubId: _eventSuccessCompanionEvent.clubId,
      eventId: _eventSuccessCompanionEvent.id,
      initialEvent: _eventSuccessCompanionEvent,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_plan_missing',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionRouteProviderOverrides(
      planValue: const AsyncData<EventSuccessPlan?>(null),
    ),
    builder: (context) => EventSuccessCompanionRouteScreen(
      clubId: _eventSuccessCompanionEvent.clubId,
      eventId: _eventSuccessCompanionEvent.id,
      initialEvent: _eventSuccessCompanionEvent,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_data_error',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionRouteProviderOverrides(
      profileValue: AsyncError<UserProfile?>(
        StateError('Capture companion profile failed'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => EventSuccessCompanionRouteScreen(
      clubId: _eventSuccessCompanionEvent.clubId,
      eventId: _eventSuccessCompanionEvent.id,
      initialEvent: _eventSuccessCompanionEvent,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_offline',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionRouteProviderOverrides(
      planValue: AsyncError<EventSuccessPlan?>(
        _eventSuccessCompanionOfflineException(action: 'load event guide'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => EventSuccessCompanionRouteScreen(
      clubId: _eventSuccessCompanionEvent.clubId,
      eventId: _eventSuccessCompanionEvent.id,
      initialEvent: _eventSuccessCompanionEvent,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: [
      uidProvider.overrideWith((ref) => Stream.value(_captureViewerUid)),
      eventSuccessLiveEffectsControllerProvider.overrideWith(
        (ref) => _NoopEventSuccessLiveEffectsController(),
      ),
    ],
    builder: (context) => EventSuccessCompanionScreen(
      event: _eventSuccessCompanionEvent,
      plan: _eventSuccessCompanionPlan,
      userProfile: _captureViewer,
      participation: _eventSuccessCompanionParticipation,
      wingmanRequestCandidates: _matchesListProfiles,
      now: _captureNow,
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_self_check_in',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      now: EventSuccessCompanionFixtures.socialStart.subtract(
        const Duration(minutes: 5),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_pre_arrival_planning',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      event: EventSuccessCompanionFixtures.racketEvent,
      plan: EventSuccessCompanionFixtures.revealUnlockedPlan,
      participation: EventSuccessCompanionFixtures.signedUpParticipation(
        event: EventSuccessCompanionFixtures.racketEvent,
      ),
      now: EventSuccessCompanionFixtures.racketStart.subtract(
        const Duration(hours: 1),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_first_hello_start',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      plan: EventSuccessCompanionFixtures.firstHelloPlan,
      now: EventSuccessCompanionFixtures.socialStart.subtract(
        const Duration(minutes: 5),
      ),
      onStartArrivalMission: () async {},
      onSkipArrivalMission: () {},
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_first_hello_assigned',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      plan: EventSuccessCompanionFixtures.firstHelloPlan,
      arrivalMission: EventSuccessCompanionFixtures.arrivalMission,
      now: EventSuccessCompanionFixtures.socialStart.subtract(
        const Duration(minutes: 5),
      ),
      onCompleteArrivalMission: (_, _) async {},
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_compatibility_questionnaire',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      plan: EventSuccessCompanionFixtures.questionnairePlan,
      now: EventSuccessCompanionFixtures.socialStart.add(
        const Duration(minutes: 30),
      ),
      onSaveCompatibilityAnswers: (_) async {},
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_compatibility_saved',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      plan: EventSuccessCompanionFixtures.questionnairePlan,
      compatibilityResponse:
          EventSuccessCompanionFixtures.compatibilityResponse,
      now: EventSuccessCompanionFixtures.socialStart.add(
        const Duration(minutes: 30),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_live_step_context',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      event: EventSuccessCompanionFixtures.racketEvent,
      plan: EventSuccessCompanionFixtures.liveStepContextPlan,
      participation: EventSuccessCompanionFixtures.attendedParticipation(
        event: EventSuccessCompanionFixtures.racketEvent,
      ),
      rotationAssignment: EventSuccessCompanionFixtures.rotationAssignment,
      rotationPeerProfiles: const [EventSuccessCompanionFixtures.peer],
      now: EventSuccessCompanionFixtures.racketStart.add(
        const Duration(minutes: 25),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_social_prompt',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      plan: EventSuccessCompanionFixtures.socialPromptPlan,
      participation: EventSuccessCompanionFixtures.attendedParticipation(),
      now: EventSuccessCompanionFixtures.socialStart.add(
        const Duration(minutes: 12),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_conversation_cues',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      plan: EventSuccessCompanionFixtures.conversationCuesPlan,
      participation: EventSuccessCompanionFixtures.attendedParticipation(),
      now: EventSuccessCompanionFixtures.socialStart.add(
        const Duration(minutes: 50),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_micro_pod_assignment',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      participation: EventSuccessCompanionFixtures.attendedParticipation(),
      assignment: EventSuccessCompanionFixtures.microPodAssignment,
      assignmentPeerProfiles: EventSuccessCompanionFixtures.peers,
      now: EventSuccessCompanionFixtures.socialStart.subtract(
        const Duration(hours: 1),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_micro_pod_loading_peers',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      participation: EventSuccessCompanionFixtures.attendedParticipation(),
      assignment: EventSuccessCompanionFixtures.microPodAssignment,
      assignmentPeersLoading: true,
      now: EventSuccessCompanionFixtures.socialStart.subtract(
        const Duration(hours: 1),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_micro_pod_opted_out',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      participation: EventSuccessCompanionFixtures.attendedParticipation(),
      microPodsOptedOut: true,
      now: EventSuccessCompanionFixtures.socialStart.subtract(
        const Duration(hours: 1),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_table_group_rotations',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      participation: EventSuccessCompanionFixtures.attendedParticipation(),
      assignment: EventSuccessCompanionFixtures.tableAssignment,
      assignmentPeerProfiles: EventSuccessCompanionFixtures.peers,
      now: EventSuccessCompanionFixtures.socialStart.subtract(
        const Duration(hours: 1),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_rotation_schedule',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      event: EventSuccessCompanionFixtures.racketEvent,
      plan: EventSuccessCompanionFixtures.rotationSchedulePlan,
      participation: EventSuccessCompanionFixtures.attendedParticipation(
        event: EventSuccessCompanionFixtures.racketEvent,
      ),
      rotationAssignment: EventSuccessCompanionFixtures.rotationAssignment,
      rotationPeerProfiles: const [EventSuccessCompanionFixtures.peer],
      now: EventSuccessCompanionFixtures.racketStart.subtract(
        const Duration(hours: 1),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_rotation_loading_peers',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      event: EventSuccessCompanionFixtures.racketEvent,
      plan: EventSuccessCompanionFixtures.rotationSchedulePlan,
      participation: EventSuccessCompanionFixtures.attendedParticipation(
        event: EventSuccessCompanionFixtures.racketEvent,
      ),
      rotationAssignment: EventSuccessCompanionFixtures.rotationAssignment,
      rotationPeersLoading: true,
      now: EventSuccessCompanionFixtures.racketStart.subtract(
        const Duration(hours: 1),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_rotation_opted_out',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      event: EventSuccessCompanionFixtures.racketEvent,
      plan: EventSuccessCompanionFixtures.rotationSchedulePlan,
      participation: EventSuccessCompanionFixtures.attendedParticipation(
        event: EventSuccessCompanionFixtures.racketEvent,
      ),
      guidedRotationsOptedOut: true,
      now: EventSuccessCompanionFixtures.racketStart.subtract(
        const Duration(hours: 1),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_live_reveal_countdown',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      event: EventSuccessCompanionFixtures.racketEvent,
      plan: EventSuccessCompanionFixtures.revealCountingDownPlan,
      participation: EventSuccessCompanionFixtures.attendedParticipation(
        event: EventSuccessCompanionFixtures.racketEvent,
      ),
      rotationAssignment: EventSuccessCompanionFixtures.rotationAssignment,
      rotationPeerProfiles: const [EventSuccessCompanionFixtures.peer],
      now: EventSuccessCompanionFixtures.racketStart.subtract(
        const Duration(hours: 1),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_live_reveal_unlocked',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      event: EventSuccessCompanionFixtures.racketEvent,
      plan: EventSuccessCompanionFixtures.revealUnlockedPlan,
      participation: EventSuccessCompanionFixtures.attendedParticipation(
        event: EventSuccessCompanionFixtures.racketEvent,
      ),
      rotationAssignment: EventSuccessCompanionFixtures.rotationAssignment,
      rotationPeerProfiles: const [EventSuccessCompanionFixtures.peer],
      now: EventSuccessCompanionFixtures.racketStart.subtract(
        const Duration(hours: 1),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_wingman_request',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      plan: EventSuccessCompanionFixtures.wingmanPlan,
      participation: EventSuccessCompanionFixtures.attendedParticipation(),
      wingmanRequestCandidates: EventSuccessCompanionFixtures.peers,
      now: EventSuccessCompanionFixtures.socialStart.add(
        const Duration(hours: 1),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_wingman_submitted',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      plan: EventSuccessCompanionFixtures.wingmanPlan,
      participation: EventSuccessCompanionFixtures.attendedParticipation(),
      wingmanRequestCandidates: EventSuccessCompanionFixtures.peers,
      wingmanRequest: EventSuccessCompanionFixtures.wingmanRequest,
      now: EventSuccessCompanionFixtures.socialStart.add(
        const Duration(hours: 1),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_afterglow_feedback',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    builder: (context) => _eventSuccessCompanionCapture(
      participation: EventSuccessCompanionFixtures.attendedParticipation(),
      existingFeedback: EventSuccessCompanionFixtures.feedback,
      now: EventSuccessCompanionFixtures.socialEvent.endTime.add(
        const Duration(hours: 2),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_text_scale_2',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    textScale: 2,
    builder: (context) => _eventSuccessCompanionCapture(
      participation: EventSuccessCompanionFixtures.attendedParticipation(),
      assignment: EventSuccessCompanionFixtures.microPodAssignment,
      assignmentPeerProfiles: EventSuccessCompanionFixtures.peers,
      now: EventSuccessCompanionFixtures.socialStart.subtract(
        const Duration(hours: 1),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'event_success_companion_reduced_motion',
    routeIds: const <String>['eventSuccessCompanionScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _eventSuccessCompanionProviderOverrides(),
    disableAnimations: true,
    builder: (context) => _eventSuccessCompanionCapture(
      event: EventSuccessCompanionFixtures.racketEvent,
      plan: EventSuccessCompanionFixtures.revealUnlockedPlan,
      participation: EventSuccessCompanionFixtures.attendedParticipation(
        event: EventSuccessCompanionFixtures.racketEvent,
      ),
      rotationAssignment: EventSuccessCompanionFixtures.rotationAssignment,
      rotationPeerProfiles: const [EventSuccessCompanionFixtures.peer],
      now: EventSuccessCompanionFixtures.racketStart.subtract(
        const Duration(hours: 1),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'matches_list_loading',
    routeIds: const <String>['matchesListScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchesListProviderOverrides(
      viewModel: const AsyncLoading<ChatsListViewModel>(),
    ),
    builder: (context) => _matchesListCapture(),
  ),
  ScreenCaptureEntry(
    id: 'matches_list_error',
    routeIds: const <String>['matchesListScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchesListProviderOverrides(
      viewModel: AsyncError<ChatsListViewModel>(
        StateError('Capture matches failed'),
        StackTrace.empty,
      ),
      matchesError: StateError('Capture matches failed'),
    ),
    builder: (context) => _matchesListCapture(),
  ),
  ScreenCaptureEntry(
    id: 'matches_list_offline',
    routeIds: const <String>['matchesListScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchesListProviderOverrides(
      viewModel: AsyncError<ChatsListViewModel>(
        _matchesOfflineException(action: 'load matches'),
        StackTrace.empty,
      ),
      matchesError: _matchesOfflineException(action: 'load matches'),
    ),
    builder: (context) => _matchesListCapture(),
  ),
  ScreenCaptureEntry(
    id: 'matches_list_no_matches_empty',
    routeIds: const <String>['matchesListScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchesListProviderOverrides(
      matches: const <Match>[],
      viewModel: const AsyncData<ChatsListViewModel>(
        ChatsListViewModel(
          newMatches: <ChatThreadPreview>[],
          conversations: <ChatThreadPreview>[],
          totalThreadCount: 0,
        ),
      ),
    ),
    builder: (context) => _matchesListCapture(),
  ),
  ScreenCaptureEntry(
    id: 'matches_list_search_open',
    routeIds: const <String>['matchesListScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchesListProviderOverrides(),
    builder: (context) => _matchesListCapture(searchQuery: 'Taylor'),
  ),
  ScreenCaptureEntry(
    id: 'matches_list_search_empty',
    routeIds: const <String>['matchesListScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchesListProviderOverrides(
      viewModel: const AsyncData<ChatsListViewModel>(
        ChatsListViewModel(
          newMatches: <ChatThreadPreview>[],
          conversations: <ChatThreadPreview>[],
          totalThreadCount: 3,
        ),
      ),
    ),
    builder: (context) =>
        _matchesListCapture(searchQuery: 'no dinner runners nearby'),
  ),
  ScreenCaptureEntry(
    id: 'matches_list_duplicate_collapsed',
    routeIds: const <String>['matchesListScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchesListProviderOverrides(
      matches: _matchesCaptureDuplicateMatches,
    ),
    builder: (context) => _matchesListCapture(),
  ),
  ScreenCaptureEntry(
    id: 'matches_list_match_celebration',
    routeIds: const <String>['matchesListScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: [
      ..._matchesListProviderOverrides(),
      celebrationEffectsControllerProvider.overrideWithValue(
        _NoopCelebrationEffectsController(),
      ),
    ],
    builder: (context) => const _MatchCelebrationCapture(),
  ),
  ScreenCaptureEntry(
    id: 'matches_list_text_scale_2',
    routeIds: const <String>['matchesListScreen'],
    device: CaptureDevice.iphone17Pro,
    textScale: 2,
    providerOverrides: _matchesListProviderOverrides(),
    builder: (context) => _matchesListCapture(),
  ),
  ScreenCaptureEntry(
    id: 'matches_list_reduced_motion',
    routeIds: const <String>['matchesListScreen'],
    device: CaptureDevice.iphone17Pro,
    disableAnimations: true,
    providerOverrides: _matchesListProviderOverrides(),
    builder: (context) => _matchesListCapture(),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_context',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.iphone17Pro,
    marketingFixtureKeys: const <String>['salesDemo.member.matchChatContext'],
    providerOverrides: [
      uidProvider.overrideWith((ref) => Stream.value(_matchChatViewerUid)),
      matchRepositoryProvider.overrideWithValue(_matchChatMatchRepository),
      conversationRepositoryProvider.overrideWithValue(
        _matchChatConversationRepository,
      ),
      watchEventProvider(
        _matchChatEvent.id,
      ).overrideWith((ref) => Stream.value(_matchChatEvent)),
      watchPublicProfileProvider(
        _matchChatOtherProfile.uid,
      ).overrideWith((ref) => Stream.value(_matchChatOtherProfile)),
    ],
    builder: (context) => ChatScreen(
      matchId: _matchChatMatch.id,
      otherProfile: _matchChatOtherProfile,
    ),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_messages_loading',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchChatProviderOverrides(messagesLoading: true),
    builder: (context) => _matchChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_messages_error',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchChatProviderOverrides(
      messagesError: StateError('Capture messages failed'),
    ),
    builder: (context) => _matchChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_offline',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchChatProviderOverrides(
      messagesError: _matchesOfflineException(
        action: 'load conversation messages',
      ),
    ),
    builder: (context) => _matchChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_empty_thread',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchChatProviderOverrides(
      match: MatchesChatSurfaceFixtures.newMatch(),
      messages: const <ChatMessage>[],
    ),
    builder: (context) =>
        _matchChatCapture(match: MatchesChatSurfaceFixtures.newMatch()),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_event_context_fallback',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchChatProviderOverrides(includeEvent: false),
    builder: (context) => _matchChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_unavailable',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchChatProviderOverrides(
      matchId: 'design-chat-missing',
    ),
    builder: (context) => _matchChatCapture(
      matchId: 'design-chat-missing',
      includeInitialProfile: false,
    ),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_blocked',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchChatProviderOverrides(
      match: MatchesChatSurfaceFixtures.blockedMatch(),
    ),
    builder: (context) =>
        _matchChatCapture(match: MatchesChatSurfaceFixtures.blockedMatch()),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_image_thread',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchChatProviderOverrides(
      messages: MatchesChatSurfaceFixtures.imageMessages,
    ),
    builder: (context) => _matchChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_suvbot_controls',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchChatProviderOverrides(
      match: MatchesChatSurfaceFixtures.suvbotMatch(),
      messages: [
        MatchesChatSurfaceFixtures.message(
          id: 'suvbot-msg-1',
          senderId: suvbotUid,
          text: 'I can refresh your seeded demo state.',
          sentAt: MatchesChatSurfaceFixtures.now.subtract(
            const Duration(minutes: 3),
          ),
        ),
      ],
    ),
    builder: (context) =>
        _matchChatCapture(match: MatchesChatSurfaceFixtures.suvbotMatch()),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_suvbot_action_error',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _matchChatProviderOverrides(
      match: MatchesChatSurfaceFixtures.suvbotMatch(),
      messages: const <ChatMessage>[],
      suvbotRepository: MatchesChatFixtureSuvbotRepository(
        error: StateError('Capture Suvbot failed'),
      ),
    ),
    builder: (context) =>
        _matchChatCapture(match: MatchesChatSurfaceFixtures.suvbotMatch()),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_share_card',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.reviewTall,
    builder: (context) => const _ChatShareCardCapture(),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_composer_states',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.reviewPhone,
    builder: (context) => const _ChatComposerStatesCapture(),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_text_scale_2',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.iphone17Pro,
    textScale: 2,
    providerOverrides: _matchChatProviderOverrides(),
    builder: (context) => _matchChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'match_chat_reduced_motion',
    routeIds: const <String>['chatScreen'],
    device: CaptureDevice.iphone17Pro,
    disableAnimations: true,
    providerOverrides: _matchChatProviderOverrides(),
    builder: (context) => _matchChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'matches_list_context',
    routeIds: const <String>['matchesListScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: [
      uidProvider.overrideWith((ref) => Stream.value(_matchChatViewerUid)),
      matchRepositoryProvider.overrideWithValue(_matchesListMatchRepository),
      for (final profile in _matchesListProfiles)
        watchPublicProfileProvider(
          profile.uid,
        ).overrideWith((ref) => Stream.value(profile)),
    ],
    builder: (context) => const ChatsListScreen(),
  ),
  ScreenCaptureEntry(
    id: 'host_inbox_queries',
    routeIds: const <String>['hostInboxScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostInboxProviderOverrides(),
    builder: (context) => const _AppRoleCapture(
      role: AppRole.host,
      child: _ReferenceChromeSafeArea(child: ChatsListScreen()),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_inbox_uid_loading',
    routeIds: const <String>['hostInboxScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostInboxProviderOverrides(
      uid: null,
      viewModel: const AsyncLoading<ChatsListViewModel>(),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: ChatsListScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_inbox_loading',
    routeIds: const <String>['hostInboxScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostInboxProviderOverrides(
      viewModel: const AsyncLoading<ChatsListViewModel>(),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: ChatsListScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_inbox_error',
    routeIds: const <String>['hostInboxScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostInboxProviderOverrides(
      viewModel: AsyncError<ChatsListViewModel>(
        StateError('Capture host inbox failed'),
        StackTrace.empty,
      ),
      matchesError: StateError('Capture host inbox failed'),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: ChatsListScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_inbox_offline',
    routeIds: const <String>['hostInboxScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostInboxProviderOverrides(
      viewModel: AsyncError<ChatsListViewModel>(
        _matchesOfflineException(action: 'load host inbox'),
        StackTrace.empty,
      ),
      matchesError: _matchesOfflineException(action: 'load host inbox'),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: ChatsListScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_inbox_empty',
    routeIds: const <String>['hostInboxScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostInboxProviderOverrides(
      matches: const <Match>[],
      viewModel: const AsyncData<ChatsListViewModel>(
        ChatsListViewModel(
          newMatches: <ChatThreadPreview>[],
          conversations: <ChatThreadPreview>[],
          totalThreadCount: 0,
        ),
      ),
    ),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: ChatsListScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_inbox_unread_filter',
    routeIds: const <String>['hostInboxScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostUnreadFilteredInboxProviderOverrides(),
    builder: (context) => const _HostUnreadOnlyInboxCapture(),
  ),
  ScreenCaptureEntry(
    id: 'matches_host_unread_empty',
    routeIds: const <String>['hostInboxScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostUnreadOnlyInboxProviderOverrides(),
    builder: (context) => const _HostUnreadOnlyInboxCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_inbox_search_active',
    routeIds: const <String>['hostInboxScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostInboxProviderOverrides(),
    builder: (context) =>
        _matchesListCapture(role: AppRole.host, searchQuery: 'Aarav'),
  ),
  ScreenCaptureEntry(
    id: 'host_inbox_search_empty',
    routeIds: const <String>['hostInboxScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostInboxSearchEmptyProviderOverrides(),
    builder: (context) => _matchesListCapture(
      role: AppRole.host,
      searchQuery: 'No attendee by this name',
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_inbox_new_query',
    routeIds: const <String>['hostInboxScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostNewInquiryProviderOverrides(),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: ChatsListScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_inbox_text_scale_2',
    routeIds: const <String>['hostInboxScreen'],
    device: CaptureDevice.iphone17Pro,
    textScale: 2,
    providerOverrides: _hostInboxProviderOverrides(),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: ChatsListScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_inbox_reduced_motion',
    routeIds: const <String>['hostInboxScreen'],
    device: CaptureDevice.iphone17Pro,
    disableAnimations: true,
    providerOverrides: _hostInboxProviderOverrides(),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: ChatsListScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_inbox_light_dark',
    routeIds: const <String>['hostInboxScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostInboxProviderOverrides(),
    builder: (context) =>
        const _AppRoleCapture(role: AppRole.host, child: ChatsListScreen()),
  ),
  ScreenCaptureEntry(
    id: 'host_chat_inquiry',
    routeIds: const <String>['hostChatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostChatProviderOverrides(),
    builder: (context) => _hostChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_chat_match_loading',
    routeIds: const <String>['hostChatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostChatProviderOverrides(matchLoading: true),
    builder: (context) => _hostChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_chat_match_error',
    routeIds: const <String>['hostChatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostChatProviderOverrides(
      matchError: StateError('Capture host chat failed'),
    ),
    builder: (context) => _hostChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_chat_not_found',
    routeIds: const <String>['hostChatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostChatProviderOverrides(
      matchId: 'design-host-chat-missing',
    ),
    builder: (context) => _hostChatCapture(matchId: 'design-host-chat-missing'),
  ),
  ScreenCaptureEntry(
    id: 'host_chat_messages_loading',
    routeIds: const <String>['hostChatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostChatProviderOverrides(messagesLoading: true),
    builder: (context) => _hostChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_chat_messages_error',
    routeIds: const <String>['hostChatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostChatProviderOverrides(
      messagesError: StateError('Capture host messages failed'),
    ),
    builder: (context) => _hostChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_chat_offline',
    routeIds: const <String>['hostChatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostChatProviderOverrides(
      messagesError: _matchesOfflineException(
        action: 'load host inquiry messages',
      ),
    ),
    builder: (context) => _hostChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_chat_empty_thread',
    routeIds: const <String>['hostChatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostChatProviderOverrides(
      messages: const <ChatMessage>[],
    ),
    builder: (context) => _hostChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_chat_event_context_fallback',
    routeIds: const <String>['hostChatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostChatProviderOverrides(includeEvent: false),
    builder: (context) => _hostChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_chat_blocked',
    routeIds: const <String>['hostChatScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: _hostChatProviderOverrides(
      match: _hostInquiryMatch.copyWith(
        status: MatchStatus.blocked,
        blockedBy: MatchesChatSurfaceFixtures.guestUid,
        blockedAt: MatchesChatSurfaceFixtures.now.subtract(
          const Duration(hours: 2),
        ),
      ),
    ),
    builder: (context) => _hostChatCapture(
      match: _hostInquiryMatch.copyWith(
        status: MatchStatus.blocked,
        blockedBy: MatchesChatSurfaceFixtures.guestUid,
        blockedAt: MatchesChatSurfaceFixtures.now.subtract(
          const Duration(hours: 2),
        ),
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'host_chat_text_scale_2',
    routeIds: const <String>['hostChatScreen'],
    device: CaptureDevice.iphone17Pro,
    textScale: 2,
    providerOverrides: _hostChatProviderOverrides(),
    builder: (context) => _hostChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_chat_reduced_motion',
    routeIds: const <String>['hostChatScreen'],
    device: CaptureDevice.iphone17Pro,
    disableAnimations: true,
    providerOverrides: _hostChatProviderOverrides(),
    builder: (context) => _hostChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_chat_light_dark',
    routeIds: const <String>['hostChatScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _hostChatProviderOverrides(),
    builder: (context) => _hostChatCapture(),
  ),
  ScreenCaptureEntry(
    id: 'host_chat_composer_states',
    routeIds: const <String>['hostChatScreen'],
    device: CaptureDevice.reviewPhone,
    builder: (context) => const _ChatComposerStatesCapture(role: AppRole.host),
  ),
  ScreenCaptureEntry(
    id: 'public_profile_member',
    routeIds: const <String>['publicProfileScreen'],
    device: CaptureDevice.reviewTall,
    precache: const <ImageProvider<Object>>[_profilePortraitAssetImage],
    providerOverrides: [
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(ProfileSurfaceFixtures.viewer),
      ),
      watchPublicProfileProvider(
        _publicProfileReferenceProfile.uid,
      ).overrideWith((ref) => Stream.value(_publicProfileReferenceProfile)),
    ],
    builder: (context) => PublicProfileScreen(
      uid: _publicProfileReferenceProfile.uid,
      initialProfile: _publicProfileReferenceProfile,
      sharedRunTitle: 'Sundowner 5K',
    ),
  ),
  ScreenCaptureEntry(
    id: 'public_profile_loading',
    routeIds: const <String>['publicProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _publicProfileProviderOverrides(
      profileStream: _captureLoadingStream<PublicProfile?>(),
    ),
    builder: (context) => _publicProfileCapture(),
  ),
  ScreenCaptureEntry(
    id: 'public_profile_initial_fallback_loading',
    routeIds: const <String>['publicProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _publicProfileProviderOverrides(
      profileStream: _captureLoadingStream<PublicProfile?>(),
    ),
    builder: (context) =>
        _publicProfileCapture(initialProfile: _profileCaptureTargetNoNetwork),
  ),
  ScreenCaptureEntry(
    id: 'public_profile_error',
    routeIds: const <String>['publicProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _publicProfileProviderOverrides(
      profileStream: _captureErrorStream<PublicProfile?>(
        'Capture public profile failed',
      ),
    ),
    builder: (context) => _publicProfileCapture(),
  ),
  ScreenCaptureEntry(
    id: 'public_profile_offline',
    routeIds: const <String>['publicProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _publicProfileProviderOverrides(
      profileStream: Stream<PublicProfile?>.error(
        ProfileSurfaceFixtures.offlineException(action: 'load public profile'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => _publicProfileCapture(),
  ),
  ScreenCaptureEntry(
    id: 'public_profile_unavailable',
    routeIds: const <String>['publicProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _publicProfileProviderOverrides(
      profileStream: Stream<PublicProfile?>.value(null),
    ),
    builder: (context) => _publicProfileCapture(),
  ),
  ScreenCaptureEntry(
    id: 'public_profile_own_profile',
    routeIds: const <String>['publicProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _publicProfileProviderOverrides(
      uid: ProfileSurfaceFixtures.ownUid,
      profile: _profileCaptureOwnNoNetwork,
    ),
    builder: (context) =>
        _publicProfileCapture(uid: ProfileSurfaceFixtures.ownUid),
  ),
  ScreenCaptureEntry(
    id: 'public_profile_block_pending',
    routeIds: const <String>['publicProfileScreen'],
    device: CaptureDevice.reviewTall,
    builder: (context) => const _PublicProfilePendingOverlayCapture(),
  ),
  ScreenCaptureEntry(
    id: 'public_profile_report_sheet',
    routeIds: const <String>['publicProfileScreen'],
    device: CaptureDevice.reviewPhone,
    builder: (context) => const _PublicProfileReportSheetCapture(),
  ),
  ScreenCaptureEntry(
    id: 'public_profile_block_confirmation',
    routeIds: const <String>['publicProfileScreen'],
    device: CaptureDevice.reviewPhone,
    builder: (context) => const _PublicProfileBlockDialogCapture(),
  ),
  ScreenCaptureEntry(
    id: 'public_profile_text_scale_2',
    routeIds: const <String>['publicProfileScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _publicProfileProviderOverrides(),
    builder: (context) => _publicProfileCapture(),
  ),
  ScreenCaptureEntry(
    id: 'public_profile_reduced_motion',
    routeIds: const <String>['publicProfileScreen'],
    device: CaptureDevice.reviewTall,
    disableAnimations: true,
    providerOverrides: _publicProfileProviderOverrides(),
    builder: (context) => _publicProfileCapture(),
  ),
  ScreenCaptureEntry(
    id: 'reviews_history_signed_out',
    routeIds: const <String>['reviewsHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _reviewsHistoryProviderOverrides(
      uid: const AsyncData<String?>(null),
    ),
    builder: (context) => const ReviewsHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'reviews_history_profile_loading',
    routeIds: const <String>['reviewsHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _reviewsHistoryProviderOverrides(
      profileStream: _captureLoadingStream<UserProfile?>(),
    ),
    builder: (context) => const ReviewsHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'reviews_history_profile_error',
    routeIds: const <String>['reviewsHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _reviewsHistoryProviderOverrides(
      profileStream: _captureErrorStream<UserProfile?>(
        'Capture reviews profile failed',
      ),
    ),
    builder: (context) => const ReviewsHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'reviews_history_reviews_loading',
    routeIds: const <String>['reviewsHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _reviewsHistoryProviderOverrides(
      reviews: const AsyncLoading<List<Review>>(),
    ),
    builder: (context) => const ReviewsHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'reviews_history_reviews_error',
    routeIds: const <String>['reviewsHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _reviewsHistoryProviderOverrides(
      reviews: AsyncError<List<Review>>(
        StateError('Review history unavailable'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => const ReviewsHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'reviews_history_empty',
    routeIds: const <String>['reviewsHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _reviewsHistoryProviderOverrides(
      reviews: const AsyncData(<Review>[]),
    ),
    builder: (context) => const ReviewsHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'reviews_history_list',
    routeIds: const <String>['reviewsHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _reviewsHistoryProviderOverrides(),
    builder: (context) => const ReviewsHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'reviews_history_missing_event_context',
    routeIds: const <String>['reviewsHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _reviewsHistoryProviderOverrides(
      reviews: AsyncData(_reviewHistoryMissingContextReviews),
      events: const AsyncData(<Event>[]),
    ),
    builder: (context) => const ReviewsHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'reviews_history_text_scale_2',
    routeIds: const <String>['reviewsHistoryScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _reviewsHistoryProviderOverrides(),
    builder: (context) => const ReviewsHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'reviews_history_reduced_motion',
    routeIds: const <String>['reviewsHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    disableAnimations: true,
    providerOverrides: _reviewsHistoryProviderOverrides(),
    builder: (context) => const ReviewsHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'settings_account',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(),
    builder: (context) => const SettingsScreen(),
  ),
  ScreenCaptureEntry(
    id: 'settings_profile_loading',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(
      profileStream: _captureLoadingStream<UserProfile?>(),
    ),
    builder: (context) => const SettingsScreen(),
  ),
  ScreenCaptureEntry(
    id: 'settings_profile_error',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(
      profileStream: _captureErrorStream<UserProfile?>(
        'Capture settings profile failed',
      ),
    ),
    builder: (context) => const SettingsScreen(),
  ),
  ScreenCaptureEntry(
    id: 'settings_profile_offline',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(
      profileStream: Stream<UserProfile?>.error(
        obviousOfflineException(),
        StackTrace.empty,
      ),
    ),
    builder: (context) => const SettingsScreen(),
  ),
  ScreenCaptureEntry(
    id: 'settings_profile_missing',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(
      profileStream: Stream.value(null),
    ),
    builder: (context) => const SettingsScreen(),
  ),
  ScreenCaptureEntry(
    id: 'settings_blocked_loading',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(
      blockedUsersStream: _captureLoadingStream<List<BlockedUser>>(),
    ),
    builder: (context) => const SettingsScreen(),
  ),
  ScreenCaptureEntry(
    id: 'settings_blocked_error',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(
      blockedUsersStream: _captureErrorStream<List<BlockedUser>>(
        'Capture blocked users failed',
      ),
    ),
    builder: (context) => const SettingsScreen(),
  ),
  ScreenCaptureEntry(
    id: 'settings_blocked_offline',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(
      blockedUsersStream: Stream<List<BlockedUser>>.error(
        obviousOfflineException(),
        StackTrace.empty,
      ),
    ),
    builder: (context) => const SettingsScreen(),
  ),
  ScreenCaptureEntry(
    id: 'settings_blocked_list',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(
      blockedUsers: _settingsBlockedUsers,
      publicProfiles: UtilitySurfaceFixtures.blockedPublicProfiles,
    ),
    builder: (context) => const SettingsScreen(),
  ),
  ScreenCaptureEntry(
    id: 'settings_text_scale_2',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _settingsAccountProviderOverrides(
      blockedUsers: _settingsBlockedUsers,
      publicProfiles: UtilitySurfaceFixtures.blockedPublicProfiles,
    ),
    builder: (context) => const SettingsScreen(),
  ),
  ScreenCaptureEntry(
    id: 'settings_reduced_motion',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    disableAnimations: true,
    providerOverrides: _settingsAccountProviderOverrides(
      blockedUsers: _settingsBlockedUsers,
      publicProfiles: UtilitySurfaceFixtures.blockedPublicProfiles,
    ),
    builder: (context) => const SettingsScreen(),
  ),
  ScreenCaptureEntry(
    id: 'settings_preference_pending',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(),
    builder: (context) => const _SettingsMutationCapture(
      mode: _SettingsMutationCaptureMode.preferencePending,
    ),
  ),
  ScreenCaptureEntry(
    id: 'settings_preference_error',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(),
    builder: (context) => const _SettingsMutationCapture(
      mode: _SettingsMutationCaptureMode.preferenceError,
    ),
  ),
  ScreenCaptureEntry(
    id: 'settings_preference_offline',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(),
    builder: (context) => const _SettingsMutationCapture(
      mode: _SettingsMutationCaptureMode.preferenceOffline,
    ),
  ),
  ScreenCaptureEntry(
    id: 'settings_delete_pending',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(),
    builder: (context) => const _SettingsMutationCapture(
      mode: _SettingsMutationCaptureMode.deletePending,
    ),
  ),
  ScreenCaptureEntry(
    id: 'settings_delete_error',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(),
    builder: (context) => const _SettingsMutationCapture(
      mode: _SettingsMutationCaptureMode.deleteError,
    ),
  ),
  ScreenCaptureEntry(
    id: 'settings_delete_offline',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(),
    builder: (context) => const _SettingsMutationCapture(
      mode: _SettingsMutationCaptureMode.deleteOffline,
    ),
  ),
  ScreenCaptureEntry(
    id: 'settings_sign_out_pending',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(),
    builder: (context) => const _SettingsMutationCapture(
      mode: _SettingsMutationCaptureMode.signOutPending,
    ),
  ),
  ScreenCaptureEntry(
    id: 'settings_sign_out_error',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(),
    builder: (context) => const _SettingsMutationCapture(
      mode: _SettingsMutationCaptureMode.signOutError,
    ),
  ),
  ScreenCaptureEntry(
    id: 'settings_sign_out_offline',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(),
    builder: (context) => const _SettingsMutationCapture(
      mode: _SettingsMutationCaptureMode.signOutOffline,
    ),
  ),
  ScreenCaptureEntry(
    id: 'settings_unblock_pending',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(
      blockedUsers: _settingsBlockedUsers,
      publicProfiles: UtilitySurfaceFixtures.blockedPublicProfiles,
    ),
    builder: (context) => const _SettingsMutationCapture(
      mode: _SettingsMutationCaptureMode.unblockPending,
    ),
  ),
  ScreenCaptureEntry(
    id: 'settings_unblock_error',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(
      blockedUsers: _settingsBlockedUsers,
      publicProfiles: UtilitySurfaceFixtures.blockedPublicProfiles,
    ),
    builder: (context) => const _SettingsMutationCapture(
      mode: _SettingsMutationCaptureMode.unblockError,
    ),
  ),
  ScreenCaptureEntry(
    id: 'settings_unblock_offline',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: _settingsAccountProviderOverrides(
      blockedUsers: _settingsBlockedUsers,
      publicProfiles: UtilitySurfaceFixtures.blockedPublicProfiles,
    ),
    builder: (context) => const _SettingsMutationCapture(
      mode: _SettingsMutationCaptureMode.unblockOffline,
    ),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_uid_loading',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _paymentHistoryProviderOverrides(
      uid: const AsyncLoading<String?>(),
    ),
    builder: (context) => const PaymentHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_signed_out',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _paymentHistoryProviderOverrides(
      uid: const AsyncData<String?>(null),
    ),
    builder: (context) => const PaymentHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_uid_error',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _paymentHistoryProviderOverrides(
      uid: AsyncError<String?>(
        StateError('Payment identity unavailable'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => const PaymentHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_uid_offline',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _paymentHistoryProviderOverrides(
      uid: AsyncError<String?>(obviousOfflineException(), StackTrace.empty),
    ),
    builder: (context) => const PaymentHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_loading',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _paymentHistoryProviderOverrides(
      payments: const AsyncLoading<List<Payment>>(),
    ),
    builder: (context) => const PaymentHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_error',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _paymentHistoryProviderOverrides(
      payments: AsyncError<List<Payment>>(
        StateError('Payment history unavailable'),
        StackTrace.empty,
      ),
    ),
    builder: (context) => const PaymentHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_payments_offline',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _paymentHistoryProviderOverrides(
      payments: AsyncError<List<Payment>>(
        obviousOfflineException(),
        StackTrace.empty,
      ),
    ),
    builder: (context) => const PaymentHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_empty',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _paymentHistoryProviderOverrides(
      payments: const AsyncData(<Payment>[]),
    ),
    builder: (context) => const PaymentHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_populated',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _paymentHistoryProviderOverrides(),
    builder: (context) => const PaymentHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_receipt_sheet',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    builder: (context) =>
        _PaymentReceiptSheetCapture(payment: _paymentHistoryPayments.first),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_failed_signup_receipt_sheet',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    builder: (context) => _PaymentReceiptSheetCapture(
      payment: _paymentHistoryPayments.firstWhere(
        (payment) => payment.signUpFailed,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_support_snackbar',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    builder: (context) => _PaymentSupportSnackBarCapture(
      payment: _paymentHistoryPayments.firstWhere(
        (payment) => payment.signUpFailed,
      ),
    ),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_missing_event_title',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: _paymentHistoryProviderOverrides(
      events: AsyncData(_paymentHistoryEvents.take(3).toList()),
    ),
    builder: (context) => const PaymentHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_text_scale_2',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewTall,
    textScale: 2,
    providerOverrides: _paymentHistoryProviderOverrides(),
    builder: (context) => const PaymentHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_reduced_motion',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    disableAnimations: true,
    providerOverrides: _paymentHistoryProviderOverrides(),
    builder: (context) => const PaymentHistoryScreen(),
  ),
];

ScreenCaptureEntry findScreenCapture(String id) {
  for (final entry in screenCaptureCatalog) {
    if (entry.id == id) return entry;
  }
  throw ArgumentError.value(id, 'id', 'Unknown screen capture id.');
}

class _ExploreCaptureStateSeed extends ConsumerStatefulWidget {
  const _ExploreCaptureStateSeed({
    required this.child,
    this.searchQuery,
    this.seedFilters = const _ExploreCaptureFilterSeed(),
  });

  final Widget child;
  final String? searchQuery;
  final _ExploreCaptureFilterSeed seedFilters;

  @override
  ConsumerState<_ExploreCaptureStateSeed> createState() =>
      _ExploreCaptureStateSeedState();
}

class _ExploreCaptureStateSeedState
    extends ConsumerState<_ExploreCaptureStateSeed> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(selectedExploreCityProvider.notifier)
          .setCity(_memberDiscoveryCities.first);
      final query = widget.searchQuery;
      if (query != null) {
        ref.read(exploreSearchQueryProvider.notifier).setQuery(query);
      }
      widget.seedFilters.apply(ref.read(exploreFiltersProvider.notifier));
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ExploreCaptureFilterSeed {
  const _ExploreCaptureFilterSeed({
    this.time,
    this.distance,
    this.activity,
    this.highRatedOnly = false,
  });

  final ExploreTimeFilter? time;
  final ExploreDistanceFilter? distance;
  final ActivityKind? activity;
  final bool highRatedOnly;

  void apply(ExploreFilters notifier) {
    final timeValue = time;
    if (timeValue != null) notifier.setTimeFilter(timeValue);
    final distanceValue = distance;
    if (distanceValue != null) notifier.setDistanceFilter(distanceValue);
    final activityValue = activity;
    if (activityValue != null) notifier.toggleActivityTag(activityValue.name);
    if (highRatedOnly) notifier.toggleHighRatedOnly();
  }
}

final class _NoOpAnalyticsReporter implements AnalyticsReporter {
  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserId(String? userId) async {}
}

ProfileReactionTarget _target(
  String id,
  SwipeReactionTargetType type,
  String label,
) => ProfileReactionTarget(id: id, type: type, label: label, preview: label);

final _profileFixture = ProfileView(
  name: 'Aanya',
  age: 27,
  heroPhoto: _profileHeroImage,
  heroReaction: _target(
    'hero',
    SwipeReactionTargetType.heroPhoto,
    'Main photo',
  ),
  kicker: 'Was at - Sundowner 5K',
  kickerActivity: ActivityKind.socialRun,
  metaLine: 'Designer - Bandra',
  sections: <ProfileSection>[
    ProfileCompatibilitySection(
      title: 'Why you might click',
      reasons: const <String>[
        'You both run at dawn around Bandra',
        'Two mutual clubs',
        'Both here for something that starts as a run',
      ],
      confidence: const <String>['Verified photos', 'Active this week'],
      reaction: _target(
        'compatibility',
        SwipeReactionTargetType.compatibility,
        'Why you might click',
      ),
    ),
    ProfilePromptSectionData(
      question: 'A perfect Sunday',
      answer:
          'Long run, longer brunch, and a bookshop I have no business being in.',
      reaction: _target(
        'prompt-1',
        SwipeReactionTargetType.profilePrompt,
        'A perfect Sunday',
      ),
    ),
    ProfileRunningSection(
      pace: '5:20-6:00 /km',
      distance: '5K, 10K',
      reasons: const <String>['Headspace miles'],
      times: const <String>['Dawn'],
      tags: const <String>[
        'Morning regular',
        'Social miles',
        'Long-run person',
      ],
      reaction: _target(
        'running',
        SwipeReactionTargetType.running,
        'Running rhythm',
      ),
    ),
    ProfilePhotoSection(
      image: _profileHeroImage,
      caption: 'Sunday sea-face crew',
      reaction: _target('photo-2', SwipeReactionTargetType.photo, 'Photo 2'),
    ),
    ProfileFactsSection(
      title: 'Details',
      facts: <ProfileFact>[
        ProfileFact(
          icon: CatchIcons.workOutlineRounded,
          text: 'Product designer',
        ),
        ProfileFact(icon: CatchIcons.straightenRounded, text: '168 cm'),
        ProfileFact(icon: CatchIcons.schoolOutlined, text: 'Design school'),
      ],
      reaction: _target('details', SwipeReactionTargetType.details, 'Details'),
    ),
  ],
);
