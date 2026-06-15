import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_event_thumbnail.dart';
import 'package:catch_dating_app/core/widgets/rich_share_card_sheet.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_calendar_links.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_screen.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_body.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_cta.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_design_primitives.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_hero_app_bar.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_share_card.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../clubs/clubs_test_helpers.dart' show FakeClubsRepository;
import '../test_pump_helpers.dart';
import 'events_test_helpers.dart';

void main() {
  group('EventDetailScreen', () {
    test('stores the route arguments', () {
      final event = buildEvent();
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
      final event = buildEvent(meetingPoint: 'Marine Drive');

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
      await tester.scrollUntilVisible(
        find.text('What to expect'),
        400,
        scrollable: findPrimaryScrollable(),
      );
      expect(find.text('Attendance matters'), findsOneWidget);
      expect(find.text('Booking policy'), findsOneWidget);
    });
  });

  group('EventDetailPhotoStrip', () {
    testWidgets('renders canonical three-tile strip with placeholders', (
      tester,
    ) async {
      final event = buildEvent().copyWith(
        eventPhotos: [
          UploadedPhoto.fromUpload(
            url: 'https://example.test/event-photo.jpg',
            storagePath: 'events/event-1/photos/photo-0.jpg',
            position: 0,
            now: DateTime(2026, 6, 15),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: EventDetailPhotoStrip(event: event),
            ),
          ),
        ),
      );

      expect(find.text('EVENT PHOTOS'), findsOneWidget);
      expect(find.text('1 UPLOADED'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('event-photo-strip-tile-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('event-photo-strip-tile-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('event-photo-strip-tile-2')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('event-photo-strip-image-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('event-photo-strip-placeholder-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('event-photo-strip-placeholder-2')),
        findsOneWidget,
      );
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
            userProfile: buildUser(),
            participation: null,
          ),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
        ],
      );

      final button = tester.widget<CatchButton>(
        find.widgetWithText(CatchButton, 'Join event — 18 spots left'),
      );
      expect(button.accentColor, isNotNull);

      await tester.tap(find.text('Join event — 18 spots left'));
      await tester.pump();

      expect(fakePaymentRepository.bookFreeEventCalled, isTrue);
      expect(fakePaymentRepository.bookedFreeEventId, 'event-1');
    });

    testWidgets('gates run-event booking behind run preferences', (
      tester,
    ) async {
      final fakePaymentRepository = FakePaymentRepository();

      await pumpEventsTestApp(
        tester,
        Scaffold(
          bottomNavigationBar: EventDetailCta(
            event: buildEvent(bookedCount: 2),
            clubId: 'club1',
            userProfile: buildUser(runPreferencesVersion: 0),
            participation: null,
          ),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
        ],
      );

      expect(find.text('Set run preferences'), findsOneWidget);
      expect(find.text('Join event — 18 spots left'), findsNothing);
      await tester.tap(find.text('Set run preferences'));
      await tester.pump();

      expect(fakePaymentRepository.bookFreeEventCalled, isFalse);
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
            userProfile: buildUser(),
            participation: null,
            inviteCode: 'CATCH-DELHI',
            inviteLinkId: 'invite-link-1',
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
      expect(
        fakePaymentRepository.bookedFreeEventInviteLinkId,
        'invite-link-1',
      );
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

      expect(find.text('Paid booking unavailable'), findsOneWidget);
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
            userProfile: buildUser(),
            participation: _participation(),
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
            userProfile: buildUser(),
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
              now: startTime.subtract(const Duration(minutes: 5)),
              userProfile: buildUser(),
              participation: _participation(),
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
                    userProfile: buildUser(uid: 'runner-9'),
                    participation: null,
                  ),
                  EventDetailCta(
                    event: buildEvent(waitlistedCount: 1),
                    clubId: 'club1',
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
    });

    testWidgets('accepts and declines active waitlist offers', (tester) async {
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

      Future<void> pumpOfferCta() async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                bottomNavigationBar: EventDetailCta(
                  event: buildEvent(),
                  clubId: 'club1',
                  now: DateTime(2026, 1, 1, 12),
                  userProfile: buildUser(uid: 'runner-9'),
                  participation: _participation(
                    uid: 'runner-9',
                    status: EventParticipationStatus.waitlisted,
                    waitlistOfferStatus: EventWaitlistOfferStatus.active,
                    waitlistOfferExpiresAt: DateTime(2026, 1, 1, 13),
                    waitlistOfferId: 'event-1_runner-9',
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
      }

      await pumpOfferCta();
      expect(find.text('Accept spot'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
      expect(find.text('Until 1:00 PM'), findsOneWidget);

      await tester.tap(find.text('Decline'));
      await tester.pump();
      expect(fakeEventRepository.declinedWaitlistOfferEventId, 'event-1');

      await pumpOfferCta();
      await tester.tap(find.text('Accept spot'));
      await tester.pump();
      expect(fakeEventRepository.acceptedWaitlistOfferEventId, 'event-1');
    });

    testWidgets('request-only events use request and withdraw copy', (
      tester,
    ) async {
      final fakeEventRepository = FakeEventRepository();
      final fakePaymentRepository = FakePaymentRepository();
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
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

      final event = buildEvent(
        eventPolicy: EventPolicyBundle.requestToJoinEvent(
          capacityLimit: 12,
          basePriceInPaise: 0,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: ListView(
                children: [
                  EventDetailCta(
                    event: event,
                    clubId: 'club1',
                    userProfile: buildUser(uid: 'runner-9'),
                    participation: null,
                  ),
                  EventDetailCta(
                    event: event,
                    clubId: 'club1',
                    userProfile: buildUser(uid: 'runner-9'),
                    participation: _participation(
                      uid: 'runner-9',
                      status: EventParticipationStatus.waitlisted,
                    ),
                  ),
                  EventDetailCta(
                    event: event,
                    clubId: 'club1',
                    userProfile: buildUser(uid: 'runner-9'),
                    participation: _participation(
                      uid: 'runner-9',
                      status: EventParticipationStatus.waitlisted,
                      hostApprovalStatus: EventJoinRequestStatus.approved,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Request to join'));
      await tester.pump();

      expect(find.text('Withdraw request'), findsOneWidget);
      expect(find.text('Join approved event'), findsOneWidget);
      expect(fakeEventRepository.joinedWaitlistEventId, 'event-1');

      await tester.tap(find.text('Join approved event'));
      await tester.pump();

      expect(fakePaymentRepository.bookFreeEventCalled, isTrue);
      expect(fakePaymentRepository.bookedFreeEventId, 'event-1');
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
                userProfile: tooYoungUser,
                participation: null,
              ),
              EventDetailCta(
                event: buildEvent(
                  constraints: const EventConstraints(maxAge: 40),
                ),
                clubId: 'club1',
                userProfile: olderUser,
                participation: null,
              ),
              EventDetailCta(
                event: buildEvent(
                  constraints: const EventConstraints(maxMen: 1),
                  genderCounts: const {'man': 1},
                ),
                clubId: 'club1',
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

  group('EventDetailHeroAppBar', () {
    testWidgets('reveals the event title in the collapsed toolbar', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final event = buildEvent(
        startTime: DateTime(2026, 5, 28, 1, 42),
        endTime: DateTime(2026, 5, 28, 2, 42),
      );
      var saved = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                EventDetailHeroAppBar(
                  event: event,
                  isSaved: false,
                  savePending: false,
                  onBack: () {},
                  onShare: (_) {},
                  showAddToCalendar: false,
                  onAddToCalendar: (_) {},
                  onToggleSaved: () => saved = true,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 900)),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('event-detail-collapsed-title')),
        findsNothing,
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -320));
      await tester.pump();

      final collapsedTitle = find.byKey(
        const ValueKey('event-detail-collapsed-title'),
      );
      expect(collapsedTitle, findsOneWidget);
      expect(tester.getTopLeft(collapsedTitle).dy, lessThan(96));

      await tester.tap(find.byTooltip('Save event'));
      await tester.pump();
      expect(saved, true);
    });

    testWidgets('keeps the expanded hero title-only', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final event = buildEvent(
        startTime: DateTime(2026, 5, 28, 7, 30),
        endTime: DateTime(2026, 5, 28, 8, 45),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                EventDetailHeroAppBar(
                  event: event,
                  isSaved: true,
                  savePending: false,
                  onBack: () {},
                  onShare: (_) {},
                  showAddToCalendar: true,
                  onAddToCalendar: (_) {},
                  onToggleSaved: () {},
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 900)),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Thursday Morning Run'), findsOneWidget);
      expect(find.textContaining('THU'), findsNothing);
      expect(find.textContaining('7:30'), findsNothing);
      expect(find.text("You're in"), findsNothing);
      expect(find.text('Saved'), findsNothing);
      expect(find.byTooltip('Share event'), findsOneWidget);
      expect(find.byTooltip('Add to calendar'), findsOneWidget);
      expect(find.byTooltip('Unsave event'), findsOneWidget);
    });

    testWidgets('prefers event photos across detail hero presentations', (
      tester,
    ) async {
      final event = buildEvent(
        photoUrl: 'https://example.com/event-detail-photo.jpg',
      );

      Future<void> pumpHero(EventDetailPresentationMode mode) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  EventDetailHeroAppBar(
                    event: event,
                    isSaved: false,
                    savePending: false,
                    onBack: () {},
                    onShare: (_) {},
                    showAddToCalendar: false,
                    onAddToCalendar: (_) {},
                    onToggleSaved: () {},
                    presentationMode: mode,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 900)),
                ],
              ),
            ),
          ),
        );
      }

      for (final mode in EventDetailPresentationMode.values) {
        await pumpHero(mode);
        final thumbnail = tester.widget<CatchEventThumbnail>(
          find.byType(CatchEventThumbnail),
        );
        expect(
          thumbnail.photoUrl,
          'https://example.com/event-detail-photo.jpg',
        );
        expect(thumbnail.preferActivityArtwork, isFalse);
      }
    });

    testWidgets('uses semantic expanded heights for detail presentations', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final event = buildEvent();

      Future<void> pumpHero(EventDetailPresentationMode mode) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  EventDetailHeroAppBar(
                    event: event,
                    isSaved: false,
                    savePending: false,
                    onBack: () {},
                    onShare: (_) {},
                    showAddToCalendar: false,
                    onAddToCalendar: (_) {},
                    onToggleSaved: () {},
                    presentationMode: mode,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 900)),
                ],
              ),
            ),
          ),
        );
      }

      await pumpHero(EventDetailPresentationMode.standard);
      final standardHeight =
          (430 * CatchLayout.eventDetailHeroStandardHeightRatio)
              .clamp(
                CatchLayout.eventDetailHeroStandardMinHeight,
                CatchLayout.eventDetailHeroStandardMaxHeight,
              )
              .toDouble();
      expect(
        tester.widget<SliverAppBar>(find.byType(SliverAppBar)).expandedHeight,
        standardHeight,
      );

      await pumpHero(EventDetailPresentationMode.ticket);
      expect(
        tester.widget<SliverAppBar>(find.byType(SliverAppBar)).expandedHeight,
        CatchLayout.eventDetailHeroTicketPhoneHeight,
      );

      await pumpHero(EventDetailPresentationMode.spotlightDark);
      expect(
        tester.widget<SliverAppBar>(find.byType(SliverAppBar)).expandedHeight,
        CatchLayout.eventDetailHeroTicketPhoneHeight,
      );
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
      final user = buildUser();
      final event = buildEvent(
        constraints: const EventConstraints(minAge: 21, maxAge: 35),
      );
      final plan = EventSuccessPlan.defaultForEvent(event);

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
          watchEventSuccessPlanProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(plan)),
        ],
      );

      expect(find.text(event.title), findsWidgets);
      expect(find.text('Requirements'), findsOneWidget);
      expect(find.text('About this event'), findsOneWidget);
      expect(find.text(event.description), findsOneWidget);
      expect(find.text('Event companion'), findsOneWidget);
      expect(find.text('Open companion'), findsOneWidget);
    });

    testWidgets('hides the companion entry until the host saves setup', (
      tester,
    ) async {
      final event = buildEvent();

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
          participation: _participation(),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
          watchEventSuccessPlanProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(null)),
        ],
      );

      expect(find.text('Event companion'), findsNothing);
      expect(find.text('Open companion'), findsNothing);
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
          watchEventSuccessPlanProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(null)),
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

    testWidgets('does not render a host bottom action footer', (tester) async {
      final event = buildEvent();

      await pumpEventsTestApp(
        tester,
        EventDetailBody(
          event: event,
          userProfile: buildUser(uid: 'host-1'),
          clubId: 'club-1',
          isHost: true,
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

      expect(find.text(event.title), findsWidgets);
      expect(find.text('HOST TOOLS'), findsNothing);
      expect(find.text('Manage event'), findsNothing);
      expect(find.text('Take attendance'), findsNothing);
      expect(find.text('Join event — 20 spots left'), findsNothing);
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
          participation: _participation(),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
          watchEventSuccessPlanProvider(
            'event-1',
          ).overrideWith((ref) => Stream.value(null)),
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
      final event = buildEvent();
      var sharedEventId = '';
      CalendarEventPayload? calendarEvent;

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
            watchEventSuccessPlanProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(null)),
            nativeCalendarLauncherProvider.overrideWithValue((event) async {
              calendarEvent = event;
              return true;
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.light.copyWith(platform: TargetPlatform.iOS),
            initialRoute: '/detail',
            routes: {
              '/': (context) =>
                  const Scaffold(body: Center(child: Text('Home'))),
              '/detail': (context) => EventDetailBody(
                event: event,
                userProfile: buildUser(),
                clubId: 'club-1',
                isHost: false,
                reviews: const [],
                isAuthenticated: true,
                isSaved: false,
                participation: _participation(),
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
      expect(
        find.descendant(
          of: find.byTooltip('Share event'),
          matching: find.byIcon(CatchIcons.iosShareRounded),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byTooltip('Share event'),
          matching: find.byIcon(CatchIcons.share),
        ),
        findsNothing,
      );
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
      expect(calendarEvent?.title, event.title);
      expect(fakeSavedEventRepository.savedEventId, 'event-1');
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('booked attendee invite card shares a rich event invite', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 2600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      ShareParams? sharedParams;
      final event = buildEvent(
        meetingPoint: 'Bandra',
        startTime: DateTime(2026, 6, 1, 18),
        endTime: DateTime(2026, 6, 1, 20),
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
          participation: _participation(),
          inviteCode: 'VIP42',
          inviteLinkId: 'invite-link-1',
          now: DateTime(2026, 5, 25),
        ),
        overrides: [
          clubsRepositoryProvider.overrideWithValue(FakeClubsRepository()),
          paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
          watchEventSuccessPlanProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(null)),
          externalShareLauncherProvider.overrideWithValue((params) async {
            sharedParams = params;
          }),
        ],
      );

      await _scrollEventDetailUntilVisible(
        tester,
        find.text('Bring someone into the room'),
      );
      await tester.tap(find.text('Invite a friend'));
      await pumpFeatureUi(tester);

      expect(sharedParams, isNull);
      expect(find.byKey(RichShareCardSheetKeys.cardPreview), findsOneWidget);
      expect(find.byType(EventShareCard), findsOneWidget);
      expect(find.text('CATCH INVITE'), findsOneWidget);

      await tester.tap(find.byKey(RichShareCardSheetKeys.shareButton));
      await tester.pump();
      await pumpFeatureUi(tester);
      await tester.runAsync(() async {
        for (var i = 0; i < 20 && sharedParams == null; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      });

      expect(sharedParams?.subject, 'Join me at ${event.title}');
      expect(sharedParams?.text, contains(event.title));
      expect(sharedParams?.text, contains('Bandra'));
      expect(sharedParams?.text, contains('invite=VIP42'));
      expect(sharedParams?.text, contains('il=invite-link-1'));
      expect(sharedParams?.files, hasLength(1));
      expect(sharedParams?.fileNameOverrides, ['catch-event-invite.png']);
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
      final locationLabel = findLastText('Race Course Road main gate');
      await tester.ensureVisible(locationLabel);
      await tester.pump();
      await tester.tap(locationLabel);
      await pumpFeatureUi(tester);

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
  EventJoinRequestStatus? hostApprovalStatus,
  EventWaitlistOfferStatus? waitlistOfferStatus,
  DateTime? waitlistOfferExpiresAt,
  String? waitlistOfferId,
}) {
  final now = DateTime(2026);
  return EventParticipation(
    id: eventParticipationId(eventId: eventId, uid: uid),
    eventId: eventId,
    clubId: 'club-1',
    uid: uid,
    status: status,
    createdAt: now,
    updatedAt: now,
    hostApprovalStatus: hostApprovalStatus,
    waitlistOfferStatus: waitlistOfferStatus,
    waitlistOfferExpiresAt: waitlistOfferExpiresAt,
    waitlistOfferId: waitlistOfferId,
  );
}
