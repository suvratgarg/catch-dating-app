import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/presentation/club_name_lookup.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/saved_events_screen.dart';
import 'package:catch_dating_app/routing/go_router.dart' as app_router;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../clubs/clubs_test_helpers.dart' as club_test;
import 'events_test_helpers.dart';

void main() {
  group('SavedEventsScreen', () {
    testWidgets('shows an empty state when there are no saved events', (
      tester,
    ) async {
      await _pumpSavedEvents(
        tester,
        savedEvents: const [],
        child: const SavedEventsScreen(),
      );

      expect(find.text('No saved events yet'), findsOneWidget);
      expect(
        find.text('Save events you want to revisit before booking.'),
        findsOneWidget,
      );
    });

    testWidgets('orders upcoming saved events before past saved events', (
      tester,
    ) async {
      final now = DateTime.now();
      final future = buildEvent(
        id: 'future-event',
        startTime: now.add(const Duration(days: 1)),
        meetingPoint: 'Future Park',
      );
      final past = buildEvent(
        id: 'past-event',
        startTime: now.subtract(const Duration(days: 1)),
        meetingPoint: 'Past Park',
      );

      await _pumpSavedEvents(
        tester,
        savedEvents: [past, future],
        child: const SavedEventsScreen(),
      );
      await tester.pump();

      expect(find.text('Events you saved'), findsOneWidget);
      expect(find.text('STRIDE SOCIAL'), findsAtLeastNWidgets(1));
      expect(find.text('SAVED'), findsOneWidget);
      expect(find.text('PAST'), findsOneWidget);
      expect(
        tester.getTopLeft(find.textContaining('Future Park')).dy,
        lessThan(tester.getTopLeft(find.textContaining('Past Park')).dy),
      );
    });

    testWidgets('opens saved event detail from the list', (tester) async {
      final event = buildEvent(
        id: 'event-1',
        clubId: 'club-1',
        startTime: DateTime.now().add(const Duration(days: 1)),
        meetingPoint: 'Future Park',
      );
      final router = GoRouter(
        initialLocation: app_router.Routes.savedEventsScreen.path,
        routes: [
          GoRoute(
            path: app_router.Routes.savedEventsScreen.path,
            builder: (_, _) => const SavedEventsScreen(),
          ),
          GoRoute(
            path: app_router.Routes.savedEventDetailScreen.path,
            builder: (context, state) => Scaffold(
              body: Text(
                'Event detail ${state.pathParameters['clubId']}/${state.pathParameters['eventId']}',
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await _pumpSavedEvents(
        tester,
        savedEvents: [event],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      );

      await tester.tap(find.textContaining('Future Park'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Event detail club-1/event-1'), findsOneWidget);
    });
  });
}

Future<void> _pumpSavedEvents(
  WidgetTester tester, {
  required List<Event> savedEvents,
  required Widget child,
}) async {
  final wrapped = child is MaterialApp || child is WidgetsApp
      ? child
      : MaterialApp(theme: AppTheme.light, home: child);

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
        clubNameLookupProvider(
          ClubNameLookupQuery(savedEvents.map((event) => event.clubId)),
        ).overrideWithValue(
          AsyncData({
            for (final event in savedEvents) event.clubId: 'Stride Social',
          }),
        ),
      ],
      child: wrapped,
    ),
  );
  await tester.pump();
  await tester.pump();
}
