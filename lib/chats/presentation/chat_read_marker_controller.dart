import 'dart:async';

import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/chat_read_marker_state.dart';

class ChatReadMarkerController {
  ChatReadMarkerController({
    required this.conversationId,
    required this.repository,
    ChatReadMarkerState? state,
  }) : _state = state ?? ChatReadMarkerState();

  final String conversationId;
  final ConversationRepository repository;
  final ChatReadMarkerState _state;

  bool markForUid(String? uid, {bool force = false}) {
    final uidToMark = _state.markForUid(uid, force: force);
    if (uidToMark == null) return false;
    _markRead(uidToMark);
    return true;
  }

  bool markForIncomingLatest({
    required String? uid,
    required List<ChatMessage> messages,
  }) {
    final uidToMark = _state.markForIncomingLatest(
      uid: uid,
      messages: messages,
    );
    if (uidToMark == null) return false;
    _markRead(uidToMark);
    return true;
  }

  bool markOnDispose() {
    final uidToMark = _state.disposeMarkUid;
    if (uidToMark == null) return false;
    _markRead(uidToMark);
    return true;
  }

  void _markRead(String uid) {
    unawaited(repository.markRead(conversationId: conversationId, uid: uid));
  }
}
