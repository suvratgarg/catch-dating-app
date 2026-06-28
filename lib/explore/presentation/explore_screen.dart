import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_count_pill.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_body.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_empty_state.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_filter_rail.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_header.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Explore — the supply-side feed (design-system Explore).
///
/// A single scrolling feed: the browse header (city + search) and filter rail
/// sit above day-grouped event tickets, club polaroids, and the editorial
/// spotlight. The map is no longer an always-on canvas — it is a focused route
/// reached from the floating bottom-left map pill ([ExploreMapScreen]).
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key, this.enableEventMapNetworkTiles = true});

  /// Retained for call-site/test compatibility. The map now lives in its own
  /// route ([ExploreMapScreen]); tile behaviour is configured there.
  final bool enableEventMapNetworkTiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final feedCount = ref
        .watch(exploreFeedViewModelProvider)
        .asData
        ?.value
        .count;
    final mapLabel = feedCount == null || feedCount == 0
        ? 'Map'
        : 'Map · $feedCount';

    final viewModelAsync = ref.watch(exploreViewModelProvider);
    final city = ref.watch(selectedExploreCityProvider);
    final query = ref.watch(exploreSearchQueryProvider).trim();
    final filters = ref.watch(exploreFiltersProvider);
    final hasSourceClubs =
        (ref.watch(exploreSourceClubsProvider).asData?.value.length ?? 0) > 0;

    final bodySlivers = switch (viewModelAsync) {
      AsyncLoading() => <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: CatchInsets.pageBody,
            child: _buildExploreSkeletonList(),
          ),
        ),
      ],
      AsyncError(:final error) => [
        CatchSliverErrorState.fromError(
          error,
          context: AppErrorContext.explore,
          onRetry: () {
            ref.invalidate(exploreViewModelProvider);
            ref.invalidate(exploreSourceClubsProvider);
          },
        ),
      ],
      AsyncData(:final value) =>
        value.isEmpty
            ? [
                SliverFillRemaining(
                  child: _buildExploreEmptyState(
                    ref,
                    cityLabel: city.label,
                    hasSourceClubs: hasSourceClubs,
                    hasSearch: query.isNotEmpty,
                    filters: filters,
                  ),
                ),
              ]
            : buildExploreBodySlivers(
                context: context,
                ref: ref,
                viewModel: value,
                includeJoinedClubsRail: false,
                includeClubDirectory: false,
              ),
    };

    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          CatchMutationErrorListener(
            mutation: ClubMembershipController.joinMutation,
            child: CustomScrollView(
              key: const ValueKey('explore-list-scroll-view'),
              slivers: [
                SliverToBoxAdapter(child: _buildExploreChrome()),
                ...bodySlivers,
              ],
            ),
          ),
          Positioned(
            left: CatchSpacing.s5,
            bottom: CatchSpacing.s5,
            child: SafeArea(
              top: false,
              child: CatchCountPill(
                label: mapLabel,
                icon: CatchIcons.map,
                semanticLabel: mapLabel,
                onPressed: () {
                  catchSelectionHaptic();
                  context.pushNamed(Routes.exploreMapScreen.name);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildExploreChrome() {
  return const Column(
    mainAxisSize: MainAxisSize.min,
    children: [ExploreDiscoveryCoverHeader(), ExploreFilterRail()],
  );
}

Widget _buildExploreEmptyState(
  WidgetRef ref, {
  required String cityLabel,
  required bool hasSourceClubs,
  required bool hasSearch,
  required ExploreFilterSelection filters,
}) {
  final hasFilters = filters.hasActiveFilters;
  if (!hasSourceClubs) {
    return ExploreEmptyState(cityLabel: cityLabel);
  }
  if (hasSearch && hasFilters) {
    return ExploreEmptyState.noFilteredSearchResults(
      action: _clearAction(ref, clearSearch: true, clearFilters: true),
    );
  }
  if (hasSearch) {
    return ExploreEmptyState.noSearchResults(
      hasFilters: false,
      action: _clearAction(ref, clearSearch: true, clearFilters: false),
    );
  }
  if (hasFilters) {
    return ExploreEmptyState.noFilterResults(
      action: _clearAction(ref, clearSearch: false, clearFilters: true),
    );
  }
  return ExploreEmptyState(cityLabel: cityLabel);
}

Widget _clearAction(
  WidgetRef ref, {
  required bool clearSearch,
  required bool clearFilters,
}) {
  final label = switch ((clearSearch, clearFilters)) {
    (true, true) => 'Clear search and filters',
    (true, false) => 'Clear search',
    (false, true) => 'Clear filters',
    (false, false) => 'Clear',
  };
  return CatchButton(
    label: label,
    onPressed: () {
      if (clearSearch) {
        ref.read(exploreSearchQueryProvider.notifier).clear();
      }
      if (clearFilters) {
        ref.read(exploreFiltersProvider.notifier).clear();
      }
    },
    variant: CatchButtonVariant.secondary,
    icon: Icon(CatchIcons.clear),
  );
}

Widget _buildExploreSkeletonList() {
  return Column(
    children: [
      CatchSkeleton.card(height: CatchLayout.exploreEventsSkeletonHeight),
      gapH16,
      CatchSkeleton.card(height: CatchLayout.skeletonCardCompactHeight),
      gapH12,
      CatchSkeleton.card(height: CatchLayout.skeletonCardCompactHeight),
    ],
  );
}
