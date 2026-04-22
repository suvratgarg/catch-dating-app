import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/horizontal_club_section.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/nearby_clubs_section.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_club_list_tile.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_clubs_empty_state.dart';
import 'package:flutter/material.dart';

class RunClubsContent extends StatelessWidget {
  const RunClubsContent({
    super.key,
    required this.viewModel,
    required this.isJoinPending,
    this.onJoin,
  });

  final RunClubsListViewModel viewModel;
  final bool isJoinPending;
  final ValueChanged<RunClub>? onJoin;

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
            isJoinPending: isJoinPending,
            onJoin: onJoin,
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
