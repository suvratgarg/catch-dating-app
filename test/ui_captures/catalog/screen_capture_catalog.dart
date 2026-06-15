import 'dart:async';
import 'dart:io';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_screen.dart';
import 'package:catch_dating_app/calendar/presentation/calendar_screen.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/device_motion.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/dashboard/presentation/activity_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_preference.dart';
import 'package:catch_dating_app/event_success/domain/event_success_wingman_request.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_effects_controller.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/attendance_sheet_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_screen.dart';
import 'package:catch_dating_app/events/presentation/saved_events_screen.dart';
import 'package:catch_dating_app/events/presentation/widgets/who_is_going.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_repository.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_screen.dart';
import 'package:catch_dating_app/hosts/presentation/edit_hosted_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/matches/presentation/matches_list_screen.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_screen.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_screen.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_screen.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_screen.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_screen.dart';
import 'package:catch_dating_app/swipes/presentation/filters_screen.dart';
import 'package:catch_dating_app/swipes/presentation/profile_redesign/catch_profile_view.dart';
import 'package:catch_dating_app/swipes/presentation/profile_redesign/profile_view.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_queue_notifier.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_screen.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;

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
  });

  final String id;
  final List<String> routeIds;
  final CaptureDevice device;
  final WidgetBuilder builder;
  final List<ImageProvider<Object>> precache;
  final List<String> marketingFixtureKeys;
  final Iterable providerOverrides;
}

final _profileHeroImage = FileImage(File('test/goldens/fixtures/portrait.jpg'));
final _captureFixtures = salesDemoSyntheticFixtures;
final _eventDetailEvent = buildEvent(
  id: 'event-detail-member',
  startTime: DateTime(2026, 6, 12, 7),
  endTime: DateTime(2026, 6, 12, 8, 15),
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
final _eventDetailParticipations = [
  for (var index = 1; index <= 12; index += 1)
    buildEventParticipation(
      event: _eventDetailEvent,
      uid: index == 1 ? _eventDetailUser.uid : 'runner-${index + 1}',
      createdAt: DateTime(2026, 5, index.clamp(1, 28), 7),
    ),
];
final _eventDetailParticipationRepository = FakeEventParticipationRepository()
  ..eventParticipations[_eventDetailEvent.id] = _eventDetailParticipations;
final _eventDetailPublicProfileRepository = FakePublicProfileRepository()
  ..profiles = [
    for (final participation in _eventDetailParticipations)
      buildPublicProfile(
        uid: participation.uid,
        name: participation.uid == _eventDetailUser.uid
            ? _eventDetailUser.name
            : 'Runner ${participation.uid.split('-').last}',
      ),
  ];

EventDetailViewModel _eventDetailCaptureViewModel() {
  return EventDetailViewModel(
    event: _eventDetailEvent,
    userProfile: _eventDetailUser,
    reviews: [
      buildReview(
        eventId: _eventDetailEvent.id,
        reviewerUserId: 'runner-2',
        reviewerName: 'Neha',
        comment: 'Warm hosting, clear route, and easy conversation.',
        createdAt: DateTime(2026, 5, 20),
      ),
    ],
    isAuthenticated: true,
    isHost: false,
    isSaved: true,
    participation: null,
  );
}

Iterable _eventDetailCaptureProviderOverrides() {
  return [
    eventDetailViewModelProvider(
      _eventDetailEvent.id,
    ).overrideWith((ref) => AsyncData(_eventDetailCaptureViewModel())),
    paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
    eventParticipationRepositoryProvider.overrideWithValue(
      _eventDetailParticipationRepository,
    ),
    publicProfileRepositoryProvider.overrideWithValue(
      _eventDetailPublicProfileRepository,
    ),
  ];
}

const _memberDiscoveryCities = [
  CityData(
    name: 'mumbai',
    label: 'Mumbai',
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
    id: 'club-discovery-dawn',
    name: 'Bandra Dawn Club',
    description: 'Easy coastal loops, warm hosts, and coffee after.',
    area: 'Bandra',
    hostName: 'Mira',
    tags: const ['social run', 'coffee', 'beginner'],
    memberCount: 128,
    reviewCount: 42,
    nextEventAt: DateTime(2026, 6, 1, 6, 30),
    nextEventLabel: 'Mon 6:30 AM',
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
    nextEventAt: DateTime(2026, 6, 3, 20),
    nextEventLabel: 'Wed 8:00 PM',
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
    nextEventAt: DateTime(2026, 6, 5, 18),
    nextEventLabel: 'Fri 6:00 PM',
  ),
];
final _memberDiscoveryEvents = [
  _captureFixtures.captureEvent(
    id: 'event-discovery-dawn-loop',
    club: _memberDiscoveryClubs[0],
    startTime: DateTime(2026, 6, 1, 6, 30),
    meetingPoint: 'Carter Road Amphitheatre',
    startingPointLat: 19.0706,
    startingPointLng: 72.8223,
    bookedCount: 18,
    capacityLimit: 24,
    description: 'A relaxed social loop with regroup points and coffee after.',
  ),
  _captureFixtures.captureEvent(
    id: 'event-discovery-sea-face',
    club: _memberDiscoveryClubs[0],
    startTime: DateTime(2026, 6, 2, 7),
    meetingPoint: 'Bandstand promenade',
    startingPointLat: 19.0469,
    startingPointLng: 72.8194,
    distanceKm: 6,
    capacityLimit: 22,
    description: 'Morning miles for people who want conversation pace.',
  ),
  _captureFixtures.captureEvent(
    id: 'event-discovery-long-table',
    club: _memberDiscoveryClubs[1],
    startTime: DateTime(2026, 6, 3, 20),
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
    startTime: DateTime(2026, 6, 5, 18),
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
    id: 'event-discovery-weekend-walk',
    club: _memberDiscoveryClubs[0],
    startTime: DateTime(2026, 6, 6, 8),
    meetingPoint: 'Bandra Fort gate',
    startingPointLat: 19.0437,
    startingPointLng: 72.8181,
    activityKind: ActivityKind.walking,
    distanceKm: 3,
    bookedCount: 20,
    capacityLimit: 28,
    description: 'A low-key weekend walk with new faces and sea views.',
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

class _CaptureDeviceLocation extends DeviceLocation {
  @override
  Future<LocationCoordinate?> build() async => null;
}

class _SilentDeviceMotionSource implements DeviceMotionSource {
  const _SilentDeviceMotionSource();

  @override
  Stream<DeviceMotionSample> watchMotion() => const Stream.empty();
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
      city: 'mumbai',
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
final _dashboardHostEvent = _captureFixtures.hostDemoEvent(
  role: 'hostEventSetup',
  club: _dashboardHostClub,
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
final _dashboardRecommendationQuery = DashboardRecommendationsQuery(
  userId: _captureViewerUid,
  followedClubIds: [_dashboardJoinedClub.id],
);
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

final _hostEvent = _captureFixtures.hostDemoEvent(
  role: 'hostLiveConsole',
  club: _dashboardHostClub,
);
final _hostEventSetupDraft = _captureFixtures.hostSetupDraft(
  id: 'host-event-setup-capture-draft',
  club: _dashboardHostClub,
  savedAt: _captureNow,
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

final _swipeHubEvent = buildEvent(
  id: 'event-swipe-hub-open',
  clubId: _dashboardJoinedClub.id,
  startTime: DateTime.now().subtract(const Duration(hours: 10)),
  endTime: DateTime.now().subtract(const Duration(hours: 9)),
  meetingPoint: 'Carter Road Amphitheatre',
  bookedCount: 22,
  checkedInCount: 19,
  capacityLimit: 24,
  description: 'A checked-in run whose catch window is still open.',
);

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

final _activityScreenNotifications = [
  ActivityNotification(
    id: 'notification-activity-event',
    uid: _captureViewerUid,
    type: ActivityNotificationType.eventReminder,
    title: 'Event starts tomorrow',
    body: 'Bandra Dawn Club meets at 6:30 AM.',
    createdAt: DateTime(2026, 5, 31, 8),
    readAt: DateTime(2026, 5, 31, 8, 5),
    eventId: _dashboardSignedUpEvent.id,
    clubId: _dashboardJoinedClub.id,
  ),
  ActivityNotification(
    id: 'notification-activity-club',
    uid: _captureViewerUid,
    type: ActivityNotificationType.clubUpdate,
    title: 'New route posted',
    body: 'Sea Face Social added a Saturday walk.',
    createdAt: DateTime(2026, 5, 30, 18),
    readAt: DateTime(2026, 5, 30, 18, 12),
    clubId: _clubDetailClub.id,
  ),
];

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
    id: 'start_welcome',
    routeIds: const <String>['startScreen'],
    device: CaptureDevice.reviewPhone,
    builder: (context) => const WelcomePage(),
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
    id: 'dashboard_home',
    routeIds: const <String>['dashboardScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: [
      uidProvider.overrideWith((ref) => Stream.value(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      watchActiveClubMembershipsForUserProvider(_captureViewerUid).overrideWith(
        (ref) => Stream.value([
          _captureMembership(
            clubId: _dashboardJoinedClub.id,
            uid: _captureViewerUid,
          ),
        ]),
      ),
      watchSignedUpEventsProvider(
        _captureViewerUid,
      ).overrideWith((ref) => Stream.value(_dashboardSignedUpEvents)),
      watchAttendedEventsProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_dashboardAttendedEvents)),
      watchActivityNotificationsProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_dashboardNotifications)),
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
        AsyncData(
          WeeklyActivitySnapshot.permissionRequired(
            referenceDate: _captureNow,
            platformLabel: 'Apple Health',
          ),
        ),
      ),
      watchReviewsByUserProvider(
        _captureViewerUid,
      ).overrideWithValue(const AsyncData<List<Review>>([])),
      dashboardRecommendedEventsProvider(
        _dashboardRecommendationQuery,
      ).overrideWithValue(
        AsyncData([
          DashboardEventRecommendationCandidate(
            event: _dashboardRecommendedEvent,
            clubName: _memberDiscoveryClubs[2].name,
            clubLocation: _memberDiscoveryClubs[2].location,
          ),
        ]),
      ),
    ],
    builder: (context) => const DashboardScreen(),
  ),
  ScreenCaptureEntry(
    id: 'club_detail_member',
    routeIds: const <String>['clubDetailScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: [
      uidProvider.overrideWith((ref) => Stream.value(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      watchClubMembershipProvider(
        _clubDetailClub.id,
        _captureViewerUid,
      ).overrideWith(
        (ref) => Stream.value(
          _captureMembership(
            clubId: _clubDetailClub.id,
            uid: _captureViewerUid,
          ),
        ),
      ),
      clubDetailViewModelProvider(_clubDetailClub.id).overrideWith(
        (ref) => AsyncData(
          ClubDetailViewModel(
            club: _clubDetailClub,
            isHost: false,
            isMember: true,
            upcomingEvents: _clubDetailEvents,
            reviews: _clubDetailReviews,
            userProfile: _captureViewer,
            uid: _captureViewerUid,
            isAuthenticated: true,
          ),
        ),
      ),
    ],
    builder: (context) => ClubDetailScreen(
      clubId: _clubDetailClub.id,
      initialClub: _clubDetailClub,
    ),
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
    id: 'member_event_discovery',
    routeIds: const <String>['exploreScreen'],
    device: CaptureDevice.reviewTall,
    marketingFixtureKeys: const <String>['salesDemo.member.eventDiscovery'],
    providerOverrides: [
      cityListProvider.overrideWith((ref) async => _memberDiscoveryCities),
      deviceLocationProvider.overrideWith(_CaptureDeviceLocation.new),
      deviceMotionSourceProvider.overrideWithValue(
        const _SilentDeviceMotionSource(),
      ),
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
    id: 'create_club_basics',
    routeIds: const <String>['hostCreateClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
    ],
    builder: (context) => const CreateClubScreen(),
  ),
  ScreenCaptureEntry(
    id: 'edit_club_basics',
    routeIds: const <String>['hostEditClubScreen'],
    device: CaptureDevice.iphone17Pro,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
    ],
    builder: (context) => CreateClubScreen(initialClub: _dashboardHostClub),
  ),
  ScreenCaptureEntry(
    id: 'host_event_setup',
    routeIds: const <String>['hostCreateEventScreen'],
    device: CaptureDevice.iphone17Pro,
    marketingFixtureKeys: const <String>['salesDemo.host.eventSetup'],
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      deviceLocationProvider.overrideWith(_CaptureDeviceLocation.new),
      eventRepositoryProvider.overrideWith((ref) => FakeEventRepository()),
    ],
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
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      deviceLocationProvider.overrideWith(_CaptureDeviceLocation.new),
      eventRepositoryProvider.overrideWith((ref) => FakeEventRepository()),
    ],
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
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      deviceLocationProvider.overrideWith(_CaptureDeviceLocation.new),
      eventRepositoryProvider.overrideWith((ref) => FakeEventRepository()),
    ],
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
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      deviceLocationProvider.overrideWith(_CaptureDeviceLocation.new),
      eventRepositoryProvider.overrideWith((ref) => FakeEventRepository()),
    ],
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
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      deviceLocationProvider.overrideWith(_CaptureDeviceLocation.new),
      eventRepositoryProvider.overrideWith((ref) => FakeEventRepository()),
    ],
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
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      deviceLocationProvider.overrideWith(_CaptureDeviceLocation.new),
      eventRepositoryProvider.overrideWith((ref) => FakeEventRepository()),
    ],
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
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      deviceLocationProvider.overrideWith(_CaptureDeviceLocation.new),
      eventRepositoryProvider.overrideWith((ref) => FakeEventRepository()),
    ],
    builder: (context) => EditHostedEventScreen(
      club: _dashboardHostClub,
      event: _dashboardHostEvent,
      loadMapTiles: false,
      now: () => _captureNow,
    ),
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
    builder: (context) => SwipeScreen(eventId: _postRunEvent.id),
  ),
  ScreenCaptureEntry(
    id: 'swipe_hub_active',
    routeIds: const <String>['swipeHubScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: [
      uidProvider.overrideWith((ref) => Stream.value(_captureViewerUid)),
      watchAttendedEventsProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData([_swipeHubEvent])),
    ],
    builder: (context) => const SwipeHubScreen(),
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
    id: 'public_profile_member',
    routeIds: const <String>['publicProfileScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: [
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      watchPublicProfileProvider(
        _matchChatOtherProfile.uid,
      ).overrideWith((ref) => Stream.value(_matchChatOtherProfile)),
    ],
    builder: (context) => PublicProfileScreen(
      uid: _matchChatOtherProfile.uid,
      initialProfile: _matchChatOtherProfile,
    ),
  ),
  ScreenCaptureEntry(
    id: 'reviews_history_list',
    routeIds: const <String>['reviewsHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      watchReviewsByUserProvider(
        _captureViewerUid,
      ).overrideWithValue(AsyncData(_reviewHistoryReviews)),
      for (final event in _reviewHistoryEvents)
        watchEventProvider(event.id).overrideWith((ref) => Stream.value(event)),
    ],
    builder: (context) => const ReviewsHistoryScreen(),
  ),
  ScreenCaptureEntry(
    id: 'settings_account',
    routeIds: const <String>['settingsScreen'],
    device: CaptureDevice.reviewTall,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchUserProfileProvider.overrideWith(
        (ref) => Stream.value(_captureViewer),
      ),
      watchBlockedUsersProvider.overrideWith((ref) => Stream.value(const [])),
    ],
    builder: (context) => const SettingsScreen(),
  ),
  ScreenCaptureEntry(
    id: 'payment_history_empty',
    routeIds: const <String>['paymentHistoryScreen'],
    device: CaptureDevice.reviewPhone,
    providerOverrides: [
      uidProvider.overrideWithValue(const AsyncData(_captureViewerUid)),
      watchPaymentsForUserProvider(
        _captureViewerUid,
      ).overrideWith((ref) => Stream.value(const [])),
    ],
    builder: (context) => const PaymentHistoryScreen(),
  ),
];

ScreenCaptureEntry findScreenCapture(String id) {
  for (final entry in screenCaptureCatalog) {
    if (entry.id == id) return entry;
  }
  throw ArgumentError.value(id, 'id', 'Unknown screen capture id.');
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
