import 'dart:typed_data';

import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/shared/google_maps_coordinate_adapter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

enum CatchMapType { normal, none }

enum CatchMapMarkerHue { azure, green, orange, red, rose, yellow }

class CatchMapCameraPosition {
  const CatchMapCameraPosition({required this.center, required this.zoom});

  final LocationCoordinate center;
  final double zoom;
}

class CatchMapMarker {
  const CatchMapMarker({
    required this.id,
    required this.position,
    this.hue = CatchMapMarkerHue.red,
    this.bitmap,
    this.anchor = const Offset(0.5, 1),
    this.zIndex = 0,
    this.infoTitle,
    this.infoSnippet,
    this.onTap,
  });

  final String id;
  final LocationCoordinate position;
  final CatchMapMarkerHue hue;
  final CatchMapMarkerBitmap? bitmap;
  final Offset anchor;
  final int zIndex;
  final String? infoTitle;
  final String? infoSnippet;
  final VoidCallback? onTap;
}

class CatchMapMarkerBitmap {
  const CatchMapMarkerBitmap({
    required this.bytes,
    required this.logicalSize,
    required this.imagePixelRatio,
  });

  final Uint8List bytes;
  final Size logicalSize;
  final double imagePixelRatio;
}

class CatchMapCircle {
  const CatchMapCircle({
    required this.id,
    required this.center,
    required this.radiusMeters,
    required this.strokeWidth,
    required this.strokeColor,
    required this.fillColor,
    this.consumeTapEvents = false,
    this.onTap,
  });

  final String id;
  final LocationCoordinate center;
  final double radiusMeters;
  final int strokeWidth;
  final Color strokeColor;
  final Color fillColor;
  final bool consumeTapEvents;
  final VoidCallback? onTap;
}

class CatchGoogleMapController {
  const CatchGoogleMapController._(this._controller);

  final gmaps.GoogleMapController _controller;

  Future<void> moveTo(LocationCoordinate center) {
    return _controller.moveCamera(
      gmaps.CameraUpdate.newLatLng(center.toGoogleMapsLatLng()),
    );
  }

  Future<void> animateTo(LocationCoordinate center, {double? zoom}) {
    final update = zoom == null
        ? gmaps.CameraUpdate.newLatLng(center.toGoogleMapsLatLng())
        : gmaps.CameraUpdate.newLatLngZoom(center.toGoogleMapsLatLng(), zoom);
    return _controller.animateCamera(update);
  }
}

class CatchGoogleMap extends StatelessWidget {
  const CatchGoogleMap({
    super.key,
    required this.initialCenter,
    required this.initialZoom,
    this.markers = const <CatchMapMarker>{},
    this.circles = const <CatchMapCircle>{},
    this.mapType = CatchMapType.normal,
    this.myLocationButtonEnabled = false,
    this.mapToolbarEnabled = false,
    this.zoomControlsEnabled = false,
    this.compassEnabled = false,
    this.onMapCreated,
    this.onTap,
    this.onCameraMove,
    this.onCameraIdle,
  });

  final LocationCoordinate initialCenter;
  final double initialZoom;
  final Set<CatchMapMarker> markers;
  final Set<CatchMapCircle> circles;
  final CatchMapType mapType;
  final bool myLocationButtonEnabled;
  final bool mapToolbarEnabled;
  final bool zoomControlsEnabled;
  final bool compassEnabled;
  final ValueChanged<CatchGoogleMapController>? onMapCreated;
  final ValueChanged<LocationCoordinate>? onTap;
  final ValueChanged<CatchMapCameraPosition>? onCameraMove;
  final VoidCallback? onCameraIdle;

  @override
  Widget build(BuildContext context) {
    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: initialCenter.toGoogleMapsLatLng(),
        zoom: initialZoom,
      ),
      markers: {for (final marker in markers) _googleMarker(marker)},
      circles: {for (final circle in circles) _googleCircle(circle)},
      myLocationButtonEnabled: myLocationButtonEnabled,
      mapToolbarEnabled: mapToolbarEnabled,
      zoomControlsEnabled: zoomControlsEnabled,
      compassEnabled: compassEnabled,
      mapType: _googleMapType(mapType),
      onMapCreated: onMapCreated == null
          ? null
          : (controller) =>
                onMapCreated!(CatchGoogleMapController._(controller)),
      onTap: onTap == null
          ? null
          : (point) => onTap!(point.toLocationCoordinate()),
      onCameraMove: onCameraMove == null
          ? null
          : (position) => onCameraMove!(
              CatchMapCameraPosition(
                center: position.target.toLocationCoordinate(),
                zoom: position.zoom,
              ),
            ),
      onCameraIdle: onCameraIdle,
    );
  }
}

gmaps.Marker _googleMarker(CatchMapMarker marker) {
  final bitmap = marker.bitmap;
  return gmaps.Marker(
    markerId: gmaps.MarkerId(marker.id),
    position: marker.position.toGoogleMapsLatLng(),
    icon: bitmap == null
        ? gmaps.BitmapDescriptor.defaultMarkerWithHue(
            _googleMarkerHue(marker.hue),
          )
        : gmaps.BitmapDescriptor.bytes(
            bitmap.bytes,
            imagePixelRatio: bitmap.imagePixelRatio,
            width: bitmap.logicalSize.width,
            height: bitmap.logicalSize.height,
          ),
    anchor: marker.anchor,
    infoWindow: gmaps.InfoWindow(
      title: marker.infoTitle,
      snippet: marker.infoSnippet,
    ),
    zIndexInt: marker.zIndex,
    onTap: marker.onTap,
  );
}

gmaps.Circle _googleCircle(CatchMapCircle circle) {
  return gmaps.Circle(
    circleId: gmaps.CircleId(circle.id),
    center: circle.center.toGoogleMapsLatLng(),
    radius: circle.radiusMeters,
    strokeWidth: circle.strokeWidth,
    strokeColor: circle.strokeColor,
    fillColor: circle.fillColor,
    consumeTapEvents: circle.consumeTapEvents,
    onTap: circle.onTap,
  );
}

gmaps.MapType _googleMapType(CatchMapType type) {
  return switch (type) {
    CatchMapType.normal => gmaps.MapType.normal,
    CatchMapType.none => gmaps.MapType.none,
  };
}

double _googleMarkerHue(CatchMapMarkerHue hue) {
  return switch (hue) {
    CatchMapMarkerHue.azure => gmaps.BitmapDescriptor.hueAzure,
    CatchMapMarkerHue.green => gmaps.BitmapDescriptor.hueGreen,
    CatchMapMarkerHue.orange => gmaps.BitmapDescriptor.hueOrange,
    CatchMapMarkerHue.red => gmaps.BitmapDescriptor.hueRed,
    CatchMapMarkerHue.rose => gmaps.BitmapDescriptor.hueRose,
    CatchMapMarkerHue.yellow => gmaps.BitmapDescriptor.hueYellow,
  };
}
