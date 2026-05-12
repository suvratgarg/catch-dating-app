import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
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

/// Firestore-backed message store for the current Catch chat schema.
///
/// UI and controllers should usually depend on `ConversationRepository` rather
/// than this class directly. This repository intentionally remains a thin data
/// adapter around `matches/{matchId}/messages`.
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
      withBackendErrorStream(
        () => _messagesRef(matchId)
            .orderBy('sentAt')
            .snapshots()
            .map((snap) => snap.docs.map((d) => d.data()).toList()),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'watch chat messages',
          resource: _matchesCollectionPath,
        ),
      );

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
  }) => withBackendErrorContext(
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
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'send message',
      resource: _matchesCollectionPath,
    ),
  );

  /// Sends a message with [imageUrl]. The message text is empty because the UI
  /// renders the image inline.
  Future<void> sendImageMessage({
    required String matchId,
    required String senderId,
    required String messageId,
    required String imageUrl,
  }) => withBackendErrorContext(
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
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'send image',
      resource: _matchesCollectionPath,
    ),
  );
}

@riverpod
ChatRepository chatRepository(Ref ref) =>
    ChatRepository(ref.watch(firebaseFirestoreProvider));
