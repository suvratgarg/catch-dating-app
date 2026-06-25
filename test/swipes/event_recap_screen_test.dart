import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';
import '../test_pump_helpers.dart';

void main() {
  testWidgets('EventRecapScreen shows recap-shaped skeleton while loading', (
    tester,
  ) async {
    final eventController = StreamController<Event?>();
    addTearDown(eventController.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>('runner-1')),
          watchEventProvider(
            'loading-event',
          ).overrideWith((ref) => eventController.stream),
          watchEventParticipationsForEventProvider(
            'loading-event',
          ).overrideWithValue(const AsyncData<List<EventParticipation>>([])),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const EventRecapScreen(eventId: 'loading-event'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Event recap'), findsOneWidget);
    expect(find.byType(EventRecapLoadingBody), findsOneWidget);
    expect(find.byType(CatchSkeleton), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byKey(SwipeKeys.openCatchesDeckButton), findsNothing);
  });

  testWidgets('EventRecapScreen builds roster from participation edges', (
    tester,
  ) async {
    final endedAt = DateTime.now().subtract(const Duration(hours: 3));
    final event = buildEvent(
      id: 'recap-event',
      startTime: endedAt.subtract(const Duration(hours: 1)),
      endTime: endedAt,
      checkedInCount: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          watchEventProvider(
            event.id,
          ).overrideWith((ref) => Stream.value(event)),
          watchEventParticipationsForEventProvider(event.id).overrideWith(
            (ref) => Stream.value([
              buildEventParticipation(
                event: event,
                uid: 'runner-1',
                status: EventParticipationStatus.attended,
                createdAt: DateTime(2026, 5, 6, 7, 1),
              ),
              buildEventParticipation(
                event: event,
                uid: 'runner-2',
                status: EventParticipationStatus.attended,
                createdAt: DateTime(2026, 5, 6, 7, 2),
              ),
              buildEventParticipation(
                event: event,
                uid: 'runner-3',
                status: EventParticipationStatus.attended,
                createdAt: DateTime(2026, 5, 6, 7, 3),
              ),
              buildEventParticipation(
                event: event,
                uid: 'runner-4',
                createdAt: DateTime(2026, 5, 6, 7, 4),
              ),
            ]),
          ),
          watchPublicProfileProvider('runner-2').overrideWith(
            (ref) => Stream.value(buildPublicProfile(uid: 'runner-2')),
          ),
          watchPublicProfileProvider('runner-3').overrideWith(
            (ref) => Stream.value(buildPublicProfile(uid: 'runner-3')),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventRecapScreen(eventId: event.id),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('5km · Easy · 3 checked in'), findsOneWidget);
    expect(find.byKey(SwipeKeys.vibeTile('runner-2')), findsOneWidget);
    expect(find.byKey(SwipeKeys.vibeTile('runner-3')), findsOneWidget);
    expect(find.byKey(SwipeKeys.vibeTile('runner-1')), findsNothing);
    expect(find.byKey(SwipeKeys.vibeTile('runner-4')), findsNothing);
  });
}
