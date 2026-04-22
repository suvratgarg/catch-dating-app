import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_clubs_list_state.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/horizontal_club_section.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/nearby_clubs_section.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/run_club_list_tile.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/run_clubs_empty_state.dart';
import 'package:flutter/material.dart';

class RunClubsContent extends StatelessWidget {
  const RunClubsContent({
    super.key,
    required this.viewModel,
    required this.isFollowPending,
    this.onFollow,
  });

  final RunClubsListViewModel viewModel;
  final bool isFollowPending;
  final ValueChanged<RunClub>? onFollow;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isEmpty) {
      return const RunClubsEmptyState();
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (viewModel.joinedClubs.isNotEmpty) ...[
          HorizontalClubSection(
            title: 'Your clubs',
            trailing: 'See all (${viewModel.joinedClubs.length})',
            height: 170,
            clubs: viewModel.joinedClubs,
            variant: RunClubListTileVariant.scrollCard,
            isJoined: true,
          ),
          const SizedBox(height: 20),
        ],
        if (viewModel.discoverClubs.isNotEmpty) ...[
          HorizontalClubSection(
            title: 'For you',
            trailing: 'See all',
            height: 172,
            clubs: viewModel.discoverClubs,
            variant: RunClubListTileVariant.portraitCard,
          ),
          const SizedBox(height: 20),
          NearbyClubsSection(
            clubs: viewModel.discoverClubs,
            isFollowPending: isFollowPending,
            onFollow: onFollow,
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
