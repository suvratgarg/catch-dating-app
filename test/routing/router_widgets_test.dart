import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/fcm_service.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../clubs/clubs_test_helpers.dart' as club_helpers;
import '../events/events_test_helpers.dart' as run_helpers;
import '../test_pump_helpers.dart';

class _FakeMatchRepository implements MatchRepository {
  _FakeMatchRepository({this.match});

  Match? match;

  @override
  Future<void> resetUnread({
    required String matchId,
    required String uid,
  }) async {}

  @override
  Stream<Match?> watchMatch({required String matchId}) => Stream.value(match);

  @override
  Stream<List<Match>> watchMatchesForUser({required String uid}) =>
      Stream.value([]);
}

class _FakeConversationRepository implements ConversationRepository {
  _FakeConversationRepository();

  @override
  Future<void> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {}

  @override
  Stream<List<ChatMessage>> watchMessages({required String conversationId}) =>
      Stream.value([]);

  @override
  String createMessageId({required String conversationId}) => 'message-1';

  @override
  Future<void> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String messageId,
    required String imageUrl,
  }) async {}

  @override
  Future<void> markRead({
    required String conversationId,
    required String uid,
  }) async {}
}

Match _buildMatch({
  String id = 'match-1',
  String user1Id = 'runner-1',
  String user2Id = 'runner-2',
}) => Match(
  id: id,
  user1Id: user1Id,
  user2Id: user2Id,
  eventIds: const ['event-1'],
  createdAt: DateTime(2026, 4, 23, 9),
);

Future<(ProviderContainer, GoRouter)> _pumpRouterApp(
  WidgetTester tester, {
  required Match? match,
  PublicProfile? routedProfile,
  PublicProfile? streamedProfile,
}) async {
  final container = ProviderContainer(
    overrides: [
      uidProvider.overrideWith((ref) => Stream.value('runner-1')),
      matchRepositoryProvider.overrideWithValue(
        _FakeMatchRepository(match: match),
      ),
      conversationRepositoryProvider.overrideWithValue(
        _FakeConversationRepository(),
      ),
      watchEventProvider('event-1').overrideWith((ref) => Stream.value(null)),
      if (streamedProfile != null)
        watchPublicProfileProvider(
          streamedProfile.uid,
        ).overrideWith((ref) => Stream.value(streamedProfile)),
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Scaffold()),
      GoRoute(
        path: '/chats/:matchId',
        builder: (context, state) => ChatScreen(
          matchId: state.pathParameters['matchId']!,
          otherProfile: state.extra is PublicProfile
              ? state.extra! as PublicProfile
              : null,
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await _settleRoute(tester);

  if (routedProfile != null) {
    router.go('/chats/match-1', extra: routedProfile);
  } else {
    router.go('/chats/match-1', extra: 'unexpected-extra');
  }
  await _settleRoute(tester);

  return (container, router);
}

Future<void> _settleRoute(WidgetTester tester) async {
  await tester.pump();
  await pumpFeatureUi(tester);
}

void main() {
  testWidgets(
    'create-event route fetches the club when no extra is available',
    (tester) async {
      final club = club_helpers.buildClub(id: 'club-1', hostUserId: 'host-1');
      final container = ProviderContainer(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          fetchClubProvider('club-1').overrideWith((ref) async => club),
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
            home: const CreateEventRouteScreen(clubId: 'club-1'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('Distance (km)'), findsOneWidget);
      expect(find.text('Club not found.'), findsNothing);
    },
  );

  testWidgets('chat route hydrates the profile when extra is invalid', (
    tester,
  ) async {
    await _pumpRouterApp(
      tester,
      match: _buildMatch(),
      streamedProfile: run_helpers.buildPublicProfile(
        uid: 'runner-2',
        name: 'Taylor',
      ),
    );

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Taylor'), findsOneWidget);
  });

  testWidgets('chat route uses a routed PublicProfile extra immediately', (
    tester,
  ) async {
    await _pumpRouterApp(
      tester,
      match: null,
      routedProfile: run_helpers.buildPublicProfile(
        uid: 'runner-2',
        name: 'Jordan',
      ),
    );

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Jordan'), findsOneWidget);
  });

  testWidgets('FCM navigation helper drives the real chat route', (
    tester,
  ) async {
    final result = await _pumpRouterApp(
      tester,
      match: _buildMatch(),
      streamedProfile: run_helpers.buildPublicProfile(
        uid: 'runner-2',
        name: 'Taylor',
      ),
    );
    final router = result.$2;

    router.go('/');
    await _settleRoute(tester);

    navigateToMessageRoute(router, {'matchId': 'match-1'});
    await _settleRoute(tester);

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Taylor'), findsOneWidget);
  });
}
