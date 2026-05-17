import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/calendar/presentation/calendar_screen.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_agenda_list.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart' as app_router;
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../clubs/clubs_test_helpers.dart' as club_test;
import '../events/events_test_helpers.dart';

void main() {
  group('CalendarScreen', () {
    testWidgets('shows a loading state while booked events are loading', (
      tester,
    ) async {
      final eventsController = StreamController<List<Event>>();
      addTearDown(eventsController.close);

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpEventsProvider(
            'runner-1',
          ).overrideWith((ref) => eventsController.stream),
        ],
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('No planned events yet'), findsNothing);
    });

    testWidgets(
      'shows the empty calendar when the user has no planned events',
      (tester) async {
        await _pumpCalendar(
          tester,
          overrides: [
            watchSignedUpEventsProvider(
              'runner-1',
            ).overrideWithValue(const AsyncData<List<Event>>([])),
          ],
        );

        expect(find.text('No planned events yet'), findsOneWidget);
        expect(
          find.text(
            'Events you book or save will show up here by day and time.',
          ),
          findsOneWidget,
        );
        expect(find.text('Planned'), findsOneWidget);
        expect(find.text('None'), findsOneWidget);
      },
    );

    testWidgets('shows an error state when planned events fail to load', (
      tester,
    ) async {
      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpEventsProvider('runner-1').overrideWithValue(
            AsyncError<List<Event>>(Exception('boom'), StackTrace.empty),
          ),
        ],
      );

      expect(find.text('Calendar unavailable'), findsOneWidget);
      expect(
        find.text('Your planned events could not be loaded.'),
        findsOneWidget,
      );
      expect(find.text('No planned events yet'), findsNothing);
    });

    testWidgets('renders agenda stats and booked event details', (
      tester,
    ) async {
      final now = DateTime.now();
      final firstEventStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1, hours: 7, minutes: 15));
      final secondEventStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 2, hours: 18, minutes: 30));
      final events = [
        buildEvent(
          id: 'event-late',
          startTime: secondEventStart,
          meetingPoint: 'Juhu Beach Gate',
          distanceKm: 8,
          pace: PaceLevel.moderate,
          bookedCount: 2,
          capacityLimit: 12,
        ),
        buildEvent(
          id: 'event-early',
          startTime: firstEventStart,
          meetingPoint: 'Carter Road Promenade',
          distanceKm: 5,
          pace: PaceLevel.easy,
          bookedCount: 1,
          capacityLimit: 20,
        ),
      ];

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpEventsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Event>>(events)),
        ],
      );

      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text(_monthYearLabel(firstEventStart)), findsOneWidget);
      expect(find.text('Planned'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('13 km'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('7:15 AM'), findsAtLeastNWidgets(1));

      await tester.scrollUntilVisible(
        find.text('Carter Road Promenade'),
        180,
        scrollable: find.byType(Scrollable),
      );
      await tester.pump();

      expect(find.text(_agendaDayLabel(firstEventStart, now)), findsOneWidget);
      expect(find.text('Carter Road Promenade'), findsOneWidget);
      expect(find.text('Juhu Beach Gate'), findsOneWidget);
      expect(find.text('Stride Social'), findsAtLeastNWidgets(1));
      expect(find.text('5km · Easy · 1/20 spots'), findsOneWidget);
      expect(find.text('8km · Moderate · 2/12 spots'), findsOneWidget);
    });

    testWidgets('includes future saved events as planned calendar rows', (
      tester,
    ) async {
      final now = DateTime.now();
      final signedUpEvent = buildEvent(
        id: 'signed-up-event',
        startTime: now.add(const Duration(days: 2)),
        meetingPoint: 'Booked Promenade',
        distanceKm: 5,
        bookedCount: 1,
      );
      final savedFutureEvent = buildEvent(
        id: 'saved-future-event',
        startTime: now.add(const Duration(days: 1)),
        meetingPoint: 'Saved Start',
        distanceKm: 8,
        bookedCount: 3,
      );
      final savedPastEvent = buildEvent(
        id: 'saved-past-event',
        startTime: now.subtract(const Duration(days: 1)),
        meetingPoint: 'Old Saved Start',
        distanceKm: 10,
      );

      await _pumpCalendar(
        tester,
        savedEvents: [savedFutureEvent, savedPastEvent],
        overrides: [
          watchSignedUpEventsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Event>>([signedUpEvent])),
        ],
      );

      expect(find.text('Planned'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('13 km'), findsOneWidget);
      expect(find.text('Old Saved Start'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('Saved Start'),
        180,
        scrollable: find.byType(Scrollable),
      );
      await tester.pump();

      expect(find.text('Saved Start'), findsOneWidget);
      expect(find.text('Booked Promenade'), findsOneWidget);
      expect(find.text('SAVED'), findsOneWidget);
      expect(find.text('JOINED'), findsOneWidget);
    });

    testWidgets('anchors calendar summary to the next upcoming event', (
      tester,
    ) async {
      final now = DateTime.now();
      final pastEvent = buildEvent(
        id: 'past-event',
        startTime: now.subtract(const Duration(days: 4, hours: -6)),
        meetingPoint: 'Old Beach',
        distanceKm: 5,
        pace: PaceLevel.easy,
      );
      final futureEvent = buildEvent(
        id: 'future-event',
        startTime: now.add(const Duration(days: 3, hours: 2)),
        meetingPoint: 'Future Park',
        distanceKm: 8,
        pace: PaceLevel.moderate,
      );

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpEventsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Event>>([pastEvent, futureEvent])),
        ],
      );

      expect(find.text('Next'), findsOneWidget);
      expect(
        find.text(_timeLabel(futureEvent.startTime)),
        findsAtLeastNWidgets(1),
      );
      expect(
        tester.getTopLeft(find.text('Future Park')).dy,
        lessThan(tester.getTopLeft(find.text('Old Beach')).dy),
      );
    });

    testWidgets(
      'falls back to the current week when there are no upcoming events',
      (tester) async {
        final now = DateTime.now();
        final oldEvent = buildEvent(
          id: 'old-event',
          startTime: DateTime(
            now.year,
            now.month,
            1,
          ).subtract(const Duration(days: 4)).add(const Duration(hours: 7)),
          meetingPoint: 'Past Month Park',
          distanceKm: 5,
          pace: PaceLevel.easy,
        );

        await _pumpCalendar(
          tester,
          overrides: [
            watchSignedUpEventsProvider(
              'runner-1',
            ).overrideWithValue(AsyncData<List<Event>>([oldEvent])),
          ],
        );

        expect(find.text(_monthYearLabel(now)), findsOneWidget);
        expect(find.text('Next'), findsOneWidget);
        expect(find.text('None'), findsOneWidget);
        expect(find.text('Past Month Park'), findsOneWidget);
      },
    );

    testWidgets('scrolls as one surface so later agenda events are reachable', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 560);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final now = DateTime.now();
      final events = List.generate(
        8,
        (index) => buildEvent(
          id: 'event-$index',
          startTime: now.add(Duration(days: index + 1)),
          meetingPoint: 'Future Event $index',
          distanceKm: 5,
          pace: PaceLevel.easy,
        ),
      );

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpEventsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Event>>(events)),
        ],
      );

      expect(find.text('Future Event 7'), findsOneWidget);
      expect(find.text('Future Event 7').hitTestable(), findsNothing);

      await tester.scrollUntilVisible(
        find.text('Future Event 7'),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.pump();

      expect(find.text('Future Event 7').hitTestable(), findsOneWidget);
    });

    testWidgets('tapping a week date scrolls to that agenda day', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 560);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final nextWeek = DateUtils.dateOnly(
        DateTime.now().add(const Duration(days: 7)),
      );
      final monday = nextWeek.subtract(Duration(days: nextWeek.weekday - 1));
      final events = List.generate(
        7,
        (index) => buildEvent(
          id: 'week-event-$index',
          startTime: monday.add(Duration(days: index, hours: 7)),
          meetingPoint: 'Week Event $index',
          distanceKm: 5,
          pace: PaceLevel.easy,
        ),
      );
      final targetDate = DateUtils.dateOnly(events.last.startTime);

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpEventsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Event>>(events)),
        ],
      );

      expect(find.text('Week Event 6'), findsOneWidget);
      expect(find.text('Week Event 6').hitTestable(), findsNothing);

      await tester.tap(find.byKey(_calendarWeekDayKey(targetDate)));
      await tester.pumpAndSettle();

      expect(find.text('Week Event 6').hitTestable(), findsOneWidget);
    });

    testWidgets(
      'opens a booked event from the agenda and back returns to calendar',
      (tester) async {
        final event = buildEvent(
          id: 'event-1',
          clubId: 'club-1',
          startTime: DateTime(2026, 5, 7, 7, 15),
          meetingPoint: 'Carter Road Promenade',
          distanceKm: 5,
          pace: PaceLevel.easy,
          bookedCount: 1,
        );
        final user = buildUser(uid: 'runner-1');
        final club = buildClub(id: 'club-1');
        final router = GoRouter(
          initialLocation: app_router.Routes.calendarScreen.path,
          routes: [
            GoRoute(
              path: app_router.Routes.calendarScreen.path,
              name: app_router.Routes.calendarScreen.name,
              builder: (context, state) => const CalendarScreen(),
            ),
            GoRoute(
              path: app_router.Routes.calendarEventDetailScreen.path,
              name: app_router.Routes.calendarEventDetailScreen.name,
              builder: (context, state) => EventDetailScreen(
                clubId: state.pathParameters['clubId']!,
                eventId: state.pathParameters['eventId']!,
              ),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              uidProvider.overrideWithValue(
                const AsyncData<String?>('runner-1'),
              ),
              watchUserProfileProvider.overrideWithValue(AsyncData(user)),
              watchSignedUpEventsProvider(
                user.uid,
              ).overrideWithValue(AsyncData<List<Event>>([event])),
              watchSavedEventDetailsForUserProvider(
                user.uid,
              ).overrideWithValue(const AsyncData<List<Event>>([])),
              watchEventProvider(event.id).overrideWithValue(AsyncData(event)),
              watchSavedEventProvider(
                user.uid,
                event.id,
              ).overrideWithValue(const AsyncData(null)),
              watchEventParticipationProvider(
                event.id,
                user.uid,
              ).overrideWithValue(
                AsyncData(
                  _participation(
                    event: event,
                    uid: user.uid,
                    status: EventParticipationStatus.signedUp,
                  ),
                ),
              ),
              clubsRepositoryProvider.overrideWith(
                (ref) =>
                    club_test.FakeClubsRepository()..clubsById[club.id] = club,
              ),
              fetchClubProvider(club.id).overrideWithValue(AsyncData(club)),
              watchReviewsForEventProvider(
                event.id,
              ).overrideWithValue(const AsyncData([])),
              paymentRepositoryProvider.overrideWithValue(
                FakePaymentRepository(),
              ),
            ],
            child: MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
            ),
          ),
        );
        await _pumpRouterFrame(tester);

        expect(find.text('Calendar'), findsWidgets);
        expect(_routerPath(router), app_router.Routes.calendarScreen.path);

        await _scrollCalendarDown(tester);

        final eventCard = find.byType(EventAgendaCard);
        expect(tester.widget<EventAgendaCard>(eventCard).onTap, isNotNull);

        tester.widget<EventAgendaCard>(eventCard).onTap!.call();
        expect(tester.takeException(), isNull);
        await _pumpRouterFrame(tester);

        expect(find.byType(EventDetailScreen), findsOneWidget);
        expect(find.byTooltip('Back'), findsOneWidget);

        await tester.tap(find.byTooltip('Back'));
        await _pumpRouterFrame(tester);

        expect(_routerPath(router), app_router.Routes.calendarScreen.path);
        expect(find.byType(EventDetailScreen), findsNothing);
        expect(find.text('Calendar'), findsWidgets);
      },
    );
  });
}

Future<void> _pumpCalendar(
  WidgetTester tester, {
  required Iterable overrides,
  List<Event> savedEvents = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(const AsyncData<String?>('runner-1')),
        clubsRepositoryProvider.overrideWith(
          (ref) =>
              club_test.FakeClubsRepository()
                ..clubsById['club-1'] = buildClub(id: 'club-1'),
        ),
        watchSavedEventDetailsForUserProvider(
          'runner-1',
        ).overrideWithValue(AsyncData<List<Event>>(savedEvents)),
        ...overrides,
      ],
      child: MaterialApp(theme: AppTheme.light, home: const CalendarScreen()),
    ),
  );
  await tester.pump();
}

Future<void> _pumpRouterFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _scrollCalendarDown(WidgetTester tester) async {
  for (var i = 0; i < 3; i += 1) {
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -320));
    await tester.pump();
  }
}

EventParticipation _participation({
  required Event event,
  required String uid,
  required EventParticipationStatus status,
}) {
  final now = DateTime(2026, 1, 1);
  return EventParticipation(
    id: eventParticipationId(eventId: event.id, uid: uid),
    eventId: event.id,
    clubId: event.clubId,
    uid: uid,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

String _timeLabel(DateTime date) => EventFormatters.time(date);

Key _calendarWeekDayKey(DateTime date) {
  return ValueKey<String>('calendar-week-day-${_dateKey(date)}');
}

String _dateKey(DateTime date) {
  final day = DateUtils.dateOnly(date);
  final month = day.month.toString().padLeft(2, '0');
  final dateOfMonth = day.day.toString().padLeft(2, '0');
  return '${day.year}-$month-$dateOfMonth';
}

String _monthYearLabel(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

String _agendaDayLabel(DateTime date, DateTime now) {
  const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  if (DateUtils.isSameDay(date, now)) return 'TODAY';
  return '${weekdays[date.weekday - 1]} · ${date.day} ${months[date.month - 1]}';
}

String _routerPath(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.path;
