import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_count_badge.dart';
import 'package:catch_ui/src/components/catch_person_row_copy.dart';
import 'package:catch_ui/src/components/catch_person_row_data.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_status_indicator.dart';
import 'package:flutter/material.dart';

class CatchPersonChatTrailing extends StatelessWidget {
  const CatchPersonChatTrailing({
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (data.timestamp != null)
          Text(
            data.timestamp!,
            style: CatchTextStyles.meta(
              context,
              color: emphasized ? t.primary : t.ink3,
            ),
          ),
        if (hasUnread) ...[
          const SizedBox(height: CatchSpacing.micro6),
          CatchCountBadge.label(
            count: data.unreadCount,
            semanticsLabel: copy.unreadCountLabel(data.unreadCount),
          ),
        ] else if (data.showFreshDot) ...[
          const SizedBox(height: CatchSpacing.micro6),
          CatchStatusIndicator(
            size: CatchSpacing.s2,
            semanticsLabel: copy.newMatchLabel,
          ),
        ],
      ],
    );
  }
}
