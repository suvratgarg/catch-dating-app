import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/app.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/location_service.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/next_run_hero.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/force_update/data/force_update_provider.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/onboarding/data/onboarding_draft_repository.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/run_clubs/data/run_club_membership_repository.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_membership.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/data/saved_run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/presentation/run_check_in_location_service.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/onboarding/onboarding_test_helpers.dart' as onboarding_helpers;
import '../test/run_clubs/run_clubs_test_helpers.dart' as club_helpers;
import '../test/runs/runs_test_helpers.dart' as run_helpers;
import '../test/test_pump_helpers.dart';

const _mumbai = CityData(
  name: 'mumbai',
  label: 'Mumbai',
  latitude: 19.076,
  longitude: 72.8777,
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('unauthenticated launch opens public club discovery', (
    tester,
  ) async {
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(uid: null, user: null, clubs: [club]),
    );

    expect(find.text('Run clubs'), findsOneWidget);
    expect(find.text('Stride Social'), findsWidgets);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets(
    'public club discovery opens club details through the real route',
    (tester) async {
      final club = club_helpers.buildRunClub(
        id: 'club-1',
        name: 'Stride Social',
        description: 'Morning runners who like easy city loops.',
      );

      await _pumpCatchApp(
        tester,
        overrides: _appOverrides(uid: null, user: null, clubs: [club]),
      );

      await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
      await pumpFeatureUi(tester);

      expect(find.text('Stride Social'), findsWidgets);
      expect(
        find.text('Morning runners who like easy city loops.'),
        findsOneWidget,
      );
      expect(find.text('Sign in to join'), findsOneWidget);
    },
  );

  testWidgets('club schedule opens a run detail route with booking CTA', (
    tester,
  ) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final run = run_helpers.buildRun(
      id: 'run-1',
      runClubId: club.id,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 2,
    );

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        clubRuns: {
          club.id: [run],
        },
      ),
    );

    await _openTab(tester, 'Clubs');
    await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Carter Road Amphitheatre'));
    await pumpFeatureUi(tester);

    expect(find.text('Carter Road Amphitheatre'), findsWidgets);
    expect(find.text('Join run — 18 spots left'), findsOneWidget);
  });

  testWidgets('run detail books a free run and shows confirmation', (
    tester,
  ) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final run = run_helpers.buildRun(
      id: 'run-1',
      runClubId: club.id,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
    );
    final paymentRepository = run_helpers.FakePaymentRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        clubRuns: {
          club.id: [run],
        },
        paymentRepository: paymentRepository,
      ),
    );

    await _openTab(tester, 'Clubs');
    await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Carter Road Amphitheatre'));
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Join run — 19 spots left'));
    await pumpFeatureUi(tester);

    expect(paymentRepository.bookFreeRunCalled, isTrue);
    expect(paymentRepository.bookedFreeRunId, run.id);
    expect(find.text('Booking confirmed'), findsOneWidget);
    expect(find.text("You're in."), findsOneWidget);
  });

  testWidgets('matches list opens chat and resets unread state', (
    tester,
  ) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final match = Match(
      id: 'match-1',
      user1Id: user.uid,
      user2Id: 'runner-2',
      runIds: const ['run-1'],
      createdAt: DateTime(2026, 4, 23, 9),
      lastMessageAt: DateTime(2026, 4, 23, 10),
      lastMessagePreview: 'See you at the run',
      lastMessageSenderId: 'runner-2',
      unreadCounts: const {'runner-1': 1},
    );
    final profile = run_helpers.buildPublicProfile(
      uid: 'runner-2',
      name: 'Taylor',
    );
    final conversationRepository = _FakeConversationRepository();

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        matches: [match],
        publicProfiles: [profile],
        conversationRepository: conversationRepository,
      ),
    );

    await _openTab(tester, 'Chats');
    expect(find.text('Taylor'), findsOneWidget);
    expect(find.text('See you at the run'), findsOneWidget);

    await tester.tap(find.text('Taylor'));
    await pumpFeatureUi(tester);

    expect(find.text('Say hi to Taylor!'), findsOneWidget);
    expect(
      conversationRepository.markReadCalls,
      contains(('match-1', user.uid)),
    );
  });

  testWidgets('dashboard next-run card opens run detail', (tester) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final club = club_helpers.buildRunClub(id: 'club-1', name: 'Stride Social');
    final run = run_helpers.buildRun(
      id: 'run-1',
      runClubId: club.id,
      startTime: DateTime.now().add(const Duration(hours: 3)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
    );

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        signedUpRuns: [run],
      ),
    );

    await tester.tap(find.byKey(NextRunHero.cardKey));
    await pumpFeatureUi(tester);

    expect(find.text('Carter Road Amphitheatre'), findsWidgets);
    expect(find.text('Cancel booking'), findsOneWidget);
  });

  testWidgets('incomplete profiles resume onboarding before app shell', (
    tester,
  ) async {
    final user = run_helpers
        .buildUser(uid: 'runner-1', name: 'Suvrat Garg')
        .copyWith(profileComplete: false, photoUrls: const []);

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(uid: user.uid, user: user),
    );

    expect(find.text('Show yourself'), findsOneWidget);
    expect(find.text('Add 2 more photos to continue.'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('authenticated shell loads the five primary feature tabs', (
    tester,
  ) async {
    final user = run_helpers.buildUser(uid: 'runner-1', name: 'Suvrat Garg');
    final joinedClub = club_helpers.buildRunClub(
      id: 'club-1',
      name: 'Stride Social',
      nextRunLabel: 'Sat 6:30 AM',
    );
    final nextRun = run_helpers.buildRun(
      id: 'run-1',
      runClubId: joinedClub.id,
      startTime: DateTime.now().add(const Duration(hours: 3)),
      bookedCount: 1,
    );
    final attendedRun = run_helpers.buildRun(
      id: 'attended-run-1',
      runClubId: joinedClub.id,
      startTime: DateTime.now().subtract(const Duration(hours: 11)),
      endTime: DateTime.now().subtract(const Duration(hours: 10)),
      checkedInCount: 2,
    );

    await _pumpCatchApp(
      tester,
      overrides: _appOverrides(
        uid: user.uid,
        user: user,
        clubs: [joinedClub],
        joinedClubIds: {joinedClub.id},
        signedUpRuns: [nextRun],
        attendedRuns: [attendedRun],
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.textContaining('NEXT RUN'), findsOneWidget);

    await _openTab(tester, 'Clubs');
    expect(find.text('Run clubs'), findsOneWidget);
    expect(find.text('Stride Social'), findsWidgets);

    await _openTab(tester, 'Catches');
    expect(find.text('After the run'), findsOneWidget);
    expect(find.text('Start catching'), findsOneWidget);

    await _openTab(tester, 'Chats');
    expect(find.text('Chats'), findsWidgets);
    expect(find.text('No catches yet'), findsOneWidget);

    await _openTab(tester, 'Profile');
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Display name'), findsOneWidget);
  });
}

Future<void> _pumpCatchApp(
  WidgetTester tester, {
  required List<Object> overrides,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(overrides: overrides.cast(), child: const MyApp()),
  );
  await pumpFeatureUi(tester);
}

List<Object> _appOverrides({
  required String? uid,
  required UserProfile? user,
  List<RunClub> clubs = const [],
  Set<String> joinedClubIds = const {},
  List<Run> signedUpRuns = const [],
  List<Run> attendedRuns = const [],
  Map<String, List<Run>> clubRuns = const {},
  List<Match> matches = const [],
  List<PublicProfile> publicProfiles = const [],
  ConversationRepository? conversationRepository,
  PaymentRepository? paymentRepository,
}) {
  final joinedClubs = clubs
      .where((club) => joinedClubIds.contains(club.id))
      .toList(growable: false);
  final knownRunsById = <String, Run>{
    for (final run in signedUpRuns) run.id: run,
    for (final run in attendedRuns) run.id: run,
    for (final run in clubRuns.values.expand((runs) => runs)) run.id: run,
  };
  final knownRunClubIds = knownRunsById.values
      .map((run) => run.runClubId)
      .toSet();
  final participationsByRunId = <String, RunParticipation>{
    if (uid != null)
      for (final run in signedUpRuns)
        run.id: run_helpers.buildRunParticipation(run: run, uid: uid),
    if (uid != null)
      for (final run in attendedRuns)
        run.id: run_helpers.buildRunParticipation(
          run: run,
          uid: uid,
          status: RunParticipationStatus.attended,
        ),
  };

  return [
    forceUpdateRequiredProvider.overrideWithValue(const AsyncData(false)),
    forceUpdateRefreshProvider.overrideWithValue(
      (ref, {required invalidatePackageInfo, shouldInvalidate}) async {},
    ),
    locationInitializerProvider.overrideWith(_NoopLocationInitializer.new),
    appAnalyticsProvider.overrideWithValue(
      AppAnalytics(
        reporter: const _NoopAnalyticsReporter(),
        shouldCollect: false,
      ),
    ),
    errorLoggerProvider.overrideWithValue(
      ErrorLogger(shouldReportErrors: false),
    ),
    appConnectivityProvider.overrideWith(
      (ref) => Stream.value(const [ConnectivityResult.wifi]),
    ),
    deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
    cityListProvider.overrideWith((ref) async => const [_mumbai]),
    onboardingDraftRepositoryProvider.overrideWithValue(
      onboarding_helpers.FakeOnboardingDraftRepository(),
    ),
    uidProvider.overrideWith((ref) => Stream.value(uid)),
    watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
    watchRunClubsByLocationProvider(
      _mumbai.name,
    ).overrideWith((ref) => Stream.value(clubs)),
    for (final club in clubs) ...[
      watchRunClubProvider(club.id).overrideWith((ref) => Stream.value(club)),
      watchRunsForClubProvider(
        club.id,
      ).overrideWithValue(AsyncData<List<Run>>(clubRuns[club.id] ?? const [])),
      watchReviewsForClubProvider(
        club.id,
      ).overrideWithValue(const AsyncData([])),
      if (uid != null)
        watchRunClubMembershipProvider(club.id, uid).overrideWith(
          (ref) => Stream.value(
            joinedClubIds.contains(club.id)
                ? RunClubMembership(
                    id: runClubMembershipId(clubId: club.id, uid: uid),
                    clubId: club.id,
                    uid: uid,
                    role: RunClubMembershipRole.member,
                    status: RunClubMembershipStatus.active,
                    joinedAt: DateTime(2026, 1, 1),
                  )
                : null,
          ),
        ),
    ],
    for (final runClubId in knownRunClubIds)
      fetchRunClubProvider(
        runClubId,
      ).overrideWith((ref) async => _clubById(clubs, runClubId)),
    for (final run in knownRunsById.values) ...[
      watchRunProvider(run.id).overrideWith((ref) => Stream.value(run)),
      watchReviewsForRunProvider(run.id).overrideWithValue(const AsyncData([])),
      if (uid != null) ...[
        watchSavedRunProvider(
          uid,
          run.id,
        ).overrideWithValue(const AsyncData(null)),
        watchRunParticipationProvider(
          run.id,
          uid,
        ).overrideWithValue(AsyncData(participationsByRunId[run.id])),
      ],
    ],
    runClubsListViewModelProvider.overrideWithValue(
      AsyncData(
        RunClubsListViewModel(
          joinedClubs: joinedClubs,
          allClubs: clubs,
          joinedClubIds: joinedClubIds,
        ),
      ),
    ),
    canCreateRunClubProvider.overrideWithValue(const AsyncData(false)),
    runRepositoryProvider.overrideWithValue(run_helpers.FakeRunRepository()),
    paymentRepositoryProvider.overrideWithValue(
      paymentRepository ?? run_helpers.FakePaymentRepository(),
    ),
    celebrationEffectsControllerProvider.overrideWithValue(
      const _NoopCelebrationEffectsController(),
    ),
    runCheckInLocationServiceProvider.overrideWithValue(
      const _FakeRunCheckInLocationService(),
    ),
    if (uid != null) ...[
      appShellFcmInitializationProvider(uid).overrideWith((ref) async {}),
      watchSignedUpRunsProvider(
        uid,
      ).overrideWithValue(AsyncData<List<Run>>(signedUpRuns)),
      watchAttendedRunsProvider(
        uid,
      ).overrideWithValue(AsyncData<List<Run>>(attendedRuns)),
      dashboardRecommendedRunsProvider(
        DashboardRecommendationsQuery(
          userId: uid,
          followedClubIds: joinedClubIds.toList(growable: false),
        ),
      ).overrideWithValue(const AsyncData<List<Run>>([])),
      watchActivityNotificationsProvider(
        uid,
      ).overrideWithValue(const AsyncData([])),
      watchActiveRunClubMembershipsForUserProvider(uid).overrideWith(
        (ref) => Stream.value([
          for (final clubId in joinedClubIds)
            RunClubMembership(
              id: runClubMembershipId(clubId: clubId, uid: uid),
              clubId: clubId,
              uid: uid,
              role: RunClubMembershipRole.member,
              status: RunClubMembershipStatus.active,
              joinedAt: DateTime(2026, 1, 1),
            ),
        ]),
      ),
      watchRunClubsHostedByProvider(uid).overrideWithValue(const AsyncData([])),
      watchMatchesForUserProvider(
        uid,
      ).overrideWith((ref) => Stream.value(matches)),
      totalUnreadCountProvider(uid).overrideWithValue(0),
      conversationRepositoryProvider.overrideWithValue(
        conversationRepository ?? _FakeConversationRepository(),
      ),
      for (final match in matches) ...[
        matchStreamProvider(
          match.id,
        ).overrideWith((ref) => Stream.value(match)),
        watchConversationMessagesProvider(
          match.id,
        ).overrideWith((ref) => Stream.value(const <ChatMessage>[])),
      ],
      for (final profile in publicProfiles)
        watchPublicProfileProvider(
          profile.uid,
        ).overrideWith((ref) => Stream.value(profile)),
      if (matches.isEmpty)
        chatsListViewModelProvider.overrideWithValue(
          const AsyncData(
            ChatsListViewModel(
              newMatches: [],
              conversations: [],
              totalThreadCount: 0,
            ),
          ),
        ),
    ],
  ];
}

RunClub? _clubById(List<RunClub> clubs, String id) {
  for (final club in clubs) {
    if (club.id == id) return club;
  }
  return null;
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await pumpFeatureUi(tester);
}

class _NoopLocationInitializer extends LocationInitializer {
  @override
  Future<void> build() async {}
}

class _NoDeviceLocation extends DeviceLocation {
  @override
  Future<LocationCoordinate?> build() async => null;
}

class _FakeRunCheckInLocationService implements RunCheckInLocationService {
  const _FakeRunCheckInLocationService();

  @override
  Future<RunCheckInLocation> getCurrentLocation() async {
    return const RunCheckInLocation(latitude: 19.07, longitude: 72.87);
  }
}

class _NoopAnalyticsReporter implements AnalyticsReporter {
  const _NoopAnalyticsReporter();

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

class _NoopCelebrationEffectsController extends CelebrationEffectsController {
  const _NoopCelebrationEffectsController();

  @override
  Future<void> play(CelebrationMomentKind kind) async {}
}

class _FakeConversationRepository implements ConversationRepository {
  final List<(String conversationId, String uid)> markReadCalls = [];

  @override
  Stream<List<ChatMessage>> watchMessages({required String conversationId}) =>
      Stream.value(const []);

  @override
  String createMessageId({required String conversationId}) => 'message-1';

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
  }) async {
    markReadCalls.add((conversationId, uid));
  }
}
