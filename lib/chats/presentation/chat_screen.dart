import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/data/suvbot_repository.dart';
import 'package:catch_dating_app/chats/domain/suvbot_action_item.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/chat_controller.dart';
import 'package:catch_dating_app/chats/presentation/chat_read_marker_state.dart';
import 'package:catch_dating_app/chats/presentation/chat_route_state.dart';
import 'package:catch_dating_app/chats/presentation/host_chat_screen_state.dart';
import 'package:catch_dating_app/chats/presentation/suvbot_controller.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_event_context_header.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_input_bar.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_message_list.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_share_card.dart';
import 'package:catch_dating_app/chats/presentation/widgets/suvbot_action_bar.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/block_user_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.matchId, this.otherProfile});

  final String matchId;
  final PublicProfile? otherProfile;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

void _retryHostChat(WidgetRef ref, String matchId, HostChatRetryIntent intent) {
  switch (intent) {
    case HostChatRetryIntent.reloadMatch:
      ref.invalidate(matchStreamProvider(matchId));
    case HostChatRetryIntent.reloadMessages:
      ref.invalidate(watchConversationMessagesProvider(matchId));
    case HostChatRetryIntent.reloadSuvbotActions:
      ref.invalidate(suvbotActionsProvider);
  }
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _readMarkerState = ChatReadMarkerState();
  late final ConversationRepository _conversationRepository;
  bool _didScrollToLatestMessage = false;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _conversationRepository = ref.read(conversationRepositoryProvider);
    _resetUnread(ref.read(uidProvider).value);
  }

  @override
  void dispose() {
    final uid = _readMarkerState.disposeMarkUid;
    if (uid != null) {
      unawaited(
        _conversationRepository.markRead(
          conversationId: widget.matchId,
          uid: uid,
        ),
      );
    }
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetUnread(String? uid, {bool force = false}) {
    final uidToMark = _readMarkerState.markForUid(uid, force: force);
    if (uidToMark == null) return;
    unawaited(
      _conversationRepository.markRead(
        conversationId: widget.matchId,
        uid: uidToMark,
      ),
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
    showCatchSnackBar(context, 'Report submitted for $targetName.');
  }

  void _showShareCard({
    required List<ChatMessage> messages,
    required String? uid,
    required Event? event,
    required ExternalShareController share,
  }) {
    if (uid == null) return;
    if (!hasShareableChatMessages(messages)) {
      showCatchSnackBar(context, 'Send a message before sharing a card.');
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

  void _openOtherProfile(HostChatScreenState chatState) {
    final otherUid = chatState.otherUid;
    if (otherUid == null || !chatState.profileNavigationEnabled) return;

    context.pushNamed(
      Routes.publicProfileScreen.name,
      pathParameters: {'uid': otherUid},
      extra: chatState.profile,
    );
  }

  void _handleThreadAction({
    required ChatThreadAction action,
    required HostChatScreenState chatState,
    required List<ChatMessage> messages,
    required String? uid,
    required Event? event,
    required ExternalShareController share,
  }) {
    final intent = chatState.intentForThreadAction(action);
    if (intent == null) return;

    switch (intent.type) {
      case HostChatActionIntentType.shareCard:
        _showShareCard(
          messages: messages,
          uid: uid,
          event: event,
          share: share,
        );
        return;
      case HostChatActionIntentType.reportUser:
        unawaited(
          _reportUser(
            targetUserId: intent.targetUserId!,
            targetName: intent.targetName!,
          ),
        );
        return;
      case HostChatActionIntentType.blockUser:
        unawaited(
          _confirmBlock(
            targetUserId: intent.targetUserId!,
            targetName: intent.targetName!,
          ),
        );
        return;
    }
  }

  CatchActionMenuItem<ChatThreadAction> _threadActionMenuItem(
    BuildContext context,
    HostChatScreenState chatState,
    ChatThreadAction action,
  ) {
    final enabled = !chatState.disabledThreadActions.contains(action);
    return switch (action) {
      ChatThreadAction.shareCard => CatchActionMenuItem(
        value: ChatThreadAction.shareCard,
        label: 'Share card',
        icon: CatchIcons.platformShare(platform: Theme.of(context).platform),
        enabled: enabled,
      ),
      ChatThreadAction.report => CatchActionMenuItem(
        value: ChatThreadAction.report,
        label: 'Report',
        icon: CatchIcons.flagOutlined,
        enabled: enabled,
      ),
      ChatThreadAction.block => CatchActionMenuItem(
        value: ChatThreadAction.block,
        label: 'Block',
        icon: CatchIcons.blockRounded,
        enabled: enabled,
        isDestructive: true,
      ),
    };
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
        final uidToMark = _readMarkerState.markForIncomingLatest(
          uid: ref.read(uidProvider).value,
          messages: messages,
        );
        if (uidToMark != null) {
          unawaited(
            ref
                .read(conversationRepositoryProvider)
                .markRead(conversationId: widget.matchId, uid: uidToMark),
          );
        }
      });
    });

    final routeState = ref.watch(
      chatRouteStateProvider(
        ChatRouteStateArgs(
          matchId: widget.matchId,
          initialProfile: widget.otherProfile,
        ),
      ),
    );
    final chatState = routeState.chatState;
    final routeError = routeState.routeError;
    if (!_didScrollToLatestMessage &&
        routeState.initialMessages != null &&
        routeState.initialMessages!.isNotEmpty) {
      _syncScrollWithMessages(messages: routeState.initialMessages!);
    }

    return CatchMutationErrorListeners(
      errorContext: AppErrorContext.chat,
      mutations: [
        ChatController.sendMessageMutation,
        ChatController.sendImageMutation,
        ChatController.reportUserMutation,
        ChatController.blockUserMutation,
        SuvbotController.requestMutation,
      ],
      child: Scaffold(
        appBar: CatchTopBar.identity(
          identityName: chatState.name,
          identityPhotoUrl: chatState.photoUrl,
          onIdentityTap: chatState.profileNavigationEnabled
              ? () => _openOtherProfile(chatState)
              : null,
          surface: true,
          border: true,
          actions: [
            if (chatState.threadActions.isNotEmpty)
              CatchTopBarMenuAction<ChatThreadAction>(
                tooltip: 'Chat actions',
                onSelected: (action) => _handleThreadAction(
                  action: action,
                  chatState: chatState,
                  messages: routeState.messages,
                  uid: routeState.uid,
                  event: routeState.event,
                  share: routeState.share,
                ),
                items: chatState.threadActions
                    .map(
                      (action) =>
                          _threadActionMenuItem(context, chatState, action),
                    )
                    .toList(),
              ),
          ],
        ),
        body: Column(
          children: [
            if (routeState.showEventContextHeader)
              ChatEventContextHeader(event: routeState.event),
            Expanded(
              child: routeError == null
                  ? ChatMessageList(
                      messagesAsync: routeState.messagesAsync,
                      currentUid: routeState.uid,
                      event: routeState.event,
                      otherName: chatState.messageOtherName,
                      scrollController: _scrollController,
                      onRetry: chatState.messagesRetryIntent == null
                          ? null
                          : () => _retryHostChat(
                              ref,
                              widget.matchId,
                              chatState.messagesRetryIntent!,
                            ),
                    )
                  : CatchErrorState.fromError(
                      routeError.error,
                      context: AppErrorContext.chat,
                      onRetry: () => _retryHostChat(
                        ref,
                        widget.matchId,
                        routeError.retryIntent,
                      ),
                    ),
            ),
            if (routeState.showSuvbotActionBar)
              SuvbotActionBar(
                actions: routeState.suvbotActionsAsync,
                pending: routeState.suvbotPending,
                onAction: _runSuvbotAction,
                onTextAction: _runSuvbotTextAction,
                onRetry: () => _retryHostChat(
                  ref,
                  widget.matchId,
                  chatState.suvbotActionsRetryIntent ??
                      HostChatRetryIntent.reloadSuvbotActions,
                ),
              ),
            if (routeState.showComposer)
              ChatInputBar(
                controller: _textController,
                sending: routeState.sendMessagePending,
                onSend: chatState.composerDisabledReason == null ? _send : null,
                onSendImage: chatState.composerDisabledReason == null
                    ? _sendImage
                    : null,
                disabledReason: chatState.composerDisabledReason,
                sendingImage: routeState.sendImagePending,
              ),
          ],
        ),
      ),
    );
  }
}
