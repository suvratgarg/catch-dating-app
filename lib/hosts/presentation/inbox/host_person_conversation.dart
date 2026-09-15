import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/data/conversation_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/chat_controller.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_input_bar.dart';
import 'package:catch_dating_app/chats/presentation/widgets/message_bubble.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/hosts/data/crm/host_whatsapp_repository.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_whatsapp_thread.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_conversation_history.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_people.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_person_conversation_actions.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_reply_drafts.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_person_conversation.g.dart';

@riverpod
Future<HostWhatsappThreadDetail> hostPersonWhatsappDetail(
  Ref ref,
  String organizerId,
  String threadId,
) => ref
    .watch(hostWhatsappRepositoryProvider)
    .getWhatsappThread(organizerId: organizerId, threadId: threadId);

/// Embedded presentation: the route/workspace owns Scaffold and keyboard insets.
class HostPersonConversationPane extends ConsumerStatefulWidget {
  const HostPersonConversationPane({
    super.key,
    required this.person,
    required this.scope,
    this.scopeLabel,
    required this.drafts,
    this.onBack,
  });
  final HostInboxPerson person;
  final HostInboxScope scope;
  final String? scopeLabel;
  final HostReplyDrafts drafts;
  final VoidCallback? onBack;
  @override
  ConsumerState<HostPersonConversationPane> createState() =>
      _HostPersonConversationPaneState();
}

class _HostPersonConversationPaneState
    extends ConsumerState<HostPersonConversationPane> {
  final _text = TextEditingController();
  String? _route;
  bool _sendingImage = false;
  bool get _sending =>
      _route != null && widget.drafts.sending(_draftKey(_route!));
  final Map<String, String?> _markedLatest = {};
  final Set<String> _readFailures = {};
  final _scroll = ScrollController();
  bool _atLatest = true;
  Timer? _windowTimer;
  DateTime? _nextExpiry;

  String get _draftContext =>
      '${widget.person.key}/${widget.scope.eventId ?? 'general'}';
  String _draftKey(String route) => '$_draftContext/$route';
  @override
  void initState() {
    super.initState();
    _route = widget.drafts.selectedRoute(_draftContext);
    _text.text = _route == null ? '' : widget.drafts.text(_draftKey(_route!));
    _text.addListener(_saveDraft);
    widget.drafts.addListener(_syncDraft);
    _scroll.addListener(() {
      final atLatest = _scroll.position.pixels <= 48;
      if (atLatest != _atLatest && mounted) {
        setState(() => _atLatest = atLatest);
      }
    });
  }

  void _saveDraft() {
    if (_route case final route?) {
      widget.drafts.setText(_draftKey(route), _text.text);
    }
  }

  void _selectRoute(String route) {
    if (_sending || _sendingImage || route == _route) return;
    _saveDraft();
    setState(() {
      _route = route;
      _text.text = widget.drafts.text(_draftKey(route));
      widget.drafts.selectRoute(_draftContext, route);
    });
  }

  @override
  void dispose() {
    widget.drafts.removeListener(_syncDraft);
    _saveDraft();
    _scroll.dispose();
    _windowTimer?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _syncDraft() {
    if (!mounted) return;
    final text = _route == null ? '' : widget.drafts.text(_draftKey(_route!));
    if (_text.text != text) _text.text = text;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final uid = catchAsyncStateFromAsyncValue(ref.watch(uidProvider)).value;
    final person = widget.person;
    final entries = <_PersonMessage>[];
    final routes = <String, String>{};
    final catchMessages = <String, List<ChatMessage>>{};
    final histories = <String, HostConversationHistoryState>{};
    final available = <String>{};
    final whatsappDetails = <String, HostWhatsappThreadDetail>{};
    var partial = _readFailures.isNotEmpty;
    DateTime? nextExpiry;
    var sharedScope = false;
    for (final source in person.catchThreads) {
      final matchState = catchAsyncStateFromAsyncValue(
        ref.watch(matchStreamProvider(source.matchId)),
      );
      final match = matchState.value;
      final valid =
          uid != null &&
          match != null &&
          match.clubId == person.organizerId &&
          (match.user1Id == uid || match.user2Id == uid) &&
          match.isClubHostInquiry &&
          match.otherId(uid) == person.linkedUid;
      if (!valid) {
        partial = true;
        continue;
      }
      final route = 'catch:${source.matchId}';
      routes[route] = person.catchThreads.length == 1
          ? context.l10n.hostInboxCatchChannel
          : '${context.l10n.hostInboxCatchChannel} · ${MaterialLocalizations.of(context).formatCompactDate(source.timestamp)}';
      if (!match.isBlocked && !match.isClosed) available.add(route);
      sharedScope |= source.eventIds.length > 1;
      final messages = catchAsyncStateFromAsyncValue(
        ref.watch(watchConversationMessagesProvider(source.matchId)),
      );
      if (messages.isLoading || messages.hasError || messages.hasStaleError) {
        partial = true;
      }
      final history = ref.watch(
        hostConversationHistoryProvider(source.matchId),
      );
      if (history.canLoadMore(messages.value?.length ?? 0)) {
        histories[source.matchId] = history;
      }
      final values =
          {
            for (final m in history.messages) m.id: m,
            for (final m in messages.value ?? <ChatMessage>[]) m.id: m,
          }.values.toList()..sort(
            (a, b) => (a.sentAt ?? DateTime(9999)).compareTo(
              b.sentAt ?? DateTime(9999),
            ),
          );
      catchMessages[source.matchId] = values;
      for (final message in values) {
        entries.add(
          _PersonMessage(
            id: '$route/${message.id}',
            text: message.text,
            imageUrl: message.imageUrl,
            sentAt: message.sentAt,
            isMe: message.senderId == uid,
            channel: context.l10n.hostInboxCatchChannel,
          ),
        );
      }
      final latest = values.lastOrNull?.id;
      if (_atLatest &&
          !_readFailures.contains(source.matchId) &&
          latest != null &&
          _markedLatest[source.matchId] != latest) {
        _markedLatest[source.matchId] = latest;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            unawaited(
              ref
                  .read(conversationRepositoryProvider)
                  .markRead(conversationId: source.matchId, uid: uid)
                  .catchError((Object _) {
                    if (mounted) {
                      setState(() {
                        _readFailures.add(source.matchId);
                        _markedLatest.remove(source.matchId);
                      });
                    }
                  }),
            );
          }
        });
      }
    }
    for (final source in person.whatsappThreads) {
      final result = catchAsyncStateFromAsyncValue(
        ref.watch(
          hostPersonWhatsappDetailProvider(person.organizerId, source.threadId),
        ),
      );
      final detail = result.value;
      if (detail == null ||
          detail.organizerId != person.organizerId ||
          detail.contactId != source.contactId ||
          detail.linkedUid != person.linkedUid) {
        partial = true;
        continue;
      }
      final route = 'whatsapp:${source.threadId}';
      whatsappDetails[route] = detail;
      routes[route] = person.whatsappThreads.length == 1
          ? context.l10n.hostInboxWhatsappReplyChannel
          : '${context.l10n.hostInboxWhatsappReplyChannel} · ${MaterialLocalizations.of(context).formatCompactDate(source.lastMessageAt)}';
      if (detail.serviceWindowOpen &&
          detail.serviceWindowExpiresAt.isAfter(DateTime.now())) {
        available.add(route);
        if (nextExpiry == null ||
            detail.serviceWindowExpiresAt.isBefore(nextExpiry)) {
          nextExpiry = detail.serviceWindowExpiresAt;
        }
      }
      sharedScope |= source.eventIds.length > 1;
      for (final message in detail.messages) {
        entries.add(
          _PersonMessage(
            id: '$route/${message.messageId}',
            text: message.body,
            sentAt: message.occurredAt,
            isMe: message.direction == HostWhatsappMessageDirection.outbound,
            channel: context.l10n.hostInboxWhatsappReplyChannel,
          ),
        );
      }
    }
    if (_nextExpiry != nextExpiry) {
      _windowTimer?.cancel();
      _nextExpiry = nextExpiry;
      if (nextExpiry != null) {
        _windowTimer = Timer(nextExpiry.difference(DateTime.now()), () {
          if (mounted) {
            setState(() {
              _nextExpiry = null;
            });
          }
        });
      }
    }
    entries.sort((a, b) {
      final date = (a.sentAt ?? DateTime(9999)).compareTo(
        b.sentAt ?? DateTime(9999),
      );
      return date == 0 ? a.id.compareTo(b.id) : date;
    });
    final selected = _route;
    final actionSource =
        selected?.startsWith('catch:') == true &&
            catchMessages.containsKey(selected!.substring(6))
        ? selected.substring(6)
        : catchMessages.keys.firstOrNull;
    final canSend =
        uid != null && selected != null && available.contains(selected);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchTopBar.identity(
          identityName: person.displayName,
          identityPhotoUrl: person.photoUrl,
          identitySemanticLabel: person.displayName,
          actions: [
            if (uid != null &&
                person.linkedUid != null &&
                catchMessages.isNotEmpty)
              HostPersonConversationActions(
                key: ValueKey('${person.key}/actions'),
                matchId: actionSource!,
                currentUid: uid,
                personUid: person.linkedUid!,
                name: person.displayName,
                messages: catchMessages[actionSource] ?? const [],
                onBlocked: widget.onBack,
              ),
          ],
          navigation: CatchTopBarNavigation(
            mode: widget.onBack == null
                ? CatchTopBarNavigationMode.none
                : CatchTopBarNavigationMode.back,
            onPressed: widget.onBack,
          ),
        ),
        CatchSection.content(
          child: Text(
            widget.scopeLabel ??
                context.l10n.hostsHostInboxScreenVisiblecopyGeneralInquiries,
            style: CatchTextStyles.supporting(context),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            reverse: true,
            key: PageStorageKey(
              'person-history-${person.key}-${widget.scope.eventId}',
            ),
            padding: CatchInsets.listBodyDense,
            itemCount: entries.length + 1,
            itemBuilder: (context, index) {
              if (index == entries.length) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.hostInboxHistoryCoverage,
                      style: CatchTextStyles.supporting(context),
                    ),
                    if (sharedScope)
                      Text(
                        context.l10n.hostInboxSharedThreadHistory,
                        style: CatchTextStyles.supporting(context),
                      ),
                    if (partial) ...[
                      Text(
                        context.l10n.hostInboxPartialSources,
                        style: CatchTextStyles.supporting(context),
                      ),
                      CatchButton(
                        label: context.l10n.sharedActionTryAgain,
                        variant: CatchButtonVariant.ghost,
                        onPressed: _retry,
                      ),
                    ],
                    for (final history in histories.entries)
                      CatchButton(
                        label: history.value.error == null
                            ? context.l10n.hostInboxOlderMessages
                            : context.l10n.sharedActionTryAgain,
                        variant: CatchButtonVariant.ghost,
                        onPressed: history.value.loading
                            ? null
                            : () => ref
                                  .read(
                                    hostConversationHistoryProvider(
                                      history.key,
                                    ).notifier,
                                  )
                                  .loadMore(),
                      ),
                    gapH12,
                  ],
                );
              }
              final message = entries[entries.length - 1 - index];
              return Column(
                key: ValueKey(message.id),
                crossAxisAlignment: message.isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.channel,
                    style: CatchTextStyles.supporting(context),
                  ),
                  MessageBubble(
                    text: message.text,
                    imageUrl: message.imageUrl,
                    isMe: message.isMe,
                    sentAt: message.sentAt,
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: CatchInsets.pageHorizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.hostInboxReplyVia,
                style: CatchTextStyles.labelL(context),
              ),
              Wrap(
                spacing: CatchSpacing.s2,
                children: [
                  for (final route in routes.entries)
                    CatchButton(
                      label: route.value,
                      variant: selected == route.key
                          ? CatchButtonVariant.primary
                          : CatchButtonVariant.secondary,
                      size: CatchButtonSize.sm,
                      onPressed: _sending || _sendingImage
                          ? null
                          : () => _selectRoute(route.key),
                    ),
                ],
              ),
              if (!canSend)
                Text(
                  selected == null
                      ? context.l10n.hostInboxChooseReplyRoute
                      : context.l10n.hostInboxRouteUnavailable,
                  style: CatchTextStyles.supporting(context),
                ),
            ],
          ),
        ),
        ChatInputBar(
          controller: _text,
          sending: _sending,
          sendingImage: _sendingImage,
          showImageButton: selected?.startsWith('catch:') == true,
          onSendImage: canSend && selected.startsWith('catch:')
              ? () => _sendImage(selected.substring(6), uid)
              : null,
          onSend: canSend
              ? () => _send(selected, uid, whatsappDetails[selected])
              : null,
          disabledReason: canSend
              ? null
              : context.l10n.hostInboxRouteUnavailable,
        ),
      ],
    );
  }

  void _retry() {
    setState(() => _readFailures.clear());
    for (final source in widget.person.catchThreads) {
      ref.invalidate(matchStreamProvider(source.matchId));
      ref.invalidate(watchConversationMessagesProvider(source.matchId));
    }
    for (final source in widget.person.whatsappThreads) {
      ref.invalidate(
        hostPersonWhatsappDetailProvider(
          widget.person.organizerId,
          source.threadId,
        ),
      );
    }
  }

  Future<void> _send(
    String route,
    String uid,
    HostWhatsappThreadDetail? whatsapp,
  ) async {
    final body = _text.text.trim();
    if (_sending || body.isEmpty) return;
    final drafts = widget.drafts;
    final draftKey = _draftKey(route);
    final operation = drafts.begin(draftKey, body);
    if (operation == null) return;
    final organizerId = widget.person.organizerId;
    var succeeded = false;
    try {
      if (route.startsWith('catch:')) {
        await ref
            .read(chatControllerProvider.notifier)
            .sendMessage(
              matchId: route.substring(6),
              senderId: uid,
              text: body,
              messageId: operation,
            );
      } else if (whatsapp != null) {
        await ref
            .read(hostWhatsappRepositoryProvider)
            .sendWhatsappReply(
              organizerId: organizerId,
              thread: whatsapp,
              body: body,
              idempotencyKey: operation,
            );
        if (mounted) {
          ref.invalidate(
            hostPersonWhatsappDetailProvider(
              widget.person.organizerId,
              whatsapp.threadId,
            ),
          );
          ref.invalidate(
            hostWhatsappThreadsProvider(widget.person.organizerId),
          );
        }
      } else {
        throw StateError('Selected route is unavailable.');
      }
      succeeded = true;
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.chat,
        );
      }
    } finally {
      drafts.finish(draftKey, operation, succeeded: succeeded);
    }
  }

  Future<void> _sendImage(String matchId, String uid) async {
    if (_sending || _sendingImage) return;
    setState(() => _sendingImage = true);
    try {
      await ref
          .read(chatControllerProvider.notifier)
          .sendImage(matchId: matchId, senderId: uid);
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.chat,
        );
      }
    } finally {
      if (mounted) setState(() => _sendingImage = false);
    }
  }
}

class _PersonMessage {
  const _PersonMessage({
    required this.id,
    required this.text,
    required this.sentAt,
    required this.isMe,
    required this.channel,
    this.imageUrl,
  });
  final String id;
  final String text;
  final String? imageUrl;
  final DateTime? sentAt;
  final bool isMe;
  final String channel;
}
