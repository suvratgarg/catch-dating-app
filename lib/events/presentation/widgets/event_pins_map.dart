import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/presentation/catch_google_map_style.dart';
import 'package:catch_dating_app/locations/presentation/google_maps_coordinate_adapter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class EventPinsMap extends StatefulWidget {
  const EventPinsMap({
    super.key,
    required this.events,
    required this.initialCenter,
    this.initialZoom = 12.5,
    this.selectedEventId,
    this.selectedEventCenter,
    this.enableNetworkTiles = true,
    this.markerIcon = Icons.directions_run_rounded,
    this.onEventSelected,
  });

  final List<Event> events;
  final LocationCoordinate initialCenter;
  final double initialZoom;
  final String? selectedEventId;
  final LocationCoordinate? selectedEventCenter;
  final bool enableNetworkTiles;
  final IconData markerIcon;
  final ValueChanged<Event>? onEventSelected;

  @override
  State<EventPinsMap> createState() => _EventPinsMapState();
}

class _EventPinsMapState extends State<EventPinsMap> {
  gmaps.GoogleMapController? _mapController;
  late LocationCoordinate _lastAppliedCenter;

  @override
  void initState() {
    super.initState();
    _lastAppliedCenter = _effectiveCameraCenter;
  }

  @override
  void dispose() {
    // GoogleMap owns disposal of its controller; clear only our reference.
    _mapController = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EventPinsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextCenter = _effectiveCameraCenter;
    if (_samePoint(_lastAppliedCenter, nextCenter)) return;
    _lastAppliedCenter = nextCenter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _moveCameraTo(nextCenter, animate: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final onEventSelected = widget.onEventSelected;
    final mapStyle = catchGoogleMapStyleFor(Theme.of(context).brightness);

    final pinnedEvents = widget.events
        .where((event) => event.hasExactStartingPoint)
        .toList(growable: false);

    if (!widget.enableNetworkTiles) {
      return _EventPinsMapPlaceholder(
        events: pinnedEvents,
        selectedEventId: widget.selectedEventId,
        markerIcon: widget.markerIcon,
        onEventSelected: onEventSelected,
      );
    }

    return gmaps.GoogleMap(
      style: mapStyle,
      initialCameraPosition: gmaps.CameraPosition(
        target: widget.initialCenter.toGoogleMapsLatLng(),
        zoom: widget.initialZoom,
      ),
      markers: {
        for (final event in pinnedEvents)
          gmaps.Marker(
            markerId: gmaps.MarkerId(event.id),
            position: gmaps.LatLng(
              event.startingPointLat!,
              event.startingPointLng!,
            ),
            infoWindow: gmaps.InfoWindow(title: event.title),
            icon: widget.selectedEventId == event.id
                ? gmaps.BitmapDescriptor.defaultMarkerWithHue(
                    gmaps.BitmapDescriptor.hueOrange,
                  )
                : gmaps.BitmapDescriptor.defaultMarkerWithHue(
                    gmaps.BitmapDescriptor.hueCyan,
                  ),
            onTap: onEventSelected == null
                ? null
                : () => onEventSelected(event),
          ),
      },
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
        _moveCameraTo(_lastAppliedCenter, animate: false);
      },
    );
  }

  void _moveCameraTo(LocationCoordinate center, {required bool animate}) {
    final controller = _mapController;
    if (controller == null) return;
    final update = gmaps.CameraUpdate.newLatLng(center.toGoogleMapsLatLng());
    if (animate) {
      unawaited(controller.animateCamera(update));
    } else {
      unawaited(controller.moveCamera(update));
    }
  }

  LocationCoordinate get _effectiveCameraCenter =>
      widget.selectedEventCenter ?? widget.initialCenter;
}

class _EventPinsMapPlaceholder extends StatelessWidget {
  const _EventPinsMapPlaceholder({
    required this.events,
    required this.selectedEventId,
    required this.markerIcon,
    required this.onEventSelected,
  });

  final List<Event> events;
  final String? selectedEventId;
  final IconData markerIcon;
  final ValueChanged<Event>? onEventSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ColoredBox(
      color: t.primarySoft,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final event in events)
            Semantics(
              button: onEventSelected != null,
              selected: selectedEventId == event.id,
              label: onEventSelected == null
                  ? '${event.title} location'
                  : 'Select ${event.title}',
              child: GestureDetector(
                onTap: onEventSelected == null
                    ? null
                    : () => onEventSelected!(event),
                child: Icon(
                  markerIcon,
                  color: selectedEventId == event.id ? t.primary : t.ink,
                  size: 42,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

bool _samePoint(LocationCoordinate a, LocationCoordinate b) =>
    a.latitude == b.latitude && a.longitude == b.longitude;
