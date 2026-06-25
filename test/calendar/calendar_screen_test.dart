import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/calendar/presentation/calendar_screen.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/presentation/club_name_lookup.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
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
import '../test_pump_helpers.dart';

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

      expect(find.byType(CatchSkeleton), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('No planned events yet'), findsNothing);
    });

    testWidgets('keeps calendar chrome visible while club names load', (
      tester,
    ) async {
      final clubNames = Completer<Map<String, String>>();
      final event = buildEvent(
        id: 'club-name-loading-event',
        startTime: DateTime.now().add(const Duration(days: 1, hours: 7)),
        meetingPoint: 'Pending Club Start',
      );

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpEventsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Event>>([event])),
          clubNameLookupProvider(
            ClubNameLookupQuery([event.clubId]),
          ).overrideWith((ref) => clubNames.future),
        ],
      );

      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Planned'), findsOneWidget);
      expect(find.byType(CatchSkeleton), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text(event.title), findsNothing);
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

      // Load failures now route through the canonical CatchErrorState with
      // mapped copy and a retry affordance (ERROR-UI-002), not a dead
      // empty-state message.
      expect(find.text('Event unavailable'), findsOneWidget);
      expect(find.text('Reload event'), findsOneWidget);
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
          bookedCount: 1,
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
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('calendar.stats.planned')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('13 km'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('7:15 AM'), findsAtLeastNWidgets(1));

      await tester.scrollUntilVisible(
        find.text(events[1].title),
        180,
        scrollable: find.byType(Scrollable),
      );
      await tester.pump();

      expect(find.text(_agendaDayLabel(firstEventStart, now)), findsOneWidget);
      expect(find.text(events[1].title), findsOneWidget);
      expect(find.text(events[0].title), findsOneWidget);
      expect(find.text('STRIDE SOCIAL'), findsAtLeastNWidgets(1));
      expect(find.text('1 going · 19 left'), findsOneWidget);
      expect(find.text('2 going · 10 left'), findsOneWidget);
    });

    testWidgets('includes future saved events as planned calendar rows', (
      tester,
    ) async {
      final now = DateTime.now();
      final signedUpEvent = buildEvent(
        id: 'signed-up-event',
        startTime: now.add(const Duration(days: 2)),
        meetingPoint: 'Booked Promenade',
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
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('calendar.stats.planned')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      expect(find.text('13 km'), findsOneWidget);
      expect(find.text('Old Saved Start'), findsNothing);

      await tester.scrollUntilVisible(
        find.text(savedFutureEvent.title),
        180,
        scrollable: find.byType(Scrollable),
      );
      await tester.pump();

      expect(find.text(savedFutureEvent.title), findsOneWidget);
      expect(find.text(signedUpEvent.title), findsOneWidget);
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
        eventFormat: _eventFormat('Old Beach'),
      );
      final futureEvent = buildEvent(
        id: 'future-event',
        startTime: now.add(const Duration(days: 3, hours: 2)),
        meetingPoint: 'Future Park',
        eventFormat: _eventFormat('Future Park'),
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
        tester.getTopLeft(find.text(futureEvent.title)).dy,
        lessThan(tester.getTopLeft(find.text(pastEvent.title)).dy),
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
          ).subtract(const Duration(days: 4)).add(const Duration(hours: 7)),
          meetingPoint: 'Past Month Park',
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
        expect(find.text(oldEvent.title), findsOneWidget);
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
          eventFormat: _eventFormat('Future Event $index'),
        ),
      );
      final targetEventLabel = events.last.title;

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpEventsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Event>>(events)),
        ],
      );

      expect(find.text(targetEventLabel), findsOneWidget);
      expect(find.text(targetEventLabel).hitTestable(), findsNothing);

      await tester.scrollUntilVisible(
        find.text(targetEventLabel),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.pump();

      expect(find.text(targetEventLabel).hitTestable(), findsOneWidget);
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
          eventFormat: _eventFormat('Week Event $index'),
        ),
      );
      final targetDate = DateUtils.dateOnly(events.last.startTime);
      final targetEventLabel = events.last.title;

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpEventsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Event>>(events)),
        ],
      );

      expect(find.text(targetEventLabel), findsOneWidget);
      expect(find.text(targetEventLabel).hitTestable(), findsNothing);

      await tester.tap(find.byKey(_calendarWeekDayKey(targetDate)));
      await pumpFeatureUi(tester);

      expect(find.text(targetEventLabel).hitTestable(), findsOneWidget);
    });

    testWidgets(
      'pulling down expands month grid and scrolling up collapses it',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(390, 640);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        final selectedDate = DateUtils.dateOnly(
          DateTime.now().add(const Duration(days: 2)),
        );
        final event = buildEvent(
          id: 'expand-event',
          startTime: selectedDate.add(const Duration(hours: 7)),
          meetingPoint: 'Expandable Start',
        );
        final firstOfMonth = DateTime(selectedDate.year, selectedDate.month);

        await _pumpCalendar(
          tester,
          overrides: [
            watchSignedUpEventsProvider(
              'runner-1',
            ).overrideWithValue(AsyncData<List<Event>>([event])),
          ],
        );

        expect(find.byKey(_calendarWeekDayKey(selectedDate)), findsOneWidget);
        expect(find.byKey(_calendarMonthDayKey(firstOfMonth)), findsNothing);

        await tester.drag(
          find.byKey(_calendarWeekDayKey(selectedDate)),
          const Offset(0, 96),
        );
        await pumpFeatureUi(tester);

        expect(find.byKey(_calendarMonthDayKey(firstOfMonth)), findsOneWidget);
        expect(find.byKey(_calendarWeekDayKey(selectedDate)), findsNothing);

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -96));
        await pumpFeatureUi(tester);

        expect(find.byKey(_calendarMonthDayKey(firstOfMonth)), findsNothing);
        expect(find.byKey(_calendarWeekDayKey(selectedDate)), findsOneWidget);
      },
    );

    testWidgets(
      'collapsed week strip follows a date selected from month grid',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(390, 640);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        final anchor = DateTime(
          DateTime.now().year,
          DateTime.now().month + 1,
          15,
        );
        final targetDate = DateTime(anchor.year, anchor.month, 22);
        final event = buildEvent(
          id: 'anchor-event',
          startTime: anchor.add(const Duration(hours: 7)),
          meetingPoint: 'Anchor Start',
        );

        await _pumpCalendar(
          tester,
          overrides: [
            watchSignedUpEventsProvider(
              'runner-1',
            ).overrideWithValue(AsyncData<List<Event>>([event])),
          ],
        );

        await tester.drag(
          find.byKey(_calendarWeekDayKey(anchor)),
          const Offset(0, 96),
        );
        await pumpFeatureUi(tester);

        await tester.tap(find.byKey(_calendarMonthDayKey(targetDate)));
        await pumpFeatureUi(tester);

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -96));
        await pumpFeatureUi(tester);

        expect(find.byKey(_calendarWeekDayKey(targetDate)), findsOneWidget);
        expect(find.byKey(_calendarWeekDayKey(anchor)), findsNothing);
      },
    );

    testWidgets('Today button returns expanded calendar to current day', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 640);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final now = DateTime.now();
      final today = DateUtils.dateOnly(now);
      final futureAnchor = DateTime(now.year, now.month + 1, 15);
      final event = buildEvent(
        id: 'future-event',
        startTime: futureAnchor.add(const Duration(hours: 7)),
        meetingPoint: 'Future Start',
      );

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpEventsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Event>>([event])),
        ],
      );

      await tester.drag(
        find.byKey(_calendarWeekDayKey(futureAnchor)),
        const Offset(0, 96),
      );
      await pumpFeatureUi(tester);

      expect(find.text(_monthYearLabel(futureAnchor)), findsOneWidget);

      await tester.tap(find.text('Today'));
      await pumpFeatureUi(tester);

      expect(find.text(_monthYearLabel(today)), findsOneWidget);
      expect(find.byKey(_calendarMonthDayKey(today)), findsOneWidget);
    });

    testWidgets('keeps month and week picker tappable after agenda jump', (
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
          id: 'sticky-week-event-$index',
          startTime: monday.add(Duration(days: index, hours: 7)),
          meetingPoint: 'Sticky Week Event $index',
          eventFormat: _eventFormat('Sticky Week Event $index'),
        ),
      );
      final targetDate = DateUtils.dateOnly(events.last.startTime);
      final targetEventLabel = events.last.title;
      final firstEventLabel = events.first.title;

      await _pumpCalendar(
        tester,
        overrides: [
          watchSignedUpEventsProvider(
            'runner-1',
          ).overrideWithValue(AsyncData<List<Event>>(events)),
        ],
      );

      await tester.tap(find.byKey(_calendarWeekDayKey(targetDate)));
      await pumpFeatureUi(tester);

      expect(find.text(targetEventLabel).hitTestable(), findsOneWidget);
      expect(
        find.text(_monthYearLabel(targetDate)).hitTestable(),
        findsOneWidget,
      );
      expect(
        find.byKey(_calendarWeekDayKey(monday)).hitTestable(),
        findsOneWidget,
      );

      await tester.tap(find.byKey(_calendarWeekDayKey(monday)));
      await pumpFeatureUi(tester);

      expect(find.text(firstEventLabel).hitTestable(), findsOneWidget);
    });

    testWidgets(
      'opens a booked event from the agenda and back returns to calendar',
      (tester) async {
        final event = buildEvent(
          startTime: DateTime(2026, 5, 7, 7, 15),
          meetingPoint: 'Carter Road Promenade',
          bookedCount: 1,
        );
        final user = buildUser();
        final club = buildClub();
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

        await tester.tap(find.text(event.title));
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
                ..clubsById['club-1'] = buildClub(),
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
  await pumpFeatureUiFor(tester, const Duration(milliseconds: 100));
  await pumpFeatureUiFor(tester, const Duration(seconds: 1));
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
  final now = DateTime(2026);
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

EventFormatSnapshot _eventFormat(String label) => EventFormatSnapshot.custom(
  label: label,
  interactionModel: EventInteractionModel.openFormat,
);

Key _calendarWeekDayKey(DateTime date) {
  return ValueKey<String>('calendar-week-day-${_dateKey(date)}');
}

Key _calendarMonthDayKey(DateTime date) {
  return ValueKey<String>('calendar-month-day-${_dateKey(date)}');
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
