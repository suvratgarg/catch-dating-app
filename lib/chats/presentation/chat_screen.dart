import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/data/suvbot_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/chat_controller.dart';
import 'package:catch_dating_app/chats/presentation/suvbot_controller.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_event_context_header.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_input_bar.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_message_list.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_share_card.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_top_bar.dart';
import 'package:catch_dating_app/chats/presentation/widgets/suvbot_action_bar.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/block_user_dialog.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_snackbar_listener.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
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
  late final ConversationReadMarker _readMarker;
  bool _didScrollToLatestMessage = false;
  int _lastMessageCount = 0;
  String? _lastResetUid;
  String? _lastKnownUid;

  @override
  void initState() {
    super.initState();
    _readMarker = ref.read(conversationReadMarkerProvider);
    _resetUnread(ref.read(uidProvider).value);
  }

  @override
  void dispose() {
    final uid = _lastKnownUid;
    if (uid != null) {
      unawaited(_readMarker.markRead(conversationId: widget.matchId, uid: uid));
    }
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetUnread(String? uid, {bool force = false}) {
    if (uid == null) return;
    _lastKnownUid = uid;
    if (!force && uid == _lastResetUid) return;

    _lastResetUid = uid;
    unawaited(_readMarker.markRead(conversationId: widget.matchId, uid: uid));
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
            duration: CatchMotion.chatScroll,
            curve: CatchMotion.easeOutCurve,
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

    try {
      await ChatController.sendMessageMutation.run(ref, (tx) async {
        await tx
            .get(chatControllerProvider.notifier)
            .sendMessage(matchId: widget.matchId, senderId: uid, text: text);
      });
    } catch (_) {
      return;
    }

    if (mounted && _textController.text.trim() == text) {
      _textController.clear();
    }

    if (_scrollController.hasClients) {
      unawaited(
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: CatchMotion.chatScroll,
          curve: CatchMotion.easeOutCurve,
        ),
      );
    }
  }

  Future<void> _runSuvbotAction(SuvbotActionItem action) async {
    if (ref.read(SuvbotController.requestMutation).isPending) return;

    try {
      await SuvbotController.requestMutation.run(ref, (tx) async {
        await tx
            .get(suvbotControllerProvider.notifier)
            .requestAction(actionId: action.id);
      });
    } catch (_) {
      return;
    }
  }

  Future<void> _runSuvbotTextAction(
    SuvbotActionItem action,
    String text,
  ) async {
    if (ref.read(SuvbotController.requestMutation).isPending) return;

    try {
      await SuvbotController.requestMutation.run(ref, (tx) async {
        await tx
            .get(suvbotControllerProvider.notifier)
            .requestAction(actionId: action.id, text: text);
      });
    } catch (_) {
      return;
    }
  }

  Future<void> _sendImage() async {
    if (isSuvbotConversation(matchId: widget.matchId)) return;

    final uid = ref.read(uidProvider).value;
    final imageMutation = ref.read(ChatController.sendImageMutation);
    if (imageMutation.isPending || uid == null) return;

    try {
      await ChatController.sendImageMutation.run(ref, (tx) async {
        await tx
            .get(chatControllerProvider.notifier)
            .sendImage(matchId: widget.matchId, senderId: uid);
      });
    } catch (_) {
      return;
    }
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

    try {
      await ChatController.blockUserMutation.run(ref, (tx) async {
        await tx
            .get(chatControllerProvider.notifier)
            .blockUser(targetUserId: targetUserId);
      });
    } catch (_) {
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _reportUser({
    required String targetUserId,
    required String targetName,
  }) async {
    try {
      await ChatController.reportUserMutation.run(ref, (tx) async {
        await tx
            .get(chatControllerProvider.notifier)
            .reportUser(targetUserId: targetUserId, matchId: widget.matchId);
      });
    } catch (_) {
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report submitted for $targetName.')),
    );
  }

  void _showShareCard({
    required List<ChatMessage> messages,
    required String? uid,
    required Event? event,
    required ExternalShareController share,
  }) {
    if (uid == null) return;
    if (!hasShareableChatMessages(messages)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Send a message before sharing a card.')),
      );
      return;
    }

    unawaited(
      showChatShareCardSheet(
        context,
        messages: messages,
        currentUid: uid,
        event: event,
        share: share,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(uidProvider, (_, next) {
      if (next.value != null) {
        _resetUnread(next.value);
      }
    });

    ref.listen(watchConversationMessagesProvider(widget.matchId), (
      previous,
      next,
    ) {
      final previousMessages = previous?.asData?.value;
      next.whenData((messages) {
        _syncScrollWithMessages(
          messages: messages,
          previousMessages: previousMessages,
        );
        final uid = ref.read(uidProvider).value;
        final latest = messages.isEmpty ? null : messages.last;
        if (uid != null && latest != null && latest.senderId != uid) {
          _resetUnread(uid, force: true);
        }
      });
    });

    final uid = ref.watch(uidProvider.select((v) => v.value));
    final messagesAsync = ref.watch(
      watchConversationMessagesProvider(widget.matchId),
    );
    final matchAsync = ref.watch(matchStreamProvider(widget.matchId));
    final match = matchAsync.asData?.value;
    final otherUid = uid == null ? null : match?.otherId(uid);
    final isSuvbot = isSuvbotConversation(
      matchId: widget.matchId,
      otherUid: otherUid,
    );
    final isHostInquiry = match?.isClubHostInquiry == true;
    final hostInquiryClub = isHostInquiry && match?.clubId != null
        ? ref.watch(watchClubProvider(match!.clubId!)).asData?.value
        : null;
    final hostProfile = otherUid == null
        ? null
        : _hostProfileFor(hostInquiryClub, otherUid);
    final otherParticipantIsHost = hostProfile != null;
    final latestEventId = isSuvbot ? null : match?.latestEventId;
    final eventAsync = latestEventId == null
        ? const AsyncData<Event?>(null)
        : ref.watch(watchEventProvider(latestEventId));
    final shouldReadPublicProfile =
        otherUid != null &&
        !isSuvbot &&
        (!isHostInquiry ||
            (hostInquiryClub != null && !otherParticipantIsHost));
    final otherProfileAsync = !shouldReadPublicProfile
        ? const AsyncData<PublicProfile?>(null)
        : ref.watch(watchPublicProfileProvider(otherUid));
    final share = ref.watch(externalShareControllerProvider);
    final initialProfile = isHostInquiry ? null : widget.initialProfile;
    final profile = otherProfileAsync.asData?.value ?? initialProfile;
    final name = isSuvbot
        ? 'Suvbot'
        : hostProfile?.displayName ??
              profile?.name ??
              (isHostInquiry ? 'Host conversation' : 'Chat');
    final photoUrl = isSuvbot
        ? null
        : hostProfile?.avatarUrl ?? profile?.primaryPhotoThumbnailUrl;
    final suvbotPending = ref.watch(SuvbotController.requestMutation).isPending;
    final suvbotActionsAsync = isSuvbot
        ? ref.watch(suvbotActionsProvider)
        : const AsyncData(<SuvbotActionItem>[]);
    final String? composerDisabledReason;
    if (matchAsync.hasError) {
      composerDisabledReason = 'Chat unavailable.';
    } else if (matchAsync.isLoading) {
      composerDisabledReason = 'Loading chat...';
    } else if (match == null) {
      composerDisabledReason = 'Chat unavailable.';
    } else if (match.isBlocked) {
      composerDisabledReason = 'This chat is closed.';
    } else {
      composerDisabledReason = null;
    }
    final initialMessages = messagesAsync.asData?.value;
    final event = eventAsync.asData?.value;
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
          otherUid: isSuvbot ? null : otherUid,
          profile: isSuvbot ? null : profile,
          profileNavigationEnabled: !isHostInquiry,
          onReport: otherUid == null || isSuvbot
              ? () {}
              : () => _reportUser(
                  targetUserId: otherUid,
                  targetName: profile?.name ?? 'this person',
                ),
          onBlock: otherUid == null || isSuvbot
              ? () {}
              : () => _confirmBlock(
                  targetUserId: otherUid,
                  targetName: profile?.name ?? 'this person',
                ),
          onShareCard: otherUid == null || isSuvbot || isHostInquiry
              ? null
              : () => _showShareCard(
                  messages: messagesAsync.asData?.value ?? const [],
                  uid: uid,
                  event: event,
                  share: share,
                ),
        ),
        body: Column(
          children: [
            if (!isSuvbot) ChatEventContextHeader(event: event),
            Expanded(
              child: ChatMessageList(
                messagesAsync: messagesAsync,
                currentUid: uid,
                event: event,
                otherName: isSuvbot
                    ? 'Suvbot'
                    : isHostInquiry
                    ? name
                    : profile?.name ?? 'your match',
                scrollController: _scrollController,
                onRetry: () => ref.invalidate(
                  watchConversationMessagesProvider(widget.matchId),
                ),
              ),
            ),
            if (isSuvbot)
              SuvbotActionBar(
                actions: suvbotActionsAsync,
                pending: suvbotPending,
                onAction: _runSuvbotAction,
                onTextAction: _runSuvbotTextAction,
                onRetry: () => ref.invalidate(suvbotActionsProvider),
              ),
            if (!isSuvbot)
              ChatInputBar(
                controller: _textController,
                sending: ref
                    .watch(ChatController.sendMessageMutation)
                    .isPending,
                onSend: composerDisabledReason == null ? _send : null,
                onSendImage: composerDisabledReason == null ? _sendImage : null,
                disabledReason: composerDisabledReason,
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

ClubHostProfile? _hostProfileFor(Club? club, String uid) {
  if (club == null) return null;
  for (final host in club.displayHostProfiles) {
    if (host.uid == uid) return host;
  }
  return null;
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
            child: MutationErrorSnackbarListener(
              mutation: SuvbotController.requestMutation,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
