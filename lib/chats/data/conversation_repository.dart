import 'package:catch_dating_app/chats/data/chat_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation_repository.g.dart';

/// App-facing conversation boundary.
///
/// The current implementation is backed by `matches/{matchId}/messages`, but
/// presentation code should depend on this contract instead of the Firestore
/// message store. If Catch later moves to Stream, Sendbird, or another chat
/// backend, this is the seam that should absorb the migration.
abstract interface class ConversationRepository {
  Stream<List<ChatMessage>> watchMessages({required String conversationId});

  String createMessageId({required String conversationId});

  Future<void> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String text,
  });

  Future<void> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String messageId,
    required String imageUrl,
  });

  Future<void> markRead({required String conversationId, required String uid});
}

class FirestoreConversationRepository implements ConversationRepository {
  const FirestoreConversationRepository({
    required this._chatRepository,
    required this._matchRepository,
  });

  final ChatRepository _chatRepository;
  final MatchRepository _matchRepository;

  @override
  Stream<List<ChatMessage>> watchMessages({required String conversationId}) =>
      _chatRepository.watchMessages(matchId: conversationId);

  @override
  String createMessageId({required String conversationId}) =>
      _chatRepository.createMessageId(matchId: conversationId);

  @override
  Future<void> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) => _chatRepository.sendMessage(
    matchId: conversationId,
    senderId: senderId,
    text: text,
  );

  @override
  Future<void> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String messageId,
    required String imageUrl,
  }) => _chatRepository.sendImageMessage(
    matchId: conversationId,
    senderId: senderId,
    messageId: messageId,
    imageUrl: imageUrl,
  );

  @override
  Future<void> markRead({
    required String conversationId,
    required String uid,
  }) => _matchRepository.resetUnread(matchId: conversationId, uid: uid);
}

@riverpod
ConversationRepository conversationRepository(Ref ref) =>
    FirestoreConversationRepository(
      chatRepository: ref.watch(chatRepositoryProvider),
      matchRepository: ref.watch(matchRepositoryProvider),
    );

@riverpod
Stream<List<ChatMessage>> watchConversationMessages(
  Ref ref,
  String conversationId,
) => ref
    .watch(conversationRepositoryProvider)
    .watchMessages(conversationId: conversationId);

class ConversationReadMarker {
  const ConversationReadMarker(this._conversationRepository);

  final ConversationRepository _conversationRepository;

  Future<void> markRead({
    required String conversationId,
    required String uid,
  }) => _conversationRepository.markRead(
    conversationId: conversationId,
    uid: uid,
  );
}

@riverpod
ConversationReadMarker conversationReadMarker(Ref ref) =>
    ConversationReadMarker(ref.watch(conversationRepositoryProvider));
