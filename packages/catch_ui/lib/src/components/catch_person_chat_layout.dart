import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_person_row_copy.dart';
import 'package:catch_ui/src/components/catch_person_row_data.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/material.dart';

class CatchPersonChatLayout extends StatelessWidget {
  const CatchPersonChatLayout({
    super.key,
    required this.data,
    required this.copy,
  });

  final CatchPersonRowData data;
  final CatchPersonRowCopy copy;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasUnread = data.unreadCount > 0;
    final emphasized = hasUnread || data.isFresh || data.showFreshDot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data.name,
          style: CatchTextStyles.fieldRowTitle(
            context,
            color: emphasized ? t.ink : t.ink2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Event context with route icon
        if (data.contextLine != null) ...[
          gapH2,
          Row(
            children: [
              Icon(
                CatchIcons.directionsRunRounded,
                size: CatchIcon.micro,
                color: t.ink3,
              ),
              gapW3,
              Expanded(
                child: Text(
                  data.contextLine!,
                  style: CatchTextStyles.supporting(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        gapH4,
        Text(
          data.isTyping ? copy.typingLabel : data.lastMessage!,
          style: CatchTextStyles.chatPreview(
            context,
            color: data.isTyping
                ? t.primary
                : data.showFreshDot
                ? t.primary
                : hasUnread
                ? t.ink
                : t.ink2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
