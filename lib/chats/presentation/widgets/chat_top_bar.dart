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
  });

  final String name;
  final String? photoUrl;
  final String? otherUid;
  final PublicProfile? profile;
  final VoidCallback onReport;
  final VoidCallback onBlock;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return CatchTopBar(
      titleWidget: _ChatTitle(name: name, photoUrl: photoUrl),
      actions: [
        if (otherUid != null)
          CatchTopBarMenuAction<String>(
            tooltip: 'Chat actions',
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.pushNamed(
                    Routes.publicProfileScreen.name,
                    pathParameters: {'uid': otherUid!},
                    extra: profile,
                  );
                case 'report':
                  onReport();
                case 'block':
                  onBlock();
                default:
              }
            },
            items: const [
              CatchActionMenuItem(
                value: 'profile',
                label: 'View profile',
                icon: Icons.person_outline_rounded,
              ),
              CatchActionMenuItem(
                value: 'report',
                label: 'Report',
                icon: Icons.flag_outlined,
              ),
              CatchActionMenuItem(
                value: 'block',
                label: 'Block',
                icon: Icons.block_rounded,
                isDestructive: true,
              ),
            ],
          ),
      ],
    );
  }
}

class _ChatTitle extends StatelessWidget {
  const _ChatTitle({required this.name, required this.photoUrl});

  final String name;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
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
    );
  }
}
