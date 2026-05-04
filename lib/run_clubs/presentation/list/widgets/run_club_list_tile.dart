import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/shared/run_club_cover_fallback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'run_club_list_tile_parts/avatar_chip.dart';
part 'run_club_list_tile_parts/club_image.dart';
part 'run_club_list_tile_parts/directory_card.dart';

enum RunClubListTileVariant {
  /// Full-width tall card with photo, tags, activity strip. Used in directory.
  directory,

  /// Circular avatar chip with name label. Used in avatar rail.
  avatarChip,
}

class RunClubListTile extends StatelessWidget {
  const RunClubListTile({
    super.key,
    required this.club,
    this.variant = RunClubListTileVariant.directory,
    this.isJoined = false,
    this.showLiveBadge = false,
  });

  final RunClub club;
  final RunClubListTileVariant variant;
  final bool isJoined;

  /// Only used by [RunClubListTileVariant.avatarChip].
  final bool showLiveBadge;

  void _openDetail(BuildContext context) => context.pushNamed(
    Routes.runClubDetailScreen.name,
    pathParameters: {'runClubId': club.id},
    extra: club,
  );

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      RunClubListTileVariant.directory => _DirectoryCard(
        club: club,
        isJoined: isJoined,
        onTap: () => _openDetail(context),
      ),
      RunClubListTileVariant.avatarChip => _AvatarChip(
        club: club,
        showLiveBadge: showLiveBadge,
        onTap: () => _openDetail(context),
      ),
    };
  }
}
