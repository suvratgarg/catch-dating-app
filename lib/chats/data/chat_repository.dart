import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/firestore_error_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_repository.g.dart';

String normalizeOutgoingChatText(String text) {
  final normalized = text.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(text, 'text', 'Message text must not be empty.');
  }
  return normalized;
}

String buildChatPreviewText(String text, {int maxLength = 80}) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}…';
}

class ChatRepository {
  const ChatRepository(this._db);

  static const _chatsCollectionPath = 'chats';
  static const _matchesCollectionPath = 'matches';

  final FirebaseFirestore _db;

  CollectionReference<ChatMessage> _messagesRef(String matchId) => _db
      .collection(_chatsCollectionPath)
      .doc(matchId)
      .collection('messages')
      .withDocumentIdConverter<ChatMessage>(
        idField: 'id',
        fromJson: ChatMessage.fromJson,
        toJson: (msg) => msg.toJson(),
      );

  DocumentReference<Map<String, dynamic>> _matchRef(String matchId) =>
      _db.collection(_matchesCollectionPath).doc(matchId);

  // ── Read ──────────────────────────────────────────────────────────────────

  Stream<List<ChatMessage>> watchMessages({required String matchId}) =>
      _messagesRef(matchId)
          .orderBy('sentAt')
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList());

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) => withFirestoreErrorContext(
    () async {
      final normalizedText = normalizeOutgoingChatText(text);
      final now = FieldValue.serverTimestamp();
      final batch = _db.batch();

      final msgRef = _db
          .collection(_chatsCollectionPath)
          .doc(matchId)
          .collection('messages')
          .doc();

      batch.set(msgRef, {
        'senderId': senderId,
        'text': normalizedText,
        'sentAt': now,
      });

      batch.update(_matchRef(matchId), {
        'lastMessageAt': now,
        'lastMessagePreview': buildChatPreviewText(normalizedText),
        'lastMessageSenderId': senderId,
      });

      await batch.commit();
    },
    collection: _chatsCollectionPath,
    action: 'send message',
  );
}

@riverpod
ChatRepository chatRepository(Ref ref) =>
    ChatRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<ChatMessage>> chatMessages(Ref ref, String matchId) =>
    ref.watch(chatRepositoryProvider).watchMessages(matchId: matchId);
