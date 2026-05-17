import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_avatar_rail.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_discover_list.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClubsListBody extends ConsumerWidget {
  const ClubsListBody({super.key, required this.viewModel});

  final ClubsListViewModel viewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCreateClub = viewModel.joinedClubs.isEmpty
        ? false
        : ref.watch(canCreateClubProvider).asData?.value ?? false;

    return SliverMainAxisGroup(
      slivers: [
        if (viewModel.joinedClubs.isNotEmpty)
          SliverToBoxAdapter(
            child: ClubAvatarRail(
              clubs: viewModel.joinedClubs,
              showCreateButton: canCreateClub,
            ),
          ),
        if (viewModel.allClubs.isNotEmpty)
          ClubDiscoverList(
            clubs: viewModel.allClubs,
            joinedClubIds: viewModel.joinedClubIds,
            hostedClubIds: viewModel.hostedClubIds,
          ),
        const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
      ],
    );
  }
}
