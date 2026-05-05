import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/widgets/message_bubble.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
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
  });

  final AsyncValue<List<ChatMessage>> messagesAsync;
  final String? currentUid;
  final String otherName;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return messagesAsync.when(
      loading: () => const CatchLoadingIndicator(),
      error: (e, _) => Center(
        child: Text(
          'Unable to load messages.',
          style: CatchTextStyles.bodyM(context, color: t.ink2),
        ),
      ),
      data: (messages) {
        if (messages.isEmpty) {
          return Center(
            child: CatchEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Say hi',
              message: 'Say hi to $otherName!',
              surface: false,
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.p12,
            vertical: Sizes.p16,
          ),
          itemCount: messages.length,
          prototypeItem: MessageBubble(
            text: 'placeholder',
            isMe: false,
            sentAt: DateTime.now(),
          ),
          itemBuilder: (context, i) {
            final msg = messages[i];
            return MessageBubble(
              text: msg.text,
              isMe: msg.senderId == currentUid,
              sentAt: msg.sentAt,
              imageUrl: msg.imageUrl,
            );
          },
        );
      },
    );
  }
}
