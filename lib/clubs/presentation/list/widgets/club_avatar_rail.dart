import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_list_tile.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_horizontal_rail.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClubAvatarRail extends StatelessWidget {
  const ClubAvatarRail({
    super.key,
    required this.clubs,
    this.showCreateButton = true,
  });

  final List<Club> clubs;
  final bool showCreateButton;

  @override
  Widget build(BuildContext context) {
    return CatchHorizontalRail(
      title: 'Your clubs',
      height: 108,
      spacing: 14,
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        final club = clubs[index];
        return ClubListTile(
          club: club,
          variant: ClubListTileVariant.avatarChip,
          showLiveBadge: club.nextEventLabel != null,
        );
      },
      trailing: showCreateButton
          ? _CreateClubButton(
              onTap: () => context.pushNamed(Routes.createClubScreen.name),
            )
          : null,
    );
  }
}

class _CreateClubButton extends StatelessWidget {
  const _CreateClubButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Tooltip(
      message: 'Create club',
      child: Semantics(
        button: true,
        label: 'Create club',
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 76,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: t.raised,
                    borderRadius: BorderRadius.circular(CatchRadius.pill),
                    border: Border.all(color: t.line2),
                  ),
                  alignment: Alignment.center,
                  child: Icon(CatchIcons.addRounded, size: 22, color: t.ink2),
                ),
                gapH6,
                Text(
                  'Create',
                  style: CatchTextStyles.labelM(context, color: t.ink2),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
