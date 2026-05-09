import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/presentation/google_maps_coordinate_adapter.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class RunPinsMap extends StatefulWidget {
  const RunPinsMap({
    super.key,
    required this.runs,
    required this.initialCenter,
    this.initialZoom = 12.5,
    this.selectedRunId,
    this.enableNetworkTiles = true,
    this.markerIcon = Icons.directions_run_rounded,
    this.onRunSelected,
  });

  final List<Run> runs;
  final LocationCoordinate initialCenter;
  final double initialZoom;
  final String? selectedRunId;
  final bool enableNetworkTiles;
  final IconData markerIcon;
  final ValueChanged<Run>? onRunSelected;

  @override
  State<RunPinsMap> createState() => _RunPinsMapState();
}

class _RunPinsMapState extends State<RunPinsMap> {
  gmaps.GoogleMapController? _mapController;
  late LocationCoordinate _lastAppliedCenter;

  @override
  void initState() {
    super.initState();
    _lastAppliedCenter = widget.initialCenter;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RunPinsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_samePoint(_lastAppliedCenter, widget.initialCenter)) return;
    _lastAppliedCenter = widget.initialCenter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController?.animateCamera(
        gmaps.CameraUpdate.newLatLng(widget.initialCenter.toGoogleMapsLatLng()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final onRunSelected = widget.onRunSelected;

    final pinnedRuns = widget.runs
        .where((run) => run.hasExactStartingPoint)
        .toList(growable: false);

    if (!widget.enableNetworkTiles) {
      return _RunPinsMapPlaceholder(
        runs: pinnedRuns,
        selectedRunId: widget.selectedRunId,
        markerIcon: widget.markerIcon,
        onRunSelected: onRunSelected,
      );
    }

    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: widget.initialCenter.toGoogleMapsLatLng(),
        zoom: widget.initialZoom,
      ),
      markers: {
        for (final run in pinnedRuns)
          gmaps.Marker(
            markerId: gmaps.MarkerId(run.id),
            position: gmaps.LatLng(
              run.startingPointLat!,
              run.startingPointLng!,
            ),
            infoWindow: gmaps.InfoWindow(title: run.title),
            icon: widget.selectedRunId == run.id
                ? gmaps.BitmapDescriptor.defaultMarkerWithHue(
                    gmaps.BitmapDescriptor.hueOrange,
                  )
                : gmaps.BitmapDescriptor.defaultMarker,
            onTap: onRunSelected == null ? null : () => onRunSelected(run),
          ),
      },
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      onMapCreated: (controller) => _mapController = controller,
    );
  }
}

class _RunPinsMapPlaceholder extends StatelessWidget {
  const _RunPinsMapPlaceholder({
    required this.runs,
    required this.selectedRunId,
    required this.markerIcon,
    required this.onRunSelected,
  });

  final List<Run> runs;
  final String? selectedRunId;
  final IconData markerIcon;
  final ValueChanged<Run>? onRunSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ColoredBox(
      color: t.primarySoft,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final run in runs)
            Semantics(
              button: onRunSelected != null,
              selected: selectedRunId == run.id,
              label: onRunSelected == null
                  ? '${run.title} location'
                  : 'Select ${run.title}',
              child: GestureDetector(
                onTap: onRunSelected == null ? null : () => onRunSelected!(run),
                child: Icon(
                  markerIcon,
                  color: selectedRunId == run.id ? t.primary : t.ink,
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
