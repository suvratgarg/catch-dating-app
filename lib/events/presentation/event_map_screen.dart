import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_map_center.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_map_sheet.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_pins_map.dart';
import 'package:catch_dating_app/events/presentation/widgets/map_overlay_controls.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventMapScreen extends ConsumerWidget {
  const EventMapScreen({super.key, this.enableNetworkTiles = true});

  final bool enableNetworkTiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      body: EventMapView(
        enableNetworkTiles: enableNetworkTiles,
        overlay: const MapOverlayControls(),
      ),
    );
  }
}

class EventMapView extends ConsumerStatefulWidget {
  const EventMapView({super.key, this.enableNetworkTiles = true, this.overlay});

  final bool enableNetworkTiles;
  final Widget? overlay;

  @override
  ConsumerState<EventMapView> createState() => _EventMapViewState();
}

class _EventMapViewState extends ConsumerState<EventMapView> {
  String? _selectedEventId;

  @override
  Widget build(BuildContext context) {
    final viewModelAsync = ref.watch(eventMapViewModelProvider);
    final deviceLocation = ref.watch(deviceLocationProvider).asData?.value;
    final selectedCity = ref.watch(selectedClubCityProvider);
    final selectedCityWasUserSelected = ref.watch(
      selectedClubCityWasUserSelectedProvider,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: viewModelAsync.when(
            loading: () => const CatchLoadingIndicator(),
            error: (error, _) => CatchErrorState.fromError(
              error,
              context: AppErrorContext.event,
              onRetry: () => ref.invalidate(eventMapViewModelProvider),
            ),
            data: (viewModel) {
              final items = viewModel.effectiveItems;
              final selectedEvent = viewModel.selectedEvent(_selectedEventId);
              final selectedEventCenter = _startingPointFor(selectedEvent);
              final mapCenter = resolveEventMapInitialCenter(
                deviceLocation: deviceLocation,
                selectedCity: selectedCity,
                selectedCityWasUserSelected: selectedCityWasUserSelected,
              );

              return viewModel.isEmpty
                  ? const _MapEmptyState()
                  : !viewModel.hasPinnedEvents
                  ? Stack(
                      children: [
                        const Positioned.fill(child: _NoPinnedEventsState()),
                        Positioned(
                          left: CatchSpacing.s5,
                          right: CatchSpacing.s5,
                          bottom: CatchSpacing.s5,
                          child: EventMapSheet(
                            items: items,
                            selectedEvent: selectedEvent,
                            onEventSelected: (event) =>
                                setState(() => _selectedEventId = event.id),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned.fill(
                          child: EventPinsMap(
                            events: viewModel.pinnedEvents,
                            initialCenter: mapCenter,
                            selectedEventId: _selectedEventId,
                            selectedEventCenter: selectedEventCenter,
                            enableNetworkTiles: widget.enableNetworkTiles,
                            onEventSelected: (event) =>
                                setState(() => _selectedEventId = event.id),
                          ),
                        ),
                        Positioned(
                          left: CatchSpacing.s5,
                          right: CatchSpacing.s5,
                          bottom: CatchSpacing.s5,
                          child: EventMapSheet(
                            items: items,
                            selectedEvent: selectedEvent,
                            onEventSelected: (event) =>
                                setState(() => _selectedEventId = event.id),
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
}

LocationCoordinate? _startingPointFor(Event? event) {
  if (event == null) return null;
  return LocationCoordinate.fromNullable(
    latitude: event.effectiveStartingPointLat,
    longitude: event.effectiveStartingPointLng,
  );
}

class _NoPinnedEventsState extends StatelessWidget {
  const _NoPinnedEventsState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CatchEmptyState(
        icon: Icons.add_location_alt_outlined,
        title: 'No exact pins yet',
        message:
            'These events are visible, but none have pinned starting points.',
        surface: false,
      ),
    );
  }
}

class _MapEmptyState extends StatelessWidget {
  const _MapEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CatchEmptyState(
        icon: Icons.map_outlined,
        title: 'No mapped events yet',
        message:
            'Join clubs, book events, or save future events to see starting points here.',
        surface: false,
      ),
    );
  }
}
