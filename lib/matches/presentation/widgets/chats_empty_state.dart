import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class ChatsEmptyState extends StatelessWidget {
  const ChatsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: const EdgeInsets.all(CatchSpacing.s5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.10),
          Container(
            padding: const EdgeInsets.all(Sizes.p20),
            decoration: BoxDecoration(
              color: t.surface,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: t.heroGrad,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 34,
                    color: t.primaryInk,
                  ),
                ),
                gapH18,
                Text(
                  'No catches yet',
                  style: CatchTextStyles.displayM(context),
                  textAlign: TextAlign.center,
                ),
                gapH8,
                Text(
                  'When someone catches you back after a shared run, '
                  'the conversation opens here with that run as context.',
                  style: CatchTextStyles.bodyM(context, color: t.ink2),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
