import 'package:catch_dating_app/chats/data/chat_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firestore_repository_test_helpers.dart';

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
    late TestTypedCollection<ChatMessage> typedMessagesCollection;
    late TestRawCollection<ChatMessage> rawMessagesCollection;
    late TestRawCollection<Object?> chatsCollection;
    late TestRawCollection<Object?> matchesCollection;
    late TestFirebaseFirestore firestore;
    late ChatRepository repository;

    setUp(() {
      typedMessagesCollection = TestTypedCollection<ChatMessage>(
        pathPrefix: 'chats/match-1/messages',
        autoDocId: 'generated-message-id',
      );
      rawMessagesCollection = TestRawCollection<ChatMessage>(
        pathPrefix: 'chats/match-1/messages',
        convertedCollection: typedMessagesCollection,
        autoDocId: 'generated-message-id',
      );
      chatsCollection = TestRawCollection<Object?>(pathPrefix: 'chats');
      matchesCollection = TestRawCollection<Object?>(pathPrefix: 'matches');
      final chatDoc =
          chatsCollection.doc('match-1') as TestRawDocumentReference;
      chatDoc.subcollections['messages'] = rawMessagesCollection;
      matchesCollection.doc('match-1');
      firestore = TestFirebaseFirestore(
        collectionsByPath: {
          'chats': chatsCollection,
          'matches': matchesCollection,
        },
      );
      repository = ChatRepository(firestore);
    });

    test('watchMessages orders by sentAt and maps snapshot data', () async {
      final firstMessage = _buildMessage(id: 'message-1', text: 'First');
      final secondMessage = _buildMessage(id: 'message-2', text: 'Second');
      typedMessagesCollection.nextOrderByResult = TestTypedQuery<ChatMessage>(
        snapshotStream: Stream.value(
          TestTypedQuerySnapshot<ChatMessage>([
            TestTypedQueryDocumentSnapshot<ChatMessage>(
              referenceValue:
                  typedMessagesCollection.doc(firstMessage.id),
              dataValue: firstMessage,
            ),
            TestTypedQueryDocumentSnapshot<ChatMessage>(
              referenceValue:
                  typedMessagesCollection.doc(secondMessage.id),
              dataValue: secondMessage,
            ),
          ]),
        ),
      );

      await expectLater(
        repository.watchMessages(matchId: 'match-1'),
        emits([firstMessage, secondMessage]),
      );

      expect(typedMessagesCollection.lastOrderByField, 'sentAt');
      expect(typedMessagesCollection.lastOrderByDescending, isFalse);
    });

    test('sendMessage writes the message and updates the match preview', () async {
      final batch = TestWriteBatch();
      firestore.batchValue = batch;

      await repository.sendMessage(
        matchId: 'match-1',
        senderId: 'runner-1',
        text: '  hello there  ',
      );

      expect(batch.setCalls, hasLength(1));
      expect(batch.updateCalls, hasLength(1));

      final messageWrite = batch.setCalls.single;
      final messageRef = messageWrite.document as DocumentReference;
      final messageData = messageWrite.data! as Map<String, dynamic>;
      expect(messageRef.path, 'chats/match-1/messages/generated-message-id');
      expect(messageData['senderId'], 'runner-1');
      expect(messageData['text'], 'hello there');
      expect(messageData['sentAt'], isA<FieldValue>());

      final matchUpdate = batch.updateCalls.single;
      final matchRef = matchUpdate.document as DocumentReference;
      expect(matchRef.path, 'matches/match-1');
      expect(matchUpdate.data['lastMessageSenderId'], 'runner-1');
      expect(matchUpdate.data['lastMessagePreview'], 'hello there');
      expect(matchUpdate.data['lastMessageAt'], isA<FieldValue>());
      expect(batch.commitCalled, isTrue);
    });
  });

  test('chatMessagesProvider streams messages from the repository', () async {
    final fakeRepository = _FakeChatRepository();
    final message = _buildMessage();
    final container = ProviderContainer(
      overrides: [
        chatRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);
    fakeRepository.messagesByMatch['match-1'] = [message];
    final subscription = container.listen<AsyncValue<List<ChatMessage>>>(
      chatMessagesProvider('match-1'),
      (_, _) {},
    );
    addTearDown(subscription.close);

    final messages = await container.read(chatMessagesProvider('match-1').future);

    expect(messages, [message]);
  });
}
