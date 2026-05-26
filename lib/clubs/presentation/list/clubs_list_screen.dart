import 'dart:async';

import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/explore_feed_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_empty_state.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_filter_rail.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_list_body.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_sliver_header.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_peek_rail.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_snackbar_listener.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_map_screen.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _exploreSheetPeekSize = 0.16;
const double _exploreSheetHalfSize = 0.55;
const double _exploreSheetFullSize = 0.92;

/// Explore screen — multi-modal discovery surface.
///
/// Three snap states share one canvas:
/// * FULL  — event feed with editorial hero + day sections + clubs avatar rail.
/// * HALF  — map visible above, event feed inside the sheet (no chrome
///           duplication; the top bar lives above the map).
/// * PEEK  — map dominant, peek rail in the sheet.
///
/// The persistent top chrome (city + headline + search + filter rail) lives
/// in the [Scaffold] body *above* the map, not inside the sheet — so the
/// filter row is always visible regardless of snap state, and the sheet body
/// contains only the relevant content per snap.
class ClubsListScreen extends ConsumerStatefulWidget {
  const ClubsListScreen({super.key, this.enableEventMapNetworkTiles = true});

  final bool enableEventMapNetworkTiles;

  @override
  ConsumerState<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends ConsumerState<ClubsListScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  double _sheetSize = _exploreSheetFullSize;
  String? _selectedMapEventId;

  bool get _isFull => _sheetSize >= _exploreSheetFullSize - 0.02;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_handleSheetSizeChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_handleSheetSizeChanged);
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final feedAsync = ref.watch(exploreFeedViewModelProvider);
    final feedCount = feedAsync.asData?.value.count;
    final mapLabel = feedCount == null || feedCount == 0
        ? 'Map'
        : 'Map · $feedCount';
    final exploreMapViewModel = feedAsync.whenData(
      _mapViewModelFromExploreFeed,
    );

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ColoredBox(
              color: t.bg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _ExploreBrowseHeader(),
                  const ClubsFilterRail(),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: EventMapView(
                      enableNetworkTiles: widget.enableEventMapNetworkTiles,
                      showSheet: false,
                      viewModel: exploreMapViewModel,
                      onRetry: () =>
                          ref.invalidate(exploreFeedViewModelProvider),
                      onEventSelected: _selectMapEvent,
                    ),
                  ),
                  DraggableScrollableSheet(
                    controller: _sheetController,
                    initialChildSize: _exploreSheetFullSize,
                    minChildSize: _exploreSheetPeekSize,
                    maxChildSize: _exploreSheetFullSize,
                    snap: true,
                    snapSizes: const [
                      _exploreSheetPeekSize,
                      _exploreSheetHalfSize,
                      _exploreSheetFullSize,
                    ],
                    // Use a single, stable scrollable across all snap
                    // states. Previously this builder swapped between
                    // `ExplorePeekRail` and `_ExploreSheetFeed` based on
                    // `_isPeek`, which detached the sheet's scroll
                    // controller from one scrollable and re-attached it to
                    // another mid-gesture — the sheet would jitter or
                    // stall when the user dragged up from PEEK. The
                    // "events near you" rail now lives as the top sliver
                    // of the feed, so the experience at PEEK is
                    // unchanged but the drag-up to HALF/FULL is smooth.
                    builder: (context, scrollController) {
                      return _ExploreSheetSurface(
                        showShadow: !_isFull,
                        child: _ExploreSheetFeed(
                          scrollController: scrollController,
                          selectedEventId: _selectedMapEventId,
                          onPeekEventTapped: _selectMapEvent,
                          onSeeAll: _showList,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: CatchSpacing.s5,
                    bottom: CatchSpacing.s5,
                    child: SafeArea(
                      top: false,
                      child: _ExploreSnapToggle(
                        mapLabel: mapLabel,
                        isFull: _isFull,
                        onShowMap: _showMap,
                        onShowList: _showList,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMap() {
    HapticFeedback.selectionClick();
    _snapTo(_exploreSheetHalfSize);
  }

  void _showList() {
    HapticFeedback.selectionClick();
    _snapTo(_exploreSheetFullSize);
  }

  void _selectMapEvent(Event event) {
    HapticFeedback.selectionClick();
    setState(() => _selectedMapEventId = event.id);
    _snapTo(_exploreSheetPeekSize);
  }

  void _snapTo(double size) {
    if (!_sheetController.isAttached) return;
    unawaited(
      _sheetController.animateTo(
        size,
        duration: CatchMotion.base,
        curve: CatchMotion.springCurve,
      ),
    );
  }

  void _handleSheetSizeChanged() {
    if (!_sheetController.isAttached) return;
    final nextSize = _sheetController.size;
    if ((nextSize - _sheetSize).abs() < 0.005) return;
    setState(() => _sheetSize = nextSize);
  }
}

class _ExploreBrowseHeader extends StatelessWidget {
  const _ExploreBrowseHeader();

  @override
  Widget build(BuildContext context) {
    return const ClubsBrowseHeaderContent();
  }
}

class _ExploreSheetSurface extends StatelessWidget {
  const _ExploreSheetSurface({required this.child, required this.showShadow});

  final Widget child;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return AnimatedContainer(
      duration: CatchMotion.fast,
      curve: CatchMotion.standardCurve,
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(CatchRadius.lg),
        ),
        border: Border.all(color: t.line),
        boxShadow: showShadow ? CatchElevation.raised : CatchElevation.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const _ExploreSheetHandle(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ExploreSheetHandle extends StatelessWidget {
  const _ExploreSheetHandle();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        top: CatchSpacing.s2,
        bottom: CatchSpacing.s1,
      ),
      child: Center(
        child: Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: t.line2,
            borderRadius: BorderRadius.circular(CatchRadius.pill),
          ),
        ),
      ),
    );
  }
}

class _ExploreSheetFeed extends ConsumerWidget {
  const _ExploreSheetFeed({
    required this.scrollController,
    required this.selectedEventId,
    required this.onPeekEventTapped,
    required this.onSeeAll,
  });

  final ScrollController scrollController;
  final String? selectedEventId;
  final ValueChanged<Event> onPeekEventTapped;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(clubsListViewModelProvider);
    final city = ref.watch(selectedClubCityProvider);
    final query = ref.watch(clubSearchQueryProvider).trim();
    final filters = ref.watch(clubBrowseFiltersProvider);
    final sourceClubCount =
        ref
            .watch(watchClubsByLocationProvider(city.name))
            .asData
            ?.value
            .length ??
        0;
    final hasSourceClubs = sourceClubCount > 0;

    // "Events near you" sliver — always present at the top so the PEEK
    // snap shows it naturally. Falls back to its own loading/empty handling.
    final nearbySlivers = buildExploreNearbySlivers(
      ref: ref,
      selectedEventId: selectedEventId,
      onEventTapped: onPeekEventTapped,
      onSeeAll: onSeeAll,
    );

    final bodySlivers = switch (viewModelAsync) {
      AsyncLoading() => const <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              CatchSpacing.s4,
              CatchSpacing.s5,
              CatchSpacing.s6,
            ),
            child: _SheetSkeletonList(),
          ),
        ),
      ],
      AsyncError(:final error) => [
        CatchSliverErrorState.fromError(
          error,
          context: AppErrorContext.club,
          onRetry: () {
            ref.invalidate(clubsListViewModelProvider);
            ref.invalidate(watchClubsByLocationProvider(city.name));
          },
        ),
      ],
      AsyncData(:final value) =>
        value.isEmpty
            ? [
                SliverFillRemaining(
                  child: _buildSheetEmptyState(
                    ref,
                    cityLabel: city.label,
                    hasSourceClubs: hasSourceClubs,
                    hasSearch: query.isNotEmpty,
                    filters: filters,
                  ),
                ),
              ]
            : buildClubsListBodySlivers(
                context: context,
                ref: ref,
                viewModel: value,
              ),
    };

    return MutationErrorSnackbarListener(
      mutation: ClubMembershipController.joinMutation,
      child: CustomScrollView(
        key: const ValueKey('explore-list-scroll-view'),
        controller: scrollController,
        // Sheet content is constrained to the sheet's visible height; the
        // default viewport cache extent (250 px) is small enough that the
        // club-directory cards below the events feed never build until the
        // user scrolls. A generous cache extent keeps them in the widget
        // tree so semantic lookups and screen-reader navigation work
        // straight away.
        cacheExtent: 1600,
        slivers: [...nearbySlivers, ...bodySlivers],
      ),
    );
  }
}

Widget _buildSheetEmptyState(
  WidgetRef ref, {
  required String cityLabel,
  required bool hasSourceClubs,
  required bool hasSearch,
  required ClubBrowseFilterSelection filters,
}) {
  final hasFilters = filters.hasActiveFilters;
  if (!hasSourceClubs) {
    return ClubsEmptyState(cityLabel: cityLabel);
  }
  if (hasSearch && hasFilters) {
    return ClubsEmptyState.noFilteredSearchResults(
      action: _clearAction(ref, clearSearch: true, clearFilters: true),
    );
  }
  if (hasSearch) {
    return ClubsEmptyState.noSearchResults(
      hasFilters: false,
      action: _clearAction(ref, clearSearch: true, clearFilters: false),
    );
  }
  if (hasFilters) {
    return ClubsEmptyState.noFilterResults(
      action: _clearAction(ref, clearSearch: false, clearFilters: true),
    );
  }
  return ClubsEmptyState(cityLabel: cityLabel);
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
        ref.read(clubSearchQueryProvider.notifier).clear();
      }
      if (clearFilters) {
        ref.read(clubBrowseFiltersProvider.notifier).clear();
      }
    },
    variant: CatchButtonVariant.secondary,
    icon: const Icon(Icons.close_rounded),
  );
}

class _SheetSkeletonList extends StatelessWidget {
  const _SheetSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CatchSkeleton.card(height: 160),
        gapH16,
        CatchSkeleton.card(height: 96),
        gapH12,
        CatchSkeleton.card(height: 96),
      ],
    );
  }
}

class _ExploreSnapToggle extends StatelessWidget {
  const _ExploreSnapToggle({
    required this.mapLabel,
    required this.isFull,
    required this.onShowMap,
    required this.onShowList,
  });

  final String mapLabel;
  final bool isFull;
  final VoidCallback onShowMap;
  final VoidCallback onShowList;

  @override
  Widget build(BuildContext context) {
    final showMap = isFull;
    return _FloatingActionPill(
      label: showMap ? mapLabel : 'List',
      icon: showMap ? CatchIcons.map : CatchIcons.list,
      onPressed: showMap ? onShowMap : onShowList,
    );
  }
}

class _FloatingActionPill extends StatelessWidget {
  const _FloatingActionPill({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      radius: CatchRadius.pill,
      elevation: CatchSurfaceElevation.raised,
      backgroundColor: t.surface,
      borderColor: t.line2,
      padding: EdgeInsets.zero,
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s4,
          vertical: CatchSpacing.s3,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: t.ink),
            gapW8,
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: t.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

EventMapViewModel _mapViewModelFromExploreFeed(ExploreFeedViewModel feed) {
  final items = [
    for (final item in feed.items)
      EventMapItem(
        event: item.event,
        status: item.status,
        clubName: item.club.name,
      ),
  ]..sort((a, b) => a.event.startTime.compareTo(b.event.startTime));
  final pinnedItems = items
      .where((item) => hasEventMapPin(item.event))
      .toList(growable: false);

  return EventMapViewModel(
    events: List.unmodifiable(items.map((item) => item.event)),
    pinnedEvents: List.unmodifiable(pinnedItems.map((item) => item.event)),
    items: List.unmodifiable(items),
    pinnedItems: List.unmodifiable(pinnedItems),
  );
}
