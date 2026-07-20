import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_count_pill.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/explore/presentation/explore_city_controller.dart';
import 'package:catch_dating_app/explore/presentation/explore_discovery_window_controller.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_body.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_city_picker.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_filter_rail.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_header.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Explore — the supply-side feed (design-system Explore).
///
/// A single scrolling feed: the browse header (city + search) and filter rail
/// sit above day-grouped event tickets, club polaroids, and the editorial
/// spotlight. The map is no longer an always-on canvas — it is a focused route
/// reached from the centered floating map pill ([ExploreMapScreen]).
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  bool _searchRequested = false;
  bool? _wasExploreTabActive;
  bool _reentryRefreshQueued = false;
  bool _guestJoinedFilterResetQueued = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final activeIndex = AppShellActiveTab.maybeIndexOf(context);
    if (activeIndex == null) return;
    final isActive = activeIndex == appShellClubsTabIndex;
    final shouldRefresh = _wasExploreTabActive == false && isActive;
    _wasExploreTabActive = isActive;
    if (!shouldRefresh || _reentryRefreshQueued) return;
    _reentryRefreshQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reentryRefreshQueued = false;
      if (!mounted) return;
      unawaited(_refreshExploreData());
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final uidAsync = ref.watch(uidProvider);
    final feedAsync = ref.watch(exploreFeedViewModelProvider);
    final recommendationsAsync = ref.watch(exploreRecommendationsProvider);
    final viewModelAsync = ref.watch(exploreClubsViewModelProvider);
    ref.watch(exploreCityControllerProvider);
    final city = ref.watch(selectedExploreCityProvider);
    final cityListAsync = ref.watch(cityListProvider);
    final cityOptions = cityListAsync.asData?.value ?? const <CityData>[];
    final cityPickerState = ExploreCityPickerState.from(
      selectedCity: city,
      cities: cityOptions,
      cityListLoading: cityListAsync.isLoading && cityOptions.isEmpty,
      cityListError: cityListAsync.hasError ? cityListAsync.error : null,
    );
    final query = ref.watch(exploreSearchQueryProvider).trim();
    final filters = ref.watch(exploreFiltersProvider);
    final uidData = uidAsync.asData;
    final showAccountControls = uidData?.value != null;
    if (uidData?.value == null && uidData != null && filters.joinedOnly) {
      _scheduleGuestJoinedFilterReset();
    }
    final visibleFilters = showAccountControls
        ? filters
        : filters.copyWith(joinedOnly: false);
    final sourceClubsAsync = ref.watch(exploreSourceClubsProvider);
    final sourceClubs = sourceClubsAsync.asData?.value ?? const [];
    final hasSourceClubs = sourceClubs.isNotEmpty;
    final featuredItem = feedAsync.asData?.value.featuredItem;
    final showFeaturedCover =
        featuredItem != null && !_searchRequested && query.isEmpty;
    final filterRailState = ExploreFilterRailState.from(
      visibleFilters,
      l10n: context.l10n,
    );
    final dateStripState = ExploreDateStripState.from(
      viewModel: feedAsync.asData?.value,
      l10n: context.l10n,
      now: ref.watch(exploreDiscoveryReferenceNowProvider),
    );
    final filterSheetState = ExploreFilterSheetState.from(
      filters: visibleFilters,
      sourceClubs: sourceClubs,
      l10n: context.l10n,
      viewModel: feedAsync.asData?.value,
      feedLoading: feedAsync.isLoading,
    );
    final screenState = ExploreDiscoveryScreenState.from(
      l10n: context.l10n,
      cityLabel: city.label,
      query: query,
      filters: visibleFilters,
      hasSourceClubs: hasSourceClubs,
      mappableEventCount: feedAsync.asData?.value.mappableEventCount,
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
              AnalyticsParameters.exploreSource:
                  context.l10n.exploreExploreScreenVisiblecopyCoverHeader,
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
              AnalyticsParameters.exploreSource:
                  context.l10n.exploreExploreScreenVisiblecopyExternalSupply,
              AnalyticsParameters.activityKind: item.event.activityKind.name,
              AnalyticsParameters.availabilityStatus:
                  context.l10n.exploreExploreScreenVisiblecopyExternalOutbound,
              context.l10n.exploreExploreScreenVisiblecopyExternalPlatform:
                  item.event.platformLabel,
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

    void openExploreFilters() {
      unawaited(
        showCatchBottomSheet<void>(
          context: context,
          builder: (_) => Consumer(
            builder: (sheetContext, ref, _) {
              final liveFilters = ref.watch(exploreFiltersProvider);
              final liveFeed = ref.watch(exploreFeedViewModelProvider);
              final liveUidData = ref.watch(uidProvider).asData;
              final showJoinedOnly = liveUidData?.value != null;
              final visibleLiveFilters = showJoinedOnly
                  ? liveFilters
                  : liveFilters.copyWith(joinedOnly: false);
              return ExploreFilterSheet(
                filters: visibleLiveFilters,
                state: filterSheetState.withLiveResults(
                  filters: visibleLiveFilters,
                  viewModel: liveFeed.asData?.value,
                  feedLoading: liveFeed.isLoading,
                  l10n: sheetContext.l10n,
                ),
                onDistanceFilterSelected: (filter) =>
                    unawaited(_applyDistanceFilter(filter)),
                onToggleJoinedOnly: showJoinedOnly
                    ? () => ref
                          .read(exploreFiltersProvider.notifier)
                          .toggleJoinedOnly()
                    : null,
                onToggleHighRatedOnly: () => ref
                    .read(exploreFiltersProvider.notifier)
                    .toggleHighRatedOnly(),
                onToggleActivityTag: (tag) => ref
                    .read(exploreFiltersProvider.notifier)
                    .toggleActivityTag(tag),
                onToggleArea: (area) =>
                    ref.read(exploreFiltersProvider.notifier).toggleArea(area),
                onClearFilters: () =>
                    ref.read(exploreFiltersProvider.notifier).clear(),
                showJoinedOnly: showJoinedOnly,
              );
            },
          ),
        ),
      );
    }

    Widget savedEventsAction({bool onDarkBackdrop = false}) {
      return CatchIconAction(
        icon: CatchIcons.bookmarkBorderRounded,
        tooltip: context.l10n.exploreExploreScreenTooltipSavedEvents,
        onPressed: () => context.push(Routes.savedEventsScreen.path),
        variant: onDarkBackdrop
            ? CatchIconButtonVariant.plain
            : CatchIconButtonVariant.bordered,
        backgroundColor: onDarkBackdrop ? Colors.transparent : null,
        foregroundColor: onDarkBackdrop ? CatchTokens.dark.ink : null,
      );
    }

    final bodySlivers = switch (bodyState.kind) {
      ExploreScreenBodyKind.loading => <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: CatchInsets.pageBody.copyWith(bottom: 0),
            child: const ExploreSkeletonList(),
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
        recommendationsAsync: recommendationsAsync,
        clubsViewModel: bodyState.viewModel,
        filters: visibleFilters,
        searchQuery: query,
        onRetryFeed: () => ref.invalidate(exploreFeedViewModelProvider),
        onRetryClubs: () => retryBodyState(ExploreScreenRetryTarget.explore),
        onClearSearch: () =>
            ref.read(exploreSearchQueryProvider.notifier).clear(),
        onClearFilters: () => ref.read(exploreFiltersProvider.notifier).clear(),
        onLoadMore: () => unawaited(_loadMore(feedAsync.asData?.value)),
        onSetTimeFilter: (filter) =>
            ref.read(exploreFiltersProvider.notifier).setTimeFilter(filter),
        onActivitySelected: (activityKind) => ref
            .read(exploreFiltersProvider.notifier)
            .toggleActivityTag(activityKind.name),
        onEventSelected: openEvent,
        onExternalEventOpened: openExternalEvent,
        onClubSelected: openClub,
        promoteFeaturedItem: showFeaturedCover,
      ),
      ExploreScreenBodyKind.contentWithoutClubs => buildExploreBodySlivers(
        context: context,
        feedAsync: feedAsync,
        recommendationsAsync: recommendationsAsync,
        filters: visibleFilters,
        searchQuery: query,
        clubSectionError: bodyState.error,
        onRetryFeed: () => ref.invalidate(exploreFeedViewModelProvider),
        onRetryClubs: () => retryBodyState(bodyState.retryTarget),
        onClearSearch: () =>
            ref.read(exploreSearchQueryProvider.notifier).clear(),
        onClearFilters: () => ref.read(exploreFiltersProvider.notifier).clear(),
        onLoadMore: () => unawaited(_loadMore(feedAsync.asData?.value)),
        onSetTimeFilter: (filter) =>
            ref.read(exploreFiltersProvider.notifier).setTimeFilter(filter),
        onActivitySelected: (activityKind) => ref
            .read(exploreFiltersProvider.notifier)
            .toggleActivityTag(activityKind.name),
        onEventSelected: openEvent,
        onExternalEventOpened: openExternalEvent,
        onClubSelected: openClub,
        promoteFeaturedItem: showFeaturedCover,
      ),
      ExploreScreenBodyKind.empty => [
        CatchSliverStateViewport(
          child: ExploreScreenEmptyState(
            state: bodyState.emptyState!,
            onClearSearch: () =>
                ref.read(exploreSearchQueryProvider.notifier).clear(),
            onClearFilters: () =>
                ref.read(exploreFiltersProvider.notifier).clear(),
            onChangeCity: cityPickerState.enabled
                ? () => unawaited(
                    showExploreCityPickerSheet(
                      context: context,
                      state: cityPickerState,
                      onSelected: (selectedCity) => ref
                          .read(selectedExploreCityProvider.notifier)
                          .setCity(selectedCity),
                    ),
                  )
                : null,
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
            child: RefreshIndicator.adaptive(
              onRefresh: _refreshExploreData,
              child: CustomScrollView(
                key: ValueKey(
                  context.l10n.exploreExploreScreenBodyExploreListScrollView,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: ExploreDiscoveryCoverHeader(
                      cityPickerState: cityPickerState,
                      query: query,
                      featuredItem: featuredItem,
                      onCitySelected: (selectedCity) => ref
                          .read(selectedExploreCityProvider.notifier)
                          .setCity(selectedCity),
                      onQueryChanged: (value) => ref
                          .read(exploreSearchQueryProvider.notifier)
                          .setQuery(value),
                      actions: showAccountControls
                          ? [savedEventsAction()]
                          : const [],
                      heroActions: showAccountControls
                          ? [savedEventsAction(onDarkBackdrop: true)]
                          : const [],
                      searchRequested: _searchRequested,
                      onSearchRequestedChanged: (expanded) {
                        if (_searchRequested == expanded) return;
                        setState(() => _searchRequested = expanded);
                      },
                      onFeaturedEventSelected: openFeaturedEvent,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ExploreFilterRail(
                      filters: visibleFilters,
                      state: filterRailState,
                      dateStripState: dateStripState,
                      sheetState: filterSheetState,
                      onTimeFilterSelected: (filter) => ref
                          .read(exploreFiltersProvider.notifier)
                          .setTimeFilter(filter),
                      onDistanceFilterSelected: (filter) =>
                          unawaited(_applyDistanceFilter(filter)),
                      onToggleJoinedOnly: showAccountControls
                          ? () => ref
                                .read(exploreFiltersProvider.notifier)
                                .toggleJoinedOnly()
                          : null,
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
                      onOpenFilters: openExploreFilters,
                      showJoinedOnly: showAccountControls,
                    ),
                  ),
                  ...bodySlivers,
                  const CatchSliverTerminalPadding(),
                ],
              ),
            ),
          ),
          if (screenState.mapLauncherState.isVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: _mapLauncherBottomOffset(context),
              child: SafeArea(
                top: false,
                child: Center(
                  child: CatchCountPill.label(
                    label: screenState.mapLauncherState.actionLabel,
                    count:
                        int.tryParse(
                          screenState.mapLauncherState.countLabel ?? '',
                        ) ??
                        0,
                    icon: CatchIcons.map,
                    semanticLabel: screenState.mapLauncherState.semanticLabel,
                    onPressed: () {
                      catchTransitionHaptic();
                      context.pushNamed(Routes.exploreMapScreen.name);
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _applyDistanceFilter(ExploreDistanceFilter filter) async {
    final failure = await ref
        .read(exploreFiltersProvider.notifier)
        .applyDistanceFilter(filter);
    if (!mounted || failure == null) return;
    _showLocationFailure(failure);
  }

  void _scheduleGuestJoinedFilterReset() {
    if (_guestJoinedFilterResetQueued) return;
    _guestJoinedFilterResetQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _guestJoinedFilterResetQueued = false;
      if (!mounted) return;
      final uidData = ref.read(uidProvider).asData;
      if (uidData == null || uidData.value != null) return;
      final filters = ref.read(exploreFiltersProvider);
      if (!filters.joinedOnly) return;
      ref.read(exploreFiltersProvider.notifier).toggleJoinedOnly();
    });
  }

  Future<void> _refreshExploreData() async {
    ref.invalidate(exploreDiscoveryReferenceNowProvider);
    ref.invalidate(exploreDiscoveryWindowProvider);
    ref.invalidate(watchClubsByLocationProvider);
    ref.invalidate(exploreSourceClubsProvider);
    ref.invalidate(exploreClubsViewModelProvider);
    ref.invalidate(exploreFeedViewModelProvider);
    ref.invalidate(exploreRecommendationsProvider);

    // The feed provider is a synchronous AsyncValue composition over several
    // async repositories, so it has no `.future` to await. Hold the refresh
    // indicator until the recomposed feed reaches either data or error.
    for (var attempt = 0; attempt < 200; attempt += 1) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      if (!ref.read(exploreFeedViewModelProvider).isLoading) return;
    }
  }

  Future<void> _loadMore(ExploreFeedViewModel? feed) async {
    final request = feed?.windowRequest;
    if (request == null || feed?.hasMore != true || feed!.isLoadingMore) return;
    try {
      await ref
          .read(exploreDiscoveryWindowProvider(request).notifier)
          .loadNext();
    } catch (error) {
      if (!mounted) return;
      showCatchErrorSnackBar(
        context,
        error,
        errorContext: AppErrorContext.explore,
        onRetry: () => unawaited(_loadMore(feed)),
      );
    }
  }

  void _showLocationFailure(DeviceLocationFailure failure) {
    final canOpenSettings =
        failure == DeviceLocationFailure.servicesDisabled ||
        failure == DeviceLocationFailure.permissionDeniedForever;
    final message = switch (failure) {
      DeviceLocationFailure.servicesDisabled =>
        context.l10n.exploreExploreMapScreenMessageLocationServicesDisabled,
      DeviceLocationFailure.permissionDeniedForever =>
        context
            .l10n
            .exploreExploreMapScreenMessageLocationPermissionDeniedForever,
      _ => context.l10n.exploreExploreMapScreenMessageLocationUnavailable,
    };
    showCatchSnackBar(
      context,
      message,
      action: canOpenSettings
          ? SnackBarAction(
              label: context.l10n.exploreExploreMapScreenActionOpenSettings,
              onPressed: () {
                unawaited(
                  ref
                      .read(deviceLocationProvider.notifier)
                      .openRecoverySettings(),
                );
              },
            )
          : null,
    );
  }
}

double _mapLauncherBottomOffset(BuildContext context) {
  return AppShellActiveTab.bottomOverlayClearanceOf(
    context,
    minimum: CatchSpacing.s5,
  );
}

class ExploreScreenEmptyState extends StatelessWidget {
  const ExploreScreenEmptyState({
    super.key,
    required this.state,
    this.onClearSearch,
    this.onClearFilters,
    this.onChangeCity,
  });

  final ExploreDiscoveryEmptyState state;
  final VoidCallback? onClearSearch;
  final VoidCallback? onClearFilters;
  final VoidCallback? onChangeCity;

  @override
  Widget build(BuildContext context) {
    final action = state.action == ExploreDiscoveryEmptyAction.none
        ? null
        : ExploreClearAction(
            clearSearch: state.clearSearch,
            clearFilters: state.clearFilters,
            onClearSearch: onClearSearch,
            onClearFilters: onClearFilters,
          );
    return switch (state.kind) {
      ExploreDiscoveryEmptyKind.noSourceClubs => Center(
        child: Padding(
          padding: CatchInsets.contentRelaxed,
          child: CatchEmptyState(
            icon: CatchIcons.groupsOutlined,
            title: context.l10n.exploreExploreScreenTitleNoClubsInCitylabel(
              cityLabel: state.cityLabel,
            ),
            message: context.l10n.exploreExploreScreenMessageTryAnotherCityFrom,
            action: CatchButton(
              label: context.l10n.exploreExploreScreenLabelChangeCity,
              icon: Icon(CatchIcons.locationOnOutlined),
              onPressed: onChangeCity,
            ),
          ),
        ),
      ),
      ExploreDiscoveryEmptyKind.noFilteredSearchResults => Center(
        child: Padding(
          padding: CatchInsets.contentRelaxed,
          child: CatchEmptyState(
            icon: CatchIcons.groupsOutlined,
            title: context.l10n.exploreExploreScreenTitleNoClubsMatchThis,
            message: context.l10n.exploreExploreScreenMessageClearTheSearchOr,
            action: action,
          ),
        ),
      ),
      ExploreDiscoveryEmptyKind.noSearchResults => Center(
        child: Padding(
          padding: CatchInsets.contentRelaxed,
          child: CatchEmptyState(
            icon: CatchIcons.groupsOutlined,
            title: context.l10n.exploreExploreScreenTitleNoClubsMatchThis,
            message: context
                .l10n
                .exploreExploreScreenMessageTryAnotherClubNeighborhood,
            action: action,
          ),
        ),
      ),
      ExploreDiscoveryEmptyKind.noFilterResults => Center(
        child: Padding(
          padding: CatchInsets.contentRelaxed,
          child: CatchEmptyState(
            icon: CatchIcons.groupsOutlined,
            title: context.l10n.exploreExploreScreenTitleNoClubsMatchThese,
            message: context.l10n.exploreExploreScreenMessageClearOneOrMore,
            action: action,
          ),
        ),
      ),
    };
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
      (true, true) =>
        context.l10n.exploreExploreScreenLabelClearSearchAndFilters,
      (true, false) => context.l10n.exploreExploreScreenLabelClearSearch,
      (false, true) => context.l10n.exploreExploreScreenLabelClearFilters,
      (false, false) => context.l10n.exploreExploreScreenLabelClear,
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
