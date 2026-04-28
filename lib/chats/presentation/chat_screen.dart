import 'dart:async';

import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/chats/data/chat_repository.dart';
import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_input_bar.dart';
import 'package:catch_dating_app/chats/presentation/widgets/message_bubble.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
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

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  bool _didScrollToLatestMessage = false;
  int _lastMessageCount = 0;
  String? _lastResetUid;
  late final MatchRepository _matchRepository;

  @override
  void initState() {
    super.initState();
    _matchRepository = ref.read(matchRepositoryProvider);
    _resetUnread(ref.read(uidProvider).value);
  }

  @override
  void dispose() {
    _resetUnread(_lastResetUid, force: true);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetUnread(String? uid, {bool force = false}) {
    if (uid == null) return;
    if (!force && uid == _lastResetUid) return;

    _lastResetUid = uid;
    unawaited(_matchRepository.resetUnread(matchId: widget.matchId, uid: uid));
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
    final text = _controller.text.trim();
    if (text.isEmpty || _sending || uid == null) return;

    setState(() => _sending = true);
    _controller.clear();

    try {
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(matchId: widget.matchId, senderId: uid, text: text);
      if (_scrollController.hasClients) {
        unawaited(
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _confirmBlock({
    required String targetUserId,
    required String targetName,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block $targetName?'),
        content: const Text(
          'You will stop seeing each other in chats, matches, swipes, and '
          'future run slots where the other person is already booked.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(safetyRepositoryProvider)
        .blockUser(targetUserId: targetUserId, source: 'chat');
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _reportUser({
    required String targetUserId,
    required String targetName,
  }) async {
    await ref
        .read(safetyRepositoryProvider)
        .reportUser(
          targetUserId: targetUserId,
          source: 'chat',
          contextId: widget.matchId,
          reasonCode: 'chat_safety_concern',
        );
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

    ref.listen(chatMessagesProvider(widget.matchId), (previous, next) {
      final previousMessages = previous?.asData?.value;
      next.whenData(
        (messages) => _syncScrollWithMessages(
          messages: messages,
          previousMessages: previousMessages,
        ),
      );
    });

    final uid = ref.watch(uidProvider).value;
    final messagesAsync = ref.watch(chatMessagesProvider(widget.matchId));
    final matchAsync = ref.watch(matchStreamProvider(widget.matchId));
    final match = matchAsync.asData?.value;
    final t = CatchTokens.of(context);
    final otherUid = uid == null ? null : match?.otherId(uid);
    final otherProfileAsync = otherUid == null
        ? const AsyncData<PublicProfile?>(null)
        : ref.watch(publicProfileProvider(otherUid));
    final profile = otherProfileAsync.asData?.value ?? widget.otherProfile;
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

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              backgroundColor: t.primarySoft,
              child: photoUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: CatchTextStyles.labelMd(context, color: t.primary),
                    )
                  : null,
            ),
            gapW10,
            Text(name),
          ],
        ),
        actions: [
          if (otherUid != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'profile') {
                  context.pushNamed(
                    Routes.publicProfileScreen.name,
                    pathParameters: {'uid': otherUid},
                    extra: profile,
                  );
                } else if (value == 'report') {
                  _reportUser(
                    targetUserId: otherUid,
                    targetName: profile?.name ?? 'this person',
                  );
                } else if (value == 'block') {
                  _confirmBlock(
                    targetUserId: otherUid,
                    targetName: profile?.name ?? 'this person',
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'profile', child: Text('View profile')),
                PopupMenuItem(value: 'report', child: Text('Report')),
                PopupMenuItem(value: 'block', child: Text('Block')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Unable to load messages.',
                  style: CatchTextStyles.bodyMd(context, color: t.ink2),
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Say hi to ${profile?.name ?? 'your match'}!',
                      style: CatchTextStyles.bodyMd(context, color: t.ink2),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.p12,
                    vertical: Sizes.p16,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == uid;
                    return MessageBubble(
                      text: msg.text,
                      isMe: isMe,
                      sentAt: msg.sentAt,
                    );
                  },
                );
              },
            ),
          ),
          ChatInputBar(
            controller: _controller,
            sending: _sending,
            onSend: match?.isBlocked == true ? null : _send,
          ),
        ],
      ),
    );
  }
}
