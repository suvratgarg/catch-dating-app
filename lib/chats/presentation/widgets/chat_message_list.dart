import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/widgets/message_bubble.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.messagesAsync,
    required this.currentUid,
    required this.otherName,
    required this.scrollController,
    this.onRetry,
  });

  final AsyncValue<List<ChatMessage>> messagesAsync;
  final String? currentUid;
  final String otherName;
  final ScrollController scrollController;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return messagesAsync.when(
      loading: () => const CatchLoadingIndicator(),
      error: (e, _) => CatchErrorState(
        title: 'Messages unavailable',
        message: 'Unable to load messages.',
        icon: CatchIcons.chatBubbleOutlineRounded,
        onRetry: onRetry,
      ),
      data: (messages) {
        if (messages.isEmpty) {
          return Center(
            child: CatchEmptyState(
              icon: CatchIcons.chatBubbleOutlineRounded,
              title: 'Say hi',
              message: 'Say hi to $otherName!',
              surface: false,
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: CatchSpacing.s3,
            vertical: CatchSpacing.s4,
          ),
          itemCount: messages.length,
          itemBuilder: (context, i) {
            final msg = messages[i];
            final previous = i == 0 ? null : messages[i - 1];
            final next = i == messages.length - 1 ? null : messages[i + 1];
            final isFirstInGroup = previous?.senderId != msg.senderId;
            final isLastInGroup = next?.senderId != msg.senderId;
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
