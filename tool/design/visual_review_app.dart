import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/calendar/presentation/calendar_screen.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/presentation/event_map_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_success_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_screen.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_screen.dart';
import 'package:catch_dating_app/swipes/presentation/filters_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  final liveRun = _run(
    id: 'event-live',
    startTime: DateTime.now().subtract(const Duration(hours: 2)),
    endTime: DateTime.now().subtract(const Duration(hours: 1)),
    checkedInCount: 4,
    startingPointLat: 19.0676,
    startingPointLng: 72.8221,
  );
  final upcomingRun = _run(
    id: 'event-upcoming',
    startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
    distanceKm: 10,
    pace: PaceLevel.moderate,
    bookedCount: 2,
    startingPointLat: 19.0760,
    startingPointLng: 72.8777,
  );
  final match = Match(
    id: 'match-1',
    user1Id: 'runner-1',
    user2Id: 'runner-2',
    eventIds: [liveRun.id],
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    lastMessageAt: DateTime.now().subtract(const Duration(minutes: 18)),
    lastMessagePreview: 'Coffee after the next 10K?',
    lastMessageSenderId: 'runner-2',
    unreadCounts: const {'runner-1': 1},
  );
  final user = _visualReviewUser();
  final publicProfiles = _publicProfiles();

  runApp(
    ProviderScope(
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
        userProfileRepositoryProvider.overrideWithValue(
          _VisualReviewUserProfileRepository(user),
        ),
        publicProfileRepositoryProvider.overrideWithValue(
          _VisualReviewPublicProfileRepository(publicProfiles),
        ),
        watchAttendedEventsProvider(
          'runner-1',
        ).overrideWithValue(AsyncData([liveRun])),
        watchSignedUpEventsProvider(
          'runner-1',
        ).overrideWithValue(AsyncData([upcomingRun])),
        recommendedEventsProvider(
          RecommendedEventsQuery.fromClubIds(const ['club-1']),
        ).overrideWithValue(AsyncData([upcomingRun])),
        watchMatchesForUserProvider(
          'runner-1',
        ).overrideWith((ref) => Stream.value([match])),
        watchEventProvider(
          liveRun.id,
        ).overrideWith((ref) => Stream.value(liveRun)),
        watchBlockedUsersProvider.overrideWithValue(const AsyncData([])),
      ],
      child: VisualReviewApp(liveRun: liveRun),
    ),
  );
}

class VisualReviewApp extends StatelessWidget {
  const VisualReviewApp({required this.liveRun, super.key});

  final Event liveRun;

  @override
  Widget build(BuildContext context) {
    final club = _club();
    final managedRun = _run(
      id: 'event-managed',
      startTime: DateTime(2026, 5, 10, 6),
      distanceKm: 7.5,
      capacityLimit: 4,
      bookedCount: 4,
      waitlistedCount: 2,
      priceInPaise: 24900,
    );
    final user = _visualReviewUser();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        backgroundColor: const Color(0xFFE8E1D8),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 20,
              runSpacing: 24,
              children: [
                const _PhoneFrame(
                  label: 'Catches hub',
                  child: SwipeHubScreen(),
                ),
                const _PhoneFrame(label: 'Calendar', child: CalendarScreen()),
                const _PhoneFrame(
                  label: 'Map view',
                  child: EventMapView(enableNetworkTiles: false),
                ),
                const _PhoneFrame(label: 'Filters', child: FiltersScreen()),
                _PhoneFrame(
                  label: 'Event recap',
                  child: EventRecapScreen(eventId: liveRun.id),
                ),
                _PhoneFrame(
                  label: 'Create success',
                  child: CreateEventSuccessScreen(
                    club: club,
                    event: managedRun,
                    onManageEvent: () {},
                    onDone: () {},
                  ),
                ),
                _PhoneFrame(
                  label: 'Host manage',
                  child: HostEventManageScreen(
                    club: club,
                    event: managedRun,
                    onBackToSuccess: () {},
                  ),
                ),
                _PhoneFrame(
                  label: 'Profile',
                  child: Scaffold(
                    body: ProfileTab(
                      user: user,
                      uploadState: (loadingIndices: <int>{}, uploadError: null),
                    ),
                  ),
                ),
                const _PhoneFrame(label: 'Settings', child: SettingsScreen()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _VisualReviewUserProfileRepository
    implements UserProfileRepository {
  const _VisualReviewUserProfileRepository(this._user);

  final UserProfile _user;

  @override
  Stream<UserProfile?> watchUserProfile({required String? uid}) =>
      Stream.value(uid == _user.uid ? _user : null);

  @override
  Future<UserProfile?> fetchUserProfile({required String? uid}) async =>
      uid == _user.uid ? _user : null;

  @override
  Future<void> setUserProfile({required UserProfile userProfile}) async {}

  @override
  Future<void> updateProfilePhotos({
    required String uid,
    required List<ProfilePhoto> profilePhotos,
  }) async {}

  @override
  Future<void> updateDetectedLocation({
    required String uid,
    required double latitude,
    required double longitude,
    String? city,
  }) async {}

  @override
  Future<void> setProfileComplete({required String uid}) async {}

  @override
  Future<void> updateUserProfile({
    required String uid,
    required UpdateUserProfilePatch patch,
    String action = 'update_profile',
  }) async {}
}

final class _VisualReviewPublicProfileRepository
    implements PublicProfileRepository {
  const _VisualReviewPublicProfileRepository(this._profiles);

  final Map<String, PublicProfile> _profiles;

  @override
  Stream<PublicProfile?> watchPublicProfile({required String uid}) =>
      Stream.value(_profiles[uid]);

  @override
  Future<PublicProfile?> fetchPublicProfile({required String uid}) async =>
      _profiles[uid];

  @override
  Future<List<PublicProfile>> fetchPublicProfiles(List<String> uids) async => [
    for (final uid in uids)
      if (_profiles[uid] != null) _profiles[uid]!,
  ];
}

class _NoDeviceLocation extends DeviceLocation {
  @override
  Future<LocationCoordinate?> build() async => null;
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.label, required this.child});

  final String label;
  final Widget child;
  static const double _scale = 0.43;
  static const Size _phoneSize = Size(390, 844);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _phoneSize.width * _scale,
      height: (_phoneSize.height * _scale) + 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          SizedBox(
            width: _phoneSize.width * _scale,
            height: _phoneSize.height * _scale,
            child: FittedBox(
              alignment: Alignment.topLeft,
              child: Container(
                width: _phoneSize.width,
                height: _phoneSize.height,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(48),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 30,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Event _run({
  required String id,
  required DateTime startTime,
  DateTime? endTime,
  double distanceKm = 5,
  PaceLevel pace = PaceLevel.easy,
  int capacityLimit = 20,
  int priceInPaise = 0,
  int bookedCount = 0,
  int checkedInCount = 0,
  int waitlistedCount = 0,
  double? startingPointLat,
  double? startingPointLng,
}) {
  return Event(
    id: id,
    clubId: 'club-1',
    startTime: startTime,
    endTime: endTime ?? startTime.add(const Duration(hours: 1)),
    meetingPoint: 'Carter Road Amphitheatre',
    startingPointLat: startingPointLat,
    startingPointLng: startingPointLng,
    distanceKm: distanceKm,
    pace: pace,
    capacityLimit: capacityLimit,
    description: 'Social pacing with a coffee stop.',
    priceInPaise: priceInPaise,
    bookedCount: bookedCount,
    checkedInCount: checkedInCount,
    waitlistedCount: waitlistedCount,
    constraints: const EventConstraints(minAge: 21, maxAge: 35),
  );
}

Club _club() {
  return Club(
    id: 'club-1',
    name: 'Bandra Striders',
    description: 'Morning runners who like easy city loops.',
    location: 'mumbai',
    area: 'Bandra',
    hostUserId: 'host-1',
    hostName: 'Priya',
    createdAt: DateTime(2025),
    memberCount: 420,
  );
}

UserProfile _user() {
  return UserProfile(
    uid: 'runner-1',
    email: 'aarav@example.com',
    name: 'Aarav Mehta',
    dateOfBirth: DateTime(1996, 5, 8),
    profilePrompts: const [
      ProfilePromptAnswer(
        promptId: profilePromptPerfectEventId,
        prompt: 'A perfect event with me looks like...',
        answer: 'Coffee after a steady 10K is the ideal Sunday.',
      ),
    ],
    gender: Gender.man,
    phoneNumber: '+919876543210',
    profileComplete: true,
    interestedInGenders: const [Gender.woman],
  );
}

UserProfile _visualReviewUser() {
  return _user().copyWith(
    activityPreferences: const ActivityPreferences(
      running: RunningPreferences(
        paceMaxSecsPerKm: 390,
        preferredDistances: [PreferredDistance.fiveK, PreferredDistance.tenK],
        runningReasons: [RunReason.community, RunReason.social],
        version: currentRunPreferencesVersion,
      ),
    ),
  );
}

PublicProfile _publicProfile(String uid, String name) {
  return PublicProfile(
    uid: uid,
    name: name,
    age: 27,
    gender: Gender.woman,
    profilePrompts: const [
      ProfilePromptAnswer(
        promptId: profilePromptPerfectEventId,
        prompt: 'A perfect event with me looks like...',
        answer: 'Steady miles, good coffee, and Sunday long events.',
      ),
    ],
  );
}

Map<String, PublicProfile> _publicProfiles() => {
  'runner-1': _publicProfile('runner-1', 'Aarav'),
  'runner-2': _publicProfile('runner-2', 'Riya'),
  'runner-3': _publicProfile('runner-3', 'Zoya'),
  'runner-4': _publicProfile('runner-4', 'Dev'),
  'runner-5': _publicProfile('runner-5', 'Maya'),
  'runner-6': _publicProfile('runner-6', 'Kabir'),
};
