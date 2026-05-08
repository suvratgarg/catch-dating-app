import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chat_search_field.dart';
import 'package:flutter/material.dart';

class ChatsSliverHeader extends CatchSliverHeader {
  ChatsSliverHeader({required int count, bool showSearchField = true})
    : super(
        title: _TitleRow(count: count),
        bottom: showSearchField ? const _SearchRow() : null,
        titleHeight: CatchSliverHeader.wrappedTitleHeight,
        bottomHeight: CatchSliverHeader.compactSearchBottomHeight,
      );
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final countLabel = count == 1 ? '1 match' : '$count matches';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s4,
        CatchSpacing.s5,
        CatchSpacing.s2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Your catches', style: CatchTextStyles.displayL(context)),
                gapH4,
                Text(
                  'Chat with your matches',
                  style: CatchTextStyles.bodyS(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: CatchSpacing.s3),
          Padding(
            padding: const EdgeInsets.only(top: CatchSpacing.s2),
            child: CatchBadge(
              label: countLabel,
              tone: CatchBadgeTone.brand,
              size: CatchBadgeSize.md,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s2,
        CatchSpacing.s5,
        CatchSpacing.s2,
      ),
      child: const SizedBox(
        height: CatchTextField.compactControlHeight,
        child: ChatSearchField(),
      ),
    );
  }
}
