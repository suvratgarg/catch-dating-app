import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/clubs.dart'
    show ClubAvatarRail, buildClubDirectorySlivers;
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_event_type_browse_grid.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_events_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show AsyncData, AsyncValue;

class ExploreBody extends StatelessWidget {
  const ExploreBody({
    super.key,
    this.feedAsync = const AsyncData(ExploreFeedViewModel(items: [])),
    this.filters = const ExploreFilterSelection(),
    this.searchQuery = '',
    this.onRetryFeed,
    this.onRetryClubs,
    this.onClearSearch,
    this.onClearFilters,
    this.onSetTimeFilter,
    this.onActivitySelected,
    this.onEventSelected,
    this.onExternalEventOpened,
    this.onClubSelected,
    ExploreViewModel? clubsViewModel,
    ExploreViewModel? viewModel,
    this.clubSectionError,
    this.includeJoinedClubsRail = true,
    this.includeClubDirectory = true,
  }) : clubsViewModel = clubsViewModel ?? viewModel;

  final AsyncValue<ExploreFeedViewModel> feedAsync;
  final ExploreViewModel? clubsViewModel;
  final ExploreFilterSelection filters;
  final String searchQuery;
  final Object? clubSectionError;
  final VoidCallback? onRetryFeed;
  final VoidCallback? onRetryClubs;
  final VoidCallback? onClearSearch;
  final VoidCallback? onClearFilters;
  final ValueChanged<ExploreTimeFilter>? onSetTimeFilter;
  final ValueChanged<ActivityKind>? onActivitySelected;
  final ExploreEventSelected? onEventSelected;
  final ValueChanged<ExploreExternalEventItem>? onExternalEventOpened;
  final ValueChanged<Club>? onClubSelected;
  final bool includeJoinedClubsRail;
  final bool includeClubDirectory;

  @override
  Widget build(BuildContext context) {
    // Compatibility wrapper for call sites that still expect one sliver. Keep
    // Explore day headers inline here because pinned headers inside a
    // SliverMainAxisGroup can violate Flutter's sliver geometry contract.
    return SliverMainAxisGroup(
      slivers: buildExploreBodySlivers(
        context: context,
        feedAsync: feedAsync,
        clubsViewModel: clubsViewModel,
        filters: filters,
        searchQuery: searchQuery,
        clubSectionError: clubSectionError,
        onRetryFeed: onRetryFeed,
        onRetryClubs: onRetryClubs,
        onClearSearch: onClearSearch,
        onClearFilters: onClearFilters,
        onSetTimeFilter: onSetTimeFilter,
        onActivitySelected: onActivitySelected,
        onEventSelected: onEventSelected,
        onExternalEventOpened: onExternalEventOpened,
        onClubSelected: onClubSelected,
        includeJoinedClubsRail: includeJoinedClubsRail,
        includeClubDirectory: includeClubDirectory,
        pinnedExploreDayHeaders: false,
      ),
    );
  }
}

/// Returns the slivers that make up the Explore feed body — mixed event/club
/// discovery feed, optional legacy club rails, and browse prompts — as a flat
/// list so they can be spread directly into a parent `CustomScrollView.slivers`
/// without triggering nested-group layout pathologies.
List<Widget> buildExploreBodySlivers({
  required BuildContext context,
  required AsyncValue<ExploreFeedViewModel> feedAsync,
  required ExploreFilterSelection filters,
  required String searchQuery,
  VoidCallback? onRetryFeed,
  VoidCallback? onRetryClubs,
  VoidCallback? onClearSearch,
  VoidCallback? onClearFilters,
  ValueChanged<ExploreTimeFilter>? onSetTimeFilter,
  ValueChanged<ActivityKind>? onActivitySelected,
  ExploreEventSelected? onEventSelected,
  ValueChanged<ExploreExternalEventItem>? onExternalEventOpened,
  ValueChanged<Club>? onClubSelected,
  ExploreViewModel? clubsViewModel,
  Object? clubSectionError,
  bool includeJoinedClubsRail = true,
  bool includeClubDirectory = true,
  bool pinnedExploreDayHeaders = true,
}) {
  final viewModel = clubsViewModel;
  final feedValue = switch (feedAsync) {
    AsyncData(:final value) => value,
    _ => null,
  };
  return [
    if (includeJoinedClubsRail &&
        viewModel != null &&
        viewModel.joinedClubs.isNotEmpty)
      SliverToBoxAdapter(child: ClubAvatarRail(clubs: viewModel.joinedClubs)),
    ...buildExploreEventsSlivers(
      feedAsync,
      filters: filters,
      searchQuery: searchQuery,
      onRetry: onRetryFeed,
      onClearSearch: onClearSearch,
      onClearFilters: onClearFilters,
      onSetTimeFilter: onSetTimeFilter,
      onEventSelected: onEventSelected,
      onExternalEventOpened: onExternalEventOpened,
      onClubSelected: onClubSelected,
      candidateClubs: viewModel?.allClubs ?? const [],
      joinedClubIds: viewModel?.joinedClubIds ?? const {},
      pinnedDayHeaders: pinnedExploreDayHeaders,
    ),
    if (clubSectionError != null)
      SliverToBoxAdapter(
        child: Padding(
          padding: CatchInsets.pageBody,
          child: CatchInlineErrorState.fromError(
            clubSectionError,
            context: AppErrorContext.explore,
            onRetry: onRetryClubs,
            compact: true,
          ),
        ),
      ),
    if (includeClubDirectory &&
        viewModel != null &&
        viewModel.allClubs.isNotEmpty)
      ...buildClubDirectorySlivers(
        context: context,
        clubs: viewModel.allClubs,
        joinedClubIds: viewModel.joinedClubIds,
      ),
    if (feedValue != null)
      SliverToBoxAdapter(
        child: ExploreEventTypeBrowseGrid(
          items: feedValue.items,
          activeActivityTag: filters.activityTag,
          onCategoryTap: onActivitySelected,
        ),
      ),
    const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
  ];
}
