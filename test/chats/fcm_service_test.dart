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

    testWidgets('does nothing when chat data is invalid', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await pumpFeatureUi(tester);

      navigateToMessageRoute(router, const {});
      await pumpFeatureUi(tester);

      expect(find.text('match-7'), findsNothing);
    });
  });
}
