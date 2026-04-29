import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/profile/presentation/widgets/profile_tab.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/presentation/create_run_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  final liveRun = _run(
    id: 'run-live',
    startTime: DateTime.now().subtract(const Duration(hours: 2)),
    endTime: DateTime.now().subtract(const Duration(hours: 1)),
    attendedUserIds: const ['runner-1', 'runner-2', 'runner-3', 'runner-4'],
  );

  runApp(
    ProviderScope(
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        attendedRunsProvider(
          'runner-1',
        ).overrideWithValue(AsyncData([liveRun])),
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
    final user = _user().copyWith(
      preferredDistances: const [
        PreferredDistance.fiveK,
        PreferredDistance.tenK,
      ],
      runningReasons: const [RunReason.community, RunReason.social],
      paceMinSecsPerKm: 300,
      paceMaxSecsPerKm: 390,
    );

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
              ],
            ),
          ),
        ),
      ),
    );
  }
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
          Transform.scale(
            scale: _scale,
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
}) {
  return Run(
    id: id,
    runClubId: 'club-1',
    startTime: startTime,
    endTime: endTime ?? startTime.add(const Duration(hours: 1)),
    meetingPoint: 'Carter Road Amphitheatre',
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
