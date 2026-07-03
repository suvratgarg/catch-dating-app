import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_map_center.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_pins_map.dart';
import 'package:catch_dating_app/explore/explore.dart'
    show
        selectedExploreCityProvider,
        selectedExploreCityWasUserSelectedProvider;
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventMapView extends ConsumerStatefulWidget {
  const EventMapView({
    super.key,
    this.enableNetworkTiles = true,
    this.overlay,
    this.onEventSelected,
    this.onCameraCenterChanged,
    this.onDistanceRingTapped,
    this.viewModel,
    this.onRetry,
    this.distanceRingRadiusKm,
    this.initialSelectedEventId,
  });

  final bool enableNetworkTiles;
  final Widget? overlay;
  final ValueChanged<Event>? onEventSelected;
  final ValueChanged<LocationCoordinate>? onCameraCenterChanged;
  final VoidCallback? onDistanceRingTapped;
  final AsyncValue<EventMapViewModel>? viewModel;
  final VoidCallback? onRetry;
  final double? distanceRingRadiusKm;
  final String? initialSelectedEventId;

  @override
  ConsumerState<EventMapView> createState() => _EventMapViewState();
}

class _EventMapViewState extends ConsumerState<EventMapView> {
  String? _selectedEventId;

  @override
  void initState() {
    super.initState();
    _selectedEventId = widget.initialSelectedEventId;
  }

  @override
  void didUpdateWidget(covariant EventMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelectedEventId != widget.initialSelectedEventId &&
        _selectedEventId == oldWidget.initialSelectedEventId) {
      _selectedEventId = widget.initialSelectedEventId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<EventMapViewModel> viewModelAsync =
        widget.viewModel ?? ref.watch(eventMapViewModelProvider);
    final deviceLocation = ref.watch(deviceLocationProvider).asData?.value;
    final selectedCity = ref.watch(selectedExploreCityProvider);
    final selectedCityWasUserSelected = ref.watch(
      selectedExploreCityWasUserSelectedProvider,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: CatchAsyncValueView<EventMapViewModel>(
            value: viewModelAsync,
            loadingBuilder: (_) => const EventMapLoadingBody(),
            errorBuilder: (_, error, _) => CatchErrorState.fromError(
              error,
              context: AppErrorContext.event,
              onRetry:
                  widget.onRetry ??
                  () => ref.invalidate(eventMapViewModelProvider),
            ),
            builder: (context, viewModel) {
              final selectedEvent = viewModel.selectedEvent(_selectedEventId);
              final selectedEventCenter = _startingPointFor(selectedEvent);
              final mapCenter = resolveEventMapInitialCenter(
                deviceLocation: deviceLocation,
                selectedCity: selectedCity,
                selectedCityWasUserSelected: selectedCityWasUserSelected,
              );

              return viewModel.isEmpty
                  ? const EventMapEmptyState()
                  : !viewModel.hasPinnedEvents
                  ? const EventMapNoPinnedEventsState()
                  : Stack(
                      children: [
                        Positioned.fill(
                          child: EventPinsMap(
                            items: viewModel.effectivePinnedItems,
                            initialCenter: mapCenter,
                            selectedEventId: _selectedEventId,
                            selectedEventCenter: selectedEventCenter,
                            enableNetworkTiles: widget.enableNetworkTiles,
                            userLocation: deviceLocation,
                            distanceRingRadiusKm: widget.distanceRingRadiusKm,
                            onEventSelected: _selectEvent,
                            onCameraCenterChanged: widget.onCameraCenterChanged,
                            onDistanceRingTapped: widget.onDistanceRingTapped,
                          ),
                        ),
                      ],
                    );
            },
          ),
        ),
        ?widget.overlay,
      ],
    );
  }

  void _selectEvent(Event event) {
    setState(() => _selectedEventId = event.id);
    widget.onEventSelected?.call(event);
  }
}

class EventMapLoadingBody extends StatelessWidget {
  const EventMapLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: CatchSkeleton.box(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                borderRadius: BorderRadius.zero,
              ),
            ),
            Center(
              child: CatchSkeleton.circle(
                size: CatchSpacing.s12 + CatchSpacing.s4,
              ),
            ),
            Positioned(
              left: CatchSpacing.s5,
              top: CatchSpacing.s5,
              child: CatchSkeleton.box(
                width: CatchSpacing.s16 * 2,
                height: CatchSpacing.s9,
                radius: CatchRadius.pill,
                borderColor: t.line,
              ),
            ),
            Positioned(
              right: CatchSpacing.s5,
              bottom: CatchSpacing.s5,
              child: CatchSkeleton.circle(),
            ),
          ],
        );
      },
    );
  }
}

LocationCoordinate? _startingPointFor(Event? event) {
  if (event == null) return null;
  return LocationCoordinate.fromNullable(
    latitude: event.effectiveStartingPointLat,
    longitude: event.effectiveStartingPointLng,
  );
}

class EventMapNoPinnedEventsState extends StatelessWidget {
  const EventMapNoPinnedEventsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CatchEmptyState(
        icon: CatchIcons.pinOutlined,
        title: 'No exact pins yet',
        message:
            'These events are visible, but none have pinned starting points.',
      ),
    );
  }
}

class EventMapEmptyState extends StatelessWidget {
  const EventMapEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CatchEmptyState(
        icon: CatchIcons.map,
        title: 'No mapped events yet',
        message:
            'Join clubs, book events, or save future events to see starting points here.',
      ),
    );
  }
}
