import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:flutter/material.dart';

class ChatsEmptyState extends StatelessWidget {
  const ChatsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CatchSpacing.s5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.10),
          CatchEmptyState(
            icon: Icons.favorite_rounded,
            title: 'No catches yet',
            message:
                'When someone catches you back after a shared run, '
                'the conversation opens here with that run as context.',
            titleStyle: CatchTextStyles.displayM(context),
          ),
        ],
      ),
    );
  }
}
