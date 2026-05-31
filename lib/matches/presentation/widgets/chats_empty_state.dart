import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:flutter/material.dart';

class ChatsEmptyState extends StatelessWidget {
  const ChatsEmptyState({
    super.key,
    this.title = 'No catches yet',
    this.message =
        'When someone catches you back after a shared event, '
        'the conversation opens here with that event as context.',
  });

  const ChatsEmptyState.noSearchResults({super.key})
    : title = 'No chats match your search',
      message = 'Try another name or clear the search field.';

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CatchSpacing.s5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: CatchSpacing.s10),
          CatchEmptyState(
            icon: CatchIcons.favoriteRounded,
            title: title,
            message: message,
            titleStyle: CatchTextStyles.headlineS(context),
          ),
        ],
      ),
    );
  }
}
