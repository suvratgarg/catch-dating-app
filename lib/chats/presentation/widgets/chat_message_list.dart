import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_event_context_copy.dart';
import 'package:catch_dating_app/chats/presentation/widgets/message_bubble.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.messagesAsync,
    required this.currentUid,
    required this.otherName,
    required this.scrollController,
    this.event,
    this.onRetry,
  });

  final AsyncValue<List<ChatMessage>> messagesAsync;
  final String? currentUid;
  final String otherName;
  final ScrollController scrollController;
  final Event? event;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return CatchAsyncValueView<List<ChatMessage>>(
      value: messagesAsync,
      loadingBuilder: (_) =>
          _buildChatMessageListSkeleton(scrollController: scrollController),
      errorBuilder: (_, e, _) => CatchErrorState(
        title: 'Messages unavailable',
        message: 'Unable to load messages.',
        icon: CatchIcons.chatBubbleOutlineRounded,
        onRetry: onRetry,
      ),
      builder: (context, messages) {
        if (messages.isEmpty) {
          return Center(
            child: CatchEmptyState(
              icon: CatchIcons.chatBubbleOutlineRounded,
              title: 'Say hi',
              message: chatEmptyThreadMessageFor(
                event: event,
                otherName: otherName,
              ),
            ),
          );
        }

        final entries = _buildEntries(messages);

        return ListView.builder(
          controller: scrollController,
          padding: CatchInsets.listBodyDense,
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final entry = entries[i];
            final date = entry.date;
            if (date != null) return _buildChatDateSeparator(context, date);

            final messageIndex = entry.messageIndex!;
            final msg = messages[messageIndex];
            final previous = messageIndex == 0
                ? null
                : messages[messageIndex - 1];
            final next = messageIndex == messages.length - 1
                ? null
                : messages[messageIndex + 1];
            final isFirstInGroup =
                previous?.senderId != msg.senderId ||
                !_sameMessageDay(previous?.sentAt, msg.sentAt);
            final isLastInGroup =
                next?.senderId != msg.senderId ||
                !_sameMessageDay(next?.sentAt, msg.sentAt);
            return MessageBubble(
              text: msg.text,
              isMe: msg.senderId == currentUid,
              sentAt: msg.sentAt,
              imageUrl: msg.imageUrl,
              isFirstInGroup: isFirstInGroup,
              isLastInGroup: isLastInGroup,
            );
          },
        );
      },
    );
  }
}

Widget _buildChatMessageListSkeleton({
  required ScrollController scrollController,
}) {
  return ListView(
    controller: scrollController,
    padding: CatchInsets.listBodyDense,
    children: [
      _buildChatDateSkeleton(),
      _buildChatBubbleSkeleton(isMe: false, widthFactor: 0.62),
      _buildChatBubbleSkeleton(isMe: false, widthFactor: 0.48),
      _buildChatBubbleSkeleton(isMe: true, widthFactor: 0.58),
      _buildChatBubbleSkeleton(isMe: true, widthFactor: 0.42),
      _buildChatBubbleSkeleton(isMe: false, widthFactor: 0.68),
    ],
  );
}

Widget _buildChatDateSkeleton() {
  return Padding(
    padding: const EdgeInsets.only(
      top: CatchSpacing.s1,
      bottom: CatchSpacing.s4,
    ),
    child: Center(
      child: CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
    ),
  );
}

Widget _buildChatBubbleSkeleton({
  required bool isMe,
  required double widthFactor,
}) {
  return Builder(
    builder: (context) {
      final t = CatchTokens.of(context);
      final radius = BorderRadius.only(
        topLeft: Radius.circular(isMe ? CatchRadius.lg : CatchRadius.sm),
        topRight: Radius.circular(isMe ? CatchRadius.sm : CatchRadius.lg),
        bottomLeft: Radius.circular(isMe ? CatchRadius.lg : CatchRadius.sm),
        bottomRight: Radius.circular(isMe ? CatchRadius.sm : CatchRadius.lg),
      );

      return Padding(
        padding: CatchInsets.chatBubbleGroupEnd,
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: FractionallySizedBox(
                alignment: isMe
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                widthFactor: widthFactor,
                child: CatchSkeleton.box(
                  height: CatchLayout.buttonLgHeight,
                  borderRadius: radius,
                  borderColor: isMe ? null : t.line,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

List<_ChatListEntry> _buildEntries(List<ChatMessage> messages) {
  final entries = <_ChatListEntry>[];
  for (var index = 0; index < messages.length; index++) {
    final message = messages[index];
    final sentAt = message.sentAt;
    final previous = index == 0 ? null : messages[index - 1];
    if (sentAt != null && !_sameMessageDay(previous?.sentAt, sentAt)) {
      entries.add(_ChatListEntry.date(sentAt));
    }
    entries.add(_ChatListEntry.message(index));
  }
  return entries;
}

bool _sameMessageDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class _ChatListEntry {
  const _ChatListEntry.message(this.messageIndex) : date = null;
  const _ChatListEntry.date(this.date) : messageIndex = null;

  final int? messageIndex;
  final DateTime? date;
}

Widget _buildChatDateSeparator(BuildContext context, DateTime date) {
  final t = CatchTokens.of(context);

  return Padding(
    padding: const EdgeInsets.only(
      top: CatchSpacing.s1,
      bottom: CatchSpacing.s4,
    ),
    child: Center(
      child: Text(
        AppTimeFormatters.weekdayDayMonth(date),
        style: CatchTextStyles.badge(context, color: t.ink3),
      ),
    ),
  );
}
