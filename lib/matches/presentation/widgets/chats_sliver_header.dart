import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chat_search_field.dart';
import 'package:flutter/material.dart';

class ChatsSliverHeader extends CatchSliverHeader {
  ChatsSliverHeader({required int count})
    : super(
        title: _TitleRow(count: count),
        bottom: const _SearchRow(),
        titleHeight: 82,
        bottomHeight: 52,
      );
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s4,
        CatchSpacing.s5,
        CatchSpacing.s2,
      ),
      child: Row(
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CatchSpacing.s3,
              vertical: CatchSpacing.s2,
            ),
            decoration: BoxDecoration(
              color: t.primarySoft,
              borderRadius: BorderRadius.circular(CatchRadius.pill),
            ),
            child: Text(
              '$count active',
              style: CatchTextStyles.labelL(context, color: t.primary),
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
        0,
        CatchSpacing.s5,
        CatchSpacing.s3,
      ),
      child: const ChatSearchField(),
    );
  }
}
