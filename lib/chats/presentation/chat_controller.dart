import 'package:catch_dating_app/chats/data/chat_repository.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_controller.g.dart';

/// **Pattern B: Stateless controller + static Mutations**
///
/// Holds no Riverpod state ([build] returns void). [Mutation]s track the
/// lifecycle of single-shot operations so the UI can show loading spinners
/// and error banners. UI wraps calls in `mutation.run(ref, ...)`.
@riverpod
class ChatController extends _$ChatController {
  static final sendMessageMutation = Mutation<void>();
  static final sendImageMutation = Mutation<void>();
  static final blockUserMutation = Mutation<void>();
  static final reportUserMutation = Mutation<void>();
  static final resetUnreadMutation = Mutation<void>();

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

  Future<void> sendImage({
    required String matchId,
    required String senderId,
  }) async {
    final image = await ref.read(chatRepositoryProvider).pickImage();
    if (image == null) return; // User cancelled
    await ref.read(chatRepositoryProvider).sendImageMessage(
      matchId: matchId,
      senderId: senderId,
      image: image,
    );
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
