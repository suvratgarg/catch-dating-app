import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/firestore_error_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
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
  ChatRepository(this._db, {FirebaseStorage? storage, ImagePicker? picker})
    : _storage = storage ?? FirebaseStorage.instance,
      _picker = picker ?? ImagePicker();

  static const _chatsCollectionPath = 'chats';
  static const _matchesCollectionPath = 'matches';

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  final ImagePicker _picker;

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

  /// Opens the device photo gallery and returns the picked file, or null.
  Future<XFile?> pickImage() => _picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1600,
    maxHeight: 2133,
    imageQuality: 85,
    requestFullMetadata: false,
  );

  /// Uploads [image] to the chat's Storage path and sends a message with
  /// the download URL as [imageUrl]. The message text is set to an empty
  /// string — the UI renders the image inline.
  Future<void> sendImageMessage({
    required String matchId,
    required String senderId,
    required XFile image,
  }) => withFirestoreErrorContext(
    () async {
      final messageId = _db
          .collection(_chatsCollectionPath)
          .doc(matchId)
          .collection('messages')
          .doc()
          .id;

      final storagePath = 'chats/$matchId/images/${messageId}_'
          '${DateTime.now().millisecondsSinceEpoch}';
      final bytes = await image.readAsBytes();
      final ref = _storage.ref(storagePath);
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await ref.putData(bytes, metadata);
      final downloadUrl = await ref.getDownloadURL();

      final now = FieldValue.serverTimestamp();
      final batch = _db.batch();

      final msgRef = _db
          .collection(_chatsCollectionPath)
          .doc(matchId)
          .collection('messages')
          .doc(messageId);

      batch.set(msgRef, {
        'senderId': senderId,
        'text': '',
        'imageUrl': downloadUrl,
        'sentAt': now,
      });

      batch.update(_matchRef(matchId), {
        'lastMessageAt': now,
        'lastMessagePreview': '\u{1F4F7} Image',
        'lastMessageSenderId': senderId,
      });

      await batch.commit();
    },
    collection: _chatsCollectionPath,
    action: 'send image',
  );
}

@riverpod
ChatRepository chatRepository(Ref ref) => ChatRepository(
  ref.watch(firebaseFirestoreProvider),
  storage: ref.watch(firebaseStorageProvider),
);

@riverpod
Stream<List<ChatMessage>> watchChatMessages(Ref ref, String matchId) =>
    ref.watch(chatRepositoryProvider).watchMessages(matchId: matchId);
