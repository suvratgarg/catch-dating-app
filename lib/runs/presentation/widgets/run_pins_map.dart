import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  final LatLng initialCenter;
  final double initialZoom;
  final String? selectedRunId;
  final bool enableNetworkTiles;
  final IconData markerIcon;
  final ValueChanged<Run>? onRunSelected;

  @override
  State<RunPinsMap> createState() => _RunPinsMapState();
}

class _RunPinsMapState extends State<RunPinsMap> {
  late final MapController _mapController;
  late LatLng _lastAppliedCenter;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _lastAppliedCenter = widget.initialCenter;
  }

  @override
  void didUpdateWidget(covariant RunPinsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_samePoint(_lastAppliedCenter, widget.initialCenter)) return;
    _lastAppliedCenter = widget.initialCenter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(widget.initialCenter, _mapController.camera.zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final onRunSelected = widget.onRunSelected;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.initialCenter,
        initialZoom: widget.initialZoom,
      ),
      children: [
        if (widget.enableNetworkTiles)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.catchdating.app',
          )
        else
          ColoredBox(color: t.primarySoft),
        MarkerLayer(
          markers: [
            for (final run in widget.runs.where(
              (run) => run.hasExactStartingPoint,
            ))
              Marker(
                point: LatLng(run.startingPointLat!, run.startingPointLng!),
                width: 52,
                height: 52,
                child: Semantics(
                  button: onRunSelected != null,
                  selected: widget.selectedRunId == run.id,
                  label: onRunSelected == null
                      ? '${run.title} location'
                      : 'Select ${run.title}',
                  child: GestureDetector(
                    onTap: onRunSelected == null
                        ? null
                        : () => onRunSelected(run),
                    child: AnimatedScale(
                      scale: widget.selectedRunId == run.id ? 1.14 : 1,
                      duration: const Duration(milliseconds: 160),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.selectedRunId == run.id
                              ? t.primary
                              : t.ink,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.markerIcon,
                          color: widget.selectedRunId == run.id
                              ? t.primaryInk
                              : t.surface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

bool _samePoint(LatLng a, LatLng b) =>
    a.latitude == b.latitude && a.longitude == b.longitude;
