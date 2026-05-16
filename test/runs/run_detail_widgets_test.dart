import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/data/saved_run_repository.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_screen.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_view_model.dart';
import 'package:catch_dating_app/runs/presentation/run_location_map_screen.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_detail_body.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_detail_cta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../run_clubs/run_clubs_test_helpers.dart' show FakeRunClubsRepository;
import '../test_pump_helpers.dart';
import 'runs_test_helpers.dart';

void main() {
  group('RunDetailScreen', () {
    test('stores the route arguments', () {
      final run = buildRun(id: 'run-1', runClubId: 'club-1');
      final screen = RunDetailScreen(
        runClubId: 'club-1',
        runId: 'run-1',
        initialRun: run,
      );

      expect(screen.runClubId, 'club-1');
      expect(screen.runId, 'run-1');
      expect(screen.initialRun, run);
    });

    testWidgets('renders the loading state', (tester) async {
      await pumpRunsTestApp(
        tester,
        const RunDetailScreen(runClubId: 'club-1', runId: 'run-1'),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          runDetailViewModelProvider(
            'run-1',
          ).overrideWith((ref) => const AsyncLoading()),
        ],
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('uses initialRun while live data is still loading', (
      tester,
    ) async {
      final run = buildRun(
        id: 'run-1',
        runClubId: 'club-1',
        meetingPoint: 'Marine Drive',
      );

      await pumpRunsTestApp(
        tester,
        RunDetailScreen(runClubId: 'club-1', runId: 'run-1', initialRun: run),
        signedInUid: null,
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value(null)),
          runDetailViewModelProvider(
            'run-1',
          ).overrideWith((ref) => const AsyncLoading()),
        ],
      );

      expect(find.text('Marine Drive'), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders the error state', (tester) async {
      await pumpRunsTestApp(
        tester,
        const RunDetailScreen(runClubId: 'club-1', runId: 'run-1'),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          runDetailViewModelProvider('run-1').overrideWith(
            (ref) => AsyncError(StateError('boom'), StackTrace.empty),
          ),
        ],
      );

      expect(find.text('boom'), findsOneWidget);
    });

    testWidgets('renders the missing state', (tester) async {
      await pumpRunsTestApp(
        tester,
        const RunDetailScreen(runClubId: 'club-1', runId: 'run-1'),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          runDetailViewModelProvider(
            'run-1',
          ).overrideWith((ref) => const AsyncData(null)),
        ],
      );

      expect(find.text('Run not found'), findsOneWidget);
      expect(find.text('This run is no longer available.'), findsOneWidget);
    });

    testWidgets('renders the loaded state', (tester) async {
      await pumpRunsTestApp(
        tester,
        const RunDetailScreen(runClubId: 'club-1', runId: 'run-1'),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          runDetailViewModelProvider('run-1').overrideWith(
            (ref) => AsyncData(
              RunDetailViewModel(
                run: buildRun(
                  id: 'run-1',
                  startTime: DateTime(2025, 4, 23, 18),
                  endTime: DateTime(2025, 4, 23, 19),
                ),
                userProfile: buildUser(),
                reviews: const [],
                isAuthenticated: true,
                isHost: false,
                isSaved: false,
                participation: null,
              ),
            ),
          ),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text('Wednesday Evening Run'), findsWidgets);
    });
  });

  group('RunDetailCta', () {
    testWidgets('books a free run from the eligible state', (tester) async {
      final fakePaymentRepository = FakePaymentRepository();

      await pumpRunsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: RunDetailCta(
            run: buildRun(bookedCount: 2),
            runClubId: 'club1',
            isHost: false,
            userProfile: buildUser(),
            participation: null,
          ),
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
        ],
      );

      await tester.tap(find.text('Join run — 18 spots left'));
      await tester.pump();

      expect(fakePaymentRepository.bookFreeRunCalled, isTrue);
      expect(fakePaymentRepository.bookedFreeRunId, 'run-1');
    });

    testWidgets('shows booking errors from the active mutation', (
      tester,
    ) async {
      final fakePaymentRepository = FakePaymentRepository()
        ..bookFreeRunError = StateError('booking failed');
      Object? uncaughtError;

      await pumpRunsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: RunDetailCta(
            run: buildRun(),
            runClubId: 'club1',
            isHost: false,
            userProfile: buildUser(),
            participation: null,
          ),
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
        ],
      );

      await runZonedGuarded(
        () async {
          await tester.tap(find.text('Join run — 20 spots left'));
          await tester.pump();
        },
        (error, stackTrace) {
          uncaughtError = error;
        },
      );

      expect(uncaughtError, isA<StateError>());
      await tester.pump();

      expect(find.text('booking failed'), findsOneWidget);
    });

    testWidgets('disables paid bookings when the platform is unsupported', (
      tester,
    ) async {
      await pumpRunsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: RunDetailCta(
            run: buildRun(priceInPaise: 15000),
            runClubId: 'club1',
            isHost: false,
            userProfile: buildUser(),
            participation: null,
          ),
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(
            FakePaymentRepository(supportsPaid: false),
          ),
        ],
      );

      expect(find.text('Unavailable on this platform'), findsOneWidget);
      expect(
        tester.widget<CatchButton>(find.byType(CatchButton)).onPressed,
        isNull,
      );
    });

    testWidgets('cancels an existing booking', (tester) async {
      final fakeRunRepository = FakeRunRepository();

      await pumpRunsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: RunDetailCta(
            run: buildRun(bookedCount: 1),
            runClubId: 'club1',
            isHost: false,
            userProfile: buildUser(),
            participation: _participation(
              status: RunParticipationStatus.signedUp,
            ),
          ),
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          runRepositoryProvider.overrideWith((ref) => fakeRunRepository),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      await tester.tap(find.text('Cancel booking'));
      await tester.pump();

      expect(fakeRunRepository.cancelledRunId, 'run-1');
    });

    testWidgets('does not use aggregate counts for the current viewer state', (
      tester,
    ) async {
      await pumpRunsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: RunDetailCta(
            run: buildRun(bookedCount: 1),
            runClubId: 'club1',
            isHost: false,
            userProfile: buildUser(uid: 'runner-1'),
            participation: null,
          ),
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text('Cancel booking'), findsNothing);
      expect(find.text('Join run — 19 spots left'), findsOneWidget);
    });

    testWidgets('renders host tools as the run-detail bottom action', (
      tester,
    ) async {
      final startTime = DateTime(2026, 1, 1, 9);

      await pumpRunsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: RunDetailCta(
            run: buildRun(startTime: startTime),
            runClubId: 'club1',
            isHost: true,
            now: startTime.subtract(const Duration(minutes: 5)),
            userProfile: buildUser(uid: 'host-1'),
            participation: null,
          ),
        ),
        overrides: [
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text('HOST TOOLS'), findsOneWidget);
      expect(find.text('ATTENDANCE OPEN'), findsOneWidget);
      expect(find.text('Take attendance'), findsOneWidget);
      expect(find.text('Manage run'), findsOneWidget);
      expect(find.text('Join run — 20 spots left'), findsNothing);
    });

    testWidgets('does not render self check-in as a run-detail bottom action', (
      tester,
    ) async {
      final startTime = DateTime(2026, 1, 1, 9);

      await pumpRunsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: RunDetailCta(
            run: buildRun(startTime: startTime, bookedCount: 1),
            runClubId: 'club1',
            isHost: false,
            now: startTime.subtract(const Duration(minutes: 5)),
            userProfile: buildUser(uid: 'runner-1'),
            participation: _participation(
              status: RunParticipationStatus.signedUp,
            ),
          ),
        ),
        overrides: [
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text('Check in'), findsNothing);
      expect(find.text('Cancel booking'), findsNothing);
    });

    testWidgets('joins and leaves the waitlist', (tester) async {
      final fakeRunRepository = FakeRunRepository();
      final container = ProviderContainer(
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          runRepositoryProvider.overrideWith((ref) => fakeRunRepository),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
          uidProvider.overrideWith((ref) => Stream.value('runner-9')),
        ],
      );
      addTearDown(container.dispose);
      final uidSubscription = container.listen(
        uidProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(uidSubscription.close);
      await container.pump();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: ListView(
                children: [
                  RunDetailCta(
                    run: buildRun(capacityLimit: 1, bookedCount: 1),
                    runClubId: 'club1',
                    isHost: false,
                    userProfile: buildUser(uid: 'runner-9'),
                    participation: null,
                  ),
                  RunDetailCta(
                    run: buildRun(waitlistedCount: 1),
                    runClubId: 'club1',
                    isHost: false,
                    userProfile: buildUser(uid: 'runner-9'),
                    participation: _participation(
                      uid: 'runner-9',
                      status: RunParticipationStatus.waitlisted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Join waitlist'));
      await tester.pump();
      await tester.tap(find.text('Leave waitlist'));
      await tester.pump();

      expect(fakeRunRepository.joinedWaitlistRunId, 'run-1');
      expect(fakeRunRepository.leftWaitlistRunId, 'run-1');
      expect(fakeRunRepository.leftWaitlistUserId, 'runner-9');
    });

    testWidgets('renders attended and past states', (tester) async {
      final pastStart = DateTime.now().subtract(const Duration(hours: 2));

      await pumpRunsTestApp(
        tester,
        Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RunDetailCta(
                run: buildRun(
                  startTime: pastStart,
                  endTime: pastStart.add(const Duration(hours: 1)),
                  checkedInCount: 1,
                ),
                runClubId: 'club1',
                isHost: false,
                userProfile: buildUser(),
                participation: _participation(
                  status: RunParticipationStatus.attended,
                ),
              ),
              RunDetailCta(
                run: buildRun(
                  startTime: DateTime.now().subtract(const Duration(hours: 2)),
                  endTime: DateTime.now().subtract(const Duration(hours: 1)),
                ),
                runClubId: 'club1',
                isHost: false,
                userProfile: buildUser(),
                participation: null,
              ),
            ],
          ),
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text('You attended this run'), findsOneWidget);
      expect(find.text('This run has ended'), findsOneWidget);
    });

    testWidgets('does not show attended state before the run starts', (
      tester,
    ) async {
      final now = DateTime(2026, 5, 13, 19);
      final futureStart = DateTime(2026, 5, 14, 3, 10);

      await pumpRunsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: RunDetailCta(
            run: buildRun(
              startTime: futureStart,
              endTime: futureStart.add(const Duration(hours: 1)),
              bookedCount: 9,
              checkedInCount: 1,
            ),
            runClubId: 'club1',
            isHost: false,
            now: now,
            userProfile: buildUser(),
            participation: _participation(
              status: RunParticipationStatus.attended,
            ),
          ),
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text('You attended this run'), findsNothing);
      expect(find.text('Completed'), findsNothing);
      expect(find.text('Cancel booking'), findsOneWidget);
    });

    testWidgets('renders ineligible reasons for age and gender caps', (
      tester,
    ) async {
      final tooYoungUser = buildUser(
        dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 16)),
      );
      final olderUser = buildUser(
        uid: 'runner-2',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 45)),
      );

      await pumpRunsTestApp(
        tester,
        Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RunDetailCta(
                run: buildRun(constraints: const RunConstraints(minAge: 18)),
                runClubId: 'club1',
                isHost: false,
                userProfile: tooYoungUser,
                participation: null,
              ),
              RunDetailCta(
                run: buildRun(constraints: const RunConstraints(maxAge: 40)),
                runClubId: 'club1',
                isHost: false,
                userProfile: olderUser,
                participation: null,
              ),
              RunDetailCta(
                run: buildRun(
                  constraints: const RunConstraints(maxMen: 1),
                  genderCounts: const {'man': 1},
                ),
                runClubId: 'club1',
                isHost: false,
                userProfile: buildUser(uid: 'runner-3'),
                participation: null,
              ),
            ],
          ),
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text('Must be 18+ to join'), findsOneWidget);
      expect(find.text('Must be 40 or younger'), findsOneWidget);
      expect(find.text('Spots for your gender are full'), findsOneWidget);
    });
  });

  group('RunDetailBody', () {
    testWidgets('renders overview detail sections for attended runs', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 3000);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final user = buildUser(uid: 'runner-1');
      final run = buildRun(
        constraints: const RunConstraints(minAge: 21, maxAge: 35),
      );

      await pumpRunsTestApp(
        tester,
        RunDetailBody(
          run: run,
          userProfile: user,
          runClubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: true,
          isSaved: false,
          participation: _participation(
            status: RunParticipationStatus.attended,
          ),
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text(run.title), findsWidgets);
      expect(find.text('Requirements'), findsOneWidget);
      expect(find.text('About this run'), findsOneWidget);
      expect(find.text(run.description), findsOneWidget);
    });

    testWidgets('does not unlock reviews for stale future attendance data', (
      tester,
    ) async {
      final now = DateTime(2026, 5, 13, 19);
      final futureStart = DateTime(2026, 5, 14, 3, 10);
      final run = buildRun(
        startTime: futureStart,
        endTime: futureStart.add(const Duration(hours: 1)),
      );

      await pumpRunsTestApp(
        tester,
        RunDetailBody(
          run: run,
          userProfile: buildUser(),
          runClubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: true,
          isSaved: false,
          participation: _participation(
            status: RunParticipationStatus.attended,
          ),
          now: now,
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      await _scrollRunDetailUntilVisible(tester, find.text('Reviews'));

      expect(find.text('Reviews'), findsOneWidget);
      expect(find.text('Write a review'), findsNothing);
      expect(find.text('Edit your review'), findsNothing);
    });

    testWidgets('renders guest roster prompt and sign-in CTA', (tester) async {
      final run = buildRun();

      await pumpRunsTestApp(
        tester,
        RunDetailBody(
          run: run,
          userProfile: null,
          runClubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: false,
          isSaved: false,
          participation: null,
        ),
        signedInUid: null,
      );

      await _scrollRunDetailUntilVisible(
        tester,
        find.text('Sign in to see who has booked this run.'),
      );

      expect(find.text(run.title), findsWidgets);
      expect(
        find.text('Sign in to see who has booked this run.'),
        findsOneWidget,
      );
      expect(find.text('Sign in to book this run'), findsOneWidget);
      expect(find.text('Reviews'), findsNothing);
      expect(find.text('Write a review'), findsNothing);
    });

    testWidgets('shows a full-screen celebration after a successful booking', (
      tester,
    ) async {
      await pumpRunsTestApp(
        tester,
        RunDetailBody(
          run: buildRun(),
          userProfile: buildUser(),
          runClubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: true,
          isSaved: false,
          participation: null,
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      await tester.tap(find.text('Join run — 20 spots left'));
      await pumpFeatureUi(tester);

      expect(find.text('BOOKING CONFIRMED'), findsOneWidget);
      expect(find.text("You're in."), findsOneWidget);
      expect(find.text('View run'), findsOneWidget);
    });

    testWidgets('shows a snackbar after cancelling a booking', (tester) async {
      final fakeRunRepository = FakeRunRepository();

      await pumpRunsTestApp(
        tester,
        RunDetailBody(
          run: buildRun(bookedCount: 1),
          userProfile: buildUser(),
          runClubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: true,
          isSaved: false,
          participation: _participation(
            status: RunParticipationStatus.signedUp,
          ),
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          runRepositoryProvider.overrideWith((ref) => fakeRunRepository),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      await tester.tap(find.text('Cancel booking'));
      await tester.pump();

      expect(find.text('Booking cancelled.'), findsOneWidget);
    });

    testWidgets('top action buttons are tappable and the back button pops', (
      tester,
    ) async {
      final fakeSavedRunRepository = FakeSavedRunRepository();
      var sharedRunId = '';
      Uri? calendarUri;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            runClubsRepositoryProvider.overrideWithValue(
              FakeRunClubsRepository(),
            ),
            paymentRepositoryProvider.overrideWithValue(
              FakePaymentRepository(),
            ),
            savedRunRepositoryProvider.overrideWithValue(
              fakeSavedRunRepository,
            ),
            externalUrlLauncherProvider.overrideWithValue((
              uri, {
              LaunchMode mode = LaunchMode.platformDefault,
            }) async {
              calendarUri = uri;
              return true;
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            initialRoute: '/detail',
            routes: {
              '/': (context) =>
                  const Scaffold(body: Center(child: Text('Home'))),
              '/detail': (context) => RunDetailBody(
                run: buildRun(),
                userProfile: buildUser(),
                runClubId: 'club-1',
                isHost: false,
                reviews: const [],
                isAuthenticated: true,
                isSaved: false,
                participation: _participation(
                  status: RunParticipationStatus.signedUp,
                ),
                onShareRun: (_, run) async {
                  sharedRunId = run.id;
                },
              ),
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byTooltip('Share run'), findsOneWidget);
      expect(find.byTooltip('Add to calendar'), findsOneWidget);
      expect(find.byTooltip('Save run'), findsOneWidget);
      await tester.tap(find.byTooltip('Share run'));
      await tester.pump();
      await tester.tap(find.byTooltip('Add to calendar'));
      await tester.pump();
      await tester.tap(find.byTooltip('Save run'));
      await tester.pump();
      await tester.tap(find.byTooltip('Back'));
      await _pumpUntilFound(tester, find.text('Home'));

      expect(sharedRunId, 'run-1');
      expect(calendarUri?.host, 'calendar.google.com');
      expect(fakeSavedRunRepository.savedRunId, 'run-1');
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('saved run button renders selected and unsaves', (
      tester,
    ) async {
      final fakeSavedRunRepository = FakeSavedRunRepository();

      await pumpRunsTestApp(
        tester,
        RunDetailBody(
          run: buildRun(),
          userProfile: buildUser(),
          runClubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: true,
          isSaved: true,
          participation: null,
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
          savedRunRepositoryProvider.overrideWithValue(fakeSavedRunRepository),
        ],
      );

      expect(find.byTooltip('Unsave run'), findsOneWidget);

      await tester.tap(find.byTooltip('Unsave run'));
      await tester.pump();

      expect(fakeSavedRunRepository.unsavedUid, 'runner-1');
      expect(fakeSavedRunRepository.unsavedRunId, 'run-1');
      expect(find.text('Run removed.'), findsOneWidget);
    });

    testWidgets('location tap opens the in-app run map', (tester) async {
      final run = buildRun(
        id: 'run-1',
        meetingPoint: 'Race Course Road main gate',
        startingPointLat: 22.7196,
        startingPointLng: 75.8577,
      );
      final router = GoRouter(
        initialLocation: '/detail',
        routes: [
          GoRoute(
            path: '/detail',
            builder: (context, state) => RunDetailBody(
              run: run,
              userProfile: buildUser(),
              runClubId: 'club-1',
              isHost: false,
              reviews: const [],
              isAuthenticated: true,
              isSaved: false,
              participation: null,
            ),
          ),
          GoRoute(
            path: Routes.runLocationMapScreen.path,
            name: Routes.runLocationMapScreen.name,
            builder: (context, state) => RunLocationMapRouteScreen(
              runId: state.pathParameters['runId']!,
              enableNetworkTiles: false,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            runClubsRepositoryProvider.overrideWithValue(
              FakeRunClubsRepository(),
            ),
            paymentRepositoryProvider.overrideWithValue(
              FakePaymentRepository(),
            ),
            runDetailViewModelProvider('run-1').overrideWith(
              (ref) => AsyncData(
                RunDetailViewModel(
                  run: run,
                  userProfile: buildUser(),
                  reviews: const [],
                  isAuthenticated: true,
                  isHost: false,
                  isSaved: false,
                  participation: null,
                ),
              ),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );

      await tester.pump();
      final locationLabel = find.text('Race Course Road main gate').last;
      await tester.ensureVisible(locationLabel);
      await tester.pump();
      await tester.tap(locationLabel);
      await tester.pumpAndSettle();

      expect(find.text('Run location'), findsNothing);
      expect(find.text('Get directions'), findsOneWidget);
    });
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxFrames = 30,
}) async {
  for (var i = 0; i < maxFrames; i += 1) {
    await tester.pump();
    if (finder.evaluate().isNotEmpty) return;
  }
}

Future<void> _scrollRunDetailUntilVisible(
  WidgetTester tester,
  Finder finder,
) async {
  final scrollView = find.byType(CustomScrollView);
  await tester.dragUntilVisible(finder, scrollView, const Offset(0, -80));
  await tester.pump();
}

RunParticipation _participation({
  String runId = 'run-1',
  String uid = 'runner-1',
  RunParticipationStatus status = RunParticipationStatus.signedUp,
}) {
  final now = DateTime(2026, 1, 1);
  return RunParticipation(
    id: runParticipationId(runId: runId, uid: uid),
    runId: runId,
    runClubId: 'club-1',
    uid: uid,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}
