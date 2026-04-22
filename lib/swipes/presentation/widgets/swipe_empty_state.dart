import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_empty_content.dart';
import 'package:flutter/material.dart';

class SwipeEmptyState extends StatelessWidget {
  const SwipeEmptyState({super.key, this.content = defaultSwipeEmptyContent});

  final SwipeEmptyContent content;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(content.icon, size: 72, color: t.line2),
            gapH16,
            Text(content.title, style: CatchTextStyles.displayLg(context)),
            gapH8,
            Text(
              content.message,
              style: CatchTextStyles.bodyMd(context, color: t.ink2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
