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
    this._iconRole = _ChatsEmptyStateIconRole.catchWindow,
  });

  const ChatsEmptyState.hostInbox({super.key})
    : title = 'No attendee queries yet',
      message =
          'Guest and attendee questions will appear here once people reach out about an event.',
      _iconRole = _ChatsEmptyStateIconRole.hostInquiry;

  const ChatsEmptyState.noSearchResults({super.key})
    : title = 'No chats match your search',
      message = 'Try another name or clear the search field.',
      _iconRole = _ChatsEmptyStateIconRole.catchWindow;

  const ChatsEmptyState.noHostSearchResults({super.key})
    : title = 'No attendee queries match your search',
      message = 'Try another attendee name or clear the search field.',
      _iconRole = _ChatsEmptyStateIconRole.hostInquiry;

  const ChatsEmptyState.noUnreadQueries({super.key})
    : title = 'No unread queries',
      message =
          'New attendee questions will move here until you open their thread.',
      _iconRole = _ChatsEmptyStateIconRole.hostInquiry;

  final String title;
  final String message;
  final _ChatsEmptyStateIconRole _iconRole;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.contentRelaxed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: CatchSpacing.s10),
          CatchEmptyState(
            icon: _iconRole.icon,
            title: title,
            message: message,
            titleStyle: CatchTextStyles.headlineS(context),
          ),
        ],
      ),
    );
  }
}

enum _ChatsEmptyStateIconRole {
  catchWindow,
  hostInquiry;

  IconData get icon => switch (this) {
    _ChatsEmptyStateIconRole.catchWindow => CatchIcons.favoriteRounded,
    _ChatsEmptyStateIconRole.hostInquiry => CatchIcons.chatBubbleOutlineRounded,
  };
}
