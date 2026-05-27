import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
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

import '../events/events_test_helpers.dart';
import '../test_pump_helpers.dart';

class _FakeMatchRepository implements MatchRepository {
  _FakeMatchRepository({required this.matches, this.match});

  final List<Match> matches;
  final Match? match;

  @override
  Future<void> resetUnread({
    required String matchId,
    required String uid,
  }) async {}

  @override
  Stream<Match?> watchMatch({required String matchId}) => Stream.value(match);

  @override
  Stream<List<Match>> watchMatchesForUser({required String uid}) =>
      Stream.value(matches);
}

class _FakeConversationRepository implements ConversationRepository {
  final List<(String matchId, String uid)> markReadCalls = [];

  @override
  Future<void> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {}

  @override
  Stream<List<ChatMessage>> watchMessages({required String conversationId}) =>
      const Stream.empty();

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
  }) async {
    markReadCalls.add((conversationId, uid));
  }
}

Match _buildMatch({
  String id = 'match-1',
  String user1Id = 'runner-1',
  String user2Id = 'runner-2',
  DateTime? createdAt,
  DateTime? lastMessageAt,
  String? lastMessagePreview,
  String? lastMessageSenderId,
  Map<String, int> unreadCounts = const {},
}) {
  return Match(
    id: id,
    user1Id: user1Id,
    user2Id: user2Id,
    eventIds: const ['event-1'],
    createdAt: createdAt ?? DateTime(2026, 4, 23, 9),
    lastMessageAt: lastMessageAt,
    lastMessagePreview: lastMessagePreview,
    lastMessageSenderId: lastMessageSenderId,
    unreadCounts: unreadCounts,
  );
}

void main() {
  testWidgets('chat sliver header search expands while pinned and editable', (
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
                slivers: [
                  ...ChatsSliverHeader().buildSlivers(context),
                  const SliverToBoxAdapter(child: SizedBox(height: 700)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Messages from your matches'), findsOneWidget);
    expect(find.text('Your catches'), findsNothing);
    expect(find.text('0 chats'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    final initialTitleTop = tester.getTopLeft(find.text('Chats')).dy;

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
    await tester.pump();

    expect(find.text('Chats').hitTestable(), findsOneWidget);
    final scrolledTitleTop = tester.getTopLeft(find.text('Chats')).dy;
    expect(scrolledTitleTop, greaterThanOrEqualTo(0));
    expect(scrolledTitleTop, lessThanOrEqualTo(initialTitleTop));

    await tester.tap(find.byTooltip('Search chats'));
    await tester.pump();
    final midSearchMorphFrame = Duration(
      milliseconds: CatchMotion.base.inMilliseconds ~/ 2,
    );
    await tester.pump(midSearchMorphFrame);

    final morphingSearchWidth = tester.getSize(find.byType(TextField)).width;
    expect(
      morphingSearchWidth,
      greaterThan(CatchTextField.compactControlHeight),
    );

    await pumpFeatureUi(tester);

    final expandedSearchWidth = tester.getSize(find.byType(TextField)).width;
    expect(expandedSearchWidth, greaterThan(morphingSearchWidth));
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(CatchIcons.keyboardHideRounded), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).textInputAction,
      TextInputAction.done,
    );
    await tester.enterText(find.byType(TextField), 'taylor');
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(container.read(chatSearchQueryProvider), 'taylor');

    await tester.tap(find.byIcon(CatchIcons.closeRounded));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(container.read(chatSearchQueryProvider), isEmpty);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFeatureUi(tester);

    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('shows the empty state when there are no matches', (
    tester,
  ) async {
    final matchRepository = _FakeMatchRepository(matches: const []);
    final conversationRepository = _FakeConversationRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          matchRepositoryProvider.overrideWithValue(matchRepository),
          conversationRepositoryProvider.overrideWithValue(
            conversationRepository,
          ),
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
        'When someone catches you back after a shared event, the conversation opens here with that event as context.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows search-specific empty copy when a query has no matches', (
    tester,
  ) async {
    final match = _buildMatch();
    final matchRepository = _FakeMatchRepository(matches: [match]);
    final conversationRepository = _FakeConversationRepository();
    final container = ProviderContainer(
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        matchRepositoryProvider.overrideWithValue(matchRepository),
        conversationRepositoryProvider.overrideWithValue(
          conversationRepository,
        ),
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

  testWidgets('collapses duplicate match docs into one chat row per person', (
    tester,
  ) async {
    final olderTaylorMatch = _buildMatch(
      id: 'old-taylor',
      user2Id: 'runner-2',
      createdAt: DateTime(2026, 4, 21, 9),
      lastMessageAt: DateTime(2026, 4, 21, 10),
      lastMessagePreview: 'Older message',
      lastMessageSenderId: 'runner-2',
      unreadCounts: const {'runner-1': 1},
    );
    final latestTaylorMatch = _buildMatch(
      id: 'latest-taylor',
      user2Id: 'runner-2',
      createdAt: DateTime(2026, 4, 22, 9),
      lastMessageAt: DateTime(2026, 4, 22, 12),
      lastMessagePreview: 'Latest message',
      lastMessageSenderId: 'runner-2',
      unreadCounts: const {'runner-1': 2},
    );
    final morganMatch = _buildMatch(
      id: 'morgan',
      user2Id: 'runner-3',
      createdAt: DateTime(2026, 4, 23, 9),
    );
    final matches = [olderTaylorMatch, latestTaylorMatch, morganMatch];
    final matchRepository = _FakeMatchRepository(matches: matches);
    final conversationRepository = _FakeConversationRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          matchRepositoryProvider.overrideWithValue(matchRepository),
          conversationRepositoryProvider.overrideWithValue(
            conversationRepository,
          ),
          watchMatchesForUserProvider(
            'runner-1',
          ).overrideWith((ref) => Stream.value(matches)),
          watchPublicProfileProvider('runner-2').overrideWith(
            (ref) => Stream.value(
              buildPublicProfile(uid: 'runner-2', name: 'Taylor'),
            ),
          ),
          watchPublicProfileProvider('runner-3').overrideWith(
            (ref) => Stream.value(
              buildPublicProfile(uid: 'runner-3', name: 'Morgan'),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ChatsListScreen(),
        ),
      ),
    );

    await pumpFeatureUi(tester);

    expect(find.text('Taylor'), findsOneWidget);
    expect(find.text('Morgan'), findsOneWidget);
    expect(find.text('New matches'), findsOneWidget);
    expect(find.text('Latest message'), findsOneWidget);
    expect(find.text('Older message'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2 chats'), findsNothing);
    expect(find.text('3 active'), findsNothing);
    expect(find.text('Messages'), findsNothing);
  });

  testWidgets('does not mark own latest message as unread', (tester) async {
    final selfSentMatch = _buildMatch(
      id: 'self-sent',
      user2Id: 'runner-2',
      lastMessageAt: DateTime(2026, 4, 23, 12),
      lastMessagePreview: 'Definitely. I liked the last 2 km push.',
      lastMessageSenderId: 'runner-1',
      unreadCounts: const {'runner-1': 3},
    );
    final matchRepository = _FakeMatchRepository(matches: [selfSentMatch]);
    final conversationRepository = _FakeConversationRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          matchRepositoryProvider.overrideWithValue(matchRepository),
          conversationRepositoryProvider.overrideWithValue(
            conversationRepository,
          ),
          watchMatchesForUserProvider(
            'runner-1',
          ).overrideWith((ref) => Stream.value([selfSentMatch])),
          watchPublicProfileProvider('runner-2').overrideWith(
            (ref) =>
                Stream.value(buildPublicProfile(uid: 'runner-2', name: 'Yash')),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ChatsListScreen(),
        ),
      ),
    );

    await pumpFeatureUi(tester);

    expect(find.text('Yash'), findsOneWidget);
    expect(
      find.text('You: Definitely. I liked the last 2 km push.'),
      findsOneWidget,
    );
    expect(find.text('3'), findsNothing);
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
    final conversationRepository = _FakeConversationRepository();
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
          conversationRepositoryProvider.overrideWithValue(
            conversationRepository,
          ),
          watchMatchesForUserProvider(
            'runner-1',
          ).overrideWith((ref) => Stream.value([match])),
          matchStreamProvider(
            match.id,
          ).overrideWith((ref) => Stream.value(match)),
          watchPublicProfileProvider(
            'runner-2',
          ).overrideWith((ref) => Stream.value(profile)),
          watchConversationMessagesProvider(
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
    expect(conversationRepository.markReadCalls, [('match-1', 'runner-1')]);
  });
}
