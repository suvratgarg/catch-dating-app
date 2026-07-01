import 'dart:async';
import 'dart:math' as math;

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_data.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/presentation/google_maps_coordinate_adapter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

const double _placeholderPinSize = CatchLayout.mapPlaceholderPinSize;

class EventPinsMap extends StatefulWidget {
  const EventPinsMap({
    super.key,
    required this.items,
    required this.initialCenter,
    this.initialZoom = 12.5,
    this.selectedEventId,
    this.selectedEventCenter,
    this.enableNetworkTiles = true,
    this.markerIcon,
    this.userLocation,
    this.distanceRingRadiusKm,
    this.onEventSelected,
    this.onCameraCenterChanged,
    this.onDistanceRingTapped,
  });

  final List<EventMapItem> items;
  final LocationCoordinate initialCenter;
  final double initialZoom;
  final String? selectedEventId;
  final LocationCoordinate? selectedEventCenter;
  final bool enableNetworkTiles;
  final IconData? markerIcon;
  final LocationCoordinate? userLocation;
  final double? distanceRingRadiusKm;
  final ValueChanged<Event>? onEventSelected;
  final ValueChanged<LocationCoordinate>? onCameraCenterChanged;
  final VoidCallback? onDistanceRingTapped;

  @override
  State<EventPinsMap> createState() => _EventPinsMapState();
}

class _EventPinsMapState extends State<EventPinsMap> {
  gmaps.GoogleMapController? _mapController;
  late LocationCoordinate _lastAppliedCenter;
  late double _cameraZoom;
  LocationCoordinate? _pendingCameraCenter;
  double? _pendingCameraZoom;
  LocationCoordinate? _lastReportedCameraCenter;

  @override
  void initState() {
    super.initState();
    _lastAppliedCenter = _effectiveCameraCenter;
    _lastReportedCameraCenter = _lastAppliedCenter;
    _cameraZoom = widget.initialZoom;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onCameraCenterChanged?.call(_lastAppliedCenter);
    });
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
      _lastReportedCameraCenter = nextCenter;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onCameraCenterChanged?.call(nextCenter);
        _moveCameraTo(nextCenter, animate: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final onEventSelected = widget.onEventSelected;
    final pinnedItems = _pinnedItems;
    final markerGroups = _markerGroups(pinnedItems);

    if (!widget.enableNetworkTiles) {
      return _eventPinsMapPlaceholder(
        context,
        items: pinnedItems,
        selectedEventId: widget.selectedEventId,
        markerIcon: widget.markerIcon ?? CatchIcons.running,
        userLocation: widget.userLocation,
        distanceRingRadiusKm: widget.distanceRingRadiusKm,
        onEventSelected: onEventSelected,
      );
    }

    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: widget.initialCenter.toGoogleMapsLatLng(),
        zoom: widget.initialZoom,
      ),
      markers: {
        for (final group in markerGroups) _markerFor(group, onEventSelected),
      },
      circles: _mapCircles(context),
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      onCameraMove: _handleCameraMove,
      onCameraIdle: _handleCameraIdle,
      onMapCreated: (controller) {
        _mapController = controller;
        _moveCameraTo(_lastAppliedCenter, animate: false);
      },
    );
  }

  List<EventMapItem> get _pinnedItems => widget.items
      .where((item) => item.event.hasExactStartingPoint)
      .toList(growable: false);

  Set<gmaps.Circle> _mapCircles(BuildContext context) {
    final userLocation = widget.userLocation;
    if (userLocation == null) return const <gmaps.Circle>{};
    final t = CatchTokens.of(context);
    final center = userLocation.toGoogleMapsLatLng();
    final ringRadiusKm = widget.distanceRingRadiusKm;
    return {
      if (ringRadiusKm != null && ringRadiusKm > 0)
        gmaps.Circle(
          circleId: const gmaps.CircleId('event-map-distance-ring'),
          center: center,
          radius: ringRadiusKm * 1000,
          strokeWidth: 2,
          strokeColor: t.primary.withValues(
            alpha: CatchOpacity.mapDistanceRingStroke,
          ),
          fillColor: t.primary.withValues(
            alpha: CatchOpacity.mapDistanceRingFill,
          ),
          consumeTapEvents: widget.onDistanceRingTapped != null,
          onTap: widget.onDistanceRingTapped,
        ),
      gmaps.Circle(
        circleId: const gmaps.CircleId('event-map-user-location'),
        center: center,
        radius: 42,
        strokeWidth: 3,
        strokeColor: CatchTokens.editorialLight.withValues(
          alpha: CatchOpacity.mapUserLocationStroke,
        ),
        fillColor: t.primary,
      ),
    };
  }

  gmaps.Marker _markerFor(
    _MapMarkerGroup group,
    ValueChanged<Event>? onEventSelected,
  ) {
    if (group.isCluster) {
      return gmaps.Marker(
        markerId: gmaps.MarkerId(group.id),
        position: group.center.toGoogleMapsLatLng(),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueAzure,
        ),
        infoWindow: gmaps.InfoWindow(
          title: '${group.items.length} events nearby',
          snippet: 'Tap to zoom in',
        ),
        onTap: () => _zoomToCluster(group),
      );
    }
    final item = group.items.single;
    final tileData = item.tileData;
    return gmaps.Marker(
      markerId: gmaps.MarkerId(item.event.id),
      position: gmaps.LatLng(
        item.event.effectiveStartingPointLat!,
        item.event.effectiveStartingPointLng!,
      ),
      icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
        _markerHueFor(item.status),
      ),
      infoWindow: gmaps.InfoWindow(
        title: '${tileData.timeLabel} · ${tileData.title}',
        snippet: tileData.meetingPoint,
      ),
      onTap: onEventSelected == null ? null : () => onEventSelected(item.event),
    );
  }

  List<_MapMarkerGroup> _markerGroups(List<EventMapItem> pinnedItems) {
    if (pinnedItems.length < 6 || _cameraZoom >= 14) {
      return [for (final item in pinnedItems) _MapMarkerGroup.single(item)];
    }
    final cellDegrees = _clusterCellDegrees(_cameraZoom);
    final buckets = <String, List<EventMapItem>>{};
    for (final item in pinnedItems) {
      final lat = item.event.effectiveStartingPointLat!;
      final lng = item.event.effectiveStartingPointLng!;
      final key =
          '${(lat / cellDegrees).floor()}:${(lng / cellDegrees).floor()}';
      buckets.putIfAbsent(key, () => <EventMapItem>[]).add(item);
    }

    return [
      for (final entry in buckets.entries)
        if (entry.value.length == 1)
          _MapMarkerGroup.single(entry.value.single)
        else
          _MapMarkerGroup.cluster(
            id: 'cluster-${entry.key}-${entry.value.length}',
            items: entry.value,
          ),
    ];
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

  void _zoomToCluster(_MapMarkerGroup group) {
    final controller = _mapController;
    if (controller == null) return;
    final nextZoom = math.min(_cameraZoom + 1.6, 15.5);
    unawaited(
      controller.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(
          group.center.toGoogleMapsLatLng(),
          nextZoom,
        ),
      ),
    );
  }

  void _handleCameraMove(gmaps.CameraPosition position) {
    _pendingCameraCenter = LocationCoordinate(
      position.target.latitude,
      position.target.longitude,
    );
    _pendingCameraZoom = position.zoom;
  }

  void _handleCameraIdle() {
    final nextCenter = _pendingCameraCenter;
    final nextZoom = _pendingCameraZoom;
    if (nextCenter != null &&
        (_lastReportedCameraCenter == null ||
            !_samePoint(_lastReportedCameraCenter!, nextCenter))) {
      _lastReportedCameraCenter = nextCenter;
      widget.onCameraCenterChanged?.call(nextCenter);
    }
    if (nextZoom != null && (nextZoom - _cameraZoom).abs() >= 0.05) {
      setState(() => _cameraZoom = nextZoom);
    }
  }

  LocationCoordinate get _effectiveCameraCenter =>
      widget.selectedEventCenter ?? widget.initialCenter;
}

class _MapMarkerGroup {
  _MapMarkerGroup._({
    required this.id,
    required this.items,
    required this.center,
    required this.isCluster,
  });

  factory _MapMarkerGroup.single(EventMapItem item) {
    return _MapMarkerGroup._(
      id: item.event.id,
      items: [item],
      center: LocationCoordinate(
        item.event.effectiveStartingPointLat!,
        item.event.effectiveStartingPointLng!,
      ),
      isCluster: false,
    );
  }

  factory _MapMarkerGroup.cluster({
    required String id,
    required List<EventMapItem> items,
  }) {
    final lat =
        items
            .map((item) => item.event.effectiveStartingPointLat!)
            .reduce((left, right) => left + right) /
        items.length;
    final lng =
        items
            .map((item) => item.event.effectiveStartingPointLng!)
            .reduce((left, right) => left + right) /
        items.length;
    return _MapMarkerGroup._(
      id: id,
      items: List.unmodifiable(items),
      center: LocationCoordinate(lat, lng),
      isCluster: true,
    );
  }

  final String id;
  final List<EventMapItem> items;
  final LocationCoordinate center;
  final bool isCluster;
}

Widget _eventPinsMapPlaceholder(
  BuildContext context, {
  required List<EventMapItem> items,
  required String? selectedEventId,
  required IconData markerIcon,
  required LocationCoordinate? userLocation,
  required double? distanceRingRadiusKm,
  required ValueChanged<Event>? onEventSelected,
}) {
  final t = CatchTokens.of(context);
  final showDistanceRing =
      userLocation != null &&
      distanceRingRadiusKm != null &&
      distanceRingRadiusKm > 0;
  return DecoratedBox(
    decoration: BoxDecoration(color: t.primarySoft),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final markerTop = constraints.maxHeight * 0.32;
        final markerWidth = constraints.maxWidth / (items.length + 1);

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _EventPinsMapPlaceholderPainter(
                  backgroundColor: t.primarySoft,
                  waterColor: t.primary.withValues(
                    alpha: CatchOpacity.mapDistanceRingFill,
                  ),
                  parkColor: t.success.withValues(
                    alpha: CatchOpacity.photoScrimLight,
                  ),
                  roadColor: t.ink.withValues(
                    alpha: CatchOpacity.photoScrimMedium,
                  ),
                  minorRoadColor: t.ink.withValues(
                    alpha: CatchOpacity.photoScrimLight,
                  ),
                  routeColor: t.primary.withValues(
                    alpha: CatchOpacity.mapDistanceRingStroke,
                  ),
                  dotColor: t.ink.withValues(alpha: CatchOpacity.warningFill),
                ),
              ),
            ),
            if (showDistanceRing)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _EventPinsMapDistanceRingPainter(
                      fillColor: t.primary.withValues(
                        alpha: CatchOpacity.mapDistanceRingFill,
                      ),
                      strokeColor: t.primary.withValues(
                        alpha: CatchOpacity.mapDistanceRingStroke,
                      ),
                    ),
                  ),
                ),
              ),
            for (final indexed in items.indexed)
              Positioned(
                left:
                    (markerWidth * (indexed.$1 + 1)) - _placeholderPinSize / 2,
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
                        : () => onEventSelected(indexed.$2.event),
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

class _EventPinsMapDistanceRingPainter extends CustomPainter {
  const _EventPinsMapDistanceRingPainter({
    required this.fillColor,
    required this.strokeColor,
  });

  final Color fillColor;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) * 0.26;
    final center = Offset(size.width * 0.5, size.height * 0.56);
    canvas.drawCircle(center, radius, Paint()..color = fillColor);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _EventPinsMapDistanceRingPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor;
  }
}

class _EventPinsMapPlaceholderPainter extends CustomPainter {
  const _EventPinsMapPlaceholderPainter({
    required this.backgroundColor,
    required this.waterColor,
    required this.parkColor,
    required this.roadColor,
    required this.minorRoadColor,
    required this.routeColor,
    required this.dotColor,
  });

  final Color backgroundColor;
  final Color waterColor;
  final Color parkColor;
  final Color roadColor;
  final Color minorRoadColor;
  final Color routeColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, basePaint);

    final waterPaint = Paint()
      ..color = waterColor
      ..style = PaintingStyle.fill;
    final waterPath = Path()
      ..moveTo(size.width * 0.58, 0)
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.08,
        size.width,
        size.height * 0.22,
      )
      ..lineTo(size.width, size.height)
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.78,
        size.width * 0.64,
        size.height * 0.52,
      )
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.26,
        size.width * 0.58,
        0,
      )
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    final parkPaint = Paint()
      ..color = parkColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.07,
          size.height * 0.14,
          size.width * 0.26,
          size.height * 0.20,
        ),
        const Radius.circular(CatchRadius.md),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.22,
          size.height * 0.58,
          size.width * 0.32,
          size.height * 0.22,
        ),
        const Radius.circular(CatchRadius.lg),
      ),
      parkPaint,
    );

    final roadPaint = Paint()
      ..color = roadColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final minorRoadPaint = Paint()
      ..color = minorRoadColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = -2; i < 8; i += 1) {
      final y = size.height * (i * 0.16);
      canvas.drawLine(
        Offset(-size.width * 0.1, y),
        Offset(size.width * 1.1, y + size.height * 0.34),
        i.isEven ? roadPaint : minorRoadPaint,
      );
    }
    for (var i = 0; i < 7; i += 1) {
      final x = size.width * (i * 0.18);
      canvas.drawLine(
        Offset(x, -size.height * 0.08),
        Offset(x - size.width * 0.22, size.height * 1.08),
        minorRoadPaint,
      );
    }

    final routePaint = Paint()
      ..color = routeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final routePath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.74)
      ..cubicTo(
        size.width * 0.32,
        size.height * 0.66,
        size.width * 0.45,
        size.height * 0.80,
        size.width * 0.60,
        size.height * 0.68,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.58,
        size.width * 0.78,
        size.height * 0.38,
        size.width * 0.92,
        size.height * 0.32,
      );
    canvas.drawPath(routePath, routePaint);

    final dotPaint = Paint()..color = dotColor;
    for (var i = 0; i < 12; i += 1) {
      final x = size.width * ((i * 0.19) % 1.0);
      final y = size.height * (0.12 + ((i * 0.31) % 0.74));
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EventPinsMapPlaceholderPainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.waterColor != waterColor ||
      oldDelegate.parkColor != parkColor ||
      oldDelegate.roadColor != roadColor ||
      oldDelegate.minorRoadColor != minorRoadColor ||
      oldDelegate.routeColor != routeColor ||
      oldDelegate.dotColor != dotColor;
}

bool _samePoint(LocationCoordinate a, LocationCoordinate b) =>
    a.latitude == b.latitude && a.longitude == b.longitude;

double _markerHueFor(EventTileStatus status) {
  return switch (status) {
    EventTileStatus.joined ||
    EventTileStatus.hosted ||
    EventTileStatus.attended => gmaps.BitmapDescriptor.hueGreen,
    EventTileStatus.saved => gmaps.BitmapDescriptor.hueAzure,
    EventTileStatus.waitlisted ||
    EventTileStatus.full => gmaps.BitmapDescriptor.hueOrange,
    EventTileStatus.ineligible ||
    EventTileStatus.cancelled => gmaps.BitmapDescriptor.hueRose,
    EventTileStatus.past => gmaps.BitmapDescriptor.hueYellow,
    EventTileStatus.recommended ||
    EventTileStatus.open => gmaps.BitmapDescriptor.hueRed,
  };
}

double _clusterCellDegrees(double zoom) {
  final clampedZoom = zoom.clamp(10.0, 14.0);
  final t = (clampedZoom - 10.0) / 4.0;
  return 0.045 - (0.033 * t);
}
