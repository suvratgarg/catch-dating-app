import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_avatar_rail.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_discover_list.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_event_type_browse_grid.dart';
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
    // Compatibility wrapper for call sites that still expect one sliver. Keep
    // Explore day headers inline here because pinned headers inside a
    // SliverMainAxisGroup can violate Flutter's sliver geometry contract.
    return SliverMainAxisGroup(
      slivers: buildClubsListBodySlivers(
        context: context,
        ref: ref,
        viewModel: viewModel,
        includeJoinedClubsRail: includeJoinedClubsRail,
        includeClubDirectory: includeClubDirectory,
        pinnedExploreDayHeaders: false,
      ),
    );
  }
}

/// Returns the slivers that make up the Explore feed body — mixed event/club
/// discovery feed, optional legacy club rails, and browse prompts — as a flat list so they can be
/// spread directly into a parent `CustomScrollView.slivers` without
/// triggering nested-group layout pathologies.
List<Widget> buildClubsListBodySlivers({
  required BuildContext context,
  required WidgetRef ref,
  required ClubsListViewModel viewModel,
  bool includeJoinedClubsRail = true,
  bool includeClubDirectory = true,
  bool pinnedExploreDayHeaders = true,
}) {
  return [
    if (includeJoinedClubsRail && viewModel.joinedClubs.isNotEmpty)
      SliverToBoxAdapter(child: ClubAvatarRail(clubs: viewModel.joinedClubs)),
    if (viewModel.allClubs.isNotEmpty)
      ...buildExploreEventsSlivers(
        ref,
        candidateClubs: viewModel.allClubs,
        joinedClubIds: viewModel.joinedClubIds,
        pinnedDayHeaders: pinnedExploreDayHeaders,
      ),
    if (includeClubDirectory && viewModel.allClubs.isNotEmpty)
      ...buildClubDirectorySlivers(
        context: context,
        clubs: viewModel.allClubs,
        joinedClubIds: viewModel.joinedClubIds,
      ),
    if (viewModel.allClubs.isNotEmpty)
      const SliverToBoxAdapter(child: ExploreEventTypeBrowseGrid()),
    const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
  ];
}
