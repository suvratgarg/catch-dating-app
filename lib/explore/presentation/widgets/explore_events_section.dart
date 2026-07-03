import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_club_cards.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_event_rows.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_event_support_widgets.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_events_status_slivers.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_synthetic_visual_fill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show AsyncData, AsyncError, AsyncLoading, AsyncValue;

export 'package:catch_dating_app/explore/presentation/widgets/explore_club_cards.dart';
export 'package:catch_dating_app/explore/presentation/widgets/explore_event_rows.dart';
export 'package:catch_dating_app/explore/presentation/widgets/explore_event_support_widgets.dart';
export 'package:catch_dating_app/explore/presentation/widgets/explore_events_status_slivers.dart';

const EdgeInsets _exploreEventsErrorPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s5,
  CatchSpacing.s3,
  CatchSpacing.s5,
  CatchSpacing.s3,
);

/// Builds the Explore feed slivers: a mixed event/club discovery stream.
///
/// Returns a flat list of slivers — not a nested [SliverMainAxisGroup] —
/// so the parent sheet keeps one scroll owner while the feed can interleave
/// compact event rows and club recommendations.
List<Widget> buildExploreEventsSlivers(
  AsyncValue<ExploreFeedViewModel> feedAsync, {
  required ExploreFilterSelection filters,
  required String searchQuery,
  VoidCallback? onRetry,
  VoidCallback? onClearSearch,
  VoidCallback? onClearFilters,
  ValueChanged<ExploreTimeFilter>? onSetTimeFilter,
  ExploreEventSelected? onEventSelected,
  ValueChanged<ExploreExternalEventItem>? onExternalEventOpened,
  ValueChanged<Club>? onClubSelected,
  bool pinnedDayHeaders = true,
  List<Club> candidateClubs = const <Club>[],
  Set<String> joinedClubIds = const <String>{},
}) {
  return switch (feedAsync) {
    AsyncLoading() => [const ExploreEventsLoadingSliver()],
    AsyncError(:final error) => [
      SliverToBoxAdapter(
        // Bound the error sliver's scroll extent so a long `error.toString()`
        // (e.g. a wrapped ProviderException with full stack trace) does not
        // dominate the sheet's sliver layout and starve following siblings
        // of paint extent. The `OverflowBox` lets the child report its
        // natural intrinsic size while we clip down to a fixed paint area.
        child: ClipRect(
          child: SizedBox(
            height: CatchLayout.exploreErrorSliverHeight,
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: 0,
              maxHeight: 1200,
              child: Padding(
                padding: _exploreEventsErrorPadding,
                child: CatchInlineErrorState.fromError(
                  error,
                  context: AppErrorContext.event,
                  onRetry: onRetry,
                  compact: true,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
    AsyncData(:final value) => () {
      final hasDiscoverableClubCandidates = rankExploreClubIntermixCandidates(
        candidateClubs,
        joinedClubIds: joinedClubIds,
      ).isNotEmpty;
      final canUseSyntheticVisualFill = shouldUseExploreSyntheticVisualFill;
      return value.isEmpty &&
              !hasDiscoverableClubCandidates &&
              !canUseSyntheticVisualFill
          ? [
              ExploreEventsEmptySliver(
                state: ExploreEventsEmptyState.from(
                  filters: filters,
                  searchQuery: searchQuery,
                ),
                onClearSearch: onClearSearch,
                onClearFilters: onClearFilters,
                onSetTimeFilter: onSetTimeFilter,
              ),
            ]
          : _exploreContentSlivers(
              value,
              candidateClubs: candidateClubs,
              joinedClubIds: joinedClubIds,
              pinnedDayHeaders: pinnedDayHeaders,
              showThisWeekList:
                  filters.timeFilter == ExploreTimeFilter.thisWeek,
              onEventSelected: onEventSelected,
              onExternalEventOpened: onExternalEventOpened,
              onClubSelected: onClubSelected,
            );
    }(),
  };
}

/// Compatibility shim — earlier call sites used `const ExploreEventsSection()`
/// as a single sliver. New call sites should prefer
/// [buildExploreEventsSlivers] so the slivers are spread into the parent
/// flat slivers list.
class ExploreEventsSection extends StatelessWidget {
  const ExploreEventsSection({
    super.key,
    this.feedAsync = const AsyncData(ExploreFeedViewModel(items: [])),
    this.filters = const ExploreFilterSelection(),
    this.searchQuery = '',
    this.onRetry,
    this.onClearSearch,
    this.onClearFilters,
    this.onSetTimeFilter,
    this.onEventSelected,
    this.onExternalEventOpened,
    this.onClubSelected,
  });

  final AsyncValue<ExploreFeedViewModel> feedAsync;
  final ExploreFilterSelection filters;
  final String searchQuery;
  final VoidCallback? onRetry;
  final VoidCallback? onClearSearch;
  final VoidCallback? onClearFilters;
  final ValueChanged<ExploreTimeFilter>? onSetTimeFilter;
  final ExploreEventSelected? onEventSelected;
  final ValueChanged<ExploreExternalEventItem>? onExternalEventOpened;
  final ValueChanged<Club>? onClubSelected;

  @override
  Widget build(BuildContext context) {
    final slivers = buildExploreEventsSlivers(
      feedAsync,
      filters: filters,
      searchQuery: searchQuery,
      onRetry: onRetry,
      onClearSearch: onClearSearch,
      onClearFilters: onClearFilters,
      onSetTimeFilter: onSetTimeFilter,
      onEventSelected: onEventSelected,
      onExternalEventOpened: onExternalEventOpened,
      onClubSelected: onClubSelected,
      pinnedDayHeaders: false,
    );
    if (slivers.length == 1) return slivers.single;
    return SliverMainAxisGroup(slivers: slivers);
  }
}

List<Widget> _exploreContentSlivers(
  ExploreFeedViewModel viewModel, {
  required List<Club> candidateClubs,
  required Set<String> joinedClubIds,
  required bool pinnedDayHeaders,
  required bool showThisWeekList,
  required ExploreEventSelected? onEventSelected,
  required ValueChanged<ExploreExternalEventItem>? onExternalEventOpened,
  required ValueChanged<Club>? onClubSelected,
}) {
  final effectiveCandidateClubs = withDebugSyntheticExploreClubs(
    candidateClubs,
    joinedClubIds: joinedClubIds,
  );
  final effectiveItems = withDebugSyntheticExploreItems(
    viewModel.items,
    seedClubs: [
      for (final item in viewModel.items) item.club,
      ...effectiveCandidateClubs,
    ],
  );
  final layoutViewModel = identical(effectiveItems, viewModel.items)
      ? viewModel
      : ExploreFeedViewModel(
          items: effectiveItems,
          externalItems: viewModel.externalItems,
        );
  final sectionState = ExploreFeedSectionState.from(
    viewModel: layoutViewModel,
    candidateClubs: effectiveCandidateClubs,
    joinedClubIds: joinedClubIds,
    showThisWeekList: showThisWeekList,
  );
  if (sectionState.isEmpty) {
    return const [SliverToBoxAdapter(child: SizedBox.shrink())];
  }
  final resultCountPadding = EdgeInsets.fromLTRB(
    CatchSpacing.s5,
    pinnedDayHeaders ? CatchSpacing.s4 : CatchSpacing.s3,
    CatchSpacing.s5,
    CatchSpacing.s1,
  );
  final thisWeekPadding = EdgeInsets.fromLTRB(
    CatchSpacing.s5,
    CatchSpacing.s3,
    CatchSpacing.s5,
    sectionState.cards.isEmpty ? CatchSpacing.s4 : CatchSpacing.s2,
  );
  final feedListPadding = EdgeInsets.fromLTRB(
    CatchSpacing.s5,
    sectionState.thisWeekItems.isEmpty
        ? (pinnedDayHeaders ? CatchSpacing.s4 : CatchSpacing.s3)
        : CatchSpacing.s4,
    CatchSpacing.s5,
    CatchSpacing.s2,
  );

  return [
    if (sectionState.bodyViewModel.count > 0)
      SliverToBoxAdapter(
        child: Padding(
          padding: resultCountPadding,
          child: Builder(
            builder: (context) => ExploreMonoLabel(
              sectionState.resultCountLabel,
              color: CatchTokens.of(context).ink3,
            ),
          ),
        ),
      ),
    if (sectionState.thisWeekItems.isNotEmpty)
      SliverToBoxAdapter(
        child: Padding(
          padding: thisWeekPadding,
          child: Builder(
            builder: (context) => ThisWeekRecommendationsSection(
              items: sectionState.thisWeekItems,
              onEventSelected: onEventSelected,
            ),
          ),
        ),
      ),
    SliverPadding(
      padding: feedListPadding,
      sliver: SliverList.separated(
        itemCount: sectionState.cards.length,
        separatorBuilder: (_, _) => const SizedBox(height: CatchSpacing.s4),
        itemBuilder: (context, index) {
          return switch (sectionState.cards[index]) {
            ExploreMixedEventRowCard(:final item) => ExploreFeedEventRow(
              item: item,
              onEventSelected: onEventSelected,
            ),
            ExploreMixedExternalEventRowCard(:final item) =>
              ExploreExternalEventRow(
                item: item,
                onExternalEventOpened: onExternalEventOpened,
              ),
            ExploreMixedClubSpotlightCard(:final club) =>
              ExploreClubPolaroidCard(
                club: club,
                onClubSelected: onClubSelected,
              ),
            ExploreMixedClubRowCard(:final club) => ExploreFeedClubRow(
              club: club,
              onClubSelected: onClubSelected,
            ),
          };
        },
      ),
    ),
    const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
  ];
}
