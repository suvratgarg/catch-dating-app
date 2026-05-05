import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/chat_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/matches/presentation/matches_list_screen.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chats_sliver_header.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../runs/runs_test_helpers.dart';
import '../test_pump_helpers.dart';

class _FakeMatchRepository implements MatchRepository {
  _FakeMatchRepository({required this.matches, this.match});

  final List<Match> matches;
  final Match? match;
  final List<(String, String)> resetUnreadCalls = [];

  @override
  Future<void> resetUnread({
    required String matchId,
    required String uid,
  }) async {
    resetUnreadCalls.add((matchId, uid));
  }

  @override
  Stream<Match?> watchMatch({required String matchId}) => Stream.value(match);

  @override
  Stream<List<Match>> watchMatchesForUser({required String uid}) =>
      Stream.value(matches);
}

class _FakeChatRepository implements ChatRepository {
  @override
  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) async {}

  @override
  Stream<List<ChatMessage>> watchMessages({required String matchId}) =>
      const Stream.empty();

  @override
  Future<XFile?> pickImage() async => null;

  @override
  Future<void> sendImageMessage({
    required String matchId,
    required String senderId,
    required XFile image,
  }) async {}
}

Match _buildMatch({
  String id = 'match-1',
  String user1Id = 'runner-1',
  String user2Id = 'runner-2',
  DateTime? createdAt,
}) {
  return Match(
    id: id,
    user1Id: user1Id,
    user2Id: user2Id,
    runId: 'run-1',
    createdAt: createdAt ?? DateTime(2026, 4, 23, 9),
  );
}

void main() {
  testWidgets('chat sliver header search fits while pinned and editable', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => CustomScrollView(
                slivers: ChatsSliverHeader(count: 0).buildSlivers(context),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextField), 'taylor');
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(container.read(chatSearchQueryProvider), 'taylor');

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(container.read(chatSearchQueryProvider), isEmpty);
  });

  testWidgets('shows the empty state when there are no matches', (
    tester,
  ) async {
    final matchRepository = _FakeMatchRepository(matches: const []);
    final chatRepository = _FakeChatRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          matchRepositoryProvider.overrideWithValue(matchRepository),
          chatRepositoryProvider.overrideWithValue(chatRepository),
          watchMatchesForUserProvider(
            'runner-1',
          ).overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ChatsListScreen(),
        ),
      ),
    );

    await pumpFeatureUi(tester);

    expect(find.text('No catches yet'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(
      find.text(
        'When someone catches you back after a shared run, the conversation opens here with that run as context.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows search-specific empty copy when a query has no matches', (
    tester,
  ) async {
    final match = _buildMatch();
    final matchRepository = _FakeMatchRepository(matches: [match]);
    final chatRepository = _FakeChatRepository();
    final container = ProviderContainer(
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        matchRepositoryProvider.overrideWithValue(matchRepository),
        chatRepositoryProvider.overrideWithValue(chatRepository),
        watchMatchesForUserProvider(
          'runner-1',
        ).overrideWith((ref) => Stream.value([match])),
        watchPublicProfileProvider('runner-2').overrideWith(
          (ref) => Stream.value(buildPublicProfile(uid: 'runner-2')),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(chatSearchQueryProvider.notifier).setQuery('zara');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ChatsListScreen(),
        ),
      ),
    );

    await pumpFeatureUi(tester);

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('No chats match your search'), findsOneWidget);
    expect(
      find.text('Try another name or clear the search field.'),
      findsOneWidget,
    );
    expect(find.text('No catches yet'), findsNothing);
  });

  testWidgets('navigates from matches list to chat without route extra', (
    tester,
  ) async {
    final match = _buildMatch();
    final profile = buildPublicProfile(uid: 'runner-2', name: 'Taylor');
    final matchRepository = _FakeMatchRepository(
      matches: [match],
      match: match,
    );
    final chatRepository = _FakeChatRepository();
    final router = GoRouter(
      initialLocation: Routes.matchesListScreen.path,
      routes: [
        GoRoute(
          path: Routes.matchesListScreen.path,
          name: Routes.matchesListScreen.name,
          builder: (_, _) => const ChatsListScreen(),
          routes: [
            GoRoute(
              path: ':matchId',
              name: Routes.chatScreen.name,
              builder: (_, state) => ChatScreen(
                matchId: state.pathParameters['matchId']!,
                otherProfile: state.extra is PublicProfile
                    ? state.extra! as PublicProfile
                    : null,
              ),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          matchRepositoryProvider.overrideWithValue(matchRepository),
          chatRepositoryProvider.overrideWithValue(chatRepository),
          watchMatchesForUserProvider(
            'runner-1',
          ).overrideWith((ref) => Stream.value([match])),
          matchStreamProvider(
            match.id,
          ).overrideWith((ref) => Stream.value(match)),
          watchPublicProfileProvider(
            'runner-2',
          ).overrideWith((ref) => Stream.value(profile)),
          watchChatMessagesProvider(
            match.id,
          ).overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );

    await pumpFeatureUi(tester);

    expect(find.text('Taylor'), findsOneWidget);

    await tester.tap(find.text('Taylor'));
    await pumpFeatureUi(tester);

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Say hi to Taylor!'), findsOneWidget);
    expect(matchRepository.resetUnreadCalls, [('match-1', 'runner-1')]);
  });
}
