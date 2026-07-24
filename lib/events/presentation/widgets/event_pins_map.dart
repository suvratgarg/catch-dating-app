import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_map_pin.dart';
import 'package:catch_dating_app/core/widgets/catch_distance_ring.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/external_event.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/shared/catch_google_map.dart';
import 'package:flutter/material.dart';

const double _placeholderPinSlotWidth = CatchLayout.activityMapPinFlagMaxWidth;

class EventPinsMap extends StatefulWidget {
  const EventPinsMap({
    super.key,
    required this.items,
    this.externalItems = const [],
    required this.initialCenter,
    this.initialZoom = 12.5,
    this.selectedEventId,
    this.selectedEventCenter,
    this.enableNetworkTiles = true,
    this.userLocation,
    this.distanceRingRadiusKm,
    this.distanceRingLabel,
    this.distanceRingSemanticHint,
    this.showOverviewControl = false,
    this.onEventSelected,
    this.onExternalEventSelected,
    this.onMapTapped,
    this.onCameraCenterChanged,
    this.onDistanceRingTapped,
  });

  final List<EventMapItem> items;
  final List<ExternalEventMapItem> externalItems;
  final LocationCoordinate initialCenter;
  final double initialZoom;
  final String? selectedEventId;
  final LocationCoordinate? selectedEventCenter;
  final bool enableNetworkTiles;
  final LocationCoordinate? userLocation;
  final double? distanceRingRadiusKm;
  final String? distanceRingLabel;
  final String? distanceRingSemanticHint;
  final bool showOverviewControl;
  final ValueChanged<Event>? onEventSelected;
  final ValueChanged<ExternalEvent>? onExternalEventSelected;
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
  final Set<_EventMapPinIconKey> _failedPinBitmapKeys = <_EventMapPinIconKey>{};
  final Map<int, CatchMapMarkerBitmap> _clusterBitmaps =
      <int, CatchMapMarkerBitmap>{};
  final Set<int> _pendingClusterBitmapCounts = <int>{};
  final Set<int> _failedClusterBitmapCounts = <int>{};
  late LocationCoordinate _lastAppliedCenter;
  late double _cameraZoom;
  LocationCoordinate? _pendingCameraCenter;
  double? _pendingCameraZoom;
  LocationCoordinate? _lastReportedCameraCenter;
  Offset? _distanceRingLabelOffset;
  int _distanceRingProjectionGeneration = 0;

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
    _distanceRingProjectionGeneration += 1;
    _mapController = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pinBitmaps.clear();
    _pendingPinBitmapKeys.clear();
    _clusterBitmaps.clear();
    _pendingClusterBitmapCounts.clear();
  }

  @override
  void didUpdateWidget(covariant EventPinsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextSelectedCenter = widget.selectedEventCenter;
    if (nextSelectedCenter != null &&
        !_samePoint(_lastAppliedCenter, nextSelectedCenter)) {
      _lastAppliedCenter = nextSelectedCenter;
      _lastReportedCameraCenter = nextSelectedCenter;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onCameraCenterChanged?.call(nextSelectedCenter);
        _moveCameraTo(nextSelectedCenter, animate: !_reduceMotion);
      });
    }
    if (!_sameEventMapCoordinates(
          [...oldWidget.items, ...oldWidget.externalItems],
          [...widget.items, ...widget.externalItems],
        ) ||
        oldWidget.userLocation != widget.userLocation ||
        oldWidget.distanceRingRadiusKm != widget.distanceRingRadiusKm ||
        oldWidget.distanceRingLabel != widget.distanceRingLabel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_fitOverview(animate: !_reduceMotion));
        unawaited(_updateDistanceRingLabelOffset());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final onEventSelected = widget.onEventSelected;
    final onExternalEventSelected = widget.onExternalEventSelected;
    final pinnedItems = _pinnedItems;

    if (!widget.enableNetworkTiles) {
      return EventPinsMapPlaceholder(
        items: pinnedItems,
        selectedEventId: widget.selectedEventId,
        userLocation: widget.userLocation,
        distanceRingRadiusKm: widget.distanceRingRadiusKm,
        distanceRingLabel: widget.distanceRingLabel,
        distanceRingSemanticHint: widget.distanceRingSemanticHint,
        onEventSelected: onEventSelected,
        onExternalEventSelected: onExternalEventSelected,
        onMapTapped: widget.onMapTapped,
        onDistanceRingTapped: widget.onDistanceRingTapped,
      );
    }

    final markerGroups = _eventMapMarkerGroups(pinnedItems, _cameraZoom);
    _ensureMapPinBitmaps(markerGroups);

    final ringLabel = widget.distanceRingLabel?.trim();
    return Stack(
      children: [
        Positioned.fill(
          child: CatchGoogleMap(
            initialCenter: widget.initialCenter,
            initialZoom: widget.initialZoom,
            markers: _markersFor(markerGroups).toSet(),
            circles: _mapCircles(context),
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            onTap: widget.onMapTapped == null
                ? null
                : (_) => widget.onMapTapped!(),
            onCameraMove: _handleCameraMove,
            onCameraIdle: _handleCameraIdle,
            onMapCreated: (controller) {
              _mapController = controller;
              final selectedCenter = widget.selectedEventCenter;
              if (selectedCenter != null) {
                _moveCameraTo(selectedCenter, animate: false);
              } else {
                unawaited(_fitOverview(animate: false));
              }
              unawaited(_updateDistanceRingLabelOffset());
            },
          ),
        ),
        if (_distanceRingLabelOffset case final offset?
            when ringLabel != null && ringLabel.isNotEmpty)
          AnimatedPositioned(
            duration: _mapOverlayMotionDuration(context),
            curve: CatchMotion.standardCurve,
            left: offset.dx,
            top: offset.dy,
            child: FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
              child: CatchDistanceRingLabel(
                label: ringLabel,
                semanticHint: widget.distanceRingSemanticHint,
                onTap: widget.onDistanceRingTapped,
              ),
            ),
          ),
        if (widget.showOverviewControl)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: CatchSpacing.s16,
                  right: CatchSpacing.s5,
                ),
                child: CatchIconButton(
                  variant: CatchIconButtonVariant.float,
                  tooltip: context
                      .l10n
                      .eventsEventPinsMapTooltipShowAllEventsAndDistance,
                  onTap: _restoreOverview,
                  child: Icon(CatchIcons.fitMap),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Iterable<CatchMapMarker> _markersFor(List<_MapMarkerGroup> groups) sync* {
    for (final group in groups) {
      final marker = _markerFor(group);
      if (marker != null) yield marker;
    }
  }

  List<EventMapPinItem> get _pinnedItems =>
      List.unmodifiable([...widget.items, ...widget.externalItems]);

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
          strokeColor: t.ink.withValues(alpha: CatchOpacity.distanceRing),
          fillColor: Colors.transparent,
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

  CatchMapMarker? _markerFor(_MapMarkerGroup group) {
    if (group.isCluster) {
      final bitmap = _clusterBitmaps[group.items.length];
      if (bitmap == null &&
          !_failedClusterBitmapCounts.contains(group.items.length)) {
        return null;
      }
      return CatchMapMarker(
        id: group.id,
        position: group.center,
        bitmap: bitmap,
        anchor: bitmap == null ? const Offset(0.5, 1) : const Offset(0.5, 0.5),
        zIndex: 3,
        infoTitle: context.l10n.eventsEventPinsMapSemanticsEventCluster(
          count: group.items.length,
        ),
        consumeTapEvents: true,
        onTap: () => _zoomToCluster(group),
      );
    }
    final item = group.items.single;
    final iconKey = _eventMapPinIconKey(item);
    final isSelected = item.mapId == widget.selectedEventId;
    final restingKey = _EventMapPinIconKey(
      activityKindName: item.activityKind.name,
      selected: false,
      label: null,
    );
    final bitmapState = eventMapPinBitmapState(
      selectedBitmap: _pinBitmaps[iconKey],
      restingBitmap: _pinBitmaps[restingKey],
      rasterFailed: _failedPinBitmapKeys.contains(iconKey),
    );
    if (!bitmapState.publish) return null;
    return CatchMapMarker(
      id: item.mapId,
      position: item.coordinate,
      bitmap: bitmapState.bitmap,
      zIndex: isSelected ? 2 : 1,
      infoTitle: eventMapMarkerSemanticLabel(item),
      consumeTapEvents: true,
      onTap: _canSelect(item) ? () => _select(item) : null,
    );
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

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations == true;

  void _restoreOverview() {
    catchTransitionHaptic();
    unawaited(_fitOverview(animate: !_reduceMotion));
  }

  Future<void> _fitOverview({required bool animate}) async {
    final controller = _mapController;
    if (controller == null) return;
    final coordinates = <LocationCoordinate>[
      for (final item in _pinnedItems) item.coordinate,
    ];
    final userLocation = widget.userLocation;
    final radiusKm = widget.distanceRingRadiusKm;
    if (userLocation != null && radiusKm != null && radiusKm > 0) {
      coordinates.addAll(
        eventMapRingBoundsCoordinates(
          userLocation,
          distanceMeters: radiusKm * 1000,
        ),
      );
    }
    if (coordinates.isEmpty) coordinates.add(widget.initialCenter);
    try {
      await controller.fitCoordinates(
        coordinates,
        padding: CatchSpacing.s16,
        animate: animate,
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Catch event map',
          context: ErrorDescription('fitting the event map overview'),
        ),
      );
      _moveCameraTo(widget.initialCenter, animate: animate);
    }
  }

  void _handleCameraMove(CatchMapCameraPosition position) {
    _pendingCameraCenter = position.center;
    _pendingCameraZoom = position.zoom;
    if (_distanceRingLabelOffset != null) {
      setState(() => _distanceRingLabelOffset = null);
    }
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
    unawaited(_updateDistanceRingLabelOffset());
  }

  Future<void> _updateDistanceRingLabelOffset() async {
    final generation = ++_distanceRingProjectionGeneration;
    final controller = _mapController;
    final center = widget.userLocation;
    final radiusKm = widget.distanceRingRadiusKm;
    final label = widget.distanceRingLabel?.trim();
    if (controller == null ||
        center == null ||
        radiusKm == null ||
        radiusKm <= 0 ||
        label == null ||
        label.isEmpty) {
      if (mounted && _distanceRingLabelOffset != null) {
        setState(() => _distanceRingLabelOffset = null);
      }
      return;
    }

    try {
      final edge = eventMapCoordinateNorthOf(
        center,
        distanceMeters: radiusKm * 1000,
      );
      final pixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
      final offset = await controller.screenOffsetFor(
        edge,
        devicePixelRatio: pixelRatio,
      );
      if (!mounted || generation != _distanceRingProjectionGeneration) return;
      setState(() => _distanceRingLabelOffset = offset);
    } catch (error, stackTrace) {
      if (!mounted || generation != _distanceRingProjectionGeneration) return;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Catch event map',
          context: ErrorDescription('projecting the distance-ring label'),
        ),
      );
      setState(() => _distanceRingLabelOffset = null);
    }
  }

  LocationCoordinate get _effectiveCameraCenter =>
      widget.selectedEventCenter ?? widget.initialCenter;

  void _ensureMapPinBitmaps(List<_MapMarkerGroup> markerGroups) {
    final pixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    final t = CatchTokens.of(context);
    final textStyle = CatchTextStyles.badge(context, color: t.primaryInk);
    final clusterTextStyle = CatchTextStyles.badge(context, color: t.bg);
    final mapLibraryLabel =
        context.l10n.eventsEventPinsMapVisiblecopyCatchEventMap;
    final buildingPinLabel =
        context.l10n.eventsEventPinsMapVisiblecopyBuildingEventMapPin;

    for (final group in markerGroups) {
      if (group.isCluster) {
        final count = group.items.length;
        if (_clusterBitmaps.containsKey(count) ||
            _pendingClusterBitmapCounts.contains(count) ||
            _failedClusterBitmapCounts.contains(count)) {
          continue;
        }
        _pendingClusterBitmapCounts.add(count);
        unawaited(
          buildEventMapClusterPinBitmap(
                count: count,
                fillColor: t.ink,
                borderColor: t.surface,
                pixelRatio: pixelRatio,
                textStyle: clusterTextStyle,
              )
              .then((bitmap) {
                if (!mounted) return;
                setState(() {
                  _pendingClusterBitmapCounts.remove(count);
                  _clusterBitmaps[count] = bitmap;
                });
              })
              .catchError((Object error, StackTrace stackTrace) {
                FlutterError.reportError(
                  FlutterErrorDetails(
                    exception: error,
                    stack: stackTrace,
                    library: 'Catch event map',
                    context: ErrorDescription('building event cluster marker'),
                  ),
                );
                if (!mounted) return;
                setState(() {
                  _pendingClusterBitmapCounts.remove(count);
                  _failedClusterBitmapCounts.add(count);
                });
              }),
        );
        continue;
      }
      final item = group.items.single;
      final key = _eventMapPinIconKey(item);
      if (_pinBitmaps.containsKey(key) ||
          _pendingPinBitmapKeys.contains(key) ||
          _failedPinBitmapKeys.contains(key)) {
        continue;
      }
      final activity = ActivityPalette.resolve(context, item.activityKind);
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
                  library: mapLibraryLabel,
                  context: ErrorDescription(buildingPinLabel),
                ),
              );
              if (!mounted) return;
              setState(() {
                _pendingPinBitmapKeys.remove(key);
                _failedPinBitmapKeys.add(key);
              });
            }),
      );
    }
  }

  _EventMapPinIconKey _eventMapPinIconKey(EventMapPinItem item) {
    final selected = item.mapId == widget.selectedEventId;
    return _EventMapPinIconKey(
      activityKindName: item.activityKind.name,
      selected: selected,
      label: selected ? eventMapPinFlagLabel(item) : null,
    );
  }

  bool _canSelect(EventMapPinItem item) => switch (item) {
    EventMapItem() => widget.onEventSelected != null,
    ExternalEventMapItem() => widget.onExternalEventSelected != null,
  };

  void _select(EventMapPinItem item) {
    switch (item) {
      case EventMapItem(:final event):
        widget.onEventSelected?.call(event);
      case ExternalEventMapItem(:final event):
        widget.onExternalEventSelected?.call(event);
    }
  }
}

@visibleForTesting
LocationCoordinate eventMapCoordinateNorthOf(
  LocationCoordinate center, {
  required double distanceMeters,
}) {
  const earthRadiusMeters = 6371008.8;
  final latitudeDeltaDegrees =
      (distanceMeters / earthRadiusMeters) * (180 / math.pi);
  return LocationCoordinate(
    (center.latitude + latitudeDeltaDegrees).clamp(-90.0, 90.0),
    center.longitude,
  );
}

@visibleForTesting
List<LocationCoordinate> eventMapRingBoundsCoordinates(
  LocationCoordinate center, {
  required double distanceMeters,
}) {
  const earthRadiusMeters = 6371008.8;
  final latitudeRadians = center.latitude * math.pi / 180;
  final latitudeDelta = (distanceMeters / earthRadiusMeters) * (180 / math.pi);
  final longitudeScale = math.max(math.cos(latitudeRadians).abs(), 0.01);
  final longitudeDelta =
      (distanceMeters / (earthRadiusMeters * longitudeScale)) * (180 / math.pi);
  return <LocationCoordinate>[
    LocationCoordinate(
      (center.latitude + latitudeDelta).clamp(-90.0, 90.0),
      center.longitude,
    ),
    LocationCoordinate(
      center.latitude,
      (center.longitude + longitudeDelta).clamp(-180.0, 180.0),
    ),
    LocationCoordinate(
      (center.latitude - latitudeDelta).clamp(-90.0, 90.0),
      center.longitude,
    ),
    LocationCoordinate(
      center.latitude,
      (center.longitude - longitudeDelta).clamp(-180.0, 180.0),
    ),
  ];
}

Duration _mapOverlayMotionDuration(BuildContext context) {
  return MediaQuery.maybeOf(context)?.disableAnimations == true
      ? Duration.zero
      : CatchMotion.calendarScroll;
}

@visibleForTesting
String eventMapPinFlagLabel(EventMapPinItem item) => item.pinFlagLabel;

@visibleForTesting
String eventMapMarkerSemanticLabel(EventMapPinItem item) =>
    item.markerSemanticLabel;

@visibleForTesting
({CatchMapMarkerBitmap? bitmap, bool publish}) eventMapPinBitmapState({
  required CatchMapMarkerBitmap? selectedBitmap,
  required CatchMapMarkerBitmap? restingBitmap,
  required bool rasterFailed,
}) {
  final bitmap = selectedBitmap ?? restingBitmap;
  return (bitmap: bitmap, publish: bitmap != null || rasterFailed);
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
      // typography:allow: theme-independent art serializes an icon font only.
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

@visibleForTesting
Future<CatchMapMarkerBitmap> buildEventMapClusterPinBitmap({
  required int count,
  required Color fillColor,
  required Color borderColor,
  required double pixelRatio,
  required TextStyle textStyle,
}) async {
  const logicalSize = CatchSpacing.s10;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixelRatio);
  const center = Offset(logicalSize / 2, logicalSize / 2);
  canvas.drawCircle(center, logicalSize / 2, Paint()..color = borderColor);
  canvas.drawCircle(
    center,
    logicalSize / 2 - CatchStroke.selection,
    Paint()..color = fillColor,
  );
  final painter = TextPainter(
    text: TextSpan(text: '$count', style: textStyle),
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout(maxWidth: logicalSize);
  painter.paint(
    canvas,
    Offset(
      (logicalSize - painter.width) / 2,
      (logicalSize - painter.height) / 2,
    ),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(
    (logicalSize * pixelRatio).ceil(),
    (logicalSize * pixelRatio).ceil(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  final bytes = byteData?.buffer.asUint8List();
  if (bytes == null || bytes.isEmpty) {
    throw StateError('Unable to render event cluster marker bitmap');
  }
  return CatchMapMarkerBitmap(
    bytes: bytes,
    logicalSize: const Size.square(logicalSize),
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

  factory _MapMarkerGroup.single(EventMapPinItem item) {
    return _MapMarkerGroup._(
      id: item.mapId,
      items: [item],
      center: item.coordinate,
      isCluster: false,
    );
  }

  factory _MapMarkerGroup.cluster({
    required String id,
    required List<EventMapPinItem> items,
  }) {
    final lat =
        items
            .map((item) => item.coordinate.latitude)
            .reduce((left, right) => left + right) /
        items.length;
    final lng =
        items
            .map((item) => item.coordinate.longitude)
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
  final List<EventMapPinItem> items;
  final LocationCoordinate center;
  final bool isCluster;
}

List<_MapMarkerGroup> _eventMapMarkerGroups(
  List<EventMapPinItem> pinnedItems,
  double cameraZoom,
) {
  if (pinnedItems.length < 6 || cameraZoom >= 14) {
    return [for (final item in pinnedItems) _MapMarkerGroup.single(item)];
  }
  final cellDegrees = _clusterCellDegrees(cameraZoom);
  final buckets = <String, List<EventMapPinItem>>{};
  for (final item in pinnedItems) {
    final lat = item.coordinate.latitude;
    final lng = item.coordinate.longitude;
    final key = '${(lat / cellDegrees).floor()}:${(lng / cellDegrees).floor()}';
    buckets.putIfAbsent(key, () => <EventMapPinItem>[]).add(item);
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

@visibleForTesting
List<int> eventMapMarkerGroupSizes(
  List<EventMapPinItem> pinnedItems, {
  required double cameraZoom,
}) => _eventMapMarkerGroups(
  pinnedItems,
  cameraZoom,
).map((group) => group.items.length).toList(growable: false);

class EventPinsMapPlaceholder extends StatelessWidget {
  const EventPinsMapPlaceholder({
    super.key,
    required this.items,
    required this.selectedEventId,
    required this.userLocation,
    required this.distanceRingRadiusKm,
    this.distanceRingLabel,
    this.distanceRingSemanticHint,
    required this.onEventSelected,
    this.onExternalEventSelected,
    this.onMapTapped,
    this.onDistanceRingTapped,
  });

  final List<EventMapPinItem> items;
  final String? selectedEventId;
  final LocationCoordinate? userLocation;
  final double? distanceRingRadiusKm;
  final String? distanceRingLabel;
  final String? distanceRingSemanticHint;
  final ValueChanged<Event>? onEventSelected;
  final ValueChanged<ExternalEvent>? onExternalEventSelected;
  final VoidCallback? onMapTapped;
  final VoidCallback? onDistanceRingTapped;

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

          final fallbackRingSize = eventMapFixtureRingSize(
            radiusKm: ringRadiusKm,
            viewport: constraints.biggest,
          );
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
                    child: const SizedBox.expand(),
                  ),
                ),
                if (showDistanceRing)
                  Center(
                    child: CatchDistanceRing(
                      size: fallbackRingSize,
                      label: distanceRingLabel,
                      semanticHint: distanceRingSemanticHint,
                      onTap: onDistanceRingTapped,
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
                          selectedEventId == indexed.$2.mapId,
                        ),
                    width: _placeholderPinSlotWidth,
                    child: Semantics(
                      button: _canSelectMapItem(
                        indexed.$2,
                        onEventSelected: onEventSelected,
                        onExternalEventSelected: onExternalEventSelected,
                      ),
                      selected: selectedEventId == indexed.$2.mapId,
                      label:
                          !_canSelectMapItem(
                            indexed.$2,
                            onEventSelected: onEventSelected,
                            onExternalEventSelected: onExternalEventSelected,
                          )
                          ? context.l10n
                                .eventsEventPinsMapLabelLocationnameLocation(
                                  locationName: indexed.$2.locationName,
                                )
                          : context.l10n
                                .eventsEventPinsMapLabelSelectLocationname(
                                  locationName: indexed.$2.locationName,
                                ),
                      child: GestureDetector(
                        onTap:
                            !_canSelectMapItem(
                              indexed.$2,
                              onEventSelected: onEventSelected,
                              onExternalEventSelected: onExternalEventSelected,
                            )
                            ? null
                            : () => _selectMapItem(
                                indexed.$2,
                                onEventSelected: onEventSelected,
                                onExternalEventSelected:
                                    onExternalEventSelected,
                              ),
                        child: Center(
                          child: CatchActivityMapPin(
                            activityKind: indexed.$2.activityKind,
                            selected: selectedEventId == indexed.$2.mapId,
                            label: selectedEventId == indexed.$2.mapId
                                ? eventMapPinFlagLabel(indexed.$2)
                                : null,
                            size: selectedEventId == indexed.$2.mapId
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

@visibleForTesting
double eventMapFixtureRingSize({
  required double? radiusKm,
  required Size viewport,
}) {
  final requested = switch (radiusKm) {
    null => CatchLayout.distanceRingDefaultSize,
    <= 1 => 150.0,
    <= 3 => 290.0,
    <= 5 => 460.0,
    _ => 640.0,
  };
  final available = CatchLayout.distanceRingAvailableDiameterFor(viewport);
  return math.min(requested, available);
}

double _placeholderPinAnchorOffset(bool selected) =>
    CatchLayout.activityMapPinAnchorOffset(selected);

bool _canSelectMapItem(
  EventMapPinItem item, {
  required ValueChanged<Event>? onEventSelected,
  required ValueChanged<ExternalEvent>? onExternalEventSelected,
}) => switch (item) {
  EventMapItem() => onEventSelected != null,
  ExternalEventMapItem() => onExternalEventSelected != null,
};

void _selectMapItem(
  EventMapPinItem item, {
  required ValueChanged<Event>? onEventSelected,
  required ValueChanged<ExternalEvent>? onExternalEventSelected,
}) {
  switch (item) {
    case EventMapItem(:final event):
      onEventSelected?.call(event);
    case ExternalEventMapItem(:final event):
      onExternalEventSelected?.call(event);
  }
}

bool _samePoint(LocationCoordinate a, LocationCoordinate b) =>
    a.latitude == b.latitude && a.longitude == b.longitude;

bool _sameEventMapCoordinates(
  List<EventMapPinItem> previous,
  List<EventMapPinItem> next,
) {
  if (identical(previous, next)) return true;
  if (previous.length != next.length) return false;
  final previousCoordinates = {
    for (final item in previous)
      '${item.mapId}:${item.coordinate.latitude}:${item.coordinate.longitude}',
  };
  final nextCoordinates = {
    for (final item in next)
      '${item.mapId}:${item.coordinate.latitude}:${item.coordinate.longitude}',
  };
  return previousCoordinates.length == nextCoordinates.length &&
      previousCoordinates.containsAll(nextCoordinates);
}

double _clusterCellDegrees(double zoom) {
  final clampedZoom = zoom.clamp(10.0, 14.0);
  final t = (clampedZoom - 10.0) / 4.0;
  return 0.045 - (0.033 * t);
}
