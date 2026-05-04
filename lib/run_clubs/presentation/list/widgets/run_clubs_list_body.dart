import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_club_avatar_rail.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_club_discover_list.dart';
import 'package:flutter/material.dart';

class RunClubsListBody extends StatelessWidget {
  const RunClubsListBody({super.key, required this.viewModel});

  final RunClubsListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (viewModel.joinedClubs.isNotEmpty)
          RunClubAvatarRail(clubs: viewModel.joinedClubs),
        if (viewModel.allClubs.isNotEmpty)
          RunClubDiscoverList(
            clubs: viewModel.allClubs,
            joinedClubIds: viewModel.joinedClubIds,
          ),
        const SizedBox(height: CatchSpacing.s6),
      ],
    );
  }
}
