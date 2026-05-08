import 'dart:async';

import 'package:catch_dating_app/chats/data/chat_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeChatRepository extends Fake implements ChatRepository {
  final messagesByMatch = <String, List<ChatMessage>>{};

  @override
  Stream<List<ChatMessage>> watchMessages({required String matchId}) =>
      Stream.value(messagesByMatch[matchId] ?? const []);
}

ChatMessage _buildMessage({
  String id = 'message-1',
  String senderId = 'runner-1',
  String text = 'Hello there',
  DateTime? sentAt,
}) {
  return ChatMessage(
    id: id,
    senderId: senderId,
    text: text,
    sentAt: sentAt ?? DateTime(2025, 1, 1, 7, 30),
  );
}

void main() {
  group('normalizeOutgoingChatText', () {
    test('trims surrounding whitespace', () {
      expect(normalizeOutgoingChatText('  hello there  '), 'hello there');
    });

    test('rejects blank messages', () {
      expect(
        () => normalizeOutgoingChatText('   \n\t  '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('buildChatPreviewText', () {
    test('returns the original text when it fits', () {
      expect(buildChatPreviewText('Hello'), 'Hello');
    });

    test('truncates long text with an ellipsis', () {
      final longText = 'a' * 100;

      final preview = buildChatPreviewText(longText);

      expect(preview, '${'a' * 80}…');
      expect(preview.length, 81);
    });
  });

  group('ChatRepository', () {
    late FakeFirebaseFirestore firestore;
    late ChatRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = ChatRepository(firestore);
    });

    test('watchMessages orders by sentAt and maps snapshot data', () async {
      final firstMessage = _buildMessage(id: 'message-1', text: 'First');
      final secondMessage = _buildMessage(
        id: 'message-2',
        text: 'Second',
        sentAt: DateTime(2025, 1, 1, 8),
      );
      await _seedMessage(firestore, 'match-1', secondMessage);
      await _seedMessage(firestore, 'match-1', firstMessage);

      await expectLater(
        repository.watchMessages(matchId: 'match-1'),
        emits([firstMessage, secondMessage]),
      );
    });

    test('sendMessage writes only the message document', () async {
      await repository.sendMessage(
        matchId: 'match-1',
        senderId: 'runner-1',
        text: '  hello there  ',
      );

      final messages = await repository.watchMessages(matchId: 'match-1').first;
      expect(messages, hasLength(1));
      expect(messages.single.senderId, 'runner-1');
      expect(messages.single.text, 'hello there');
      expect(messages.single.sentAt, isA<DateTime>());
    });

    test('sendImageMessage stores the already-uploaded image URL', () async {
      await repository.sendImageMessage(
        matchId: 'match-1',
        senderId: 'runner-1',
        messageId: 'message-1',
        imageUrl: 'https://storage.test/chat-image.jpg',
      );

      final messages = await repository.watchMessages(matchId: 'match-1').first;
      expect(messages.single.imageUrl, 'https://storage.test/chat-image.jpg');
      expect(messages.single.text, isEmpty);
    });
  });

  test(
    'watchChatMessagesProvider streams messages from the repository',
    () async {
      final fakeRepository = _FakeChatRepository();
      final message = _buildMessage();
      final container = ProviderContainer(
        overrides: [chatRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      addTearDown(container.dispose);
      fakeRepository.messagesByMatch['match-1'] = [message];
      final subscription = container.listen<AsyncValue<List<ChatMessage>>>(
        watchChatMessagesProvider('match-1'),
        (_, _) {},
      );
      addTearDown(subscription.close);

      final messages = await container.read(
        watchChatMessagesProvider('match-1').future,
      );

      expect(messages, [message]);
    },
  );

  test(
    'watchChatMessagesProvider auto-disposes route listeners when unwatched',
    () async {
      final message = _buildMessage();
      final cancelCompleter = Completer<void>();
      final messagesController = StreamController<List<ChatMessage>>(
        onCancel: () {
          if (!cancelCompleter.isCompleted) cancelCompleter.complete();
        },
      );
      addTearDown(() async {
        if (!cancelCompleter.isCompleted) await messagesController.close();
      });

      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(
            _LifecycleChatRepository(messagesController.stream),
          ),
        ],
      );
      addTearDown(container.dispose);

      final provider = watchChatMessagesProvider('match-1');
      final subscription = container.listen(provider, (_, _) {});

      messagesController.add([message]);
      await container.pump();
      expect(subscription.read().value, [message]);

      subscription.close();
      await container.pump();

      await expectLater(cancelCompleter.future, completes);
    },
  );
}

class _LifecycleChatRepository extends Fake implements ChatRepository {
  _LifecycleChatRepository(this.messagesStream);

  final Stream<List<ChatMessage>> messagesStream;

  @override
  Stream<List<ChatMessage>> watchMessages({required String matchId}) =>
      messagesStream;
}

Future<void> _seedMessage(
  FakeFirebaseFirestore firestore,
  String matchId,
  ChatMessage message,
) {
  return firestore
      .collection('matches')
      .doc(matchId)
      .collection('messages')
      .doc(message.id)
      .set(message.toJson());
}
