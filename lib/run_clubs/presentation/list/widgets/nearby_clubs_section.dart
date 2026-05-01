import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_club_list_tile.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/section_header.dart';
import 'package:flutter/material.dart';

class NearbyClubsSection extends StatelessWidget {
  const NearbyClubsSection({
    super.key,
    required this.clubs,
    required this.isJoinPending,
    this.onJoin,
  });

  final List<RunClub> clubs;
  final bool isJoinPending;
  final ValueChanged<RunClub>? onJoin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: 'Nearby'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s5),
          child: Column(
            children: [
              for (var i = 0; i < clubs.length; i++) ...[
                RunClubListTile(
                  club: clubs[i],
                  variant: RunClubListTileVariant.rowTile,
                  onJoin: onJoin == null || isJoinPending
                      ? null
                      : () => onJoin!(clubs[i]),
                ),
                if (i < clubs.length - 1)
                  Divider(color: CatchTokens.of(context).line, height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
