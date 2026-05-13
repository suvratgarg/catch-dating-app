import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_club_avatar_rail.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_club_discover_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunClubsListBody extends ConsumerWidget {
  const RunClubsListBody({super.key, required this.viewModel});

  final RunClubsListViewModel viewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCreateRunClub = viewModel.joinedClubs.isEmpty
        ? false
        : ref.watch(canCreateRunClubProvider).asData?.value ?? false;

    return SliverMainAxisGroup(
      slivers: [
        if (viewModel.joinedClubs.isNotEmpty)
          SliverToBoxAdapter(
            child: RunClubAvatarRail(
              clubs: viewModel.joinedClubs,
              showCreateButton: canCreateRunClub,
            ),
          ),
        if (viewModel.allClubs.isNotEmpty)
          RunClubDiscoverList(
            clubs: viewModel.allClubs,
            joinedClubIds: viewModel.joinedClubIds,
            hostedClubIds: viewModel.hostedClubIds,
          ),
        const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
      ],
    );
  }
}
