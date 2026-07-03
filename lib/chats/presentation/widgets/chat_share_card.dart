import 'dart:math' as math;

import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_event_context_copy.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_share_card_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/material.dart';

Future<void> showChatShareCardSheet(
  BuildContext context, {
  required List<ChatMessage> messages,
  required String currentUid,
  required Event? event,
  required ExternalShareController share,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => CatchShareCardSheet(
      card: ChatShareCard(
        messages: messages,
        currentUid: currentUid,
        event: event,
      ),
      share: share,
      fileName: 'catch-chat-card.png',
      buttonLabel: 'Share card',
      footnote: 'Names, photos, and timestamps are hidden.',
      subject: 'Catch chat card',
      text: 'Shared from Catch.',
      // ignore: avoid_redundant_argument_values
      maxWidth: CatchLayout.chatShareCardWidth,
      // ignore: avoid_redundant_argument_values
      pixelRatio: CatchLayout.chatShareCardPixelRatio,
    ),
  );
}

bool hasShareableChatMessages(List<ChatMessage> messages) {
  return messages.any((message) => _shareableText(message).isNotEmpty);
}

// Public for Widgetbook.
class ChatShareCard extends StatelessWidget {
  const ChatShareCard({
    super.key,
    required this.messages,
    required this.currentUid,
    required this.event,
  });

  final List<ChatMessage> messages;
  final String currentUid;
  final Event? event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = event == null
        ? null
        : eventActivityVisual(event!.activityKind, context: context);
    final accent = visual?.accent ?? t.primary;
    final cardMessages = _visibleShareMessages(messages);

    return AspectRatio(
      aspectRatio: CatchLayout.chatShareCardAspectRatio,
      child: CatchSurface(
        backgroundColor: t.bg,
        borderColor: t.line2,
        padding: CatchInsets.contentRelaxed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShareCardHeader(event: event, accent: accent, visual: visual),
            gapH16,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (var i = 0; i < cardMessages.length; i++)
                    ShareCardBubble(
                      text: cardMessages[i].text,
                      isMe: cardMessages[i].senderId == currentUid,
                      isFirstInGroup:
                          i == 0 ||
                          cardMessages[i - 1].senderId !=
                              cardMessages[i].senderId,
                      isLastInGroup:
                          i == cardMessages.length - 1 ||
                          cardMessages[i + 1].senderId !=
                              cardMessages[i].senderId,
                    ),
                ],
              ),
            ),
            gapH14,
            Row(
              children: [
                Text(
                  'CATCH',
                  style: CatchTextStyles.kicker(context, color: t.ink),
                ),
                const Spacer(),
                Text(
                  chatContextStampFor(event),
                  style: CatchTextStyles.labelS(context, color: accent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShareCardHeader extends StatelessWidget {
  const ShareCardHeader({
    super.key,
    required this.event,
    required this.accent,
    required this.visual,
  });

  final Event? event;
  final Color accent;
  final EventActivityVisualSpec? visual;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
        CatchIconTile(
          icon: visual?.icon ?? CatchIcons.chatBubbleOutlineRounded,
          iconColor: accent,
          backgroundColor: t.surface,
          borderColor: accent.withValues(alpha: CatchOpacity.subtleBorder),
          size: CatchLayout.chatShareCardHeaderIconExtent,
          iconSize: CatchIcon.md,
          radius: CatchRadius.pill,
        ),
        gapW10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chatContextStampFor(event),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.labelM(
                  context,
                  color: accent,
                ).copyWith(fontWeight: FontWeight.w800),
              ),
              gapH3,
              Text(
                chatShareCardTitleFor(event),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.titleL(context, color: t.ink),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShareCardBubble extends StatelessWidget {
  const ShareCardBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.isFirstInGroup,
    required this.isLastInGroup,
  });

  final String text;
  final bool isMe;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: isLastInGroup
          ? CatchInsets.chatBubbleGroupEnd
          : CatchInsets.chatBubbleGroupContinue,
      child: Align(
        alignment: isMe
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: math.min(
                  constraints.maxWidth * CatchLayout.chatBubbleMaxWidthFraction,
                  CatchLayout.chatBubbleMaxWidth,
                ),
              ),
              child: CatchSurface(
                backgroundColor: isMe ? t.primary : t.surface,
                borderColor: isMe ? null : t.line,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    isMe || isFirstInGroup ? CatchRadius.lg : CatchRadius.sm,
                  ),
                  topRight: Radius.circular(
                    !isMe || isFirstInGroup ? CatchRadius.lg : CatchRadius.sm,
                  ),
                  bottomLeft: Radius.circular(
                    isMe || !isLastInGroup ? CatchRadius.lg : CatchRadius.sm,
                  ),
                  bottomRight: Radius.circular(
                    isMe && isLastInGroup ? CatchRadius.sm : CatchRadius.lg,
                  ),
                ),
                padding: CatchInsets.chatBubbleContent,
                child: Text(
                  text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.chatMessage(
                    context,
                    color: isMe ? t.primaryInk : t.ink,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

List<ChatMessage> _visibleShareMessages(List<ChatMessage> messages) {
  final textMessages = messages
      .where((message) => _shareableText(message).isNotEmpty)
      .map(
        (message) => ChatMessage(
          id: message.id,
          senderId: message.senderId,
          text: _shareableText(message),
        ),
      )
      .toList();
  final start = math.max(
    0,
    textMessages.length - CatchLayout.chatShareCardMaxMessages,
  );
  return textMessages.sublist(start);
}

String _shareableText(ChatMessage message) => message.text.trim();
