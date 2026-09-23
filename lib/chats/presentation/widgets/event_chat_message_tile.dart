import 'package:catch_dating_app/chats/domain/event_chat.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class EventChatMessageTile extends StatelessWidget {
  const EventChatMessageTile({
    super.key,
    required this.message,
    required this.isMe,
    required this.enabled,
    required this.onReply,
    required this.onReact,
    required this.onReaction,
  });
  final EventChatMessage message;
  final bool isMe, enabled;
  final VoidCallback onReply, onReact;
  final ValueChanged<EventChatReaction?> onReaction;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final l = context.l10n;
    final ink = isMe ? t.primaryInk : t.ink;
    return Align(
      alignment: isMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: CatchFractionalViewport(
        fraction: CatchLayout.chatBubbleMaxWidthFraction,
        maxWidth: CatchLayout.chatBubbleMaxWidth,
        alignment: isMe
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (message.available)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isMe ? l.eventChatYou : message.senderName ?? '',
                      style: CatchTextStyles.supporting(context),
                    ),
                  ),
                  CatchActionMenu<String>(
                    variant: CatchIconActionVariant.plain,
                    tooltip: l.eventChatMessageActions,
                    enabled: enabled,
                    items: [
                      CatchActionMenuItem(
                        value: 'reply',
                        label: l.eventChatReply,
                      ),
                      CatchActionMenuItem(
                        value: 'react',
                        label: l.eventChatReact,
                      ),
                    ],
                    onSelected: (action) =>
                        action == 'reply' ? onReply() : onReact(),
                  ),
                ],
              ),
            CatchSurface(
              padding: CatchInsets.chatBubbleContent,
              backgroundColor: isMe ? t.primary : t.surface,
              borderColor: isMe ? null : t.line,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (message.reply case final reply?) ...[
                    Text(
                      reply.available
                          ? reply.senderName ?? ''
                          : l.eventChatUnavailable,
                      style: CatchTextStyles.supporting(context, color: ink),
                    ),
                    gapH4,
                    Text(
                      reply.available
                          ? reply.text ?? ''
                          : l.eventChatUnavailable,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.proseM(context, color: ink),
                    ),
                    gapH12,
                  ],
                  CatchTimestampedMessageText(
                    text: message.available
                        ? message.text ?? ''
                        : l.eventChatUnavailable,
                    timestamp: AppTimeFormatters.time(message.sentAt.toLocal()),
                    textStyle: CatchTextStyles.chatMessage(context, color: ink),
                    timestampStyle: CatchTextStyles.supporting(
                      context,
                      color: ink,
                    ),
                  ),
                ],
              ),
            ),
            if (message.available &&
                message.reactionCounts.values.any((n) => n > 0)) ...[
              gapH4,
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s1,
                children: [
                  for (final reaction in EventChatReaction.values)
                    if ((message.reactionCounts[reaction] ?? 0) > 0)
                      CatchButton.selection(
                        label:
                            '${reaction.emoji} ${message.reactionCounts[reaction]}',
                        semanticsLabel: eventChatReactionLabel(
                          context,
                          reaction,
                        ),
                        backgroundColor: message.myReaction == reaction
                            ? t.primarySoft
                            : null,
                        onPressed: enabled
                            ? () => onReaction(
                                message.myReaction == reaction
                                    ? null
                                    : reaction,
                              )
                            : null,
                      ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String eventChatReactionLabel(
  BuildContext context,
  EventChatReaction reaction,
) => switch (reaction) {
  EventChatReaction.like => context.l10n.eventChatReactionLike,
  EventChatReaction.love => context.l10n.eventChatReactionLove,
  EventChatReaction.laugh => context.l10n.eventChatReactionLaugh,
  EventChatReaction.wow => context.l10n.eventChatReactionWow,
  EventChatReaction.sad => context.l10n.eventChatReactionSad,
  EventChatReaction.thanks => context.l10n.eventChatReactionThanks,
};

class EventChatReactionSection extends StatelessWidget {
  const EventChatReactionSection({
    super.key,
    required this.onSelected,
    required this.onClose,
    required this.selected,
  });
  final ValueChanged<EventChatReaction?> onSelected;
  final VoidCallback onClose;
  final EventChatReaction? selected;
  @override
  Widget build(BuildContext context) => Padding(
    padding: CatchInsets.content,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.eventChatReactionsTitle,
                style: CatchTextStyles.recordBody(context),
              ),
            ),
            CatchIconAction(
              tooltip: context.l10n.eventChatCloseReactions,
              onPressed: onClose,
              child: Icon(CatchIcons.closeRounded),
            ),
          ],
        ),
        gapH8,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            for (final reaction in EventChatReaction.values)
              CatchButton.selection(
                label: reaction.emoji,
                semanticsLabel: eventChatReactionLabel(context, reaction),
                backgroundColor: selected == reaction
                    ? CatchTokens.of(context).primarySoft
                    : null,
                onPressed: () =>
                    onSelected(selected == reaction ? null : reaction),
              ),
          ],
        ),
      ],
    ),
  );
}
