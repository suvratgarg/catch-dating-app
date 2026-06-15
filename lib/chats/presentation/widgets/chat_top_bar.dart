import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatTopBar({
    super.key,
    required this.name,
    required this.photoUrl,
    required this.otherUid,
    required this.profile,
    required this.onReport,
    required this.onBlock,
    this.profileNavigationEnabled = true,
    this.onShareCard,
  });

  final String name;
  final String? photoUrl;
  final String? otherUid;
  final PublicProfile? profile;
  final VoidCallback onReport;
  final VoidCallback onBlock;
  final bool profileNavigationEnabled;
  final VoidCallback? onShareCard;

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
        onTap: otherUid == null || !profileNavigationEnabled
            ? null
            : () => context.pushNamed(
                Routes.publicProfileScreen.name,
                pathParameters: {'uid': otherUid!},
                extra: profile,
              ),
      ),
      actions: [
        if (otherUid != null)
          CatchTopBarMenuAction<String>(
            tooltip: 'Chat actions',
            onSelected: (value) {
              switch (value) {
                case 'shareCard':
                  onShareCard?.call();
                case 'report':
                  onReport();
                case 'block':
                  onBlock();
                default:
              }
            },
            items: [
              if (onShareCard != null)
                CatchActionMenuItem(
                  value: 'shareCard',
                  label: 'Share card',
                  icon: CatchIcons.platformShare(
                    platform: Theme.of(context).platform,
                  ),
                ),
              CatchActionMenuItem(
                value: 'report',
                label: 'Report',
                icon: CatchIcons.flagOutlined,
              ),
              CatchActionMenuItem(
                value: 'block',
                label: 'Block',
                icon: CatchIcons.blockRounded,
                isDestructive: true,
              ),
            ],
          ),
      ],
    );
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
              PersonAvatar(size: 36, name: name, imageUrl: photoUrl),
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
