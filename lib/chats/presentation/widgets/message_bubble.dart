import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.sentAt,
    this.imageUrl,
  });

  final String text;
  final bool isMe;
  final DateTime? sentAt;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final sentAt = this.sentAt;
    final timeStr = sentAt == null
        ? 'Sending...'
        : AppTimeFormatters.time(sentAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) gapW4,
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: (MediaQuery.of(context).size.width * 0.72).clamp(
                  0,
                  480,
                ),
              ),
              child: CatchSurface(
                padding: const EdgeInsets.symmetric(
                  horizontal: CatchSpacing.micro14,
                  vertical: CatchSpacing.micro10,
                ),
                backgroundColor: isMe ? t.primary : t.raised,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(CatchRadius.lg),
                  topRight: const Radius.circular(CatchRadius.lg),
                  bottomLeft: Radius.circular(isMe ? CatchRadius.lg : 4),
                  bottomRight: Radius.circular(isMe ? 4 : CatchRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: CatchSpacing.micro6,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(CatchRadius.md),
                          child: Image.network(
                            imageUrl!,
                            width: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return SizedBox(
                                width: 200,
                                height: 150,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    if (text.isNotEmpty)
                      Text(
                        text,
                        style: CatchTextStyles.chatMessage(
                          context,
                          color: isMe ? t.primaryInk : t.ink,
                        ),
                      ),
                    gapH2,
                    Text(
                      timeStr,
                      style: CatchTextStyles.statusLabel(
                        context,
                        color: isMe ? t.primaryInk.withAlpha(180) : t.ink2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) gapW4,
        ],
      ),
    );
  }
}
