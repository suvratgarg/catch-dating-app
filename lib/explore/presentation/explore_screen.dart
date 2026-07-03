import 'dart:async';

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_count_pill.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
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
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final feedAsync = ref.watch(exploreFeedViewModelProvider);
    final viewModelAsync = ref.watch(exploreClubsViewModelProvider);
    final city = ref.watch(selectedExploreCityProvider);
    final query = ref.watch(exploreSearchQueryProvider).trim();
    final filters = ref.watch(exploreFiltersProvider);
    final sourceClubsAsync = ref.watch(exploreSourceClubsProvider);
    final sourceClubs = sourceClubsAsync.asData?.value ?? const [];
    final hasSourceClubs = sourceClubs.isNotEmpty;
    final featuredItem = feedAsync.asData?.value.featuredItem;
    final filterRailState = ExploreFilterRailState.from(filters);
    final filterSheetState = ExploreFilterSheetState.from(
      filters: filters,
      sourceClubs: sourceClubs,
    );
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

    void retryBodyState(ExploreScreenRetryTarget? retryTarget) {
      switch (retryTarget) {
        case ExploreScreenRetryTarget.eventFeed:
          ref.invalidate(exploreFeedViewModelProvider);
        case ExploreScreenRetryTarget.explore:
        case null:
          ref.invalidate(exploreClubsViewModelProvider);
          ref.invalidate(exploreSourceClubsProvider);
      }
    }

    void openFeaturedEvent(ExploreEventItem item) {
      ref
          .read(appAnalyticsProvider)
          .logEvent(
            AnalyticsEvents.exploreEventOpened,
            parameters: {
              AnalyticsParameters.eventId: item.event.id,
              AnalyticsParameters.clubId: item.event.clubId,
              AnalyticsParameters.exploreSource: 'cover_header',
            },
          );
      context.pushNamed(
        Routes.eventDetailScreen.name,
        pathParameters: {'clubId': item.event.clubId, 'eventId': item.event.id},
        extra: EventDetailRouteExtra(
          initialEvent: item.event,
          presentationMode: EventDetailPresentationMode.spotlightDark,
        ),
      );
    }

    void openEvent(ExploreEventItem item, String source) {
      ref
          .read(appAnalyticsProvider)
          .logEvent(
            AnalyticsEvents.exploreEventOpened,
            parameters: {
              AnalyticsParameters.eventId: item.event.id,
              AnalyticsParameters.clubId: item.club.id,
              AnalyticsParameters.exploreSource: source,
              AnalyticsParameters.activityKind: item.event.activityKind.name,
              AnalyticsParameters.availabilityStatus:
                  item.availability?.status.name,
              AnalyticsParameters.distanceKm: item.distanceFromUserKm == null
                  ? null
                  : double.parse(item.distanceFromUserKm!.toStringAsFixed(2)),
            },
          );
      context.pushNamed(
        Routes.eventDetailScreen.name,
        pathParameters: {'clubId': item.event.clubId, 'eventId': item.event.id},
        extra: EventDetailRouteExtra(
          initialEvent: item.event,
          transition: EventDetailRouteTransition.ticketCard,
          presentationMode: EventDetailPresentationMode.ticket,
          heroTag: eventTicketHeroTag(item.event.id, source),
        ),
      );
    }

    void openExternalEvent(ExploreExternalEventItem item) {
      final uri = item.event.primaryExternalUri;
      if (uri == null) return;
      ref
          .read(appAnalyticsProvider)
          .logEvent(
            AnalyticsEvents.exploreEventOpened,
            parameters: {
              AnalyticsParameters.eventId: item.event.id,
              AnalyticsParameters.exploreSource: 'external_supply',
              AnalyticsParameters.activityKind: item.event.activityKind.name,
              AnalyticsParameters.availabilityStatus: 'external_outbound',
              'external_platform': item.event.platformLabel,
              AnalyticsParameters.distanceKm: item.distanceFromUserKm == null
                  ? null
                  : double.parse(item.distanceFromUserKm!.toStringAsFixed(2)),
            },
          );
      unawaited(ref.read(externalLinkControllerProvider).openExternal(uri));
    }

    void openClub(Club club) {
      context.pushNamed(
        Routes.clubDetailScreen.name,
        pathParameters: {'clubId': club.id},
        extra: club,
      );
    }

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
          onRetry: () => retryBodyState(bodyState.retryTarget),
        ),
      ],
      ExploreScreenBodyKind.content => buildExploreBodySlivers(
        context: context,
        feedAsync: feedAsync,
        clubsViewModel: bodyState.viewModel,
        filters: filters,
        searchQuery: query,
        onRetryFeed: () => ref.invalidate(exploreFeedViewModelProvider),
        onRetryClubs: () => retryBodyState(ExploreScreenRetryTarget.explore),
        onClearSearch: () =>
            ref.read(exploreSearchQueryProvider.notifier).clear(),
        onClearFilters: () => ref.read(exploreFiltersProvider.notifier).clear(),
        onSetTimeFilter: (filter) =>
            ref.read(exploreFiltersProvider.notifier).setTimeFilter(filter),
        onActivitySelected: (activityKind) => ref
            .read(exploreFiltersProvider.notifier)
            .toggleActivityTag(activityKind.name),
        onEventSelected: openEvent,
        onExternalEventOpened: openExternalEvent,
        onClubSelected: openClub,
        includeJoinedClubsRail: false,
        includeClubDirectory: false,
      ),
      ExploreScreenBodyKind.contentWithoutClubs => buildExploreBodySlivers(
        context: context,
        feedAsync: feedAsync,
        filters: filters,
        searchQuery: query,
        clubSectionError: bodyState.error,
        onRetryFeed: () => ref.invalidate(exploreFeedViewModelProvider),
        onRetryClubs: () => retryBodyState(bodyState.retryTarget),
        onClearSearch: () =>
            ref.read(exploreSearchQueryProvider.notifier).clear(),
        onClearFilters: () => ref.read(exploreFiltersProvider.notifier).clear(),
        onSetTimeFilter: (filter) =>
            ref.read(exploreFiltersProvider.notifier).setTimeFilter(filter),
        onActivitySelected: (activityKind) => ref
            .read(exploreFiltersProvider.notifier)
            .toggleActivityTag(activityKind.name),
        onEventSelected: openEvent,
        onExternalEventOpened: openExternalEvent,
        onClubSelected: openClub,
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
                SliverToBoxAdapter(
                  child: ExploreChrome(
                    query: query,
                    featuredItem: featuredItem,
                    filters: filters,
                    filterRailState: filterRailState,
                    filterSheetState: filterSheetState,
                    onQueryChanged: (value) => ref
                        .read(exploreSearchQueryProvider.notifier)
                        .setQuery(value),
                    onFeaturedEventSelected: openFeaturedEvent,
                    onTimeFilterSelected: (filter) => ref
                        .read(exploreFiltersProvider.notifier)
                        .setTimeFilter(filter),
                    onDistanceFilterSelected: (filter) => ref
                        .read(exploreFiltersProvider.notifier)
                        .setDistanceFilter(filter),
                    onToggleJoinedOnly: () => ref
                        .read(exploreFiltersProvider.notifier)
                        .toggleJoinedOnly(),
                    onToggleHighRatedOnly: () => ref
                        .read(exploreFiltersProvider.notifier)
                        .toggleHighRatedOnly(),
                    onToggleActivityTag: (tag) => ref
                        .read(exploreFiltersProvider.notifier)
                        .toggleActivityTag(tag),
                    onToggleArea: (area) => ref
                        .read(exploreFiltersProvider.notifier)
                        .toggleArea(area),
                    onClearFilters: () =>
                        ref.read(exploreFiltersProvider.notifier).clear(),
                  ),
                ),
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
}

class ExploreChrome extends StatelessWidget {
  const ExploreChrome({
    super.key,
    required this.query,
    required this.featuredItem,
    required this.filters,
    required this.filterRailState,
    required this.filterSheetState,
    required this.onQueryChanged,
    required this.onFeaturedEventSelected,
    required this.onTimeFilterSelected,
    required this.onDistanceFilterSelected,
    required this.onToggleJoinedOnly,
    required this.onToggleHighRatedOnly,
    required this.onToggleActivityTag,
    required this.onToggleArea,
    required this.onClearFilters,
  });

  final String query;
  final ExploreEventItem? featuredItem;
  final ExploreFilterSelection filters;
  final ExploreFilterRailState filterRailState;
  final ExploreFilterSheetState filterSheetState;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ExploreEventItem> onFeaturedEventSelected;
  final ValueChanged<ExploreTimeFilter> onTimeFilterSelected;
  final ValueChanged<ExploreDistanceFilter> onDistanceFilterSelected;
  final VoidCallback onToggleJoinedOnly;
  final VoidCallback onToggleHighRatedOnly;
  final ValueChanged<String> onToggleActivityTag;
  final ValueChanged<String> onToggleArea;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExploreDiscoveryCoverHeader(
          query: query,
          featuredItem: featuredItem,
          onQueryChanged: onQueryChanged,
          onFeaturedEventSelected: onFeaturedEventSelected,
        ),
        ExploreFilterRail(
          filters: filters,
          state: filterRailState,
          sheetState: filterSheetState,
          onTimeFilterSelected: onTimeFilterSelected,
          onDistanceFilterSelected: onDistanceFilterSelected,
          onToggleJoinedOnly: onToggleJoinedOnly,
          onToggleHighRatedOnly: onToggleHighRatedOnly,
          onToggleActivityTag: onToggleActivityTag,
          onToggleArea: onToggleArea,
          onClearFilters: onClearFilters,
        ),
      ],
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
