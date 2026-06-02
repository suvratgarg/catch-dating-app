import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_list_tile.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_horizontal_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClubAvatarRail extends StatelessWidget {
  const ClubAvatarRail({
    super.key,
    required this.clubs,
    this.showCreateButton = true,
    this.headerPadding,
    this.listPadding,
    this.showDivider = true,
  });

  final List<Club> clubs;
  final bool showCreateButton;
  final EdgeInsets? headerPadding;
  final EdgeInsetsGeometry? listPadding;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return CatchHorizontalRail(
      title: 'Your clubs',
      height: CatchLayout.clubAvatarRailHeight,
      spacing: CatchSpacing.micro14,
      showDivider: showDivider,
      headerPadding: headerPadding ?? CatchInsets.sectionHeader,
      listPadding: listPadding ?? CatchInsets.pageHorizontal,
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
            width: CatchLayout.clubAvatarRailColumnWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchSurface(
                  width: CatchLayout.clubCreateButtonExtent,
                  height: CatchLayout.clubCreateButtonExtent,
                  radius: CatchRadius.pill,
                  backgroundColor: t.raised,
                  borderColor: t.line2,
                  child: Icon(
                    CatchIcons.addRounded,
                    size: CatchIcon.row,
                    color: t.ink2,
                  ),
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
