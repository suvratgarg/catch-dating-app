import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/material.dart';

enum ChatTopBarAction { shareCard, report, block }

class ChatTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatTopBar({
    super.key,
    required this.name,
    required this.photoUrl,
    this.onProfileTap,
    this.actions = const [],
    this.disabledActions = const {},
    this.onActionSelected,
  }) : assert(actions.length == 0 || onActionSelected != null);

  final String name;
  final String? photoUrl;
  final VoidCallback? onProfileTap;
  final List<ChatTopBarAction> actions;
  final Set<ChatTopBarAction> disabledActions;
  final ValueChanged<ChatTopBarAction>? onActionSelected;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchTopBar(
      backgroundColor: t.surface,
      border: true,
      titleWidget: _ChatTitle(
        name: name,
        photoUrl: photoUrl,
        onTap: onProfileTap,
      ),
      actions: [
        if (actions.isNotEmpty)
          CatchTopBarMenuAction<ChatTopBarAction>(
            tooltip: 'Chat actions',
            onSelected: onActionSelected,
            items: actions
                .map((action) => _actionMenuItem(context, action))
                .toList(),
          ),
      ],
    );
  }

  CatchActionMenuItem<ChatTopBarAction> _actionMenuItem(
    BuildContext context,
    ChatTopBarAction action,
  ) {
    final enabled = !disabledActions.contains(action);
    return switch (action) {
      ChatTopBarAction.shareCard => CatchActionMenuItem(
        value: ChatTopBarAction.shareCard,
        label: 'Share card',
        icon: CatchIcons.platformShare(platform: Theme.of(context).platform),
        enabled: enabled,
      ),
      ChatTopBarAction.report => CatchActionMenuItem(
        value: ChatTopBarAction.report,
        label: 'Report',
        icon: CatchIcons.flagOutlined,
        enabled: enabled,
      ),
      ChatTopBarAction.block => CatchActionMenuItem(
        value: ChatTopBarAction.block,
        label: 'Block',
        icon: CatchIcons.blockRounded,
        enabled: enabled,
        isDestructive: true,
      ),
    };
  }
}

class _ChatTitle extends StatelessWidget {
  const _ChatTitle({
    required this.name,
    required this.photoUrl,
    required this.onTap,
  });

  final String name;
  final String? photoUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      button: onTap != null,
      label: onTap == null ? null : 'View $name profile',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CatchRadius.lg),
        child: Padding(
          padding: CatchInsets.controlVerticalTight,
          child: Row(
            children: [
              CatchPersonAvatar(size: 36, name: name, imageUrl: photoUrl),
              gapW10,
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.titleL(context, color: t.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
