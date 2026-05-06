import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/chat_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/chat_controller.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_input_bar.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_message_list.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_run_context_header.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_top_bar.dart';
import 'package:catch_dating_app/core/widgets/block_user_dialog.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_snackbar_listener.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.matchId, this.otherProfile});

  final String matchId;
  final PublicProfile? otherProfile;

  @override
  Widget build(BuildContext context) {
    return _ChatContent(matchId: matchId, initialProfile: otherProfile);
  }
}

class _ChatContent extends ConsumerStatefulWidget {
  const _ChatContent({required this.matchId, required this.initialProfile});

  final String matchId;
  final PublicProfile? initialProfile;

  @override
  ConsumerState<_ChatContent> createState() => _ChatContentState();
}

class _ChatContentState extends ConsumerState<_ChatContent> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _didScrollToLatestMessage = false;
  int _lastMessageCount = 0;
  String? _lastResetUid;

  @override
  void initState() {
    super.initState();
    _resetUnread(ref.read(uidProvider).value);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetUnread(String? uid) {
    if (uid == null) return;
    if (uid == _lastResetUid) return;

    _lastResetUid = uid;
    unawaited(
      ref
          .read(chatControllerProvider.notifier)
          .resetUnread(matchId: widget.matchId, uid: uid),
    );
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    return (position.maxScrollExtent - position.pixels) <= 80;
  }

  void _scheduleScrollToBottom({bool animated = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        unawaited(
          _scrollController.animateTo(
            target,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          ),
        );
        return;
      }

      _scrollController.jumpTo(target);
    });
  }

  void _syncScrollWithMessages({
    required List<ChatMessage> messages,
    List<ChatMessage>? previousMessages,
  }) {
    final previousCount = previousMessages?.length ?? _lastMessageCount;
    final nextCount = messages.length;

    if (nextCount == 0) {
      _lastMessageCount = 0;
      return;
    }

    if (!_didScrollToLatestMessage) {
      _didScrollToLatestMessage = true;
      _lastMessageCount = nextCount;
      _scheduleScrollToBottom();
      return;
    }

    final hasNewMessages = nextCount > previousCount;
    if (hasNewMessages && _isNearBottom()) {
      _lastMessageCount = nextCount;
      _scheduleScrollToBottom(animated: true);
      return;
    }

    _lastMessageCount = nextCount;
  }

  Future<void> _send() async {
    final uid = ref.read(uidProvider).value;
    final text = _textController.text.trim();
    final sendMutation = ref.read(ChatController.sendMessageMutation);
    if (text.isEmpty || sendMutation.isPending || uid == null) return;

    _textController.clear();

    await ChatController.sendMessageMutation.run(ref, (tx) async {
      await tx
          .get(chatControllerProvider.notifier)
          .sendMessage(matchId: widget.matchId, senderId: uid, text: text);
    });

    if (_scrollController.hasClients) {
      unawaited(
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        ),
      );
    }
  }

  Future<void> _sendImage() async {
    final uid = ref.read(uidProvider).value;
    final imageMutation = ref.read(ChatController.sendImageMutation);
    if (imageMutation.isPending || uid == null) return;

    await ChatController.sendImageMutation.run(ref, (tx) async {
      await tx
          .get(chatControllerProvider.notifier)
          .sendImage(matchId: widget.matchId, senderId: uid);
    });
  }

  Future<void> _confirmBlock({
    required String targetUserId,
    required String targetName,
  }) async {
    final confirmed = await showBlockUserDialog(
      context: context,
      name: targetName,
    );
    if (confirmed != true) return;

    await ChatController.blockUserMutation.run(ref, (tx) async {
      await tx
          .get(chatControllerProvider.notifier)
          .blockUser(targetUserId: targetUserId);
    });
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _reportUser({
    required String targetUserId,
    required String targetName,
  }) async {
    await ChatController.reportUserMutation.run(ref, (tx) async {
      await tx
          .get(chatControllerProvider.notifier)
          .reportUser(targetUserId: targetUserId, matchId: widget.matchId);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report submitted for $targetName.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(uidProvider, (_, next) {
      if (next.value != null) {
        _resetUnread(next.value);
      }
    });

    ref.listen(watchChatMessagesProvider(widget.matchId), (previous, next) {
      final previousMessages = previous?.asData?.value;
      next.whenData(
        (messages) => _syncScrollWithMessages(
          messages: messages,
          previousMessages: previousMessages,
        ),
      );
    });

    final uid = ref.watch(uidProvider.select((v) => v.value));
    final messagesAsync = ref.watch(watchChatMessagesProvider(widget.matchId));
    final matchAsync = ref.watch(matchStreamProvider(widget.matchId));
    final match = matchAsync.asData?.value;
    final runAsync = match == null
        ? const AsyncData<Run?>(null)
        : ref.watch(watchRunProvider(match.runId));
    final otherUid = uid == null ? null : match?.otherId(uid);
    final otherProfileAsync = otherUid == null
        ? const AsyncData<PublicProfile?>(null)
        : ref.watch(watchPublicProfileProvider(otherUid));
    final profile = otherProfileAsync.asData?.value ?? widget.initialProfile;
    final name = profile?.name ?? 'Chat';
    final photoUrl = profile?.photoUrls.isNotEmpty == true
        ? profile!.photoUrls.first
        : null;
    final initialMessages = messagesAsync.asData?.value;
    if (!_didScrollToLatestMessage &&
        initialMessages != null &&
        initialMessages.isNotEmpty) {
      _syncScrollWithMessages(messages: initialMessages);
    }

    return _ChatMutationListeners(
      child: Scaffold(
        appBar: ChatTopBar(
          name: name,
          photoUrl: photoUrl,
          otherUid: otherUid,
          profile: profile,
          onReport: otherUid == null
              ? () {}
              : () => _reportUser(
                  targetUserId: otherUid,
                  targetName: profile?.name ?? 'this person',
                ),
          onBlock: otherUid == null
              ? () {}
              : () => _confirmBlock(
                  targetUserId: otherUid,
                  targetName: profile?.name ?? 'this person',
                ),
        ),
        body: Column(
          children: [
            ChatRunContextHeader(run: runAsync.asData?.value),
            Expanded(
              child: ChatMessageList(
                messagesAsync: messagesAsync,
                currentUid: uid,
                otherName: profile?.name ?? 'your match',
                scrollController: _scrollController,
                onRetry: () =>
                    ref.invalidate(watchChatMessagesProvider(widget.matchId)),
              ),
            ),
            ChatInputBar(
              controller: _textController,
              sending: ref.watch(ChatController.sendMessageMutation).isPending,
              onSend: match?.isBlocked == true ? null : _send,
              onSendImage: match?.isBlocked == true ? null : _sendImage,
              sendingImage: ref
                  .watch(ChatController.sendImageMutation)
                  .isPending,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMutationListeners extends StatelessWidget {
  const _ChatMutationListeners({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MutationErrorSnackbarListener(
      mutation: ChatController.sendMessageMutation,
      child: MutationErrorSnackbarListener(
        mutation: ChatController.sendImageMutation,
        child: MutationErrorSnackbarListener(
          mutation: ChatController.reportUserMutation,
          child: MutationErrorSnackbarListener(
            mutation: ChatController.blockUserMutation,
            child: child,
          ),
        ),
      ),
    );
  }
}
