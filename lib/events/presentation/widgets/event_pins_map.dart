import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_map_pin.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tile_data.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/shared/catch_google_map.dart';
import 'package:flutter/material.dart';

const double _placeholderPinSlotWidth = CatchLayout.activityMapPinFlagMaxWidth;

class EventPinsMap extends StatefulWidget {
  const EventPinsMap({
    super.key,
    required this.items,
    required this.initialCenter,
    this.initialZoom = 12.5,
    this.selectedEventId,
    this.selectedEventCenter,
    this.enableNetworkTiles = true,
    this.userLocation,
    this.distanceRingRadiusKm,
    this.onEventSelected,
    this.onMapTapped,
    this.onCameraCenterChanged,
    this.onDistanceRingTapped,
  });

  final List<EventMapItem> items;
  final LocationCoordinate initialCenter;
  final double initialZoom;
  final String? selectedEventId;
  final LocationCoordinate? selectedEventCenter;
  final bool enableNetworkTiles;
  final LocationCoordinate? userLocation;
  final double? distanceRingRadiusKm;
  final ValueChanged<Event>? onEventSelected;
  final VoidCallback? onMapTapped;
  final ValueChanged<LocationCoordinate>? onCameraCenterChanged;
  final VoidCallback? onDistanceRingTapped;

  @override
  State<EventPinsMap> createState() => _EventPinsMapState();
}

class _EventPinsMapState extends State<EventPinsMap> {
  CatchGoogleMapController? _mapController;
  final Map<_EventMapPinIconKey, CatchMapMarkerBitmap> _pinBitmaps =
      <_EventMapPinIconKey, CatchMapMarkerBitmap>{};
  final Set<_EventMapPinIconKey> _pendingPinBitmapKeys =
      <_EventMapPinIconKey>{};
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pinBitmaps.clear();
    _pendingPinBitmapKeys.clear();
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

    if (!widget.enableNetworkTiles) {
      return EventPinsMapPlaceholder(
        items: pinnedItems,
        selectedEventId: widget.selectedEventId,
        userLocation: widget.userLocation,
        distanceRingRadiusKm: widget.distanceRingRadiusKm,
        onEventSelected: onEventSelected,
        onMapTapped: widget.onMapTapped,
      );
    }

    final markerGroups = _markerGroups(pinnedItems);
    _ensureMapPinBitmaps(markerGroups);

    return CatchGoogleMap(
      initialCenter: widget.initialCenter,
      initialZoom: widget.initialZoom,
      markers: {
        for (final group in markerGroups) _markerFor(group, onEventSelected),
      },
      circles: _mapCircles(context),
      onTap: widget.onMapTapped == null ? null : (_) => widget.onMapTapped!(),
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

  Set<CatchMapCircle> _mapCircles(BuildContext context) {
    final userLocation = widget.userLocation;
    if (userLocation == null) return const <CatchMapCircle>{};
    final t = CatchTokens.of(context);
    final ringRadiusKm = widget.distanceRingRadiusKm;
    return {
      if (ringRadiusKm != null && ringRadiusKm > 0)
        CatchMapCircle(
          id: 'event-map-distance-ring',
          center: userLocation,
          radiusMeters: ringRadiusKm * 1000,
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
      CatchMapCircle(
        id: 'event-map-user-location',
        center: userLocation,
        radiusMeters: 42,
        strokeWidth: 3,
        strokeColor: CatchTokens.editorialWhite.withValues(
          alpha: CatchOpacity.mapUserLocationStroke,
        ),
        fillColor: t.primary,
      ),
    };
  }

  CatchMapMarker _markerFor(
    _MapMarkerGroup group,
    ValueChanged<Event>? onEventSelected,
  ) {
    if (group.isCluster) {
      return CatchMapMarker(
        id: group.id,
        position: group.center,
        hue: CatchMapMarkerHue.azure,
        infoTitle: context.l10n.eventsEventPinsMapVisiblecopyLengthEventsNearby(
          length: group.items.length,
        ),
        infoSnippet: context.l10n.eventsEventPinsMapVisiblecopyTapToZoomIn,
        onTap: () => _zoomToCluster(group),
      );
    }
    final item = group.items.single;
    final tileData = item.tileData;
    final iconKey = _eventMapPinIconKey(item);
    final isSelected = item.event.id == widget.selectedEventId;
    return CatchMapMarker(
      id: item.event.id,
      position: LocationCoordinate(
        item.event.effectiveStartingPointLat!,
        item.event.effectiveStartingPointLng!,
      ),
      hue: _markerHueFor(item.status),
      bitmap: _pinBitmaps[iconKey],
      zIndex: isSelected ? 2 : 1,
      infoTitle: context.l10n.eventsEventPinsMapVisiblecopyTimelabelTitle(
        timeLabel: tileData.timeLabel,
        title: tileData.title,
      ),
      infoSnippet: tileData.meetingPoint,
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
      final key = context.l10n.eventsEventPinsMapVisiblecopyFloorFloor2(
        floor: (lat / cellDegrees).floor(),
        floor2: (lng / cellDegrees).floor(),
      );
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
    if (animate) {
      unawaited(controller.animateTo(center));
    } else {
      unawaited(controller.moveTo(center));
    }
  }

  void _zoomToCluster(_MapMarkerGroup group) {
    final controller = _mapController;
    if (controller == null) return;
    final nextZoom = math.min(_cameraZoom + 1.6, 15.5);
    unawaited(controller.animateTo(group.center, zoom: nextZoom));
  }

  void _handleCameraMove(CatchMapCameraPosition position) {
    _pendingCameraCenter = position.center;
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

  void _ensureMapPinBitmaps(List<_MapMarkerGroup> markerGroups) {
    final pixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    final t = CatchTokens.of(context);
    final textStyle = CatchTextStyles.badge(context, color: t.primaryInk);

    for (final group in markerGroups) {
      if (group.isCluster) continue;
      final item = group.items.single;
      final key = _eventMapPinIconKey(item);
      if (_pinBitmaps.containsKey(key) || _pendingPinBitmapKeys.contains(key)) {
        continue;
      }
      final activity = ActivityPalette.resolve(
        context,
        item.event.activityKind,
      );
      _pendingPinBitmapKeys.add(key);
      unawaited(
        _buildEventMapPinBitmap(
              activityColor: activity.accent,
              inkColor: t.ink,
              shadowColor: t.ink.withValues(
                alpha: CatchOpacity.activityMapPinShadow,
              ),
              selected: key.selected,
              label: key.label,
              pixelRatio: pixelRatio,
              textStyle: textStyle,
            )
            .then((bitmap) {
              if (!mounted) return;
              setState(() {
                _pendingPinBitmapKeys.remove(key);
                _pinBitmaps[key] = bitmap;
              });
            })
            .catchError((Object error, StackTrace stackTrace) {
              FlutterError.reportError(
                FlutterErrorDetails(
                  exception: error,
                  stack: stackTrace,
                  library:
                      context.l10n.eventsEventPinsMapVisiblecopyCatchEventMap,
                  context: ErrorDescription(
                    context
                        .l10n
                        .eventsEventPinsMapVisiblecopyBuildingEventMapPin,
                  ),
                ),
              );
              if (!mounted) return;
              setState(() => _pendingPinBitmapKeys.remove(key));
            }),
      );
    }
  }

  _EventMapPinIconKey _eventMapPinIconKey(EventMapItem item) {
    final selected = item.event.id == widget.selectedEventId;
    return _EventMapPinIconKey(
      activityKindName: item.event.activityKind.name,
      selected: selected,
      label: selected ? eventMapPinFlagLabel(item) : null,
    );
  }
}

@visibleForTesting
String eventMapPinFlagLabel(EventMapItem item) {
  return '${item.event.activityKind.label.toUpperCase()} · ${item.tileData.timeLabel.toUpperCase()}';
}

class _EventMapPinIconKey {
  const _EventMapPinIconKey({
    required this.activityKindName,
    required this.selected,
    required this.label,
  });

  final String activityKindName;
  final bool selected;
  final String? label;

  @override
  bool operator ==(Object other) {
    return other is _EventMapPinIconKey &&
        other.activityKindName == activityKindName &&
        other.selected == selected &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(activityKindName, selected, label);
}

Future<CatchMapMarkerBitmap> _buildEventMapPinBitmap({
  required Color activityColor,
  required Color inkColor,
  required Color shadowColor,
  required bool selected,
  required String? label,
  required double pixelRatio,
  required TextStyle textStyle,
}) async {
  final flagLabel = label?.trim();
  final hasFlag = selected && flagLabel != null && flagLabel.isNotEmpty;
  final pinSize = selected
      ? CatchLayout.activityMapPinSelectedSize
      : CatchLayout.activityMapPinRestingSize;
  final canvasPadding = CatchLayout.activityMapPinNativeCanvasPadding;
  final flagHorizontalPadding = CatchSpacing.s2;
  final flagVerticalPadding = CatchSpacing.s1;
  final flagGap = CatchSpacing.micro2;
  final maxFlagWidth = CatchLayout.activityMapPinFlagMaxWidth;
  final iconData = CatchIcons.pin;

  TextPainter? flagPainter;
  double flagWidth = 0;
  double flagHeight = 0;
  if (hasFlag) {
    flagPainter = TextPainter(
      text: TextSpan(text: flagLabel, style: textStyle),
      maxLines: 1,
      ellipsis: '…',
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    )..layout(maxWidth: maxFlagWidth - flagHorizontalPadding * 2);
    flagWidth = math.min(
      maxFlagWidth,
      flagPainter.width + flagHorizontalPadding * 2,
    );
    flagHeight = flagPainter.height + flagVerticalPadding * 2;
  }

  final logicalWidth = math.max(pinSize, flagWidth) + canvasPadding * 2;
  final logicalHeight =
      pinSize + canvasPadding * 2 + (hasFlag ? flagHeight + flagGap : 0);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(pixelRatio);

  if (hasFlag && flagPainter != null) {
    final flagRect = Rect.fromLTWH(
      (logicalWidth - flagWidth) / 2,
      canvasPadding,
      flagWidth,
      flagHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        flagRect,
        const Radius.circular(CatchRadius.pill),
      ),
      Paint()..color = inkColor,
    );
    flagPainter.paint(
      canvas,
      Offset(
        flagRect.left + flagHorizontalPadding,
        flagRect.top + flagVerticalPadding,
      ),
    );
  }

  final iconPainter = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      // Native map marker bitmaps have to serialize the icon font into a PNG;
      // user-visible text above still comes from CatchTextStyles.
      style: TextStyle(
        color: activityColor,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        fontFamilyFallback: iconData.fontFamilyFallback,
        fontSize: pinSize,
        height: 1,
        shadows: [
          Shadow(
            color: shadowColor,
            blurRadius: CatchLayout.activityMapPinShadowBlur,
            offset: const Offset(0, CatchLayout.activityMapPinShadowDy),
          ),
        ],
      ),
    ),
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout(minWidth: pinSize, maxWidth: pinSize);
  iconPainter.paint(
    canvas,
    Offset(
      (logicalWidth - pinSize) / 2,
      canvasPadding + (hasFlag ? flagHeight + flagGap : 0),
    ),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(
    (logicalWidth * pixelRatio).ceil(),
    (logicalHeight * pixelRatio).ceil(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  final bytes = byteData?.buffer.asUint8List();
  if (bytes == null || bytes.isEmpty) {
    throw StateError('Unable to render event map pin bitmap');
  }
  return CatchMapMarkerBitmap(
    bytes: bytes,
    logicalSize: Size(logicalWidth, logicalHeight),
    imagePixelRatio: pixelRatio,
  );
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

class EventPinsMapPlaceholder extends StatelessWidget {
  const EventPinsMapPlaceholder({
    super.key,
    required this.items,
    required this.selectedEventId,
    required this.userLocation,
    required this.distanceRingRadiusKm,
    required this.onEventSelected,
    this.onMapTapped,
  });

  final List<EventMapItem> items;
  final String? selectedEventId;
  final LocationCoordinate? userLocation;
  final double? distanceRingRadiusKm;
  final ValueChanged<Event>? onEventSelected;
  final VoidCallback? onMapTapped;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final ringRadiusKm = distanceRingRadiusKm;
    final showDistanceRing =
        userLocation != null && ringRadiusKm != null && ringRadiusKm > 0;
    return DecoratedBox(
      decoration: BoxDecoration(color: t.primarySoft),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final markerTop = constraints.maxHeight * 0.32;
          final markerWidth = constraints.maxWidth / (items.length + 1);

          return Semantics(
            container: true,
            explicitChildNodes: true,
            label: context.l10n.eventsEventPinsMapLabelEventMapPreview,
            button: onMapTapped != null,
            onTap: onMapTapped,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerUp: onMapTapped == null
                        ? null
                        : (_) => onMapTapped!(),
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
                        dotColor: t.ink.withValues(
                          alpha: CatchOpacity.warningFill,
                        ),
                      ),
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
                        (markerWidth * (indexed.$1 + 1)) -
                        _placeholderPinSlotWidth / 2,
                    top:
                        markerTop +
                        (indexed.$1.isEven ? 0 : CatchSpacing.s6) -
                        _placeholderPinAnchorOffset(
                          selectedEventId == indexed.$2.event.id,
                        ),
                    width: _placeholderPinSlotWidth,
                    child: Semantics(
                      button: onEventSelected != null,
                      selected: selectedEventId == indexed.$2.event.id,
                      label: onEventSelected == null
                          ? context.l10n
                                .eventsEventPinsMapLabelLocationnameLocation(
                                  locationName: indexed.$2.event.locationName,
                                )
                          : context.l10n
                                .eventsEventPinsMapLabelSelectLocationname(
                                  locationName: indexed.$2.event.locationName,
                                ),
                      child: GestureDetector(
                        onTap: onEventSelected == null
                            ? null
                            : () => onEventSelected!(indexed.$2.event),
                        child: Center(
                          child: CatchActivityMapPin(
                            activityKind: indexed.$2.event.activityKind,
                            selected: selectedEventId == indexed.$2.event.id,
                            label: selectedEventId == indexed.$2.event.id
                                ? eventMapPinFlagLabel(indexed.$2)
                                : null,
                            size: selectedEventId == indexed.$2.event.id
                                ? CatchLayout.activityMapPinSelectedSize
                                : CatchLayout.activityMapPinRestingSize,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

double _placeholderPinAnchorOffset(bool selected) {
  if (!selected) return CatchLayout.activityMapPinRestingSize / 2;
  return CatchLayout.activityMapPinSelectedSize + CatchSpacing.s5;
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

CatchMapMarkerHue _markerHueFor(EventTileStatus status) {
  return switch (status) {
    EventTileStatus.joined ||
    EventTileStatus.hosted ||
    EventTileStatus.attended => CatchMapMarkerHue.green,
    EventTileStatus.saved => CatchMapMarkerHue.azure,
    EventTileStatus.waitlisted ||
    EventTileStatus.full => CatchMapMarkerHue.orange,
    EventTileStatus.ineligible ||
    EventTileStatus.cancelled => CatchMapMarkerHue.rose,
    EventTileStatus.past => CatchMapMarkerHue.yellow,
    EventTileStatus.recommended ||
    EventTileStatus.open => CatchMapMarkerHue.red,
  };
}

double _clusterCellDegrees(double zoom) {
  final clampedZoom = zoom.clamp(10.0, 14.0);
  final t = (clampedZoom - 10.0) / 4.0;
  return 0.045 - (0.033 * t);
}
