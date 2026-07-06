import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_list_tile.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_horizontal_rail.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClubAvatarRail extends StatelessWidget {
  const ClubAvatarRail({
    super.key,
    required this.clubs,
    this.fullBleed = false,
    this.headerPadding,
    this.listPadding,
    bool? showDivider,
  }) : showDivider = showDivider ?? fullBleed;

  final List<Club> clubs;
  final bool fullBleed;
  final EdgeInsets? headerPadding;
  final EdgeInsetsGeometry? listPadding;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return CatchHorizontalRail(
      title: 'Your clubs',
      height: null,
      spacing: CatchSpacing.micro14,
      fullBleed: fullBleed,
      showDivider: showDivider,
      headerPadding: headerPadding,
      listPadding: listPadding,
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        final club = clubs[index];
        return AvatarChip(
          club: club,
          showLiveBadge: club.nextEventLabel != null,
          onTap: () => _openClubDetail(context, club),
        );
      },
    );
  }
}

void _openClubDetail(BuildContext context, Club club) {
  context.pushNamed(
    Routes.clubDetailScreen.name,
    pathParameters: {'clubId': club.id},
    extra: club,
  );
}
