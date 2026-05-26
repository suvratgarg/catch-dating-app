import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_pin_renderer.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/presentation/catch_google_map_style.dart';
import 'package:catch_dating_app/locations/presentation/google_maps_coordinate_adapter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

const double _placeholderPinSize = 42;

class EventPinsMap extends StatefulWidget {
  const EventPinsMap({
    super.key,
    required this.items,
    required this.initialCenter,
    this.initialZoom = 12.5,
    this.selectedEventId,
    this.selectedEventCenter,
    this.enableNetworkTiles = true,
    this.markerIcon = Icons.directions_run_rounded,
    this.onEventSelected,
  });

  final List<EventMapItem> items;
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
  Map<String, gmaps.BitmapDescriptor> _pinIcons =
      const <String, gmaps.BitmapDescriptor>{};
  double? _lastRebuildDevicePixelRatio;
  int _renderToken = 0;

  @override
  void initState() {
    super.initState();
    _lastAppliedCenter = _effectiveCameraCenter;
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EventPinsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextCenter = _effectiveCameraCenter;
    if (!_samePoint(_lastAppliedCenter, nextCenter)) {
      _lastAppliedCenter = nextCenter;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _moveCameraTo(nextCenter, animate: true);
      });
    }
    if (widget.enableNetworkTiles && _pinIconsNeedRebuild(oldWidget)) {
      unawaited(_rebuildPinIcons());
    }
  }

  @override
  Widget build(BuildContext context) {
    final onEventSelected = widget.onEventSelected;
    final mapStyle = catchGoogleMapStyleFor(Theme.of(context).brightness);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    // Skip bitmap pin rendering in placeholder (network-tiles-disabled) mode.
    // It saves async work and keeps widget tests deterministic — the
    // placeholder paints its own icons via the placeholder widget below.
    if (widget.enableNetworkTiles && _lastRebuildDevicePixelRatio != dpr) {
      unawaited(_rebuildPinIcons(devicePixelRatio: dpr));
    }

    final pinnedItems = _pinnedItems;

    if (!widget.enableNetworkTiles) {
      return _EventPinsMapPlaceholder(
        items: pinnedItems,
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
        for (final item in pinnedItems)
          gmaps.Marker(
            markerId: gmaps.MarkerId(item.event.id),
            position: gmaps.LatLng(
              item.event.effectiveStartingPointLat!,
              item.event.effectiveStartingPointLng!,
            ),
            anchor: EventPinRenderer.anchor,
            icon: _pinIcons[item.event.id] ??
                gmaps.BitmapDescriptor.defaultMarker,
            onTap: onEventSelected == null
                ? null
                : () => onEventSelected(item.event),
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

  List<EventMapItem> get _pinnedItems => widget.items
      .where((item) => item.event.hasExactStartingPoint)
      .toList(growable: false);

  bool _pinIconsNeedRebuild(EventPinsMap oldWidget) {
    if (oldWidget.selectedEventId != widget.selectedEventId) return true;
    if (oldWidget.items.length != widget.items.length) return true;
    for (var i = 0; i < oldWidget.items.length; i += 1) {
      final left = oldWidget.items[i];
      final right = widget.items[i];
      if (left.event.id != right.event.id) return true;
      if (left.status != right.status) return true;
      if (!left.event.startTime.isAtSameMomentAs(right.event.startTime)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _rebuildPinIcons({double? devicePixelRatio}) async {
    final token = ++_renderToken;
    final dpr = devicePixelRatio ??
        _lastRebuildDevicePixelRatio ??
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    _lastRebuildDevicePixelRatio = dpr;
    final selectedId = widget.selectedEventId;
    final items = _pinnedItems;
    final entries = await Future.wait(
      items.map((item) async {
        final descriptor = await EventPinRenderer.render(
          spec: EventPinSpec(
            timeLabel: EventFormatters.time(item.event.startTime),
            status: item.status,
            selected: item.event.id == selectedId,
          ),
          devicePixelRatio: dpr,
        );
        return MapEntry<String, gmaps.BitmapDescriptor>(
          item.event.id,
          descriptor,
        );
      }),
    );
    if (!mounted || token != _renderToken) return;
    setState(() {
      _pinIcons = Map<String, gmaps.BitmapDescriptor>.fromEntries(entries);
    });
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
    required this.items,
    required this.selectedEventId,
    required this.markerIcon,
    required this.onEventSelected,
  });

  final List<EventMapItem> items;
  final String? selectedEventId;
  final IconData markerIcon;
  final ValueChanged<Event>? onEventSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ColoredBox(
      color: t.primarySoft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (items.isEmpty) return const SizedBox.shrink();
          final markerTop = constraints.maxHeight * 0.32;
          final markerWidth = constraints.maxWidth / (items.length + 1);

          return Stack(
            children: [
              for (final indexed in items.indexed)
                Positioned(
                  left:
                      (markerWidth * (indexed.$1 + 1)) -
                      _placeholderPinSize / 2,
                  top:
                      markerTop +
                      (indexed.$1.isEven ? 0 : CatchSpacing.s6) -
                      _placeholderPinSize / 2,
                  child: Semantics(
                    button: onEventSelected != null,
                    selected: selectedEventId == indexed.$2.event.id,
                    label: onEventSelected == null
                        ? '${indexed.$2.event.locationName} location'
                        : 'Select ${indexed.$2.event.locationName}',
                    child: GestureDetector(
                      onTap: onEventSelected == null
                          ? null
                          : () => onEventSelected!(indexed.$2.event),
                      child: Icon(
                        markerIcon,
                        color: selectedEventId == indexed.$2.event.id
                            ? t.primary
                            : t.ink,
                        size: _placeholderPinSize,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

bool _samePoint(LocationCoordinate a, LocationCoordinate b) =>
    a.latitude == b.latitude && a.longitude == b.longitude;
