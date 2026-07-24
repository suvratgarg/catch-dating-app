import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/public_profile/data/public_profiles_lookup.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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
          publicProfilesByIdsProvider(
            PublicProfilesQuery(['runner-2', 'runner-3']),
          ).overrideWith(
            (ref) async => {
              'runner-2': buildPublicProfile(uid: 'runner-2'),
              'runner-3': buildPublicProfile(uid: 'runner-3'),
            },
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

  testWidgets('keeps profile lookup loading distinct from missing profiles', (
    tester,
  ) async {
    final event = buildEvent(id: 'recap-event');
    final profiles = Completer<Map<String, PublicProfile>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>('runner-1')),
          watchEventProvider(
            event.id,
          ).overrideWithValue(AsyncData<Event?>(event)),
          watchEventParticipationsForEventProvider(event.id).overrideWithValue(
            AsyncData<List<EventParticipation>>([
              buildEventParticipation(
                event: event,
                uid: 'runner-1',
                status: EventParticipationStatus.attended,
              ),
              buildEventParticipation(
                event: event,
                uid: 'runner-2',
                status: EventParticipationStatus.attended,
              ),
            ]),
          ),
          publicProfilesByIdsProvider(
            PublicProfilesQuery(['runner-2']),
          ).overrideWith((ref) => profiles.future),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventRecapScreen(eventId: event.id),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(VibeGridSkeleton), findsOneWidget);
    expect(find.text('Guest'), findsNothing);
    expect(find.byKey(SwipeKeys.openCatchesDeckButton), findsOneWidget);

    profiles.complete({
      'runner-2': buildPublicProfile(uid: 'runner-2', name: 'Mira'),
    });
    await pumpFeatureUi(tester);
    expect(find.text('Mira'), findsOneWidget);
  });

  testWidgets('profile lookup failures expose retry and recover', (
    tester,
  ) async {
    final event = buildEvent(id: 'recap-event');
    var attempts = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>('runner-1')),
          watchEventProvider(
            event.id,
          ).overrideWithValue(AsyncData<Event?>(event)),
          watchEventParticipationsForEventProvider(event.id).overrideWithValue(
            AsyncData<List<EventParticipation>>([
              buildEventParticipation(
                event: event,
                uid: 'runner-1',
                status: EventParticipationStatus.attended,
              ),
              buildEventParticipation(
                event: event,
                uid: 'runner-2',
                status: EventParticipationStatus.attended,
              ),
            ]),
          ),
          publicProfilesByIdsProvider(
            PublicProfilesQuery(['runner-2']),
          ).overrideWith((ref) async {
            attempts += 1;
            if (attempts == 1) throw StateError('profiles failed');
            return {
              'runner-2': buildPublicProfile(uid: 'runner-2', name: 'Mira'),
            };
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventRecapScreen(eventId: event.id),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Profile unavailable'), findsOneWidget);
    expect(find.text('Reload profile'), findsOneWidget);
    expect(find.text('Guest'), findsNothing);

    await tester.tap(find.text('Reload profile'));
    await pumpFeatureUi(tester);
    expect(attempts, 2);
    expect(find.text('Mira'), findsOneWidget);
  });

  testWidgets('EventRecapScreen can seed selected vibe ids', (tester) async {
    final endedAt = DateTime.now().subtract(const Duration(hours: 3));
    final event = buildEvent(
      id: 'recap-event',
      startTime: endedAt.subtract(const Duration(hours: 1)),
      endTime: endedAt,
      checkedInCount: 2,
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
              ),
              buildEventParticipation(
                event: event,
                uid: 'runner-2',
                status: EventParticipationStatus.attended,
              ),
              buildEventParticipation(
                event: event,
                uid: 'runner-3',
                status: EventParticipationStatus.attended,
              ),
            ]),
          ),
          publicProfilesByIdsProvider(
            PublicProfilesQuery(['runner-2', 'runner-3']),
          ).overrideWith(
            (ref) async => {
              'runner-2': buildPublicProfile(uid: 'runner-2', name: 'Mira'),
              'runner-3': buildPublicProfile(uid: 'runner-3', name: 'Kabir'),
            },
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: EventRecapScreen(
            eventId: event.id,
            initialSelectedVibeIds: const {'runner-2'},
          ),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    final selectedTooltip = tester.widget<Tooltip>(
      find.descendant(
        of: find.byKey(SwipeKeys.vibeTile('runner-2')),
        matching: find.byType(Tooltip),
      ),
    );
    final unselectedTooltip = tester.widget<Tooltip>(
      find.descendant(
        of: find.byKey(SwipeKeys.vibeTile('runner-3')),
        matching: find.byType(Tooltip),
      ),
    );

    expect(selectedTooltip.message, 'Remove Mira');
    expect(unselectedTooltip.message, 'Remember Kabir');
  });

  testWidgets('EventRecapScreen passes selected vibe ids to catches deck', (
    tester,
  ) async {
    final endedAt = DateTime.now().subtract(const Duration(hours: 3));
    final event = buildEvent(
      id: 'recap-event',
      startTime: endedAt.subtract(const Duration(hours: 1)),
      endTime: endedAt,
      checkedInCount: 2,
    );
    Object? routedExtra;

    final router = GoRouter(
      initialLocation: '/recap',
      routes: [
        GoRoute(
          path: '/recap',
          builder: (context, state) => EventRecapScreen(eventId: event.id),
        ),
        GoRoute(
          name: Routes.swipeEventScreen.name,
          path: Routes.swipeEventScreen.path,
          builder: (context, state) {
            routedExtra = state.extra;
            return Text('Deck ${state.pathParameters['eventId']}');
          },
        ),
      ],
    );
    addTearDown(router.dispose);

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
              ),
              buildEventParticipation(
                event: event,
                uid: 'runner-2',
                status: EventParticipationStatus.attended,
              ),
              buildEventParticipation(
                event: event,
                uid: 'runner-3',
                status: EventParticipationStatus.attended,
              ),
            ]),
          ),
          publicProfilesByIdsProvider(
            PublicProfilesQuery(['runner-2', 'runner-3']),
          ).overrideWith(
            (ref) async => {
              'runner-2': buildPublicProfile(uid: 'runner-2', name: 'Mira'),
              'runner-3': buildPublicProfile(uid: 'runner-3', name: 'Kabir'),
            },
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await pumpFeatureUi(tester);

    await tester.tap(find.byKey(SwipeKeys.vibeTile('runner-3')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(SwipeKeys.openCatchesDeckButton));
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(SwipeKeys.openCatchesDeckButton));
    await pumpFeatureUi(tester);

    expect(find.text('Deck ${event.id}'), findsOneWidget);
    expect(routedExtra, isA<Set<String>>());
    expect(routedExtra, {'runner-3'});
  });
}
