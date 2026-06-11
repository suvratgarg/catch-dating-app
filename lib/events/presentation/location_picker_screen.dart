import 'dart:async';

import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/list_tile_material.dart';
import 'package:catch_dating_app/locations/data/places_repository.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/presentation/google_maps_coordinate_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({
    super.key,
    this.countryIsoCode,
    this.initialLocation,
    this.initialCenter,
    this.initialLabel,
    this.loadMapTiles = true,
  });

  /// ISO country code used to scope meeting-point search suggestions.
  final String? countryIsoCode;

  /// If provided, the map opens centred on this pin.
  final LocationCoordinate? initialLocation;

  /// If provided without [initialLocation], the map opens centred here without
  /// treating it as an already selected meeting location.
  final LocationCoordinate? initialCenter;

  /// Existing attendee-facing name for [initialLocation], if known.
  final String? initialLabel;

  /// Retained as a test hook while the screen uses the Google Maps SDK.
  final bool loadMapTiles;

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

@immutable
class LocationPickerResult {
  const LocationPickerResult({
    required this.coordinate,
    this.name,
    this.address,
    this.placeId,
  });

  final LocationCoordinate coordinate;
  final String? name;
  final String? address;
  final String? placeId;

  String? get displayName => _trimToNull(name) ?? _trimToNull(address);
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final _searchController = TextEditingController();
  LocationCoordinate? _selected;
  String? _selectedLabel;
  String? _selectedAddress;
  String? _selectedPlaceId;
  gmaps.GoogleMapController? _mapController;
  Timer? _searchDebounce;
  String _sessionToken = _newSessionToken();
  var _suggestions = <PlaceAutocompleteSuggestion>[];
  var _searching = false;
  PlaceAutocompleteSuggestion? _pendingSuggestion;
  String? _searchError;

  LocationCoordinate get _defaultCenter {
    final city = defaultCityDataForMarket();
    return LocationCoordinate(city.latitude, city.longitude);
  }

  String get _countryIsoCode =>
      widget.countryIsoCode ?? defaultCityDataForMarket().countryIsoCode;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
    _selectedLabel = _trimToNull(widget.initialLabel);
    _searchController.text = _selectedLabel ?? '';
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    // GoogleMap owns disposal of its controller; clear only our reference.
    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialCameraTarget =
        widget.initialLocation ?? widget.initialCenter ?? _defaultCenter;
    final hasInitialCameraHint =
        widget.initialLocation != null || widget.initialCenter != null;

    return Scaffold(
      body: Stack(
        children: [
          gmaps.GoogleMap(
            initialCameraPosition: gmaps.CameraPosition(
              target: initialCameraTarget.toGoogleMapsLatLng(),
              zoom: hasInitialCameraHint ? 15 : 12,
            ),
            markers: {
              if (_selected != null)
                gmaps.Marker(
                  markerId: const gmaps.MarkerId('selected-starting-point'),
                  position: _selected!.toGoogleMapsLatLng(),
                  icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
                    gmaps.BitmapDescriptor.hueOrange,
                  ),
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
            top: CatchSpacing.s4,
            left: CatchSpacing.s4,
            right: CatchSpacing.s4,
            child: SafeArea(
              bottom: false,
              child: _MapPickerSearchRow(
                onBack: () => Navigator.of(context).maybePop(),
                searchPanel: _PlaceSearchPanel(
                  controller: _searchController,
                  suggestions: _suggestions,
                  stateText: _searchStateText,
                  errorText: _searchError,
                  onChanged: _onSearchChanged,
                  onSuggestionSelected: _selectSuggestion,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              top: false,
              child: _SelectedPointPanel(
                selectedLabel: _selectedLabel,
                hasSelection: _selected != null,
                onConfirm: _selected == null || _pendingSuggestion != null
                    ? null
                    : () => Navigator.of(context).pop(
                        LocationPickerResult(
                          coordinate: _selected!,
                          name: _selectedLabel,
                          address: _selectedAddress,
                          placeId: _selectedPlaceId,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? get _searchStateText {
    if (_pendingSuggestion != null) return 'Selecting...';
    if (_searching && _suggestions.isEmpty) return 'Searching...';
    return null;
  }

  void _setSelectedPoint(
    LocationCoordinate point, {
    String? label,
    String? address,
    String? placeId,
  }) {
    setState(() {
      _selected = point;
      _selectedLabel = _trimToNull(label);
      _selectedAddress = _trimToNull(address);
      _selectedPlaceId = _trimToNull(placeId);
      _suggestions = const [];
      _pendingSuggestion = null;
      _searchError = null;
    });
    if (_selectedLabel == null) {
      _searchController.clear();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _suggestions = const [];
        _searchError = null;
        _searching = false;
        _pendingSuggestion = null;
      });
      return;
    }
    setState(() {
      _suggestions = const [];
      _searchError = null;
      _searching = true;
    });
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
            bias:
                _selected ??
                widget.initialLocation ??
                widget.initialCenter ??
                _defaultCenter,
            countryIsoCode: _countryIsoCode,
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
    final label = _suggestionLabel(suggestion);
    setState(() {
      _pendingSuggestion = suggestion;
      _suggestions = const [];
      _searching = false;
      _searchError = null;
    });
    FocusScope.of(context).unfocus();

    try {
      final place = await ref
          .read(placesRepositoryProvider)
          .details(placeId: suggestion.placeId, sessionToken: _sessionToken);
      if (!mounted) return;
      _sessionToken = _newSessionToken();
      final displayName = place.displayName.isNotEmpty
          ? place.displayName
          : label;
      _searchController.text = displayName;
      _setSelectedPoint(
        place.location,
        label: displayName,
        address: place.formattedAddress,
        placeId: place.placeId,
      );
      await _mapController?.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(
          place.location.toGoogleMapsLatLng(),
          16,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pendingSuggestion = null;
        _suggestions = [suggestion];
        _searching = false;
        _searchError = 'Could not load that place. Try another result.';
      });
    }
  }
}

String _newSessionToken() => 'places-${DateTime.now().microsecondsSinceEpoch}';

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

String _suggestionLabel(PlaceAutocompleteSuggestion suggestion) {
  if (suggestion.mainText.isNotEmpty) return suggestion.mainText;
  if (suggestion.description.isNotEmpty) return suggestion.description;
  return 'selected place';
}

class _MapPickerSearchRow extends StatelessWidget {
  const _MapPickerSearchRow({required this.searchPanel, required this.onBack});

  final Widget searchPanel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchTopBarIconAction(
          icon: CatchIcons.arrowBackIosNewRounded,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          backgroundColor: t.surface.withValues(
            alpha: CatchOpacity.locationPickerTopChromeFill,
          ),
          size: CatchControlMetrics.floatingMinHeight,
          onPressed: onBack,
        ),
        gapW12,
        Expanded(child: searchPanel),
      ],
    );
  }
}

class _PlaceSearchPanel extends StatelessWidget {
  const _PlaceSearchPanel({
    required this.controller,
    required this.suggestions,
    required this.stateText,
    required this.errorText,
    required this.onChanged,
    required this.onSuggestionSelected,
  });

  final TextEditingController controller;
  final List<PlaceAutocompleteSuggestion> suggestions;
  final String? stateText;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final ValueChanged<PlaceAutocompleteSuggestion> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isPending = stateText != null;

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
          errorText: errorText,
          size: CatchTextFieldSize.floating,
          shape: CatchTextFieldShape.pill,
          tone: CatchTextFieldTone.raised,
          prefixIcon: Icon(CatchIcons.searchRounded, size: CatchIcon.md),
          suffixText: stateText,
          suffixIcon: isPending
              ? const Center(
                  child: SizedBox.square(
                    dimension: CatchIcon.md,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
          showClearButton: !isPending,
        ),
        if (suggestions.isNotEmpty) ...[
          gapH8,
          CatchSurface(
            padding: EdgeInsets.zero,
            elevation: CatchSurfaceElevation.overlay,
            borderColor: t.line,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: t.line),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ListTileMaterial(
                    child: ListTile(
                      dense: true,
                      leading: Icon(CatchIcons.placeOutlined),
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
                              style: CatchTextStyles.supporting(
                                context,
                                color: t.ink2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      onTap: () => onSuggestionSelected(suggestion),
                    ),
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

class _SelectedPointPanel extends StatelessWidget {
  const _SelectedPointPanel({
    required this.hasSelection,
    required this.selectedLabel,
    required this.onConfirm,
  });

  final bool hasSelection;
  final String? selectedLabel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final title = hasSelection
        ? selectedLabel ?? 'Pinned location'
        : 'No location selected';
    final subtitle = hasSelection
        ? selectedLabel == null
              ? 'Confirm this map pin or tap elsewhere to adjust.'
              : 'Confirm this place or tap elsewhere to adjust.'
        : 'Search for a place or tap the map to set the meeting point.';

    return CatchSurface(
      padding: CatchInsets.content,
      elevation: CatchSurfaceElevation.overlay,
      borderColor: t.line,
      radius: CatchRadius.md,
      backgroundColor: t.surface.withValues(
        alpha: CatchOpacity.locationPickerPanelFill,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                hasSelection
                    ? CatchIcons.checkCircleOutlineRounded
                    : CatchIcons.touchAppRounded,
                size: 20,
                color: hasSelection ? t.success : t.ink2,
              ),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.labelL(context, color: t.ink),
                    ),
                    gapH4,
                    Text(
                      subtitle,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          gapH12,
          CatchButton(
            label: 'Confirm location',
            onPressed: onConfirm,
            fullWidth: true,
            size: CatchButtonSize.lg,
          ),
        ],
      ),
    );
  }
}
