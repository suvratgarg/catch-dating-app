import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/data/suvbot_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/chat_screen.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';
import '../test_pump_helpers.dart';

class FakeMatchRepository implements MatchRepository {
  FakeMatchRepository({this.match});

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
      const Stream.empty();
}

class FakeConversationRepository implements ConversationRepository {
  FakeConversationRepository({this.failSends = false, this.messageStream});

  final bool failSends;
  final Stream<List<ChatMessage>>? messageStream;
  final Map<String, List<ChatMessage>> messagesByMatch = {};
  final List<(String matchId, String senderId, String text)> sendCalls = [];
  final List<(String matchId, String uid)> markReadCalls = [];

  @override
  Future<void> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    sendCalls.add((conversationId, senderId, text));
    if (failSends) {
      throw Exception('send failed');
    }
  }

  @override
  Stream<List<ChatMessage>> watchMessages({required String conversationId}) {
    return messageStream ??
        Stream.value(messagesByMatch[conversationId] ?? const []);
  }

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

class FakeSuvbotRepository implements SuvbotRepository {
  final calls = <({String actionId, String? text})>[];
  final actions = const [
    SuvbotActionItem(
      id: 'refreshDemoState',
      label: 'Refresh demo state',
      description: 'Clear demo state and warm it again.',
      icon: 'refresh',
      destructive: true,
    ),
    SuvbotActionItem(
      id: 'checkDemoState',
      label: 'Check setup',
      description: 'Show seeded state.',
      icon: 'check',
    ),
    SuvbotActionItem(
      id: 'help',
      label: 'Help',
      description: 'Explain Suvbot controls.',
      icon: 'help',
    ),
    SuvbotActionItem(
      id: 'warmSignupState',
      label: 'Warm signups',
      description: 'Create signup state.',
      icon: 'event',
    ),
    SuvbotActionItem(
      id: 'warmPostEventState',
      label: 'Warm post-event',
      description: 'Create post-event state.',
      icon: 'flag',
    ),
    SuvbotActionItem(
      id: 'warmChatState',
      label: 'Warm chats',
      description: 'Create chat state.',
      icon: 'chat',
    ),
    SuvbotActionItem(
      id: 'warmPaymentState',
      label: 'Warm payments',
      description: 'Create payment state.',
      icon: 'payment',
    ),
    SuvbotActionItem(
      id: 'matchTesterByPhone',
      label: 'Match tester',
      description: 'Create a tester match.',
      icon: 'personAdd',
      requiresText: true,
    ),
    SuvbotActionItem(
      id: 'resetChats',
      label: 'Reset chats',
      description: 'Delete demo chat state.',
      icon: 'chatReset',
      destructive: true,
    ),
    SuvbotActionItem(
      id: 'resetBookings',
      label: 'Reset bookings',
      description: 'Delete demo bookings.',
      icon: 'eventReset',
      destructive: true,
    ),
    SuvbotActionItem(
      id: 'resetNotifications',
      label: 'Reset alerts',
      description: 'Delete demo alerts.',
      icon: 'notifications',
      destructive: true,
    ),
    SuvbotActionItem(
      id: 'clearDemoState',
      label: 'Fresh start',
      description: 'Delete demo state.',
      icon: 'clean',
      destructive: true,
    ),
  ];

  @override
  Future<List<SuvbotActionItem>> fetchActions() async => actions;

  @override
  Future<void> requestAction({required String actionId, String? text}) async {
    calls.add((actionId: actionId, text: text));
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
  List<String> eventIds = const ['event-1'],
  Map<String, int> unreadCounts = const {},
}) {
  return Match(
    id: id,
    user1Id: user1Id,
    user2Id: user2Id,
    eventIds: eventIds,
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
      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(null)),
            watchPublicProfileProvider('runner-2').overrideWith(
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

      await pumpFeatureUi(tester);

      expect(find.text('Taylor'), findsOneWidget);
      expect(find.text('Say hi to Taylor!'), findsOneWidget);
    });

    testWidgets('empty match thread grounds the prompt in the shared event', (
      tester,
    ) async {
      final event = buildEvent(startTime: DateTime(2026, 5, 29, 19));
      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(event)),
            watchPublicProfileProvider('runner-2').overrideWith(
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

      await pumpFeatureUi(tester);

      expect(
        find.text('You both ran ${event.title}. Say hi to Taylor!'),
        findsOneWidget,
      );
    });

    testWidgets('resets unread once the uid becomes available after mount', (
      tester,
    ) async {
      final uidController = StreamController<String?>.broadcast();
      addTearDown(uidController.close);

      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => uidController.stream),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ChatScreen(matchId: 'match-1'),
          ),
        ),
      );

      await tester.pump();
      expect(conversationRepository.markReadCalls, isEmpty);

      uidController.add('runner-1');
      await tester.pump();
      await tester.pump();

      expect(conversationRepository.markReadCalls, [('match-1', 'runner-1')]);
    });

    testWidgets('sends trimmed messages and clears the input', (tester) async {
      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(null)),
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

      await pumpFeatureUi(tester);

      await tester.enterText(find.byType(TextField), '  Hello Taylor  ');
      await tester.tap(find.byIcon(CatchIcons.sendRounded));
      await pumpFeatureUi(tester);

      expect(conversationRepository.sendCalls, hasLength(1));
      expect(conversationRepository.sendCalls.single.$1, 'match-1');
      expect(conversationRepository.sendCalls.single.$2, 'runner-1');
      expect(conversationRepository.sendCalls.single.$3, 'Hello Taylor');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty,
      );
    });

    testWidgets('keeps composed text when send fails', (tester) async {
      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository(
        failSends: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(null)),
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

      await pumpFeatureUi(tester);

      await tester.enterText(find.byType(TextField), '  Still here  ');
      await tester.tap(find.byIcon(CatchIcons.sendRounded));
      await pumpFeatureUi(tester);

      expect(conversationRepository.sendCalls, hasLength(1));
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '  Still here  ',
      );
    });

    testWidgets('resets unread again for incoming messages while open', (
      tester,
    ) async {
      final messageController = StreamController<List<ChatMessage>>.broadcast();
      addTearDown(messageController.close);
      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository(
        messageStream: messageController.stream,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(null)),
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
      expect(conversationRepository.markReadCalls, [('match-1', 'runner-1')]);

      messageController.add([
        buildMessage(senderId: 'runner-2', text: 'Incoming'),
      ]);
      await tester.pump();
      await tester.pump();

      expect(conversationRepository.markReadCalls, [
        ('match-1', 'runner-1'),
        ('match-1', 'runner-1'),
      ]);
    });

    testWidgets('shows a friendly error when messages fail to load', (
      tester,
    ) async {
      final matchRepository = FakeMatchRepository(match: buildMatch());
      final conversationRepository = FakeConversationRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream.value(null)),
            watchConversationMessagesProvider('match-1').overrideWithValue(
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

    testWidgets('shows Suvbot controls without chat composer', (tester) async {
      final matchRepository = FakeMatchRepository(
        match: buildMatch(
          id: 'suvbot_runner-1',
          user1Id: suvbotUid,
          user2Id: 'runner-1',
          eventIds: const ['suvbot'],
          lastMessagePreview: 'I can refresh your seeded demo state.',
          lastMessageSenderId: suvbotUid,
        ),
      );
      final conversationRepository = FakeConversationRepository();
      final suvbotRepository = FakeSuvbotRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            matchRepositoryProvider.overrideWithValue(matchRepository),
            conversationRepositoryProvider.overrideWithValue(
              conversationRepository,
            ),
            suvbotRepositoryProvider.overrideWithValue(suvbotRepository),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ChatScreen(matchId: 'suvbot_runner-1'),
          ),
        ),
      );

      await pumpFeatureUi(tester);

      expect(find.text('Suvbot'), findsOneWidget);
      expect(find.text('Suvbot controls'), findsOneWidget);
      expect(find.text('No typing needed'), findsOneWidget);
      expect(find.text('Refresh all'), findsOneWidget);
      expect(find.text('Check setup'), findsOneWidget);
      expect(find.text('Create a test state'), findsOneWidget);
      expect(find.text('Signups'), findsOneWidget);
      expect(find.text('Post-event'), findsOneWidget);
      expect(find.text('Chats'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Reset...'), findsOneWidget);
      expect(find.text('YOU BOTH RAN'), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(CatchIcons.imageOutlined), findsNothing);
      expect(find.byIcon(CatchIcons.sendRounded), findsNothing);

      await tester.tap(find.text('Check setup'));
      await pumpFeatureUi(tester);

      expect(suvbotRepository.calls.single.actionId, 'checkDemoState');

      await tester.tap(find.text('Reset...'));
      await pumpFeatureUi(tester);
      expect(find.text('Reset demo state'), findsOneWidget);
      expect(find.text('Delete demo chat state.'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
      await tester.tap(find.text('Reset chats'));
      await pumpFeatureUi(tester);

      expect(suvbotRepository.calls.last.actionId, 'resetChats');

      await tester.tap(find.text('Match tester'));
      await pumpFeatureUi(tester);
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), '+919999999999');
      await tester.tap(find.text('Create match'));
      await pumpFeatureUi(tester);

      expect(suvbotRepository.calls.last.actionId, 'matchTesterByPhone');
      expect(suvbotRepository.calls.last.text, '+919999999999');
    });
  });
}
