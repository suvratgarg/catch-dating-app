import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_avatar_rail.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_discover_list.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_events_section.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClubsListBody extends ConsumerWidget {
  const ClubsListBody({
    super.key,
    required this.viewModel,
    this.includeJoinedClubsRail = true,
    this.includeClubDirectory = true,
  });

  final ClubsListViewModel viewModel;
  final bool includeJoinedClubsRail;
  final bool includeClubDirectory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Multi-sliver body; callers spread it into a parent slivers list.
    // We deliberately do NOT wrap in `SliverMainAxisGroup` — nesting
    // groups can cause downstream sliver layout to skip the directory
    // section when an upstream sibling has a large scroll extent.
    return SliverMainAxisGroup(
      slivers: buildClubsListBodySlivers(
        context: context,
        ref: ref,
        viewModel: viewModel,
        includeJoinedClubsRail: includeJoinedClubsRail,
        includeClubDirectory: includeClubDirectory,
      ),
    );
  }
}

/// Returns the slivers that make up the Explore feed body — joined-clubs
/// rail, events feed, club directory — as a flat list so they can be
/// spread directly into a parent `CustomScrollView.slivers` without
/// triggering nested-group layout pathologies.
List<Widget> buildClubsListBodySlivers({
  required BuildContext context,
  required WidgetRef ref,
  required ClubsListViewModel viewModel,
  bool includeJoinedClubsRail = true,
  bool includeClubDirectory = true,
}) {
  final canCreateClub = viewModel.joinedClubs.isEmpty
      ? false
      : ref.watch(canCreateClubProvider).asData?.value ?? false;

  return [
    if (includeJoinedClubsRail && viewModel.joinedClubs.isNotEmpty)
      SliverToBoxAdapter(
        child: ClubAvatarRail(
          clubs: viewModel.joinedClubs,
          showCreateButton: canCreateClub,
        ),
      ),
    if (viewModel.allClubs.isNotEmpty) ...buildExploreEventsSlivers(ref),
    if (includeClubDirectory && viewModel.allClubs.isNotEmpty)
      ...buildClubDirectorySlivers(
        context: context,
        clubs: viewModel.allClubs,
        joinedClubIds: viewModel.joinedClubIds,
        hostedClubIds: viewModel.hostedClubIds,
      ),
    const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
  ];
}
