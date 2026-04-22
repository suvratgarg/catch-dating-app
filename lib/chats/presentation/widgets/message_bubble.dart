import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.sentAt,
  });

  final String text;
  final bool isMe;
  final DateTime sentAt;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final timeStr =
        '${sentAt.hour.toString().padLeft(2, '0')}:${sentAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.p8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) gapW4,
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.p14,
                vertical: Sizes.p10,
              ),
              decoration: BoxDecoration(
                color: isMe ? t.primary : t.raised,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(CatchRadius.cardLg),
                  topRight: const Radius.circular(CatchRadius.cardLg),
                  bottomLeft: Radius.circular(isMe ? CatchRadius.cardLg : 4),
                  bottomRight: Radius.circular(isMe ? 4 : CatchRadius.cardLg),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: CatchTextStyles.bodyMd(
                      context,
                      color: isMe ? t.primaryInk : t.ink,
                    ),
                  ),
                  gapH2,
                  Text(
                    timeStr,
                    style: CatchTextStyles.caption(
                      context,
                      color: isMe ? t.primaryInk.withAlpha(180) : t.ink2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) gapW4,
        ],
      ),
    );
  }
}
