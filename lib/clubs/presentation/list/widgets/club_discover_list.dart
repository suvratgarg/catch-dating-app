import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_list_tile.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:flutter/material.dart';

class ClubDiscoverList extends StatelessWidget {
  const ClubDiscoverList({
    super.key,
    required this.clubs,
    required this.joinedClubIds,
    required this.hostedClubIds,
  });

  final List<Club> clubs;
  final Set<String> joinedClubIds;
  final Set<String> hostedClubIds;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Discover',
            uppercase: false,
            titleStyle: CatchTextStyles.titleL(context),
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              14,
              CatchSpacing.s5,
              8,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s5),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index.isOdd) {
                return const SizedBox(height: 14);
              }

              final club = clubs[index ~/ 2];
              return ClubListTile(
                club: club,
                variant: ClubListTileVariant.directory,
                isJoined: joinedClubIds.contains(club.id),
                isHost: hostedClubIds.contains(club.id),
              );
            }, childCount: clubs.isEmpty ? 0 : clubs.length * 2 - 1),
          ),
        ),
      ],
    );
  }
}
