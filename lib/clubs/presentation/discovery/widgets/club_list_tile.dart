import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/clubs/presentation/shared/catch_polaroid.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_corner_sash.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/graded_image.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'club_list_tile_parts/avatar_chip.dart';
part 'club_list_tile_parts/club_image.dart';
part 'club_list_tile_parts/directory_card.dart';

enum ClubListTileVariant {
  /// Full-width tall card with photo, tags, activity strip. Used in directory.
  directory,

  /// Circular avatar chip with name label. Used in avatar rail.
  avatarChip,
}

class ClubListTile extends StatelessWidget {
  const ClubListTile({
    super.key,
    required this.club,
    this.variant = ClubListTileVariant.directory,
    this.isJoined = false,
    this.showLiveBadge = false,
  });

  final Club club;
  final ClubListTileVariant variant;
  final bool isJoined;

  /// Only used by [ClubListTileVariant.avatarChip].
  final bool showLiveBadge;

  void _openDetail(BuildContext context) => context.pushNamed(
    Routes.clubDetailScreen.name,
    pathParameters: {'clubId': club.id},
    extra: club,
  );

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      ClubListTileVariant.directory => _DirectoryCard(
        club: club,
        isJoined: isJoined,
        onTap: () => _openDetail(context),
      ),
      ClubListTileVariant.avatarChip => _AvatarChip(
        club: club,
        showLiveBadge: showLiveBadge,
        onTap: () => _openDetail(context),
      ),
    };
  }
}
