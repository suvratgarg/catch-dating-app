import 'dart:async';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/domain/event_chat.dart';
import 'package:catch_dating_app/chats/domain/event_chat_timing.dart';
import 'package:catch_dating_app/chats/presentation/event_chat_controller.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_input_bar.dart';
import 'package:catch_dating_app/chats/presentation/widgets/event_chat_message_tile.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventChatScreen extends ConsumerStatefulWidget {
  const EventChatScreen({super.key, required this.eventId});
  final String eventId;
  @override
  ConsumerState<EventChatScreen> createState() => _EventChatScreenState();
}

class _EventChatScreenState extends ConsumerState<EventChatScreen>
    with WidgetsBindingObserver {
  final _draft = TextEditingController();
  final _scroll = ScrollController();
  String? _replyId, _reactionId;
  bool _resumed = true;
  bool? _active;
  Timer? _clock;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resumed =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _draft.addListener(_draftChanged);
  }

  EventChatController get _controller =>
      ref.read(eventChatControllerProvider(widget.eventId).notifier);
  void _draftChanged() =>
      _controller.draftChanged(_draft.text.trim().isNotEmpty);
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    if (mounted) setState(() {});
  }

  void _syncActive(bool active) {
    if (_active == active) return;
    _active = active;
    _clock?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _active != active) return;
      _controller.setForeground(active);
      if (active) {
        _clock = Timer.periodic(EventChatTiming.presenceDisplayTick, (_) {
          if (mounted) setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock?.cancel();
    _draft.removeListener(_draftChanged);
    _draft.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String reviewedUid) async {
    final uid = ref.read(uidProvider).asData?.value;
    if (uid != reviewedUid) return;
    final text = _draft.text.trim();
    final reply = _replyId;
    final sent = await _controller.send(
      text,
      reviewedUid: reviewedUid,
      replyToMessageId: reply,
    );
    if (!mounted || ref.read(uidProvider).asData?.value != uid || !sent) return;
    if (_draft.text.trim() == text && _replyId == reply) {
      _draft.clear();
      setState(() => _replyId = null);
    }
    if (_scroll.hasClients) {
      unawaited(
        _scroll.animateTo(
          0,
          duration: CatchMotion.fast,
          curve: CatchMotion.standardCurve,
        ),
      );
    }
  }

  Future<void> _messageAction(
    EventChatState reviewed,
    EventChatMessage message,
    EventChatSafetyAction action,
  ) async {
    final l = context.l10n;
    EventChatReportReason? reason;
    if (action == EventChatSafetyAction.report) {
      reason = await showCatchSelectionSheet<EventChatReportReason?>(
        context: context,
        title: l.eventChatReport,
        subtitle: l.eventChatReportDisclosure,
        value: null,
        items: [
          CatchSelectionMenuItem(
            value: EventChatReportReason.harassment,
            label: l.eventChatReportHarassment,
          ),
          CatchSelectionMenuItem(
            value: EventChatReportReason.spam,
            label: l.eventChatReportSpam,
          ),
          CatchSelectionMenuItem(
            value: EventChatReportReason.inappropriate,
            label: l.eventChatReportInappropriate,
          ),
          CatchSelectionMenuItem(
            value: EventChatReportReason.other,
            label: l.eventChatReportOther,
          ),
        ],
      );
      if (reason == null) return;
    } else {
      final confirmed = await showCatchConfirmDialog(
        context: context,
        copy: catchDialogCopy(l),
        title: action == EventChatSafetyAction.block
            ? l.eventChatBlock
            : l.eventChatRemove,
        message: action == EventChatSafetyAction.block
            ? l.eventChatBlockDisclosure
            : l.eventChatRemoveDisclosure,
        confirmLabel: action == EventChatSafetyAction.block
            ? l.eventChatBlock
            : l.eventChatRemove,
        danger: true,
      );
      if (confirmed != true) return;
    }
    if (!mounted || ref.read(uidProvider).asData?.value != reviewed.uid) return;
    final saved = await _controller.actOnMessage(
      message,
      action,
      reviewedUid: reviewed.uid,
      reason: reason,
    );
    if (!mounted ||
        ref.read(uidProvider).asData?.value != reviewed.uid ||
        !saved) {
      return;
    }
    if (action != EventChatSafetyAction.report) {
      setState(() {
        _replyId = null;
        _reactionId = null;
      });
    }
    showCatchSnackBar(context, switch (action) {
      EventChatSafetyAction.report => l.eventChatReported,
      EventChatSafetyAction.block => l.eventChatBlocked,
      EventChatSafetyAction.remove => l.eventChatRemoved,
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = eventChatControllerProvider(widget.eventId);
    final value = ref.watch(provider);
    final display = catchAsyncStateFromAsyncValue(value);
    final current = display.isSettledData ? display.value : null;
    _syncActive(_resumed && (ModalRoute.isCurrentOf(context) ?? true));
    ref.listen(uidProvider, (before, after) {
      if (before?.asData?.value != after.asData?.value) {
        _draft.clear();
        setState(() {
          _replyId = null;
          _reactionId = null;
        });
      }
    });
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
        title: current?.access.title ?? context.l10n.eventChatTitle,
        navigation: const CatchTopBarNavigation(
          mode: CatchTopBarNavigationMode.back,
        ),
        emphasis: scrolledUnder
            ? CatchTopBarEmphasis.divided
            : CatchTopBarEmphasis.plain,
        actions: [
          if (current?.access.canReadMessages == true)
            CatchIconAction.toolbar(
              tooltip: context.l10n.eventChatParticipantsTitle,
              icon: CatchIcons.peopleOutlineRounded,
              onPressed: current!.busy
                  ? null
                  : () => context.pushNamed(
                      Routes.eventChatParticipantsScreen.name,
                      pathParameters: {'eventId': widget.eventId},
                    ),
            ),
          if (current != null)
            CatchIconAction(
              tooltip: context.l10n.eventProfileMine,
              onPressed: current.busy
                  ? null
                  : () => context.pushNamed(
                      Routes.eventProfileSharingScreen.name,
                      pathParameters: {'eventId': widget.eventId},
                    ),
              child: Icon(CatchIcons.personOutlineRounded),
            ),
          if (current != null &&
              (current.access.canManage ||
                  current.access.membershipStatus == 'joined'))
            CatchActionMenu<EventChatAction>(
              tooltip: context.l10n.eventChatTitle,
              enabled: !current.busy,
              items: [
                if (current.access.canManage)
                  CatchActionMenuItem(
                    value: current.access.roomStatus == 'open'
                        ? EventChatAction.close
                        : EventChatAction.open,
                    label: current.access.roomStatus == 'open'
                        ? context.l10n.eventChatClose
                        : context.l10n.eventChatOpen,
                  ),
                if (current.access.membershipStatus == 'joined')
                  CatchActionMenuItem(
                    value: EventChatAction.leave,
                    label: context.l10n.eventChatLeave,
                  ),
              ],
              onSelected: (action) => unawaited(
                _controller.updateAccess(action, reviewedUid: current.uid),
              ),
            ),
        ],
      ),
      body: CatchRouteBody.fullBleed(
        child: CatchAsyncBoundary<EventChatState>(
          value: value,
          retainDataOn: const {},
          onRetry: () => unawaited(_controller.refresh()),
          builder: (context, state) => EventChatPageBody(
            state: state,
            draft: _draft,
            scrollController: _scroll,
            now: DateTime.now(),
            replyId: _replyId,
            reactionId: _reactionId,
            onSend: () => unawaited(_send(state.uid)),
            onMessageAction: (message, action) =>
                unawaited(_messageAction(state, message, action)),
            onViewProfile: (uid) => context.pushNamed(
              Routes.eventParticipantProfileScreen.name,
              pathParameters: {
                'eventId': widget.eventId,
                'participantUid': uid,
              },
            ),
            onLoadEarlier: () => unawaited(_controller.loadEarlier()),
            onAction: (action) => unawaited(
              _controller.updateAccess(action, reviewedUid: state.uid),
            ),
            onReviewProfile: AppConfig.appRole.isHost
                ? null
                : () => context.pushNamed(Routes.formProfilesScreen.name),
            onReply: (id) => setState(() {
              _replyId = id;
              _reactionId = null;
            }),
            onShowReactions: (id) {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() => _reactionId = id);
            },
            onReaction: (message, reaction) {
              setState(() => _reactionId = null);
              unawaited(
                _controller.react(message, reaction, reviewedUid: state.uid),
              );
            },
          ),
        ),
      ),
    );
  }
}

class EventChatPageBody extends StatelessWidget {
  const EventChatPageBody({
    super.key,
    required this.state,
    required this.draft,
    required this.scrollController,
    required this.now,
    required this.replyId,
    required this.reactionId,
    required this.onSend,
    required this.onLoadEarlier,
    required this.onAction,
    required this.onReviewProfile,
    required this.onReply,
    required this.onShowReactions,
    required this.onReaction,
    this.onViewProfile,
    this.onMessageAction,
  });
  final EventChatState state;
  final TextEditingController draft;
  final ScrollController scrollController;
  final DateTime now;
  final String? replyId, reactionId;
  final VoidCallback onSend, onLoadEarlier;
  final ValueChanged<String>? onViewProfile;
  final void Function(EventChatMessage, EventChatSafetyAction)? onMessageAction;
  final ValueChanged<EventChatAction> onAction;
  final VoidCallback? onReviewProfile;
  final ValueChanged<String?> onReply, onShowReactions;
  final void Function(EventChatMessage, EventChatReaction?) onReaction;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final access = state.access;
    final reply = state.messages
        .where((m) => m.messageId == replyId && m.available)
        .firstOrNull;
    final reacting = state.messages
        .where((m) => m.messageId == reactionId && m.available)
        .firstOrNull;
    final typing = state.typingAt(now).map((p) => p.displayName).join(', ');
    if (!access.canReadMessages || !state.active) {
      return CatchPageBody.screen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            gapH24,
            Text(
              access.roomStatus != 'open'
                  ? l.eventChatNotOpen
                  : l.eventChatJoinTitle,
              style: CatchTextStyles.headlineS(context),
            ),
            gapH16,
            Text(
              access.roomStatus != 'open'
                  ? access.canManage
                        ? l.eventChatHostSetup
                        : l.eventChatGuestWaiting
                  : l.eventChatJoinDisclosure,
              style: CatchTextStyles.recordBody(context),
            ),
            gapH24,
            if (access.canManage && access.roomStatus != 'open')
              CatchButton(
                label: l.eventChatOpen,
                fullWidth: true,
                status: state.busy
                    ? CatchButtonStatus.loading
                    : CatchButtonStatus.idle,
                onPressed: state.busy
                    ? null
                    : () => onAction(EventChatAction.open),
              ),
            if (access.profileClaimRequired) ...[
              gapH24,
              Text(
                l.eventChatProfileRequired,
                style: CatchTextStyles.sectionTitle(context),
              ),
              gapH8,
              Text(
                onReviewProfile == null
                    ? l.eventChatProfileHostHelp
                    : l.eventChatProfileHelp,
                style: CatchTextStyles.recordBody(context),
              ),
              if (onReviewProfile != null) ...[
                gapH16,
                CatchButton(
                  label: l.eventChatReviewProfile,
                  fullWidth: true,
                  variant: CatchButtonVariant.secondary,
                  onPressed: onReviewProfile,
                ),
              ],
            ] else if (access.canJoin) ...[
              CatchButton(
                label: l.eventChatJoin,
                fullWidth: true,
                status: state.busy
                    ? CatchButtonStatus.loading
                    : CatchButtonStatus.idle,
                onPressed: state.busy
                    ? null
                    : () => onAction(EventChatAction.join),
              ),
            ],
          ],
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: state.messages.isEmpty
              ? Center(
                  child: Padding(
                    padding: CatchInsets.contentRelaxed,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l.eventChatEmptyTitle,
                          style: CatchTextStyles.headlineS(context),
                        ),
                        gapH12,
                        Text(
                          l.eventChatEmptyBody,
                          textAlign: TextAlign.center,
                          style: CatchTextStyles.recordBody(context),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  padding: CatchInsets.content,
                  itemCount:
                      state.messages.length +
                      (state.nextBeforeSequence == null ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length) {
                      return CatchButton(
                        label: l.eventChatEarlier,
                        variant: CatchButtonVariant.ghost,
                        onPressed: state.busy ? null : onLoadEarlier,
                      );
                    }
                    final message = state.messages[index];
                    return Padding(
                      key: ValueKey(message.messageId),
                      padding: CatchInsets.chatBubbleGroupEnd,
                      child: EventChatMessageTile(
                        message: message,
                        isMe: message.senderUid == state.uid,
                        enabled: state.canSend,
                        onReport:
                            onMessageAction != null &&
                                message.senderUid != state.uid
                            ? () => onMessageAction!(
                                message,
                                EventChatSafetyAction.report,
                              )
                            : null,
                        onBlock:
                            onMessageAction != null &&
                                message.senderUid != state.uid
                            ? () => onMessageAction!(
                                message,
                                EventChatSafetyAction.block,
                              )
                            : null,
                        onRemove:
                            onMessageAction != null &&
                                (message.senderUid == state.uid ||
                                    access.canManage)
                            ? () => onMessageAction!(
                                message,
                                EventChatSafetyAction.remove,
                              )
                            : null,
                        onReply: () => onReply(message.messageId),
                        onViewProfile:
                            message.senderUid == null || onViewProfile == null
                            ? null
                            : () => onViewProfile!(message.senderUid!),
                        onReact: () => onShowReactions(message.messageId),
                        onReaction: (reaction) => onReaction(message, reaction),
                      ),
                    );
                  },
                ),
        ),
        if (typing.isNotEmpty)
          Padding(
            padding: CatchInsets.contentHorizontal,
            child: Text(
              l.eventChatTyping(names: typing),
              style: CatchTextStyles.supporting(context),
            ),
          ),
        if (reacting != null)
          EventChatReactionSection(
            selected: reacting.myReaction,
            onClose: () => onShowReactions(null),
            onSelected: (reaction) => onReaction(reacting, reaction),
          ),
        if (replyId != null && reacting == null)
          Padding(
            padding: CatchInsets.contentHorizontal,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reply == null
                            ? l.eventChatUnavailable
                            : l.eventChatReplyingTo(
                                name: reply.senderName ?? '',
                              ),
                        style: CatchTextStyles.supporting(context),
                      ),
                      if (reply != null)
                        Text(
                          reply.text ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.proseM(context),
                        ),
                    ],
                  ),
                ),
                CatchIconAction(
                  tooltip: l.eventChatClearReply,
                  onPressed: () => onReply(null),
                  child: Icon(CatchIcons.closeRounded),
                ),
              ],
            ),
          ),
        if (reacting == null)
          ChatInputBar(
            controller: draft,
            sending: state.busy,
            showImageButton: false,
            contract: CatchContractConstraints
                .sendEventChatMessageCallablePayloadText,
            disabledReason: replyId != null && reply == null
                ? l.eventChatUnavailable
                : null,
            onSend: onSend,
          ),
      ],
    );
  }
}
