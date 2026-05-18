import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_screen.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_body.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_cta.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../clubs/clubs_test_helpers.dart' show FakeClubsRepository;
import '../test_pump_helpers.dart';
import 'events_test_helpers.dart';

void main() {
  group('EventDetailScreen', () {
    test('stores the route arguments', () {
      final event = buildEvent(id: 'event-1', clubId: 'club-1');
      final screen = EventDetailScreen(
        clubId: 'club-1',
        eventId: 'event-1',
        initialEvent: event,
      );

      expect(screen.clubId, 'club-1');
      expect(screen.eventId, 'event-1');
      expect(screen.initialEvent, event);
    });

    testWidgets('renders the loading state', (tester) async {
      await pumpEventsTestApp(
        tester,
        const EventDetailScreen(clubId: 'club-1', eventId: 'event-1'),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          eventDetailViewModelProvider(
            'event-1',
          ).overrideWith((ref) => const AsyncLoading()),
        ],
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('uses initialEvent while live data is still loading', (
      tester,
    ) async {
      final event = buildEvent(
        id: 'event-1',
        clubId: 'club-1',
        meetingPoint: 'Marine Drive',
      );

      await pumpEventsTestApp(
        tester,
        EventDetailScreen(
          clubId: 'club-1',
          eventId: 'event-1',
          initialEvent: event,
        ),
        signedInUid: null,
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value(null)),
          eventDetailViewModelProvider(
            'event-1',
          ).overrideWith((ref) => const AsyncLoading()),
        ],
      );

      expect(find.text('Marine Drive'), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders the error state', (tester) async {
      await pumpEventsTestApp(
        tester,
        const EventDetailScreen(clubId: 'club-1', eventId: 'event-1'),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          eventDetailViewModelProvider('event-1').overrideWith(
            (ref) => AsyncError(StateError('boom'), StackTrace.empty),
          ),
        ],
      );

      expect(find.text('boom'), findsOneWidget);
    });

    testWidgets('renders the missing state', (tester) async {
      await pumpEventsTestApp(
        tester,
        const EventDetailScreen(clubId: 'club-1', eventId: 'event-1'),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          eventDetailViewModelProvider(
            'event-1',
          ).overrideWith((ref) => const AsyncData(null)),
        ],
      );

      expect(find.text('Event not found'), findsOneWidget);
      expect(find.text('This event is no longer available.'), findsOneWidget);
    });

    testWidgets('renders the loaded state', (tester) async {
      await pumpEventsTestApp(
        tester,
        const EventDetailScreen(clubId: 'club-1', eventId: 'event-1'),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          eventDetailViewModelProvider('event-1').overrideWith(
            (ref) => AsyncData(
              EventDetailViewModel(
                event: buildEvent(
                  id: 'event-1',
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

      expect(find.text('Wednesday Evening Event'), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('What to expect'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Attendance matters'), findsOneWidget);
      expect(find.text('Booking policy'), findsOneWidget);
    });
  });

  group('EventDetailCta', () {
    testWidgets('books a free event from the eligible state', (tester) async {
      final fakePaymentRepository = FakePaymentRepository();

      await pumpEventsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: EventDetailCta(
            event: buildEvent(bookedCount: 2),
            clubId: 'club1',
            isHost: false,
            userProfile: buildUser(),
            participation: null,
          ),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
        ],
      );

      await tester.tap(find.text('Join event — 18 spots left'));
      await tester.pump();

      expect(fakePaymentRepository.bookFreeEventCalled, isTrue);
      expect(fakePaymentRepository.bookedFreeEventId, 'event-1');
    });

    testWidgets('passes invite query codes into booking actions', (
      tester,
    ) async {
      final fakePaymentRepository = FakePaymentRepository();
      final event = buildEvent(
        bookedCount: 2,
        eventPolicy: EventPolicyBundle.inviteOnlyEvent(
          capacityLimit: 20,
          basePriceInPaise: 0,
        ),
      );

      await pumpEventsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: EventDetailCta(
            event: event,
            clubId: 'club1',
            isHost: false,
            userProfile: buildUser(),
            participation: null,
            inviteCode: 'CATCH-DELHI',
          ),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
        ],
      );

      await tester.tap(find.text('Join event — 18 spots left'));
      await tester.pump();

      expect(fakePaymentRepository.bookedFreeEventInviteCode, 'CATCH-DELHI');
    });

    testWidgets('keeps invite-only events blocked without an invite code', (
      tester,
    ) async {
      await pumpEventsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: EventDetailCta(
            event: buildEvent(
              eventPolicy: EventPolicyBundle.inviteOnlyEvent(
                capacityLimit: 20,
                basePriceInPaise: 0,
              ),
            ),
            clubId: 'club1',
            isHost: false,
            userProfile: buildUser(),
            participation: null,
          ),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text('Invite required'), findsOneWidget);
    });

    testWidgets('shows booking errors from the active mutation', (
      tester,
    ) async {
      final fakePaymentRepository = FakePaymentRepository()
        ..bookFreeEventError = StateError('booking failed');
      Object? uncaughtError;

      await pumpEventsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: EventDetailCta(
            event: buildEvent(),
            clubId: 'club1',
            isHost: false,
            userProfile: buildUser(),
            participation: null,
          ),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
        ],
      );

      await runZonedGuarded(
        () async {
          await tester.tap(find.text('Join event — 20 spots left'));
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
      await pumpEventsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: EventDetailCta(
            event: buildEvent(priceInPaise: 15000),
            clubId: 'club1',
            isHost: false,
            userProfile: buildUser(),
            participation: null,
          ),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
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
      final fakeEventRepository = FakeEventRepository();

      await pumpEventsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: EventDetailCta(
            event: buildEvent(bookedCount: 1),
            clubId: 'club1',
            isHost: false,
            userProfile: buildUser(),
            participation: _participation(
              status: EventParticipationStatus.signedUp,
            ),
          ),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      await tester.tap(find.text('Cancel booking'));
      await tester.pump();

      expect(fakeEventRepository.cancelledEventId, 'event-1');
    });

    testWidgets('does not use aggregate counts for the current viewer state', (
      tester,
    ) async {
      await pumpEventsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: EventDetailCta(
            event: buildEvent(bookedCount: 1),
            clubId: 'club1',
            isHost: false,
            userProfile: buildUser(uid: 'runner-1'),
            participation: null,
          ),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text('Cancel booking'), findsNothing);
      expect(find.text('Join event — 19 spots left'), findsOneWidget);
    });

    testWidgets('renders host tools as the event-detail bottom action', (
      tester,
    ) async {
      final startTime = DateTime(2026, 1, 1, 9);

      await pumpEventsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: EventDetailCta(
            event: buildEvent(startTime: startTime),
            clubId: 'club1',
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
      expect(find.text('Manage event'), findsOneWidget);
      expect(find.text('Join event — 20 spots left'), findsNothing);
    });

    testWidgets(
      'does not render self check-in as an event-detail bottom action',
      (tester) async {
        final startTime = DateTime(2026, 1, 1, 9);

        await pumpEventsTestApp(
          tester,
          Scaffold(
            bottomNavigationBar: EventDetailCta(
              event: buildEvent(startTime: startTime, bookedCount: 1),
              clubId: 'club1',
              isHost: false,
              now: startTime.subtract(const Duration(minutes: 5)),
              userProfile: buildUser(uid: 'runner-1'),
              participation: _participation(
                status: EventParticipationStatus.signedUp,
              ),
            ),
          ),
          overrides: [
            paymentRepositoryProvider.overrideWithValue(
              FakePaymentRepository(),
            ),
          ],
        );

        expect(find.text('Check in'), findsNothing);
        expect(find.text('Cancel booking'), findsNothing);
      },
    );

    testWidgets('joins and leaves the waitlist', (tester) async {
      final fakeEventRepository = FakeEventRepository();
      final container = ProviderContainer(
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
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
                  EventDetailCta(
                    event: buildEvent(capacityLimit: 1, bookedCount: 1),
                    clubId: 'club1',
                    isHost: false,
                    userProfile: buildUser(uid: 'runner-9'),
                    participation: null,
                  ),
                  EventDetailCta(
                    event: buildEvent(waitlistedCount: 1),
                    clubId: 'club1',
                    isHost: false,
                    userProfile: buildUser(uid: 'runner-9'),
                    participation: _participation(
                      uid: 'runner-9',
                      status: EventParticipationStatus.waitlisted,
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

      expect(fakeEventRepository.joinedWaitlistEventId, 'event-1');
      expect(fakeEventRepository.leftWaitlistEventId, 'event-1');
      expect(fakeEventRepository.leftWaitlistUserId, 'runner-9');
    });

    testWidgets('renders attended and past states', (tester) async {
      final pastStart = DateTime.now().subtract(const Duration(hours: 2));

      await pumpEventsTestApp(
        tester,
        Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EventDetailCta(
                event: buildEvent(
                  startTime: pastStart,
                  endTime: pastStart.add(const Duration(hours: 1)),
                  checkedInCount: 1,
                ),
                clubId: 'club1',
                isHost: false,
                userProfile: buildUser(),
                participation: _participation(
                  status: EventParticipationStatus.attended,
                ),
              ),
              EventDetailCta(
                event: buildEvent(
                  startTime: DateTime.now().subtract(const Duration(hours: 2)),
                  endTime: DateTime.now().subtract(const Duration(hours: 1)),
                ),
                clubId: 'club1',
                isHost: false,
                userProfile: buildUser(),
                participation: null,
              ),
            ],
          ),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text('You attended this event'), findsOneWidget);
      expect(find.text('This event has ended'), findsOneWidget);
    });

    testWidgets('does not show attended state before the event starts', (
      tester,
    ) async {
      final now = DateTime(2026, 5, 13, 19);
      final futureStart = DateTime(2026, 5, 14, 3, 10);

      await pumpEventsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: EventDetailCta(
            event: buildEvent(
              startTime: futureStart,
              endTime: futureStart.add(const Duration(hours: 1)),
              bookedCount: 9,
              checkedInCount: 1,
            ),
            clubId: 'club1',
            isHost: false,
            now: now,
            userProfile: buildUser(),
            participation: _participation(
              status: EventParticipationStatus.attended,
            ),
          ),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text('You attended this event'), findsNothing);
      expect(find.text('Completed'), findsNothing);
      expect(find.text('Cancel booking'), findsOneWidget);
    });

    testWidgets('renders ineligible ages and waitlistable cohort caps', (
      tester,
    ) async {
      final tooYoungUser = buildUser(
        dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 16)),
      );
      final olderUser = buildUser(
        uid: 'runner-2',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 45)),
      );

      await pumpEventsTestApp(
        tester,
        Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EventDetailCta(
                event: buildEvent(
                  constraints: const EventConstraints(minAge: 18),
                ),
                clubId: 'club1',
                isHost: false,
                userProfile: tooYoungUser,
                participation: null,
              ),
              EventDetailCta(
                event: buildEvent(
                  constraints: const EventConstraints(maxAge: 40),
                ),
                clubId: 'club1',
                isHost: false,
                userProfile: olderUser,
                participation: null,
              ),
              EventDetailCta(
                event: buildEvent(
                  constraints: const EventConstraints(maxMen: 1),
                  genderCounts: const {'man': 1},
                ),
                clubId: 'club1',
                isHost: false,
                userProfile: buildUser(uid: 'runner-3'),
                participation: null,
              ),
            ],
          ),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text('Must be 18+ to join'), findsOneWidget);
      expect(find.text('Must be 40 or younger'), findsOneWidget);
      expect(find.text('Join waitlist'), findsOneWidget);
    });
  });

  group('EventDetailBody', () {
    testWidgets('renders overview detail sections for attended events', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 3000);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final user = buildUser(uid: 'runner-1');
      final event = buildEvent(
        constraints: const EventConstraints(minAge: 21, maxAge: 35),
      );

      await pumpEventsTestApp(
        tester,
        EventDetailBody(
          event: event,
          userProfile: user,
          clubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: true,
          isSaved: false,
          participation: _participation(
            status: EventParticipationStatus.attended,
          ),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      expect(find.text(event.title), findsWidgets);
      expect(find.text('Requirements'), findsOneWidget);
      expect(find.text('About this event'), findsOneWidget);
      expect(find.text(event.description), findsOneWidget);
      expect(find.text('Event companion'), findsOneWidget);
      expect(find.text('Open companion'), findsOneWidget);
    });

    testWidgets('does not unlock reviews for stale future attendance data', (
      tester,
    ) async {
      final now = DateTime(2026, 5, 13, 19);
      final futureStart = DateTime(2026, 5, 14, 3, 10);
      final event = buildEvent(
        startTime: futureStart,
        endTime: futureStart.add(const Duration(hours: 1)),
      );

      await pumpEventsTestApp(
        tester,
        EventDetailBody(
          event: event,
          userProfile: buildUser(),
          clubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: true,
          isSaved: false,
          participation: _participation(
            status: EventParticipationStatus.attended,
          ),
          now: now,
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      await _scrollEventDetailUntilVisible(tester, find.text('Reviews'));

      expect(find.text('Reviews'), findsOneWidget);
      expect(find.text('Write a review'), findsNothing);
      expect(find.text('Edit your review'), findsNothing);
    });

    testWidgets('renders guest roster prompt and sign-in CTA', (tester) async {
      final event = buildEvent();

      await pumpEventsTestApp(
        tester,
        EventDetailBody(
          event: event,
          userProfile: null,
          clubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: false,
          isSaved: false,
          participation: null,
        ),
        signedInUid: null,
      );

      await _scrollEventDetailUntilVisible(
        tester,
        find.text('Sign in to see who has booked this event.'),
      );

      expect(find.text(event.title), findsWidgets);
      expect(
        find.text('Sign in to see who has booked this event.'),
        findsOneWidget,
      );
      expect(find.text('Sign in to book this event'), findsOneWidget);
      expect(find.text('Reviews'), findsNothing);
      expect(find.text('Write a review'), findsNothing);
    });

    testWidgets('shows a full-screen celebration after a successful booking', (
      tester,
    ) async {
      await pumpEventsTestApp(
        tester,
        EventDetailBody(
          event: buildEvent(),
          userProfile: buildUser(),
          clubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: true,
          isSaved: false,
          participation: null,
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
        ],
      );

      await tester.tap(find.text('Join event — 20 spots left'));
      await pumpFeatureUi(tester);

      expect(find.text('BOOKING CONFIRMED'), findsOneWidget);
      expect(find.text("You're in."), findsOneWidget);
      expect(find.text('View event'), findsOneWidget);
    });

    testWidgets('shows a snackbar after cancelling a booking', (tester) async {
      final fakeEventRepository = FakeEventRepository();

      await pumpEventsTestApp(
        tester,
        EventDetailBody(
          event: buildEvent(bookedCount: 1),
          userProfile: buildUser(),
          clubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: true,
          isSaved: false,
          participation: _participation(
            status: EventParticipationStatus.signedUp,
          ),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
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
      final fakeSavedEventRepository = FakeSavedEventRepository();
      var sharedEventId = '';
      Uri? calendarUri;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
            paymentRepositoryProvider.overrideWithValue(
              FakePaymentRepository(),
            ),
            savedEventRepositoryProvider.overrideWithValue(
              fakeSavedEventRepository,
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
              '/detail': (context) => EventDetailBody(
                event: buildEvent(),
                userProfile: buildUser(),
                clubId: 'club-1',
                isHost: false,
                reviews: const [],
                isAuthenticated: true,
                isSaved: false,
                participation: _participation(
                  status: EventParticipationStatus.signedUp,
                ),
                onShareEvent: (_, event) async {
                  sharedEventId = event.id;
                },
              ),
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byTooltip('Share event'), findsOneWidget);
      expect(find.byTooltip('Add to calendar'), findsOneWidget);
      expect(find.byTooltip('Save event'), findsOneWidget);
      await tester.tap(find.byTooltip('Share event'));
      await tester.pump();
      await tester.tap(find.byTooltip('Add to calendar'));
      await tester.pump();
      await tester.tap(find.byTooltip('Save event'));
      await tester.pump();
      await tester.tap(find.byTooltip('Back'));
      await _pumpUntilFound(tester, find.text('Home'));

      expect(sharedEventId, 'event-1');
      expect(calendarUri?.host, 'calendar.google.com');
      expect(fakeSavedEventRepository.savedEventId, 'event-1');
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('saved event button renders selected and unsaves', (
      tester,
    ) async {
      final fakeSavedEventRepository = FakeSavedEventRepository();

      await pumpEventsTestApp(
        tester,
        EventDetailBody(
          event: buildEvent(),
          userProfile: buildUser(),
          clubId: 'club-1',
          isHost: false,
          reviews: const [],
          isAuthenticated: true,
          isSaved: true,
          participation: null,
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
          savedEventRepositoryProvider.overrideWithValue(
            fakeSavedEventRepository,
          ),
        ],
      );

      expect(find.byTooltip('Unsave event'), findsOneWidget);

      await tester.tap(find.byTooltip('Unsave event'));
      await tester.pump();

      expect(fakeSavedEventRepository.unsavedUid, 'runner-1');
      expect(fakeSavedEventRepository.unsavedEventId, 'event-1');
      expect(find.text('Event removed.'), findsOneWidget);
    });

    testWidgets('location tap opens the in-app event map', (tester) async {
      final event = buildEvent(
        id: 'event-1',
        meetingPoint: 'Race Course Road main gate',
        startingPointLat: 22.7196,
        startingPointLng: 75.8577,
      );
      final router = GoRouter(
        initialLocation: '/detail',
        routes: [
          GoRoute(
            path: '/detail',
            builder: (context, state) => EventDetailBody(
              event: event,
              userProfile: buildUser(),
              clubId: 'club-1',
              isHost: false,
              reviews: const [],
              isAuthenticated: true,
              isSaved: false,
              participation: null,
            ),
          ),
          GoRoute(
            path: Routes.eventLocationMapScreen.path,
            name: Routes.eventLocationMapScreen.name,
            builder: (context, state) => EventLocationMapRouteScreen(
              eventId: state.pathParameters['eventId']!,
              enableNetworkTiles: false,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
            paymentRepositoryProvider.overrideWithValue(
              FakePaymentRepository(),
            ),
            eventDetailViewModelProvider('event-1').overrideWith(
              (ref) => AsyncData(
                EventDetailViewModel(
                  event: event,
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

      expect(find.text('Event location'), findsNothing);
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

Future<void> _scrollEventDetailUntilVisible(
  WidgetTester tester,
  Finder finder,
) async {
  final scrollView = find.byType(CustomScrollView);
  await tester.dragUntilVisible(finder, scrollView, const Offset(0, -80));
  await tester.pump();
}

EventParticipation _participation({
  String eventId = 'event-1',
  String uid = 'runner-1',
  EventParticipationStatus status = EventParticipationStatus.signedUp,
}) {
  final now = DateTime(2026, 1, 1);
  return EventParticipation(
    id: eventParticipationId(eventId: eventId, uid: uid),
    eventId: eventId,
    clubId: 'club-1',
    uid: uid,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}
