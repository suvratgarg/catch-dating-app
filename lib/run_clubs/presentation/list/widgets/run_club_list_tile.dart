import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'run_club_list_tile_parts/avatar_chip.dart';
part 'run_club_list_tile_parts/club_image.dart';
part 'run_club_list_tile_parts/directory_card.dart';
part 'run_club_list_tile_parts/portrait_card.dart';
part 'run_club_list_tile_parts/row_tile.dart';
part 'run_club_list_tile_parts/scroll_card.dart';

enum RunClubListTileVariant {
  /// List row: avatar · name/subtitle · Join chip. Used in "Nearby".
  rowTile,

  /// 220 px wide horizontal-scroll card. Used in "Your clubs".
  scrollCard,

  /// 160 × 160 portrait card with gradient overlay. Used in "For you".
  portraitCard,

  /// Full-width tall card with photo, tags, activity strip. Used in directory.
  directory,

  /// Circular 58 px avatar chip with name label. Used as a filter chip row.
  avatarChip,
}

class RunClubListTile extends StatelessWidget {
  const RunClubListTile({
    super.key,
    required this.club,
    this.variant = RunClubListTileVariant.rowTile,
    this.isJoined = false,
    this.isActive = false,
    this.onJoin,
  });

  final RunClub club;
  final RunClubListTileVariant variant;
  final bool isJoined;

  /// Only used by [RunClubListTileVariant.avatarChip].
  final bool isActive;

  /// Only used by [RunClubListTileVariant.rowTile].
  final VoidCallback? onJoin;

  void _openDetail(BuildContext context) => context.pushNamed(
    Routes.runClubDetailScreen.name,
    pathParameters: {'runClubId': club.id},
    extra: club,
  );

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      RunClubListTileVariant.rowTile => _RowTile(
        club: club,
        isJoined: isJoined,
        onTap: () => _openDetail(context),
        onJoin: onJoin,
      ),
      RunClubListTileVariant.scrollCard => _ScrollCard(
        club: club,
        isJoined: isJoined,
        onTap: () => _openDetail(context),
      ),
      RunClubListTileVariant.portraitCard => _PortraitCard(
        club: club,
        onTap: () => _openDetail(context),
      ),
      RunClubListTileVariant.directory => _DirectoryCard(
        club: club,
        isJoined: isJoined,
        onTap: () => _openDetail(context),
      ),
      RunClubListTileVariant.avatarChip => _AvatarChip(
        club: club,
        isActive: isActive,
        onTap: () => _openDetail(context),
      ),
    };
  }
}
