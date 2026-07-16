import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/clubs.dart'
    show ClubAvatarRail, buildClubDirectorySlivers;
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/explore/domain/explore_event_recommendation.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_event_type_browse_grid.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_events_section.dart';
import 'package:catch_dating_app/explore/presentation/widgets/recommendations.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show AsyncData, AsyncError, AsyncLoading, AsyncValue;

/// Returns the slivers that make up the Explore feed body — mixed event/club
/// discovery feed, optional legacy club rails, and browse prompts — as a flat
/// list so they can be spread directly into a parent `CustomScrollView.slivers`.
/// When sticky day headers are enabled, only the event stream is wrapped in a
/// bounded [SliverMainAxisGroup]; compatibility callers disable pinning and
/// continue to receive flat inline-header slivers, avoiding nested groups.
List<Widget> buildExploreBodySlivers({
  required BuildContext context,
  required AsyncValue<ExploreFeedViewModel> feedAsync,
  AsyncValue<List<ExploreEventRecommendation>>? recommendationsAsync,
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
  bool promoteFeaturedItem = false,
  DateTime? now,
}) {
  final viewModel = clubsViewModel;
  final feedValue = switch (feedAsync) {
    AsyncData(:final value) => value,
    _ => null,
  };
  final eventSlivers = buildExploreEventsSlivers(
    feedAsync,
    l10n: context.l10n,
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
    promoteFeaturedItem: promoteFeaturedItem,
    now: now,
  );
  return [
    if (includeJoinedClubsRail &&
        viewModel != null &&
        viewModel.joinedClubs.isNotEmpty)
      SliverToBoxAdapter(
        child: ClubAvatarRail(clubs: viewModel.joinedClubs, fullBleed: true),
      ),
    if (pinnedExploreDayHeaders)
      SliverMainAxisGroup(slivers: eventSlivers)
    else
      ...eventSlivers,
    if (recommendationsAsync != null)
      switch (recommendationsAsync) {
        AsyncLoading() => const SliverToBoxAdapter(
          child: Padding(
            padding: CatchInsets.pageBody,
            child: CatchSkeletonList(
              count: 2,
              height: CatchLayout.dashboardRecommendedEventSkeletonHeight,
            ),
          ),
        ),
        AsyncError(:final error) => SliverToBoxAdapter(
          child: Padding(
            padding: CatchInsets.pageBody,
            child: CatchInlineErrorState.fromError(
              error,
              context: AppErrorContext.explore,
              onRetry: onRetryFeed,
              compact: true,
            ),
          ),
        ),
        AsyncData(:final value) =>
          value.isEmpty
              ? const SliverToBoxAdapter(child: SizedBox.shrink())
              : SliverToBoxAdapter(
                  child: Padding(
                    padding: CatchInsets.pageBody,
                    child: Recommendations(recommendations: value),
                  ),
                ),
      },
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
  ];
}
