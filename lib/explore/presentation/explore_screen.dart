import 'dart:async';

import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/device_motion.dart';
import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_count_pill.dart';
import 'package:catch_dating_app/core/widgets/catch_draggable_sheet_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_map_screen.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_map_motion_reveal.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_body.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_empty_state.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_filter_rail.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_header.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_peek_rail.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _exploreSheetPeekSize = CatchLayout.exploreSheetPeekSize;
const double _exploreSheetMapSize = CatchLayout.exploreSheetMapSize;
const double _exploreSheetFullSize = CatchLayout.exploreSheetFullSize;
const double _exploreMotionRevealOvershootSize =
    CatchLayout.exploreSheetRevealOvershootSize;
const double _exploreHeaderContentHeight =
    CatchLayout.exploreHeaderContentHeight;
const double _exploreFilterRailHeight = CatchLayout.exploreFilterRailHeight;
const Duration _exploreMotionRevealDropDuration = CatchMotion.revealDrop;
const Duration _exploreMotionRevealSettleDuration = CatchMotion.revealSettle;

/// Explore screen — multi-modal discovery surface.
///
/// Three snap states share one canvas:
/// * FULL  — event feed with editorial hero + day sections + clubs avatar rail.
/// * MAP   — map visible above, with selected map events promoted into a
///           tappable event card at the top of the sheet.
/// * PEEK  — map dominant, with only a handle and aggregate result summary.
///
/// The persistent top chrome (city + headline + search + filter rail) floats
/// above the map/sheet canvas. The map stays mounted behind the surface, but
/// FULL covers the status-bar/notch area and chrome with an opaque top lid so
/// the closed feed reads as a normal page. MAP fades that lid away and
/// collapses the sheet exclusion so the map becomes truly full-bleed only once
/// it is exposed.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key, this.enableEventMapNetworkTiles = true});

  final bool enableEventMapNetworkTiles;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  double _sheetSize = _exploreSheetFullSize;
  String? _selectedMapEventId;
  LocationCoordinate? _mapCameraCenter;
  Timer? _sheetSettleTimer;
  StreamSubscription<DeviceMotionSample>? _motionRevealSubscription;
  final _motionRevealRecognizer = ExploreMapMotionRevealRecognizer();
  bool _settlingSheet = false;
  bool _motionRevealAvailable = true;

  bool get _isFull => _sheetSize >= _exploreSheetFullSize - 0.02;
  bool get _isPeek => _sheetSize <= _exploreSheetPeekSize + 0.09;
  double get _mapRevealProgress {
    final range = _exploreSheetFullSize - _exploreSheetMapSize;
    return ((_exploreSheetFullSize - _sheetSize) / range)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_handleSheetSizeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncMotionRevealListener();
    });
  }

  @override
  void dispose() {
    _sheetController.removeListener(_handleSheetSizeChanged);
    _sheetController.dispose();
    _sheetSettleTimer?.cancel();
    unawaited(_motionRevealSubscription?.cancel() ?? Future<void>.value());
    _motionRevealSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final feedAsync = ref.watch(exploreFeedViewModelProvider);
    final feedCount = feedAsync.asData?.value.count;
    final filters = ref.watch(exploreFiltersProvider);
    final distanceRingRadiusKm = exploreDistanceFilterKm(
      filters.distanceFilter,
    );
    final mapLabel = feedCount == null || feedCount == 0
        ? 'Map'
        : 'Map · $feedCount';
    final exploreMapViewModel = feedAsync.whenData(
      _mapViewModelFromExploreFeed,
    );
    final mapRevealProgress = _mapRevealProgress;
    final lidProgress = CatchMotion.easeOutCubicCurve.transform(
      mapRevealProgress,
    );
    final spacerProgress = CatchMotion.easeInOutCubicCurve.transform(
      mapRevealProgress,
    );
    final topInset = MediaQuery.paddingOf(context).top;
    final chromeHeight = topInset + _exploreChromeHeightFor(context);
    final sheetTopExclusion = chromeHeight * (1 - spacerProgress);
    final chromeLidColor = t.bg.withValues(alpha: 1 - lidProgress);

    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: EventMapView(
              enableNetworkTiles: widget.enableEventMapNetworkTiles,
              viewModel: exploreMapViewModel,
              distanceRingRadiusKm: distanceRingRadiusKm,
              onRetry: () => ref.invalidate(exploreFeedViewModelProvider),
              onEventSelected: _selectMapEvent,
              onCameraCenterChanged: _handleMapCameraCenterChanged,
              onDistanceRingTapped: _cycleDistanceFilter,
            ),
          ),
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _exploreSheetFullSize,
            minChildSize: _exploreSheetPeekSize,
            // Use a single, stable scrollable across all snap states. The
            // lead sliver changes from summary -> selected card -> nearby
            // rail, but the sheet controller remains bound to the same
            // CustomScrollView during gestures.
            builder: (context, scrollController) {
              return Padding(
                padding: EdgeInsets.only(top: sheetTopExclusion),
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: _handleSheetScrollEnd,
                  child: CatchDraggableSheetShell(
                    showShadow: lidProgress > 0.05,
                    showHandle: !_isFull,
                    handleOpacity: lidProgress,
                    topRadius: CatchRadius.lg * lidProgress,
                    child: _ExploreSheetFeed(
                      scrollController: scrollController,
                      isFull: _isFull,
                      isPeek: _isPeek,
                      selectedEventId: _selectedMapEventId,
                      mapCameraCenter: _mapCameraCenter,
                      onPeekEventTapped: _selectMapEvent,
                      onSeeAll: _showList,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ColoredBox(
              key: const ValueKey('explore-top-lid'),
              color: chromeLidColor,
              child: SafeArea(
                bottom: false,
                child: _ExploreFloatingChrome(backgroundColor: chromeLidColor),
              ),
            ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMap() {
    catchSelectionHaptic();
    _stopMotionRevealListener();
    unawaited(
      _snapTo(
        _exploreSheetMapSize,
        duration: CatchMotion.slow,
        curve: CatchMotion.easeOutCubicCurve,
      ),
    );
  }

  void _showMapFromMotionReveal() {
    _stopMotionRevealListener();
    unawaited(_snapToMapWithMomentum());
  }

  Future<void> _snapToMapWithMomentum() async {
    if (!_sheetController.isAttached || _settlingSheet) return;

    _settlingSheet = true;
    catchTransitionHaptic();
    try {
      await _snapTo(
        _exploreMotionRevealOvershootSize,
        duration: _exploreMotionRevealDropDuration,
        curve: const Cubic(0.08, 0.82, 0.14, 1.0),
      );
      if (!mounted || !_sheetController.isAttached) return;
      await _snapTo(
        _exploreSheetMapSize,
        duration: _exploreMotionRevealSettleDuration,
      );
    } finally {
      _settlingSheet = false;
    }
  }

  void _showList() {
    catchSelectionHaptic();
    if (_selectedMapEventId != null) {
      setState(() => _selectedMapEventId = null);
    }
    unawaited(_snapTo(_exploreSheetFullSize));
    _syncMotionRevealListener();
  }

  void _selectMapEvent(Event event) {
    catchSelectionHaptic();
    setState(() => _selectedMapEventId = event.id);
    unawaited(_snapTo(_exploreSheetMapSize));
  }

  void _handleMapCameraCenterChanged(LocationCoordinate center) {
    final current = _mapCameraCenter;
    if (current != null &&
        current.latitude == center.latitude &&
        current.longitude == center.longitude) {
      return;
    }
    setState(() => _mapCameraCenter = center);
  }

  void _cycleDistanceFilter() {
    catchSelectionHaptic();
    final controller = ref.read(exploreFiltersProvider.notifier);
    final current = ref.read(exploreFiltersProvider).distanceFilter;
    controller.setDistanceFilter(switch (current) {
      ExploreDistanceFilter.any => ExploreDistanceFilter.oneKm,
      ExploreDistanceFilter.oneKm => ExploreDistanceFilter.threeKm,
      ExploreDistanceFilter.threeKm => ExploreDistanceFilter.fiveKm,
      ExploreDistanceFilter.fiveKm => ExploreDistanceFilter.tenKm,
      ExploreDistanceFilter.tenKm => ExploreDistanceFilter.any,
    });
  }

  Future<void> _snapTo(
    double size, {
    Duration duration = CatchMotion.base,
    Curve curve = CatchMotion.springCurve,
  }) {
    if (!_sheetController.isAttached) return Future<void>.value();
    return _sheetController.animateTo(size, duration: duration, curve: curve);
  }

  void _handleSheetSizeChanged() {
    if (!_sheetController.isAttached) return;
    final nextSize = _sheetController.size;
    if ((nextSize - _sheetSize).abs() < 0.005) return;
    setState(() => _sheetSize = nextSize);
    _syncMotionRevealListener();
    if (!_settlingSheet) {
      _scheduleSheetSettle();
    }
  }

  void _syncMotionRevealListener() {
    final shouldListen =
        mounted &&
        _motionRevealAvailable &&
        _isFull &&
        _selectedMapEventId == null;
    if (shouldListen) {
      _startMotionRevealListener();
    } else {
      _stopMotionRevealListener();
    }
  }

  void _startMotionRevealListener() {
    if (_motionRevealSubscription != null) return;
    _motionRevealRecognizer.reset();
    _motionRevealSubscription = ref
        .read(deviceMotionSourceProvider)
        .watchMotion()
        .listen(
          _handleMotionRevealSample,
          onError: (Object error, StackTrace stackTrace) {
            _motionRevealAvailable = false;
            _stopMotionRevealListener();
          },
        );
  }

  void _stopMotionRevealListener() {
    final subscription = _motionRevealSubscription;
    if (subscription == null) return;
    _motionRevealSubscription = null;
    _motionRevealRecognizer.reset();
    unawaited(subscription.cancel());
  }

  void _handleMotionRevealSample(DeviceMotionSample sample) {
    if (!_isFull || _selectedMapEventId != null) return;
    if (!_motionRevealRecognizer.handle(sample)) return;
    _showMapFromMotionReveal();
  }

  bool _handleSheetScrollEnd(ScrollEndNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    WidgetsBinding.instance.addPostFrameCallback((_) => _settleSheet());
    return false;
  }

  void _scheduleSheetSettle() {
    _sheetSettleTimer?.cancel();
    _sheetSettleTimer = Timer(const Duration(milliseconds: 180), _settleSheet);
  }

  void _settleSheet() {
    if (!mounted || !_sheetController.isAttached || _settlingSheet) return;
    final size = _sheetController.size;
    final target = switch (size) {
      < _exploreSheetPeekSize + 0.18 => _exploreSheetPeekSize,
      > _exploreSheetFullSize - 0.06 => _exploreSheetFullSize,
      _ when (size - _exploreSheetMapSize).abs() < 0.06 => _exploreSheetMapSize,
      _ => null,
    };
    if (target == null || (size - target).abs() < 0.005) return;

    _settlingSheet = true;
    unawaited(
      _snapTo(
        target,
        duration: CatchMotion.fast,
        curve: CatchMotion.standardCurve,
      ).whenComplete(() => _settlingSheet = false),
    );
  }
}

double _exploreChromeHeightFor(BuildContext context) {
  final textScale = MediaQuery.textScalerOf(
    context,
  ).scale(1.0).clamp(0.85, 1.15);
  return CatchSpacing.s4 +
      (_exploreHeaderContentHeight * textScale) +
      CatchSpacing.s3 +
      _exploreFilterRailHeight;
}

class _ExploreFloatingChrome extends StatelessWidget {
  const _ExploreFloatingChrome({required this.backgroundColor});

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExploreBrowseHeaderContent(backgroundColor: backgroundColor),
        ExploreFilterRail(backgroundColor: backgroundColor),
      ],
    );
  }
}

class _ExploreSheetFeed extends ConsumerWidget {
  const _ExploreSheetFeed({
    required this.scrollController,
    required this.isFull,
    required this.isPeek,
    required this.selectedEventId,
    required this.mapCameraCenter,
    required this.onPeekEventTapped,
    required this.onSeeAll,
  });

  final ScrollController scrollController;
  final bool isFull;
  final bool isPeek;
  final String? selectedEventId;
  final LocationCoordinate? mapCameraCenter;
  final ValueChanged<Event> onPeekEventTapped;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(exploreViewModelProvider);
    final city = ref.watch(selectedExploreCityProvider);
    final query = ref.watch(exploreSearchQueryProvider).trim();
    final filters = ref.watch(exploreFiltersProvider);
    final sourceClubCount =
        ref.watch(exploreSourceClubsProvider).asData?.value.length ?? 0;
    final hasSourceClubs = sourceClubCount > 0;

    final shouldShowMapLead = !isFull || selectedEventId != null;
    final nearbySlivers = shouldShowMapLead
        ? buildExploreMapSheetLeadSlivers(
            ref: ref,
            selectedEventId: selectedEventId,
            cameraCenter: mapCameraCenter,
            filters: filters,
            scopeLabel: exploreMapScopeLabel(
              city: city,
              cameraCenter: mapCameraCenter,
            ),
            leadMode: isPeek && selectedEventId == null
                ? ExploreMapSheetLeadMode.collapsedSummary
                : selectedEventId != null
                ? ExploreMapSheetLeadMode.selectedEvent
                : ExploreMapSheetLeadMode.nearbyRail,
            onEventTapped: onPeekEventTapped,
            onSeeAll: onSeeAll,
          )
        : const <Widget>[];

    if (isPeek && selectedEventId == null) {
      return CatchMutationErrorListener(
        mutation: ClubMembershipController.joinMutation,
        child: CustomScrollView(
          key: const ValueKey('explore-list-scroll-view'),
          controller: scrollController,
          slivers: nearbySlivers,
        ),
      );
    }

    final bodySlivers = switch (viewModelAsync) {
      AsyncLoading() => const <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: CatchInsets.pageBody,
            child: _SheetSkeletonList(),
          ),
        ),
      ],
      AsyncError(:final error) => [
        CatchSliverErrorState.fromError(
          error,
          context: AppErrorContext.club,
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
                  child: _buildSheetEmptyState(
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

    return CatchMutationErrorListener(
      mutation: ClubMembershipController.joinMutation,
      child: CustomScrollView(
        key: const ValueKey('explore-list-scroll-view'),
        controller: scrollController,
        // Sheet content is constrained to the sheet's visible height; the
        // default viewport cache extent (250 px) is small enough that mixed
        // feed cards below the first viewport may not build until the user
        // scrolls. A generous cache extent keeps them in the widget tree so
        // semantic lookups and screen-reader navigation work straight away.
        scrollCacheExtent: const ScrollCacheExtent.pixels(1600),
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

class _SheetSkeletonList extends StatelessWidget {
  const _SheetSkeletonList();

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

class _ExploreSnapToggle extends StatelessWidget {
  const _ExploreSnapToggle({
    required this.mapLabel,
    required this.isFull,
    required this.onShowMap,
  });

  final String mapLabel;
  final bool isFull;
  final VoidCallback onShowMap;

  @override
  Widget build(BuildContext context) {
    if (!isFull) return const SizedBox.shrink();
    return CatchCountPill(
      label: mapLabel,
      icon: CatchIcons.map,
      onPressed: onShowMap,
      semanticLabel: mapLabel,
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
