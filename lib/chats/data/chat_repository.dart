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
  ChatRepository(this._db);

  static const _matchesCollectionPath = 'matches';

  final FirebaseFirestore _db;

  CollectionReference<ChatMessage> _messagesRef(String matchId) => _db
      .collection(_matchesCollectionPath)
      .doc(matchId)
      .collection('messages')
      .withDocumentIdConverter<ChatMessage>(
        idField: 'id',
        fromJson: ChatMessage.fromJson,
        toJson: (msg) => msg.toJson(),
      );

  // ── Read ──────────────────────────────────────────────────────────────────

  Stream<List<ChatMessage>> watchMessages({required String matchId}) =>
      _messagesRef(matchId)
          .orderBy('sentAt')
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList());

  // ── Write ─────────────────────────────────────────────────────────────────

  String createMessageId({required String matchId}) => _db
      .collection(_matchesCollectionPath)
      .doc(matchId)
      .collection('messages')
      .doc()
      .id;

  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) => withFirestoreErrorContext(
    () async {
      final normalizedText = normalizeOutgoingChatText(text);
      await _db
          .collection(_matchesCollectionPath)
          .doc(matchId)
          .collection('messages')
          .doc()
          .set({
            'senderId': senderId,
            'text': normalizedText,
            'sentAt': FieldValue.serverTimestamp(),
          });
    },
    collection: _matchesCollectionPath,
    action: 'send message',
  );

  /// Sends a message with [imageUrl]. The message text is empty because the UI
  /// renders the image inline.
  Future<void> sendImageMessage({
    required String matchId,
    required String senderId,
    required String messageId,
    required String imageUrl,
  }) => withFirestoreErrorContext(
    () async {
      await _db
          .collection(_matchesCollectionPath)
          .doc(matchId)
          .collection('messages')
          .doc(messageId)
          .set({
            'senderId': senderId,
            'text': '',
            'imageUrl': imageUrl,
            'sentAt': FieldValue.serverTimestamp(),
          });
    },
    collection: _matchesCollectionPath,
    action: 'send image',
  );
}

@riverpod
ChatRepository chatRepository(Ref ref) =>
    ChatRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<ChatMessage>> watchChatMessages(Ref ref, String matchId) =>
    ref.watch(chatRepositoryProvider).watchMessages(matchId: matchId);
