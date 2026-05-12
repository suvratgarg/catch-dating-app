import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/locations/data/places_repository.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/presentation/google_maps_coordinate_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({
    super.key,
    this.initialLocation,
    this.loadMapTiles = true,
  });

  /// If provided, the map opens centred on this pin.
  final LocationCoordinate? initialLocation;

  /// Retained as a test hook while the screen uses the Google Maps SDK.
  final bool loadMapTiles;

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  // Default centre: Mumbai, India
  static const _defaultCenter = LocationCoordinate(19.0760, 72.8777);

  final _searchController = TextEditingController();
  LocationCoordinate? _selected;
  gmaps.GoogleMapController? _mapController;
  Timer? _searchDebounce;
  String _sessionToken = _newSessionToken();
  var _suggestions = <PlaceAutocompleteSuggestion>[];
  var _searching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Scaffold(
      appBar: CatchTopBar(
        title: 'Pick starting point',
        actions: [
          CatchTopBarTextAction(
            label: 'Confirm',
            onPressed: _selected == null
                ? null
                : () => Navigator.of(context).pop(_selected),
          ),
        ],
      ),
      body: Stack(
        children: [
          gmaps.GoogleMap(
            initialCameraPosition: gmaps.CameraPosition(
              target: (widget.initialLocation ?? _defaultCenter)
                  .toGoogleMapsLatLng(),
              zoom: widget.initialLocation != null ? 15 : 12,
            ),
            markers: {
              if (_selected != null)
                gmaps.Marker(
                  markerId: const gmaps.MarkerId('selected-starting-point'),
                  position: _selected!.toGoogleMapsLatLng(),
                ),
            },
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapType: widget.loadMapTiles
                ? gmaps.MapType.normal
                : gmaps.MapType.none,
            onMapCreated: (controller) => _mapController = controller,
            onTap: (point) => _setSelectedPoint(point.toLocationCoordinate()),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _PlaceSearchPanel(
              controller: _searchController,
              suggestions: _suggestions,
              searching: _searching,
              errorText: _searchError,
              onChanged: _onSearchChanged,
              onSuggestionSelected: _selectSuggestion,
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: CatchSurface(
              padding: const EdgeInsets.all(12),
              elevation: CatchSurfaceElevation.overlay,
              borderColor: t.line,
              child: _selected == null
                  ? const Text(
                      'Tap on the map to set the starting point',
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      '${_selected!.latitude.toStringAsFixed(6)}, '
                      '${_selected!.longitude.toStringAsFixed(6)}',
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _setSelectedPoint(LocationCoordinate point) {
    setState(() {
      _selected = point;
      _suggestions = const [];
      _searchError = null;
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _suggestions = const [];
        _searchError = null;
        _searching = false;
      });
      return;
    }
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => _searchPlaces(query),
    );
  }

  Future<void> _searchPlaces(String query) async {
    setState(() {
      _searching = true;
      _searchError = null;
    });

    try {
      final results = await ref
          .read(placesRepositoryProvider)
          .autocomplete(
            input: query,
            sessionToken: _sessionToken,
            bias: _selected ?? widget.initialLocation ?? _defaultCenter,
          );
      if (!mounted || _searchController.text.trim() != query) return;
      setState(() {
        _suggestions = results;
        _searching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = const [];
        _searching = false;
        _searchError = 'Could not search places. Try again.';
      });
    }
  }

  Future<void> _selectSuggestion(PlaceAutocompleteSuggestion suggestion) async {
    setState(() {
      _searching = true;
      _searchError = null;
    });

    try {
      final place = await ref
          .read(placesRepositoryProvider)
          .details(placeId: suggestion.placeId, sessionToken: _sessionToken);
      if (!mounted) return;
      _sessionToken = _newSessionToken();
      _searchController.text = place.displayName.isNotEmpty
          ? place.displayName
          : suggestion.description;
      _setSelectedPoint(place.location);
      setState(() => _searching = false);
      FocusScope.of(context).unfocus();
      await _mapController?.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(
          place.location.toGoogleMapsLatLng(),
          16,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _searchError = 'Could not load that place. Try another result.';
      });
    }
  }
}

String _newSessionToken() => 'places-${DateTime.now().microsecondsSinceEpoch}';

class _PlaceSearchPanel extends StatelessWidget {
  const _PlaceSearchPanel({
    required this.controller,
    required this.suggestions,
    required this.searching,
    required this.errorText,
    required this.onChanged,
    required this.onSuggestionSelected,
  });

  final TextEditingController controller;
  final List<PlaceAutocompleteSuggestion> suggestions;
  final bool searching;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final ValueChanged<PlaceAutocompleteSuggestion> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: EdgeInsets.zero,
      elevation: CatchSurfaceElevation.overlay,
      borderColor: t.line,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 52,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search for a meeting point',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searching
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                      ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          if (errorText != null)
            _SearchStatusRow(
              icon: Icons.error_outline_rounded,
              text: errorText!,
              color: t.danger,
            )
          else if (suggestions.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: t.line),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined),
                    title: Text(
                      suggestion.mainText.isNotEmpty
                          ? suggestion.mainText
                          : suggestion.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: suggestion.secondaryText.isEmpty
                        ? null
                        : Text(
                            suggestion.secondaryText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    onTap: () => onSuggestionSelected(suggestion),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchStatusRow extends StatelessWidget {
  const _SearchStatusRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
