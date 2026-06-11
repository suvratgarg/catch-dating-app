import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_list_tile.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_horizontal_rail.dart';
import 'package:flutter/material.dart';

class ClubAvatarRail extends StatelessWidget {
  const ClubAvatarRail({
    super.key,
    required this.clubs,
    this.headerPadding,
    this.listPadding,
    this.showDivider = true,
  });

  final List<Club> clubs;
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
    );
  }
}
