import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/data/suvbot_repository.dart';
import 'package:catch_dating_app/chats/domain/suvbot_action_item.dart';
import 'package:catch_dating_app/chats/presentation/chat_controller.dart';
import 'package:catch_dating_app/chats/presentation/chat_read_marker_controller.dart';
import 'package:catch_dating_app/chats/presentation/chat_retry_controller.dart';
import 'package:catch_dating_app/chats/presentation/chat_route_state.dart';
import 'package:catch_dating_app/chats/presentation/chat_scroll_coordinator.dart';
import 'package:catch_dating_app/chats/presentation/chat_thread_action_controller.dart';
import 'package:catch_dating_app/chats/presentation/host_chat_screen_state.dart';
import 'package:catch_dating_app/chats/presentation/suvbot_controller.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_event_context_header.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_input_bar.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_message_list.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_share_card.dart';
import 'package:catch_dating_app/chats/presentation/widgets/suvbot_action_bar.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/block_user_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.matchId,
    this.otherProfile,
    this.initialDraftText,
  });

  final String matchId;
  final PublicProfile? otherProfile;
  final String? initialDraftText;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final TextEditingController _textController;
  late final ChatReadMarkerController _readMarkerController;
  late final ChatScrollCoordinator _scrollCoordinator;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialDraftText);
    _readMarkerController = ChatReadMarkerController(
      conversationId: widget.matchId,
      repository: ref.read(conversationRepositoryProvider),
    );
    _scrollCoordinator = ChatScrollCoordinator(isMounted: () => mounted);
    _resetUnread(ref.read(uidProvider).value);
  }

  @override
  void dispose() {
    _readMarkerController.markOnDispose();
    _textController.dispose();
    _scrollCoordinator.dispose();
    super.dispose();
  }

  void _resetUnread(String? uid, {bool force = false}) {
    _readMarkerController.markForUid(uid, force: force);
  }

  ChatThreadActionController get _threadActionController =>
      ChatThreadActionController(
        safetyRunner: RiverpodChatSafetyActionRunner(
          ref: ref,
          matchId: widget.matchId,
        ),
      );

  ChatRetryController get _retryController =>
      ChatRetryController(ref: ref, matchId: widget.matchId);

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

    _scrollCoordinator.scrollAfterSendSuccess();
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

  ChatThreadActionUi _threadActionUi() {
    return ChatThreadActionUi(
      showFeedback: (message) {
        if (!mounted) return;
        showCatchSnackBar(context, message);
      },
      showShareCard: (request) {
        if (!mounted) return;
        unawaited(
          showChatShareCardSheet(
            context,
            messages: request.messages,
            currentUid: request.currentUid,
            event: request.event,
            share: request.share,
          ),
        );
      },
      confirmBlock: (targetName) async {
        if (!mounted) return false;
        return await showBlockUserDialog(context: context, name: targetName) ==
            true;
      },
      closeAfterBlock: () {
        if (mounted) Navigator.of(context).pop();
      },
    );
  }

  void _openOtherProfile(HostChatScreenState chatState) {
    final request = _threadActionController.profileNavigationRequest(chatState);
    if (request == null) return;

    context.pushNamed(
      Routes.publicProfileScreen.name,
      pathParameters: {'uid': request.uid},
      extra: request.profile,
    );
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
        _scrollCoordinator.syncWithMessages(
          messages: messages,
          previousMessages: previousMessages,
        );
        _readMarkerController.markForIncomingLatest(
          uid: ref.read(uidProvider).value,
          messages: messages,
        );
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
    if (!_scrollCoordinator.didScrollToLatestMessage &&
        routeState.initialMessages != null &&
        routeState.initialMessages!.isNotEmpty) {
      _scrollCoordinator.syncWithMessages(
        messages: routeState.initialMessages!,
      );
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
                onSelected: (action) => unawaited(
                  _threadActionController.runThreadAction(
                    action: action,
                    chatState: chatState,
                    messages: routeState.messages,
                    uid: routeState.uid,
                    event: routeState.event,
                    share: routeState.share,
                    ui: _threadActionUi(),
                  ),
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
                      scrollController: _scrollCoordinator.scrollController,
                      onRetry: chatState.messagesRetryIntent == null
                          ? null
                          : () => _retryController.run(
                              chatState.messagesRetryIntent!,
                            ),
                    )
                  : CatchErrorState.fromError(
                      routeError.error,
                      context: AppErrorContext.chat,
                      onRetry: () =>
                          _retryController.run(routeError.retryIntent),
                    ),
            ),
            if (routeState.showSuvbotActionBar)
              SuvbotActionBar(
                actions: routeState.suvbotActionsAsync,
                pending: routeState.suvbotPending,
                onAction: _runSuvbotAction,
                onTextAction: _runSuvbotTextAction,
                onRetry: () => _retryController.run(
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
