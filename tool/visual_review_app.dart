import 'package:catch_dating_app/activity/presentation/activity_screen.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/calendar/presentation/calendar_screen.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/profile/presentation/widgets/profile_tab.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/presentation/create_run_screen.dart';
import 'package:catch_dating_app/runs/presentation/run_map_screen.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_screen.dart';
import 'package:catch_dating_app/swipes/presentation/filters_screen.dart';
import 'package:catch_dating_app/swipes/presentation/run_recap_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  final liveRun = _run(
    id: 'run-live',
    startTime: DateTime.now().subtract(const Duration(hours: 2)),
    endTime: DateTime.now().subtract(const Duration(hours: 1)),
    attendedUserIds: const ['runner-1', 'runner-2', 'runner-3', 'runner-4'],
    startingPointLat: 19.0676,
    startingPointLng: 72.8221,
  );
  final upcomingRun = _run(
    id: 'run-upcoming',
    startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
    distanceKm: 10,
    pace: PaceLevel.moderate,
    signedUpUserIds: const ['runner-1', 'runner-2'],
    startingPointLat: 19.0760,
    startingPointLng: 72.8777,
  );
  final match = Match(
    id: 'match-1',
    user1Id: 'runner-1',
    user2Id: 'runner-2',
    runId: liveRun.id,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    lastMessageAt: DateTime.now().subtract(const Duration(minutes: 18)),
    lastMessagePreview: 'Coffee after the next 10K?',
    unreadCounts: const {'runner-1': 2},
  );
  final user = _visualReviewUser();

  runApp(
    ProviderScope(
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        userProfileRepositoryProvider.overrideWithValue(
          _VisualReviewUserProfileRepository(user),
        ),
        attendedRunsProvider(
          'runner-1',
        ).overrideWithValue(AsyncData([liveRun])),
        signedUpRunsProvider(
          'runner-1',
        ).overrideWithValue(AsyncData([upcomingRun])),
        matchesForUserProvider(
          'runner-1',
        ).overrideWith((ref) => Stream.value([match])),
        watchRunProvider(
          liveRun.id,
        ).overrideWith((ref) => Stream.value(liveRun)),
        publicProfileProvider('runner-2').overrideWith(
          (ref) => Stream.value(_publicProfile('runner-2', 'Riya')),
        ),
        publicProfileProvider('runner-3').overrideWith(
          (ref) => Stream.value(_publicProfile('runner-3', 'Zoya')),
        ),
        publicProfileProvider('runner-4').overrideWith(
          (ref) => Stream.value(_publicProfile('runner-4', 'Dev')),
        ),
      ],
      child: VisualReviewApp(liveRun: liveRun),
    ),
  );
}

class VisualReviewApp extends StatelessWidget {
  const VisualReviewApp({required this.liveRun, super.key});

  final Run liveRun;

  @override
  Widget build(BuildContext context) {
    final club = _club();
    final managedRun = _run(
      id: 'run-managed',
      startTime: DateTime(2026, 5, 10, 6),
      distanceKm: 7.5,
      capacityLimit: 4,
      signedUpUserIds: const ['runner-1', 'runner-2', 'runner-3', 'runner-4'],
      waitlistUserIds: const ['runner-5', 'runner-6'],
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
                _PhoneFrame(
                  label: 'Catches hub',
                  child: const SwipeHubScreen(),
                ),
                _PhoneFrame(label: 'Calendar', child: const CalendarScreen()),
                _PhoneFrame(
                  label: 'Map view',
                  child: const RunMapScreen(enableNetworkTiles: false),
                ),
                _PhoneFrame(label: 'Activity', child: const ActivityScreen()),
                _PhoneFrame(label: 'Filters', child: const FiltersScreen()),
                _PhoneFrame(
                  label: 'Run recap',
                  child: RunRecapScreen(runId: liveRun.id),
                ),
                _PhoneFrame(
                  label: 'Create success',
                  child: CreateRunSuccessScreen(
                    runClub: club,
                    run: managedRun,
                    onManageRun: () {},
                    onDone: () {},
                  ),
                ),
                _PhoneFrame(
                  label: 'Host manage',
                  child: HostRunManageScreen(
                    runClub: club,
                    run: managedRun,
                    onBackToSuccess: () {},
                  ),
                ),
                _PhoneFrame(
                  label: 'Profile',
                  child: ProviderScope(
                    child: Scaffold(
                      body: ProfileTab(
                        user: user,
                        uploadState: (
                          loadingIndices: <int>{},
                          uploadError: null,
                        ),
                      ),
                    ),
                  ),
                ),
                _PhoneFrame(
                  label: 'Settings',
                  child: ProviderScope(
                    overrides: [
                      blockedUsersProvider.overrideWithValue(
                        const AsyncData([]),
                      ),
                    ],
                    child: const SettingsScreen(),
                  ),
                ),
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
  Future<void> updatePhotoUrls({
    required String uid,
    required List<String> photoUrls,
  }) async {}

  @override
  Future<void> setProfileComplete({required String uid}) async {}

  @override
  Future<void> saveRun({required String uid, required String runId}) async {}

  @override
  Future<void> unsaveRun({required String uid, required String runId}) async {}
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
              fit: BoxFit.contain,
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

Run _run({
  required String id,
  required DateTime startTime,
  DateTime? endTime,
  double distanceKm = 5,
  PaceLevel pace = PaceLevel.easy,
  int capacityLimit = 20,
  int priceInPaise = 0,
  List<String> signedUpUserIds = const [],
  List<String> attendedUserIds = const [],
  List<String> waitlistUserIds = const [],
  double? startingPointLat,
  double? startingPointLng,
}) {
  return Run(
    id: id,
    runClubId: 'club-1',
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
    signedUpUserIds: signedUpUserIds,
    attendedUserIds: attendedUserIds,
    waitlistUserIds: waitlistUserIds,
    constraints: const RunConstraints(minAge: 21, maxAge: 35),
  );
}

RunClub _club() {
  return RunClub(
    id: 'club-1',
    name: 'Bandra Striders',
    description: 'Morning runners who like easy city loops.',
    location: IndianCity.mumbai,
    area: 'Bandra',
    hostUserId: 'host-1',
    hostName: 'Priya',
    createdAt: DateTime(2025, 1, 1),
    memberUserIds: const ['host-1', 'runner-1', 'runner-2'],
    memberCount: 420,
  );
}

UserProfile _user() {
  return UserProfile(
    uid: 'runner-1',
    email: 'aarav@example.com',
    name: 'Aarav Mehta',
    dateOfBirth: DateTime(1996, 5, 8),
    bio: 'Coffee after a steady 10K is the ideal Sunday.',
    gender: Gender.man,
    sexualOrientation: SexualOrientation.straight,
    phoneNumber: '+919876543210',
    profileComplete: true,
    interestedInGenders: const [Gender.woman],
    photoUrls: const [],
  );
}

UserProfile _visualReviewUser() {
  return _user().copyWith(
    preferredDistances: const [PreferredDistance.fiveK, PreferredDistance.tenK],
    runningReasons: const [RunReason.community, RunReason.social],
    paceMinSecsPerKm: 300,
    paceMaxSecsPerKm: 390,
  );
}

PublicProfile _publicProfile(String uid, String name) {
  return PublicProfile(
    uid: uid,
    name: name,
    age: 27,
    bio: 'Steady miles, good coffee, and Sunday long runs.',
    gender: Gender.woman,
  );
}
