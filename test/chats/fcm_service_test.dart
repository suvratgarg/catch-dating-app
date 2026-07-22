import 'package:catch_dating_app/core/fcm_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../test_pump_helpers.dart';

void main() {
  group('chatRouteFromMessageData', () {
    test('returns the chat route when matchId is present', () {
      expect(
        chatRouteFromMessageData({'matchId': 'match-7'}),
        '/chats/match-7',
      );
    });

    test('returns null when matchId is missing', () {
      expect(chatRouteFromMessageData(const {}), isNull);
    });

    test('returns null when matchId is empty', () {
      expect(chatRouteFromMessageData({'matchId': ''}), isNull);
    });
  });

  group('eventCompanionRouteFromMessageData', () {
    test('returns the companion route for companion-ready notifications', () {
      expect(
        eventCompanionRouteFromMessageData({
          'type': 'eventCompanionReady',
          'clubId': 'club-1',
          'eventId': 'event-7',
        }),
        '/organizers/club-1/events/event-7/companion',
      );
    });

    test('returns null for other event notifications', () {
      expect(
        eventCompanionRouteFromMessageData({
          'type': 'eventReminder',
          'clubId': 'club-1',
          'eventId': 'event-7',
        }),
        isNull,
      );
    });
  });

  group('routeFromMessageData', () {
    test('keeps chat notification routing intact', () {
      expect(routeFromMessageData({'matchId': 'match-7'}), '/chats/match-7');
    });

    test('routes companion-ready notifications', () {
      expect(
        routeFromMessageData({
          'type': 'eventCompanionReady',
          'clubId': 'club-1',
          'eventId': 'event-7',
        }),
        '/organizers/club-1/events/event-7/companion',
      );
    });
  });

  group('navigateToMessageRoute', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SizedBox(),
            routes: [
              GoRoute(
                path: 'chats/:matchId',
                builder: (context, state) =>
                    Text(state.pathParameters['matchId']!),
              ),
              GoRoute(
                path: 'organizers/:clubId/events/:eventId/companion',
                builder: (context, state) => Text(
                  'Companion ${state.pathParameters['clubId']} '
                  '${state.pathParameters['eventId']}',
                ),
              ),
            ],
          ),
        ],
      );
    });

    tearDown(() {
      router.dispose();
    });

    testWidgets('navigates when chat data is valid', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await pumpFeatureUi(tester);

      navigateToMessageRoute(router, {'matchId': 'match-7'});
      await pumpFeatureUi(tester);

      expect(find.text('match-7'), findsOneWidget);
    });

    testWidgets('navigates when companion data is valid', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await pumpFeatureUi(tester);

      navigateToMessageRoute(router, {
        'type': 'eventCompanionReady',
        'clubId': 'club-1',
        'eventId': 'event-7',
      });
      await pumpFeatureUi(tester);

      expect(find.text('Companion club-1 event-7'), findsOneWidget);
    });

    testWidgets('does nothing when chat data is invalid', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await pumpFeatureUi(tester);

      navigateToMessageRoute(router, const {});
      await pumpFeatureUi(tester);

      expect(find.text('match-7'), findsNothing);
    });
  });
}
