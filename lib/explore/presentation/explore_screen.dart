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
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
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
    final feedAsync = ref.watch(exploreFeedViewModelProvider);
    final viewModelAsync = ref.watch(exploreViewModelProvider);
    final city = ref.watch(selectedExploreCityProvider);
    final query = ref.watch(exploreSearchQueryProvider).trim();
    final filters = ref.watch(exploreFiltersProvider);
    final hasSourceClubs =
        (ref.watch(exploreSourceClubsProvider).asData?.value.length ?? 0) > 0;
    final screenState = ExploreDiscoveryScreenState.from(
      cityLabel: city.label,
      query: query,
      filters: filters,
      hasSourceClubs: hasSourceClubs,
      eventFeedCount: feedAsync.asData?.value.count,
      viewModelLoading: viewModelAsync.isLoading,
      viewModelError: viewModelAsync.hasError ? viewModelAsync.error : null,
      viewModel: viewModelAsync.asData?.value,
      eventFeedLoading: feedAsync.isLoading,
      eventFeedError: feedAsync.hasError ? feedAsync.error : null,
      eventFeedHasContent: feedAsync.asData?.value.isEmpty == false,
    );
    final bodyState = screenState.bodyState;

    final bodySlivers = switch (bodyState.kind) {
      ExploreScreenBodyKind.loading => <Widget>[
        const SliverToBoxAdapter(
          child: Padding(
            padding: CatchInsets.pageBody,
            child: ExploreSkeletonList(),
          ),
        ),
      ],
      ExploreScreenBodyKind.error => [
        CatchSliverErrorState.fromError(
          bodyState.error!,
          context: bodyState.retryTarget == ExploreScreenRetryTarget.eventFeed
              ? AppErrorContext.event
              : AppErrorContext.explore,
          onRetry: () => _retryBodyState(ref, bodyState.retryTarget),
        ),
      ],
      ExploreScreenBodyKind.content => buildExploreBodySlivers(
        context: context,
        ref: ref,
        viewModel: bodyState.viewModel!,
        includeJoinedClubsRail: false,
        includeClubDirectory: false,
      ),
      ExploreScreenBodyKind.empty => [
        SliverFillRemaining(
          child: ExploreScreenEmptyState(
            state: bodyState.emptyState!,
            onClearSearch: () =>
                ref.read(exploreSearchQueryProvider.notifier).clear(),
            onClearFilters: () =>
                ref.read(exploreFiltersProvider.notifier).clear(),
          ),
        ),
      ],
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
                const SliverToBoxAdapter(child: ExploreChrome()),
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
                label: screenState.mapLauncherState.label,
                icon: CatchIcons.map,
                semanticLabel: screenState.mapLauncherState.label,
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

  void _retryBodyState(WidgetRef ref, ExploreScreenRetryTarget? retryTarget) {
    switch (retryTarget) {
      case ExploreScreenRetryTarget.eventFeed:
        ref.invalidate(exploreFeedViewModelProvider);
      case ExploreScreenRetryTarget.explore:
      case null:
        ref.invalidate(exploreViewModelProvider);
        ref.invalidate(exploreSourceClubsProvider);
    }
  }
}

class ExploreChrome extends StatelessWidget {
  const ExploreChrome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [ExploreDiscoveryCoverHeader(), ExploreFilterRail()],
    );
  }
}

class ExploreScreenEmptyState extends StatelessWidget {
  const ExploreScreenEmptyState({
    super.key,
    required this.state,
    this.onClearSearch,
    this.onClearFilters,
  });

  final ExploreDiscoveryEmptyState state;
  final VoidCallback? onClearSearch;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final action = _actionForState();
    return switch (state.kind) {
      ExploreDiscoveryEmptyKind.noSourceClubs => ExploreEmptyState(
        cityLabel: state.cityLabel,
        action: action,
      ),
      ExploreDiscoveryEmptyKind.noFilteredSearchResults =>
        ExploreEmptyState.noFilteredSearchResults(action: action),
      ExploreDiscoveryEmptyKind.noSearchResults =>
        ExploreEmptyState.noSearchResults(hasFilters: false, action: action),
      ExploreDiscoveryEmptyKind.noFilterResults =>
        ExploreEmptyState.noFilterResults(action: action),
    };
  }

  Widget? _actionForState() {
    if (state.action == ExploreDiscoveryEmptyAction.none) return null;
    return ExploreClearAction(
      clearSearch: state.clearSearch,
      clearFilters: state.clearFilters,
      onClearSearch: onClearSearch,
      onClearFilters: onClearFilters,
    );
  }
}

class ExploreClearAction extends StatelessWidget {
  const ExploreClearAction({
    super.key,
    required this.clearSearch,
    required this.clearFilters,
    this.onClearSearch,
    this.onClearFilters,
    this.icon,
  });

  final bool clearSearch;
  final bool clearFilters;
  final VoidCallback? onClearSearch;
  final VoidCallback? onClearFilters;

  /// Optional override for the action icon. Defaults to [CatchIcons.clear].
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
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
          onClearSearch?.call();
        }
        if (clearFilters) {
          onClearFilters?.call();
        }
      },
      variant: CatchButtonVariant.secondary,
      icon: Icon(icon ?? CatchIcons.clear),
    );
  }
}

class ExploreSkeletonList extends StatelessWidget {
  const ExploreSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
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
}
