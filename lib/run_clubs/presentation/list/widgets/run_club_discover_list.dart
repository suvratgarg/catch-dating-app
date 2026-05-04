import 'package:catch_dating_app/core/widgets/catch_vertical_section.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_club_list_tile.dart';
import 'package:flutter/material.dart';

class RunClubDiscoverList extends StatelessWidget {
  const RunClubDiscoverList({
    super.key,
    required this.clubs,
    required this.joinedClubIds,
  });

  final List<RunClub> clubs;
  final Set<String> joinedClubIds;

  @override
  Widget build(BuildContext context) {
    return CatchVerticalSection(
      title: 'Discover',
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        final club = clubs[index];
        return RunClubListTile(
          club: club,
          variant: RunClubListTileVariant.directory,
          isJoined: joinedClubIds.contains(club.id),
        );
      },
    );
  }
}
