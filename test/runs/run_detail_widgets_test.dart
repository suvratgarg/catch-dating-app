import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_screen.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_view_model.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_detail_body.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_detail_cta.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../run_clubs/run_clubs_test_helpers.dart' show FakeRunClubsRepository;
import 'runs_test_helpers.dart';

void main() {
  group('RunDetailScreen', () {
    test('stores the route arguments', () {
      final screen = RunDetailScreen(runClubId: 'club-1', runId: 'run-1');

      expect(screen.runClubId, 'club-1');
      expect(screen.runId, 'run-1');
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

      expect(find.text('Run not found.'), findsOneWidget);
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
            run: buildRun(signedUpUserIds: const ['a', 'b']),
            runClubId: 'club1',
            isHost: false,
            userProfile: buildUser(),
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
            run: buildRun(signedUpUserIds: const ['runner-1']),
            runClubId: 'club1',
            isHost: false,
            userProfile: buildUser(),
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

    testWidgets('shows attendance action for hosts after attendance opens', (
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
          ),
        ),
        overrides: [
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text('Take Attendance'), findsOneWidget);
      expect(find.text('Join run — 20 spots left'), findsNothing);
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
                    run: buildRun(
                      capacityLimit: 1,
                      signedUpUserIds: const ['other-runner'],
                    ),
                    runClubId: 'club1',
                    isHost: false,
                    userProfile: buildUser(uid: 'runner-9'),
                  ),
                  RunDetailCta(
                    run: buildRun(waitlistUserIds: const ['runner-9']),
                    runClubId: 'club1',
                    isHost: false,
                    userProfile: buildUser(uid: 'runner-9'),
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
      await pumpRunsTestApp(
        tester,
        Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RunDetailCta(
                run: buildRun(attendedUserIds: const ['runner-1']),
                runClubId: 'club1',
                isHost: false,
                userProfile: buildUser(),
              ),
              RunDetailCta(
                run: buildRun(
                  startTime: DateTime.now().subtract(const Duration(hours: 2)),
                  endTime: DateTime.now().subtract(const Duration(hours: 1)),
                ),
                runClubId: 'club1',
                isHost: false,
                userProfile: buildUser(),
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
              ),
              RunDetailCta(
                run: buildRun(constraints: const RunConstraints(maxAge: 40)),
                runClubId: 'club1',
                isHost: false,
                userProfile: olderUser,
              ),
              RunDetailCta(
                run: buildRun(
                  constraints: const RunConstraints(maxMen: 1),
                  genderCounts: const {'man': 1},
                ),
                runClubId: 'club1',
                isHost: false,
                userProfile: buildUser(uid: 'runner-3'),
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
    testWidgets('renders detail sections and review CTA when attended', (
      tester,
    ) async {
      final user = buildUser(uid: 'runner-1');
      final run = buildRun(
        attendedUserIds: const ['runner-1'],
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
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      await _scrollRunDetailUntilVisible(tester, find.text("Who's running"));

      expect(find.text(run.title), findsWidgets);
      expect(find.text('Requirements'), findsOneWidget);
      expect(find.text("Who's running"), findsOneWidget);
      expect(find.text('Reviews'), findsOneWidget);
      expect(find.text('Write a review'), findsOneWidget);
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

    testWidgets('shows a snackbar after a successful booking', (tester) async {
      await pumpRunsTestApp(
        tester,
        RunDetailBody(
          run: buildRun(),
          userProfile: buildUser(),
          runClubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: true,
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      await tester.tap(find.text('Join run — 20 spots left'));
      await tester.pump();

      expect(find.text('Booking confirmed!'), findsOneWidget);
    });

    testWidgets('shows a snackbar after cancelling a booking', (tester) async {
      final fakeRunRepository = FakeRunRepository();

      await pumpRunsTestApp(
        tester,
        RunDetailBody(
          run: buildRun(signedUpUserIds: const ['runner-1']),
          userProfile: buildUser(),
          runClubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: true,
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
      final fakeUserProfileRepository = FakeUserProfileRepository();
      var sharedRunId = '';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            runClubsRepositoryProvider.overrideWithValue(
              FakeRunClubsRepository(),
            ),
            paymentRepositoryProvider.overrideWithValue(
              FakePaymentRepository(),
            ),
            userProfileRepositoryProvider.overrideWithValue(
              fakeUserProfileRepository,
            ),
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
      expect(find.byTooltip('Save run'), findsOneWidget);
      await tester.tap(find.byTooltip('Share run'));
      await tester.pump();
      await tester.tap(find.byTooltip('Save run'));
      await tester.pump();
      await tester.tap(find.byTooltip('Back'));
      await _pumpUntilFound(tester, find.text('Home'));

      expect(sharedRunId, 'run-1');
      expect(fakeUserProfileRepository.savedRunId, 'run-1');
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('saved run button renders selected and unsaves', (
      tester,
    ) async {
      final fakeUserProfileRepository = FakeUserProfileRepository();

      await pumpRunsTestApp(
        tester,
        RunDetailBody(
          run: buildRun(),
          userProfile: buildUser(savedRunIds: const ['run-1']),
          runClubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: true,
        ),
        overrides: [
          runClubsRepositoryProvider.overrideWithValue(
            FakeRunClubsRepository(),
          ),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
          userProfileRepositoryProvider.overrideWithValue(
            fakeUserProfileRepository,
          ),
        ],
      );

      expect(find.byTooltip('Unsave run'), findsOneWidget);

      await tester.tap(find.byTooltip('Unsave run'));
      await tester.pump();

      expect(fakeUserProfileRepository.unsavedUid, 'runner-1');
      expect(fakeUserProfileRepository.unsavedRunId, 'run-1');
      expect(find.text('Run removed.'), findsOneWidget);
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
  await tester.scrollUntilVisible(
    finder,
    220,
    scrollable: find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
      description: 'vertical run detail scrollable',
    ),
  );
  await tester.pump();
}
