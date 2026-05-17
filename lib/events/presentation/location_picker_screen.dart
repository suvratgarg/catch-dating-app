import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/presentation/widgets/map_overlay_controls.dart';
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
          MapOverlayControls(
            trailing: CatchSurface(
              tone: CatchSurfaceTone.raised,
              elevation: CatchSurfaceElevation.overlay,
              borderColor: t.line,
              radius: CatchRadius.pill,
              child: CatchTopBarTextAction(
                label: 'Confirm',
                onPressed: _selected == null
                    ? null
                    : () => Navigator.of(context).pop(_selected),
              ),
            ),
            below: _PlaceSearchPanel(
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
            child: _SelectedPointStatusCard(hasSelection: _selected != null),
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CatchTextField(
          label: 'Search for a meeting point',
          showLabel: false,
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          textCapitalization: TextCapitalization.words,
          hintText: 'Search for a meeting point',
          size: CatchTextFieldSize.compact,
          shape: CatchTextFieldShape.pill,
          tone: CatchTextFieldTone.raised,
          prefixIcon: const Icon(Icons.search_rounded, size: 18),
          suffixIcon: searching
              ? const Padding(
                  padding: EdgeInsets.all(CatchSpacing.s3),
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
          showClearButton: !searching,
        ),
        if (errorText != null || suggestions.isNotEmpty) ...[
          gapH8,
          CatchSurface(
            padding: EdgeInsets.zero,
            elevation: CatchSurfaceElevation.overlay,
            borderColor: t.line,
            child: errorText != null
                ? _SearchStatusRow(
                    icon: Icons.error_outline_rounded,
                    text: errorText!,
                    color: t.danger,
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: suggestions.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: t.line),
                      itemBuilder: (context, index) {
                        final suggestion = suggestions[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.place_outlined),
                          title: Text(
                            suggestion.mainText.isNotEmpty
                                ? suggestion.mainText
                                : suggestion.description,
                            style: CatchTextStyles.labelM(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: suggestion.secondaryText.isEmpty
                              ? null
                              : Text(
                                  suggestion.secondaryText,
                                  style: CatchTextStyles.bodyS(
                                    context,
                                    color: t.ink2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          onTap: () => onSuggestionSelected(suggestion),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ],
    );
  }
}

class _SelectedPointStatusCard extends StatelessWidget {
  const _SelectedPointStatusCard({required this.hasSelection});

  final bool hasSelection;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      elevation: CatchSurfaceElevation.overlay,
      borderColor: t.line,
      radius: CatchRadius.pill,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSelection
                ? Icons.check_circle_outline_rounded
                : Icons.touch_app_rounded,
            size: 18,
            color: hasSelection ? t.success : t.ink2,
          ),
          gapW8,
          Flexible(
            child: Text(
              hasSelection
                  ? 'Starting point selected. Tap elsewhere to adjust.'
                  : 'Tap on the map to set the starting point.',
              style: CatchTextStyles.bodyS(
                context,
                color: hasSelection ? t.ink : t.ink2,
              ),
              textAlign: TextAlign.center,
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
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          gapW8,
          Expanded(
            child: Text(
              text,
              style: CatchTextStyles.bodyS(context, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
