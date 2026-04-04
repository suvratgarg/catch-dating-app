import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_repository.g.dart';

class ChatRepository {
  ChatRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<ChatMessage> _getMessagesCollectionReference(
          String matchId) =>
      _db
          .collection('chats')
          .doc(matchId)
          .collection('messages')
          .withConverter<ChatMessage>(
            fromFirestore: (doc, _) =>
                ChatMessage.fromJson({...doc.data()!, 'id': doc.id}),
            toFirestore: (msg, _) => msg.toJson(),
          );

  // ── Read ──────────────────────────────────────────────────────────────────

  Stream<List<ChatMessage>> watchMessages({required String matchId}) =>
      _getMessagesCollectionReference(matchId)
          .orderBy('sentAt')
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList());

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) async {
    final now = FieldValue.serverTimestamp();
    final batch = _db.batch();

    // Use an untyped ref so we can write FieldValue.serverTimestamp() for sentAt.
    final msgRef = _db
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .doc();

    batch.set(msgRef, {
      'senderId': senderId,
      'text': text,
      'sentAt': now,
    });

    batch.update(_db.collection('matches').doc(matchId), {
      'lastMessageAt': now,
      'lastMessagePreview':
          text.length > 80 ? '${text.substring(0, 80)}…' : text,
      'lastMessageSenderId': senderId,
    });

    await batch.commit();
  }
}

@riverpod
ChatRepository chatRepository(Ref ref) =>
    ChatRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<ChatMessage>> chatMessages(Ref ref, String matchId) =>
    ref.watch(chatRepositoryProvider).watchMessages(matchId: matchId);
