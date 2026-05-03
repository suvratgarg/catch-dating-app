import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/chat_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

class FakeMatchRepository implements MatchRepository {
  FakeMatchRepository({this.match});

  Match? match;
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
      const Stream.empty();
}

class FakeChatRepository implements ChatRepository {
  final Map<String, List<ChatMessage>> messagesByMatch = {};
  final List<(String matchId, String senderId, String text)> sendCalls = [];

  @override
  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) async {
    sendCalls.add((matchId, senderId, text));
  }

  @override
  Stream<List<ChatMessage>> watchMessages({required String matchId}) {
    return Stream.value(messagesByMatch[matchId] ?? const []);
  }
}

Match buildMatch({
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
    runId: 'run-1',
    createdAt: createdAt ?? DateTime(2026, 4, 23, 9),
    lastMessageAt: lastMessageAt,
    lastMessagePreview: lastMessagePreview,
    lastMessageSenderId: lastMessageSenderId,
    unreadCounts: unreadCounts,
  );
}

ChatMessage buildMessage({
  String id = 'msg-1',
  String senderId = 'runner-1',
  String text = 'Hello there',
  DateTime? sentAt,
}) {
  return ChatMessage(
    id: id,
    senderId: senderId,
    text: text,
    sentAt: sentAt ?? DateTime(2026, 4, 23, 10),
  );
}

void main() {
  group('ChatScreen', () {
    testWidgets('hydrates the other profile without route extra', (
      tester,
    ) async {
      final matchRepository = FakeMatchRepository(
        match: buildMatch(user1Id: 'runner-1', user2Id: 'runner-2'),
      );
      final chatRepository = FakeChatRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            chatRepositoryProvider.overrideWithValue(chatRepository),
            publicProfileProvider('runner-2').overrideWith(
              (ref) => Stream.value(
                buildPublicProfile(uid: 'runner-2', name: 'Taylor'),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ChatScreen(matchId: 'match-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Taylor'), findsOneWidget);
      expect(find.text('Say hi to Taylor!'), findsOneWidget);
    });

    testWidgets('resets unread once the uid becomes available after mount', (
      tester,
    ) async {
      final uidController = StreamController<String?>.broadcast();
      addTearDown(uidController.close);

      final matchRepository = FakeMatchRepository(
        match: buildMatch(user1Id: 'runner-1', user2Id: 'runner-2'),
      );
      final chatRepository = FakeChatRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => uidController.stream),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            chatRepositoryProvider.overrideWithValue(chatRepository),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ChatScreen(matchId: 'match-1'),
          ),
        ),
      );

      await tester.pump();
      expect(matchRepository.resetUnreadCalls, isEmpty);

      uidController.add('runner-1');
      await tester.pump();
      await tester.pump();

      expect(matchRepository.resetUnreadCalls, [('match-1', 'runner-1')]);
    });

    testWidgets('sends trimmed messages and clears the input', (tester) async {
      final matchRepository = FakeMatchRepository(
        match: buildMatch(user1Id: 'runner-1', user2Id: 'runner-2'),
      );
      final chatRepository = FakeChatRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            chatRepositoryProvider.overrideWithValue(chatRepository),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ChatScreen(
              matchId: 'match-1',
              otherProfile: buildPublicProfile(uid: 'runner-2', name: 'Taylor'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '  Hello Taylor  ');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(chatRepository.sendCalls, hasLength(1));
      expect(chatRepository.sendCalls.single.$1, 'match-1');
      expect(chatRepository.sendCalls.single.$2, 'runner-1');
      expect(chatRepository.sendCalls.single.$3, 'Hello Taylor');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty,
      );
    });

    testWidgets('shows a friendly error when messages fail to load', (
      tester,
    ) async {
      final matchRepository = FakeMatchRepository(
        match: buildMatch(user1Id: 'runner-1', user2Id: 'runner-2'),
      );
      final chatRepository = FakeChatRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            chatRepositoryProvider.overrideWithValue(chatRepository),
            chatMessagesProvider('match-1').overrideWithValue(
              AsyncError<List<ChatMessage>>(
                Exception('boom'),
                StackTrace.empty,
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ChatScreen(
              matchId: 'match-1',
              otherProfile: buildPublicProfile(uid: 'runner-2', name: 'Taylor'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('Unable to load messages.'), findsOneWidget);
    });
  });
}
