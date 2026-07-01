import 'package:catch_dating_app/core/app_config.dart';
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

  const ChatsEmptyState.noHostSearchResults({super.key})
    : title = 'No attendee queries match your search',
      message = 'Try another attendee name or clear the search field.';

  const ChatsEmptyState.noUnreadQueries({super.key})
    : title = 'No unread queries',
      message =
          'New attendee questions will move here until you open their thread.';

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isHostApp = AppConfig.appRole.isHost;
    return Padding(
      padding: CatchInsets.contentRelaxed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: CatchSpacing.s10),
          CatchEmptyState(
            icon: isHostApp
                ? CatchIcons.chatBubbleOutlineRounded
                : CatchIcons.favoriteRounded,
            title: isHostApp && title == 'No catches yet'
                ? 'No attendee queries yet'
                : title,
            message: isHostApp && title == 'No catches yet'
                ? 'Guest and attendee questions will appear here once people reach out about an event.'
                : message,
            titleStyle: CatchTextStyles.headlineS(context),
          ),
        ],
      ),
    );
  }
}
