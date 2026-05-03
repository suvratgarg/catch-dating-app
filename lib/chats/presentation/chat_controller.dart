import 'package:catch_dating_app/chats/data/chat_repository.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_controller.g.dart';

@riverpod
class ChatController extends _$ChatController {
  @override
  void build() {}

  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) async {
    await ref
        .read(chatRepositoryProvider)
        .sendMessage(matchId: matchId, senderId: senderId, text: text);
  }

  Future<void> blockUser({required String targetUserId}) async {
    await ref
        .read(safetyRepositoryProvider)
        .blockUser(targetUserId: targetUserId, source: 'chat');
  }

  Future<void> reportUser({required String targetUserId, required String matchId}) async {
    await ref.read(safetyRepositoryProvider).reportUser(
      targetUserId: targetUserId,
      source: 'chat',
      contextId: matchId,
      reasonCode: 'chat_safety_concern',
    );
  }

  Future<void> resetUnread({required String matchId, required String uid}) async {
    await ref.read(matchRepositoryProvider).resetUnread(matchId: matchId, uid: uid);
  }
}
